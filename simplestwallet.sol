pragma solidity 0.4.18;

contract SimplestWallet {
    
    address constant public owner1 = 0xCAfEcAfeCAfECaFeCaFecaFecaFECafECafeCaFe;
    address constant public owner2 = 0xdeaDDeADDEaDdeaDdEAddEADDEAdDeadDEADDEaD;
    address constant public owner3 = 0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef;
    uint8 constant public threshold = 2;
    uint256 public nonce;
    
    function execute(uint8 sigV1, uint8 sigV2, uint8 sigV3, bytes32 sigR1, bytes32 sigR2, bytes32 sigR3, bytes32 sigS1, bytes32 sigS2, bytes32 sigS3, address destination, uint value, bytes data) public {

        uint8 recovered;
        // Follows ERC191 signature scheme: https://github.com/ethereum/EIPs/issues/191
        bytes32 txHash = keccak256(byte(0x19), byte(0), this, destination, value, data, nonce);
    
        if (owner1 == ecrecover(txHash, sigV1, sigR1, sigS1)) recovered++; 
        if (owner2 == ecrecover(txHash, sigV2, sigR2, sigS2)) recovered++; 
        if (owner3 == ecrecover(txHash, sigV3, sigR3, sigS3)) recovered++; 
        
        require(recovered >= threshold);
        require(destination.call.value(value)(data));
      
    }
    
    function () public payable {}    
    
}