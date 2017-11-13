var SignAndVerifyExample = artifacts.require("./SignAndVerifyExample.sol");

module.exports = function(deployer) {
  deployer.deploy(SignAndVerifyExample);
};
