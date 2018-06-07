var RegulatorServiceImpl = artifacts.require('RegulatorServiceImpl.sol');
var AllowRegulationRule = artifacts.require('AllowRegulationRule.sol');
var IcoFactory = artifacts.require('IcoFactory.sol');
var MintingSale = artifacts.require('MintingSaleMock.sol');
var MintableToken = artifacts.require('MintableToken.sol');
var RegulatedTokenImpl = artifacts.require('RegulatedTokenImpl.sol');
var KycProviderImpl = artifacts.require('KycProviderImpl.sol');

const tests = require("@daonomic/tests-common");
const awaitEvent = tests.awaitEvent;
const expectThrow = tests.expectThrow;
const randomAddress = tests.randomAddress;

contract("IcoFactory", accounts => {
  let data;
  let regulatorService;
  let allowRegulationRule;

  let factory;
  let TokenCreated;
  let SaleCreated;
  let KycProviderCreated;

  before(async () => {
    data = require("./data.json");
    regulatorService = await RegulatorServiceImpl.new();
    allowRegulationRule = await AllowRegulationRule.new();
  });

  beforeEach(async () => {
    factory = await IcoFactory.new(regulatorService.address, allowRegulationRule.address);
    TokenCreated = factory.TokenCreated({});
    SaleCreated = factory.SaleCreated({});
    KycProviderCreated = factory.KycProviderCreated({});
  });

  it("should deploy simple token", async () => {
    var tx = await factory.createToken(data.token, [], []);
    var tokenCreated = await awaitEvent(TokenCreated);

    var token = await MintableToken.at(tokenCreated.args.addr);
    await token.mint(accounts[1], 100);
    assert.equal(await token.totalSupply(), 100);
    assert.equal(await token.balanceOf(accounts[1]), 100);
  });

  it("should deploy regulated token and kyc provider", async () => {
    var tx = await factory.createToken(data.regulatedToken, ["0x0000000000000000000000000000000000000000"], []);
    var providerCreated = await awaitEvent(KycProviderCreated);
    var tokenCreated = await awaitEvent(TokenCreated);

    var provider = await KycProviderImpl.at(providerCreated.args.addr);
    var token = await RegulatedTokenImpl.at(tokenCreated.args.addr);

	await expectThrow(
	  token.mint(accounts[1], 100)
	);

    await provider.setData(accounts[1], await factory.ALLOWED(), "");
    await token.mint(accounts[1], 100);
    assert.equal(await token.totalSupply(), 100);
    assert.equal(await token.balanceOf(accounts[1]), 100);
  });

  it("should create working ico", async () => {
    var TokenCreated = factory.TokenCreated({});
    var SaleCreated = factory.SaleCreated({});

    var tx = await factory.createIco(data.token, [], data.sale, []);
    var tokenCreated = await awaitEvent(TokenCreated);
    var saleCreated = await awaitEvent(SaleCreated);

    var sale = await MintingSale.at(saleCreated.args.addr);
    assert.equal(await sale.token(), tokenCreated.args.addr);
  });
});
