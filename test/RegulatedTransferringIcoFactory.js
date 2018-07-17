var RegulatorServiceImpl = artifacts.require('RegulatorServiceImpl.sol');
var AllowRegulationRule = artifacts.require('AllowRegulationRule.sol');
var FakeRegulatorService = artifacts.require('FakeRegulatorService.sol');
var IcoFactory = artifacts.require('RegulatedTransferringIcoFactory.sol');
var TransferringSale = artifacts.require('TransferringSale.sol');
var BasicToken = artifacts.require('BasicToken.sol');
var Secured = artifacts.require('Secured.sol');
var RegulatedTokenImpl = artifacts.require('RegulatedTokenImpl.sol');
var KycProviderImpl = artifacts.require('KycProviderImpl.sol');
var ZERO = "0x0000000000000000000000000000000000000000";

const tests = require("@daonomic/tests-common");
const awaitEvent = tests.awaitEvent;
const expectThrow = tests.expectThrow;
const randomAddress = tests.randomAddress;

contract("RegulatedTransferringIcoFactory", accounts => {
  let data;
  let regulatorService;
  let allowRegulationRule;
  let fakeRegulatorService;
  let ALLOWED = Math.pow(2, 16) - 2;

  let factory;
  let TokenCreated;
  let SaleCreated;
  let KycProviderCreated;

  before(async () => {
    data = require("./data.json");
    regulatorService = await RegulatorServiceImpl.new();
    allowRegulationRule = await AllowRegulationRule.new();
    fakeRegulatorService = await FakeRegulatorService.new();
  });

  beforeEach(async () => {
    factory = await IcoFactory.new(regulatorService.address, fakeRegulatorService.address);
    TokenCreated = factory.TokenCreated({});
    SaleCreated = factory.SaleCreated({});
    KycProviderCreated = factory.KycProviderCreated({});
  });

  it("should deploy regulated token and kyc provider", async () => {
    var tx = await factory.createRegulatedToken(data.regulatedIssuedToken, accounts[9], [ZERO], [ALLOWED], [allowRegulationRule.address], [100]);
    var providerCreated = await awaitEvent(KycProviderCreated);
    var tokenCreated = await awaitEvent(TokenCreated);

    var provider = KycProviderImpl.at(providerCreated.args.addr);
    var token = RegulatedTokenImpl.at(tokenCreated.args.addr);

		await expectThrow(
		  token.transfer(accounts[1], 100)
		);

		await expectThrow(
			provider.setData(accounts[1], ALLOWED, "", {from: accounts[1]})
		);
    await provider.setData(accounts[1], ALLOWED, "", {from: accounts[9]});
    await token.transfer(accounts[1], 100);
    assert.equal(await token.balanceOf(accounts[1]), 100);
  });


  it("should deploy security token ico and new provider", async () => {
    var usProvider = await KycProviderImpl.new();
    var tx = await factory.createIco(data.regulatedIssuedToken, "100000000000000000000", accounts[9], [ZERO, usProvider.address], [ALLOWED], [allowRegulationRule.address], [1000], data.securityTransferringSale);

    var tokenCreated = await awaitEvent(TokenCreated);
    var saleCreated = await awaitEvent(SaleCreated);
    var providerCreated = await awaitEvent(KycProviderCreated);

	  var token = RegulatedTokenImpl.at(tokenCreated.args.addr);
    var sale = TransferringSale.at(saleCreated.args.addr);
    assert.equal(await sale.token(), token.address);
    var provider = KycProviderImpl.at(providerCreated.args.addr);

    assert.equal(await sale.canBuy(accounts[1]), false);
    await expectThrow(
        sale.sendTransaction({from: accounts[1], value: 5})
    );
    await provider.setData(accounts[1], ALLOWED, "", {from: accounts[9]});
    assert.equal(await sale.canBuy(accounts[1]), true);
    await sale.sendTransaction({from: accounts[1], value: 5});
    await expectThrow(
        sale.sendTransaction({from: accounts[2], value: 5})
    );
  });
});
