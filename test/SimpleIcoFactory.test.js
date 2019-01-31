var IcoFactory = artifacts.require('SimpleIcoFactory.sol');
var Sale = artifacts.require('SimpleSaleMock.sol');
var MintableToken = artifacts.require('ERC20Mintable.sol');
var Pools = artifacts.require('Pools.sol');
var MinterRole = artifacts.require('MinterRole.sol');
var ZERO = "0x0000000000000000000000000000000000000000";

const tests = require("@daonomic/tests-common");
const findLog = tests.findLog;
const expectThrow = tests.expectThrow;
const randomAddress = tests.randomAddress;

contract("SimpleIcoFactory", accounts => {
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
    var tx = await factory.createToken(data.simpleToken, "0x");
    console.log(tx.receipt.gasUsed);
    var tokenCreated = findLog(tx, "TokenCreated");
    var token = await MintableToken.at(tokenCreated.args.addr);

    await token.mint(accounts[1], 100);
    assert.equal(await token.totalSupply(), 100);
    assert.equal(await token.balanceOf(accounts[1]), 100);

    assert.equal(findLog(tx, "PoolCreatedEvent"), null);
  });

  it("should deploy token with pools", async () => {
    var tx = await factory.createToken(data.simpleToken, data.pools);
    console.log(tx.receipt.gasUsed);

    var tokenCreated = findLog(tx, "TokenCreated");
    var token = await MintableToken.at(tokenCreated.args.addr);
    var poolsCreated = findLog(tx, "PoolsCreated");
    var pools = await Pools.at(poolsCreated.args.addr);

    assert.equal(await pools.owner(), accounts[0]);
    assert(await token.isMinter(pools.address), "pools is not minter");
    await pools.createHolder("direct", accounts[1], 100);
    assert.equal(await token.balanceOf(accounts[1]), 100);
  });

  it("should deploy ico", async () => {
    var tx = await factory.createIco(data.simpleToken, data.simpleSale, "0x");
    console.log(tx.receipt.gasUsed);

    var tokenCreated = findLog(tx, "TokenCreated");
    var saleCreated = findLog(tx, "SaleCreated");
    var sale = await Sale.at(saleCreated.args.addr);
    var token = await MintableToken.at(tokenCreated.args.addr);
    assert.equal(await sale.token(), tokenCreated.args.addr);

    await sale.sendTransaction({from: accounts[5], value: 5});
    assert.equal(await token.balanceOf(accounts[5]), 5000000);
  });

  it("should deploy ico with pools", async () => {
    var tx = await factory.createIco(data.simpleToken, data.simpleSale, data.pools);
    console.log(tx.receipt.gasUsed);

    var poolsCreated = findLog(tx, "PoolsCreated");
    var pools = await Pools.at(poolsCreated.args.addr);

    assert.equal(await pools.owner(), accounts[0]);
  });

});
