var IcoFactory = artifacts.require('IcoFactory.sol');
var MintingSale = artifacts.require('MintingSaleMock.sol');

const tests = require("@daonomic/tests-common");
const awaitEvent = tests.awaitEvent;
const expectThrow = tests.expectThrow;
const randomAddress = tests.randomAddress;

contract("IcoFactory", accounts => {
  let factory;

  beforeEach(async function() {
    factory = await IcoFactory.new();
  });

  it("should create working ico", async () => {
    var data = require("./data.json");
    var TokenCreated = factory.TokenCreated({});
    var SaleCreated = factory.SaleCreated({});

    var tx = await factory.createIco(data.token, data.sale);
    var tokenCreated = await awaitEvent(TokenCreated);
    var saleCreated = await awaitEvent(SaleCreated);

    var sale = await MintingSale.at(saleCreated.args.addr);
    assert.equal(await sale.token(), tokenCreated.args.addr);
  });
});
