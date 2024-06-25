const ManualMinter = artifacts.require("ManualMinter");

module.exports = async function(deployer, network, accounts) {
    const initialAdmin = accounts[0];
    await deployer.deploy(ManualMinter, initialAdmin);
};
