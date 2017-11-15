pragma solidity 0.4.18;

contract TokenTransfer {
    function transfer(address destination, uint256 value);
}


contract MultiSigSafe {
    
    // INITIALIZING OWNERS
    address constant public owner0 = 0x627306090abaB3A6e1400e9345bC60c78a8BEf57;
    address constant public owner1 = 0xf17f52151EbEF6C7334FAD080c5704D77216b732;
    address constant public owner2 = 0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef;

    address constant public destination0 = 0x821aea9a577a9b44299b9c15c88cf3087f3b5544;
    address constant public destination1 = 0x0d1d4e623d10f9fba5db95830f7d3839406c6af2;
    address constant public destination2 = 0x2932b7a2355d6fecc4b5c0b6bd44cc31df247a2e;


    // INITIALIZING GLOBAL PUBLIC VARIABLES
    uint8 constant public threshold = 2;            // Number of valid signatures for executing Tx
    uint256 constant public limit = 1000*10**18;    // Limit of one Tx; modify at deploy time if needed
    uint256 public nonce;                           // to prevent multiple Tx executions

    function execute(uint8[] sigV, bytes32[] sigR, bytes32[] sigS, uint destinationNumber, uint256 value, address token) public {

        // VALIDATE INPUTS
        require(value <= limit);                    // check value below limits
        require(sigV.length == 3 && sigR.length == 3 && sigS.length == 3);
        require(destinationNumber < 3);

        if (destinationNumber == 0) destination = destination0
        else if (destinationNumber == 1) destination = destination1
        else if (destinationNumber == 2) destination = destination2;

        // VERIFYING OWNERS
        // Follows ERC191 signature scheme: https://github.com/ethereum/EIPs/issues/191
        // calculate hash
        bytes32 txHash = keccak256(byte(0x19), byte(0), this, destination, value, data, nonce);

        // count recovered if signature of owner0 is valid         
        uint8 recovered = 0;
        if (owner0 == ecrecover(txHash, sigV[0], sigR[0], sigS[0])) recovered = recovered + 1; 
        if (owner1 == ecrecover(txHash, sigV[1], sigR[1], sigS[1])) recovered = recovered + 1;
        if (owner2 == ecrecover(txHash, sigV[2], sigR[2], sigS[2])) recovered = recovered + 1;
  
        // VALIDATE CONFIGURATION
        require(recovered >= threshold);            // validate configuration

        // NONCE
        nonce = nonce + 1;                          // count nonce to avoid multiple Tx executions

        // SENDING Tx
        if (token == 0x0) {
            destination.transfer(value);  // send Tx, throws if not successfull
        } else {
            TokenTransfer tok = TokenTransfer(token);
            require(tok.transfer(destination, value));
        }

    }

    function () public payable {}     

}