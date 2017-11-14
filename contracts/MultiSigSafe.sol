pragma solidity 0.4.18;

contract MultiSigSafe {
    
    // INITIALIZING OWNERS
    address constant public owner0 = 0x627306090abaB3A6e1400e9345bC60c78a8BEf57; //address of owner0
    address constant public owner1 = 0xf17f52151EbEF6C7334FAD080c5704D77216b732; //address of owner1
    address constant public owner2 = 0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef; //address of owner2

    // INITIALIZING GLOBAL PUBLIC VARIABLES
    uint8 constant public threshold = 2;            // Number of valid signatures for executing Tx
    uint256 constant public limit = 1000*10**18;    // Limit of one Tx
    uint256 public nonce;                           // to prevent multiple Tx executions

    event LogAddress(string _msg, address _address);


    function execute(uint8[] sigV, bytes32[] sigR, bytes32[] sigS, address destination, uint256 value, bytes data) public {
 
        uint8 recovered = 0;

        // VALIDATE INPUTS
        require(value <= limit);            // check value within limits
        require(sigV.length == 3 && sigR.length == 3 && sigS.length == 3);

        // VERIFYING OWNERS
        // Follows ERC191 signature scheme: https://github.com/ethereum/EIPs/issues/191
        bytes32 txHash = keccak256(byte(0x19), byte(0), this, destination, value, data, nonce); // calculate txHash

        if (owner0 == ecrecover(txHash, sigV[0], sigR[0], sigS[0])) recovered = recovered + 1; // count recovered if signature of owner0 is valid         
        if (owner1 == ecrecover(txHash, sigV[1], sigR[1], sigS[1])) recovered = recovered + 1; // count recovered if signature of owner1 is valid
        if (owner2 == ecrecover(txHash, sigV[2], sigR[2], sigS[2])) recovered = recovered + 1; // count recovered if signature of owner2 is valid
  
        // VALIDATE CONFIGURATION
        require(recovered >= threshold);    // validate configuration

        // NONCE
        nonce = nonce + 1;                  // count nonce to avoid multiple Tx executions

        // SENDING Tx
        require(destination.call.value(value)(data));        // send Tx, throws if not successfull

    }

    function () public payable {}     

}