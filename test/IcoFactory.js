var RegulatorServiceImpl = artifacts.require('RegulatorServiceImpl.sol');
var AllowRegulationRule = artifacts.require('AllowRegulationRule.sol');
var FakeKycProvider = artifacts.require('FakeKycProvider.sol');
var IcoFactory = artifacts.require('IcoFactory.sol');
var MintingSale = artifacts.require('MintingSaleMock.sol');
var MintableToken = artifacts.require('MintableToken.sol');
var Secured = artifacts.require('Secured.sol');
var RegulatedTokenImpl = artifacts.require('RegulatedTokenImpl.sol');
var KycProviderImpl = artifacts.require('KycProviderImpl.sol');
var ZERO = "0x0000000000000000000000000000000000000000";

const tests = require("@daonomic/tests-common");
const awaitEvent = tests.awaitEvent;
const expectThrow = tests.expectThrow;
const randomAddress = tests.randomAddress;

contract("IcoFactory", accounts => {
  let data;
  let regulatorService;
  let allowRegulationRule;
  let fakeKycProvider;

  let factory;
  let TokenCreated;
  let SaleCreated;
  let KycProviderCreated;
  let ALLOWED;

  before(async () => {
    data = require("./data.json");
    regulatorService = await RegulatorServiceImpl.new();
    allowRegulationRule = await AllowRegulationRule.new();
    fakeKycProvider = await FakeKycProvider.new();
  });

  beforeEach(async () => {
    factory = await IcoFactory.new(regulatorService.address, fakeKycProvider.address, allowRegulationRule.address);
    ALLOWED = await factory.ALLOWED();
    TokenCreated = factory.TokenCreated({});
    SaleCreated = factory.SaleCreated({});
    KycProviderCreated = factory.KycProviderCreated({});
  });

  it("should deploy simple token", async () => {
    var tx = await factory.createSimpleToken(data.simpleToken, []);
    var tokenCreated = await awaitEvent(TokenCreated);
    var token = await MintableToken.at(tokenCreated.args.addr);

    await token.mint(accounts[1], 100);
    assert.equal(await token.totalSupply(), 100);
    assert.equal(await token.balanceOf(accounts[1]), 100);
  });

  it("should deploy regulated token and kyc provider", async () => {
    var tx = await factory.createRegulatedToken(data.regulatedToken, accounts[9], [ZERO], [ALLOWED], [allowRegulationRule.address], [100]);
    var providerCreated = await awaitEvent(KycProviderCreated);
    var tokenCreated = await awaitEvent(TokenCreated);

    var provider = KycProviderImpl.at(providerCreated.args.addr);
    var token = RegulatedTokenImpl.at(tokenCreated.args.addr);

	await expectThrow(
	  token.mint(accounts[1], 100)
	);

	await expectThrow(
		provider.setData(accounts[1], ALLOWED, "", {from: accounts[1]})
	);
    await provider.setData(accounts[1], ALLOWED, "", {from: accounts[9]});
    await token.mint(accounts[1], 100);
    assert.equal(await token.totalSupply(), 200);
    assert.equal(await token.balanceOf(accounts[1]), 100);
  });

  it("should deploy simple ico", async () => {
    var tx = await factory.createSimpleIco(data.simpleToken, [], data.simpleSale);

    var tokenCreated = await awaitEvent(TokenCreated);
    var saleCreated = await awaitEvent(SaleCreated);
    var sale = MintingSale.at(saleCreated.args.addr);
    var token = MintableToken.at(tokenCreated.args.addr);
    assert.equal(await sale.token(), tokenCreated.args.addr);

    await sale.sendTransaction({from: accounts[5], value: 5});
    assert.equal(await token.balanceOf(accounts[5]), 5000);
  });

  it("should deploy kyc ico and new provider", async () => {
    var tx = await factory.createKycIco(data.simpleToken, [], data.kycSale, accounts[9], ZERO);

    var tokenCreated = await awaitEvent(TokenCreated);
    var saleCreated = await awaitEvent(SaleCreated);
    var providerCreated = await awaitEvent(KycProviderCreated);

    var sale = await MintingSale.at(saleCreated.args.addr);
    assert.equal(await sale.token(), tokenCreated.args.addr);
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

  it("should deploy security token ico and new provider", async () => {
    var tx = await factory.createSecurityIco(data.regulatedToken, accounts[9], [ZERO, randomAddress()], [ALLOWED], [allowRegulationRule.address], [], data.securitySale);

    var tokenCreated = await awaitEvent(TokenCreated);
    var saleCreated = await awaitEvent(SaleCreated);
    var providerCreated = await awaitEvent(KycProviderCreated);

    var sale = await MintingSale.at(saleCreated.args.addr);
    assert.equal(await sale.token(), tokenCreated.args.addr);
    var provider = KycProviderImpl.at(providerCreated.args.addr);

    console.log("test1");
    assert.equal(await sale.canBuy(accounts[1]), false);
    await expectThrow(
        sale.sendTransaction({from: accounts[1], value: 5})
    );
    console.log("test3");
    await provider.setData(accounts[1], ALLOWED, "", {from: accounts[9]});
    assert.equal(await sale.canBuy(accounts[1]), true);

    console.log("test5");
    await sale.sendTransaction({from: accounts[1], value: 5});
    await expectThrow(
        sale.sendTransaction({from: accounts[2], value: 5})
    );
  });

});
