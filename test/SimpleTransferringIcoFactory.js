var IcoFactory = artifacts.require('SimpleTransferringIcoFactory.sol');
var TransferringSale = artifacts.require('TransferringSale.sol');
var BasicToken = artifacts.require('BasicToken.sol');
var Secured = artifacts.require('Secured.sol');
var ZERO = "0x0000000000000000000000000000000000000000";

const tests = require("@daonomic/tests-common");
const awaitEvent = tests.awaitEvent;
const expectThrow = tests.expectThrow;
const randomAddress = tests.randomAddress;

contract("SimpleTransferringIcoFactory", accounts => {
  let data;

  let factory;
  let TokenCreated;
  let SaleCreated;

  before(async () => {
    data = require("./data.json");
  });

  beforeEach(async () => {
    factory = await IcoFactory.new();
    TokenCreated = factory.TokenCreated({});
    SaleCreated = factory.SaleCreated({});
  });

  it("should deploy token", async () => {
    var tx = await factory.createToken(data.issuedToken, [10000]);
    var tokenCreated = await awaitEvent(TokenCreated);
    var token = await BasicToken.at(tokenCreated.args.addr);

    await token.transfer(accounts[1], 100);
    assert.equal(await token.totalSupply(), 1000000000000000000000000);
    assert.equal(await token.balanceOf(accounts[1]), 100);
  });

  it("should deploy ico", async () => {
    var tx = await factory.createIco(data.issuedToken, "100000000000000000000000", [10000], data.transferringSale);

    var tokenCreated = await awaitEvent(TokenCreated);
    var saleCreated = await awaitEvent(SaleCreated);
    var sale = TransferringSale.at(saleCreated.args.addr);
    var token = BasicToken.at(tokenCreated.args.addr);
    assert.equal(await sale.token(), tokenCreated.args.addr);
    assert.equal(await token.balanceOf(sale.address), 100000000000000000000000);
    assert.equal(await token.balanceOf(accounts[0]), 900000000000000000000000);

    await sale.sendTransaction({from: accounts[5], value: 5});
    assert.equal(await token.balanceOf(accounts[5]), 5000);
  });

});
