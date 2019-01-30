var IcoFactory = artifacts.require('SimpleIcoFactory.sol');
var Sale = artifacts.require('WhitelistSaleMock.sol');
var MintableToken = artifacts.require('ERC20Mintable.sol');
var Ownable = artifacts.require('Ownable.sol');
var ZERO = "0x0000000000000000000000000000000000000000";

const tests = require("@daonomic/tests-common");
const findLog = tests.findLog;
const expectThrow = tests.expectThrow;
const randomAddress = tests.randomAddress;

contract("SimpleIcoFactory (whitelist)", accounts => {
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

  it("should deploy ico with whitelist", async () => {
    var tx = await factory.createIco(data.simpleToken, data.whitelistSale, "0x");
    console.log(tx.receipt.gasUsed);

    var tokenCreated = findLog(tx, "TokenCreated");
    var saleCreated = findLog(tx, "SaleCreated");
    var sale = await Sale.at(saleCreated.args.addr);
    var token = await MintableToken.at(tokenCreated.args.addr);
    assert.equal(await sale.token(), tokenCreated.args.addr);

    await sale.addWhitelistAdmin(accounts[1]);
    await sale.setWhitelisted(accounts[5], true);
    await sale.sendTransaction({from: accounts[5], value: 5});
    assert.equal(await token.balanceOf(accounts[5]), 5000000);
  });

});
