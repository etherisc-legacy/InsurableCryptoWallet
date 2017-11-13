var MultiSigSafe = artifacts.require("./MultiSigSafe.sol");

module.exports = function(deployer) {
  deployer.deploy(MultiSigSafe);
};
