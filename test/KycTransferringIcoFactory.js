var IcoFactory = artifacts.require('KycTransferringIcoFactory.sol');
var TransferringSale = artifacts.require('TransferringSale.sol');
var BasicToken = artifacts.require('BasicToken.sol');
var Secured = artifacts.require('Secured.sol');
var KycProviderImpl = artifacts.require('KycProviderImpl.sol');
var ZERO = "0x0000000000000000000000000000000000000000";

const tests = require("@daonomic/tests-common");
const awaitEvent = tests.awaitEvent;
const expectThrow = tests.expectThrow;
const randomAddress = tests.randomAddress;

contract("KycTransferringIcoFactory", accounts => {
  let data;

  let factory;
  let TokenCreated;
  let SaleCreated;
  let KycProviderCreated;
  let ALLOWED = Math.pow(2, 16) - 2;

  before(async () => {
    data = require("./data.json");
  });

  beforeEach(async () => {
    factory = await IcoFactory.new();
    TokenCreated = factory.TokenCreated({});
    SaleCreated = factory.SaleCreated({});
    KycProviderCreated = factory.KycProviderCreated({});
  });

  it("should deploy ico and new provider", async () => {
    var tx = await factory.createIco(data.issuedToken, "100000000000000000000000", ["10000000000000000000000"], data.kycTransferringSale, accounts[9], ZERO);

    var tokenCreated = await awaitEvent(TokenCreated);
    var saleCreated = await awaitEvent(SaleCreated);
    var providerCreated = await awaitEvent(KycProviderCreated);

    var sale = await TransferringSale.at(saleCreated.args.addr);
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


});
