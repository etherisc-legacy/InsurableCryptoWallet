pragma solidity 0.4.18;

contract MultiSigSafe {
    
    // INITIALIZING OWNERS
    address constant public owner1 = 0xCAfEcAfeCAfECaFeCaFecaFecaFECafECafeCaFe; //address of owner1
    address constant public owner2 = 0xdeaDDeADDEaDdeaDdEAddEADDEAdDeadDEADDEaD; //address of owner2
    address constant public owner3 = 0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef; //address of owner2

    // INITIALIZING DESTINATIONS
    address constant public destination1 = 0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef; //address of destination wallet1
    address constant public destination2 = 0xCAfEcAfeCAfECaFeCaFecaFecaFECafECafeCaFe; //address of destination wallet2
    address constant public destination3 = 0xdeaDDeADDEaDdeaDdEAddEADDEAdDeadDEADDEaD; //address of destination wallet3

    // INITIALIZING GLOBAL PUBLIC VARIABLES
    uint8 constant public threshold = 2;    // Number of valid signatures for executing Tx
    uint256 constant public limit = 1000;   // Limit of one Tx
    uint256 public nonce;                   // to prevent multiple Tx executions
    
    function execute(uint8 sigV1, uint8 sigV2, uint8 sigV3, bytes32 sigR1, bytes32 sigR2, bytes32 sigR3, bytes32 sigS1, bytes32 sigS2, bytes32 sigS3, uint8 destinationNumber, uint value) public {
        
        // INITIALIZING LOCAL VARIABLES
        address destination = this;         // init destination, walletaddress
        uint8 recovered = 0;                // init recovered

        // CHECK LIMIT
        require(value <= limit);            // check value within limits

        // CHECK AND CHOOSING DESTINATION
        if (destinationNumber == 1) { destination = destination1 }
        else if (destinationNumber == 2) { destination = destination2 }
        else if (destinationNumber == 3) { destination = destination3 }
        else throw;

        // VERIFYING OWNERS
        // Follows ERC191 signature scheme: https://github.com/ethereum/EIPs/issues/191
        bytes32 txHash = keccak256(byte(0x19), byte(0), this, destination, value, data, nonce); // calculate txHash
        if (owner1 == ecrecover(txHash, sigV1, sigR1, sigS1)) recovered++; // count recovered if signature of owner1 is valid
        if (owner2 == ecrecover(txHash, sigV2, sigR2, sigS2)) recovered++; // count recovered if signature of owner2 is valid
        if (owner3 == ecrecover(txHash, sigV3, sigR3, sigS3)) recovered++; // count recovered if signature of owner3 is valid
        
        // VALIDATE CONFIGURATION
        require(recovered >= threshold);    // validate configuration

        // NONCE
        nonce = nonce + 1;                  // count nonce to avoid multiple Tx executions

        // SENDING Tx
        destination.transfer(value);        // send Tx, throws if not successfull

    }
     function () public payable {}     
}