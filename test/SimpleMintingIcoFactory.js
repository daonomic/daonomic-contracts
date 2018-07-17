var IcoFactory = artifacts.require('SimpleMintingIcoFactory.sol');
var MintingSale = artifacts.require('MintingSaleMock.sol');
var MintableToken = artifacts.require('MintableToken.sol');
var Secured = artifacts.require('Secured.sol');
var KycProviderImpl = artifacts.require('KycProviderImpl.sol');
var ZERO = "0x0000000000000000000000000000000000000000";

const tests = require("@daonomic/tests-common");
const awaitEvent = tests.awaitEvent;
const expectThrow = tests.expectThrow;
const randomAddress = tests.randomAddress;

contract("SimpleMintingIcoFactory", accounts => {
  let data;

  let factory;
  let TokenCreated;
  let SaleCreated;
  let HolderCreated;

  before(async () => {
    data = require("./data.json");
  });

  beforeEach(async () => {
    factory = await IcoFactory.new();
    TokenCreated = factory.TokenCreated({});
    SaleCreated = factory.SaleCreated({});
    HolderCreated = factory.HolderCreated({});
  });

  it("should deploy token", async () => {
    var tx = await factory.createToken(data.simpleToken, [500]);
    var tokenCreated = await awaitEvent(TokenCreated);
    var token = await MintableToken.at(tokenCreated.args.addr);

    await token.mint(accounts[1], 100);
    assert.equal(await token.totalSupply(), 600);
    assert.equal(await token.balanceOf(accounts[1]), 100);
  });

  it("should deploy ico", async () => {
    var tx = await factory.createIco(data.simpleToken, [1000], data.simpleSale);

    var tokenCreated = await awaitEvent(TokenCreated);
    var saleCreated = await awaitEvent(SaleCreated);
    var sale = MintingSale.at(saleCreated.args.addr);
    var token = MintableToken.at(tokenCreated.args.addr);
    assert.equal(await sale.token(), tokenCreated.args.addr);

    await sale.sendTransaction({from: accounts[5], value: 5});
    assert.equal(await token.balanceOf(accounts[5]), 5000);
  });


});
