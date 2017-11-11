pragma solidity 0.4.18;

contract SimplestWallet {
    
    address constant public owner1 = 0xCAfEcAfeCAfECaFeCaFecaFecaFECafECafeCaFe;
    address constant public owner2 = 0xdeaDDeADDEaDdeaDdEAddEADDEAdDeadDEADDEaD;
    address constant public owner3 = 0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef;
    address constant public destination1 = 0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef;
    address constant public destination2 = 0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef;
    address constant public destination3 = 0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef;

    uint8 constant public threshold = 2;
    address destination;
    uint256 public nonce;
    
    function execute(uint8 sigV1, uint8 sigV2, uint8 sigV3, bytes32 sigR1, bytes32 sigR2, bytes32 sigR3, bytes32 sigS1, bytes32 sigS2, bytes32 sigS3, uint8 destinationNumber, uint value) public {

        uint8 recovered;
        // Follows ERC191 signature scheme: https://github.com/ethereum/EIPs/issues/191
        if (destinationNumber == 1) { destination = destination1 }
        else if (destinationNumber == 2) { destination = destination2 }
        else if (destinationNumber == 3) { destination = destination3 }
        else throw;

        bytes32 txHash = keccak256(byte(0x19), byte(0), this, destination, value, data, nonce);
    
        if (owner1 == ecrecover(txHash, sigV1, sigR1, sigS1)) recovered++; 
        if (owner2 == ecrecover(txHash, sigV2, sigR2, sigS2)) recovered++; 
        if (owner3 == ecrecover(txHash, sigV3, sigR3, sigS3)) recovered++; 
        
        require(recovered >= threshold);
        destination.transfer(value);    // throws if not successfull

    }
    
    function () public payable {}    
    
}