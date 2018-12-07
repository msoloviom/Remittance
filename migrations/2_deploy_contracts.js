const Remittance = artifacts.require("./Remittance.sol");
const Owned = artifacts.require("./Owned.sol");

module.exports = function(deployer) {
    deployer.deploy(Owned);
    deployer.link(Owned, Remittance);
    deployer.deploy(Remittance);
};
