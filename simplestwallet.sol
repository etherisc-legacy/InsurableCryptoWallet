pragma solidity 0.4.18;

contract SimplestWallet {
    
    address constant public owner1 = 0x0;
    address constant public owner2 = 0x0;
    address constant public owner3 = 0x0;
    uint8 constant public threshold = 2;
    uint256 public nonce;
    
    function execute(uint8[] sigV, bytes32[] sigR, bytes32[] sigS, address destination, uint value, bytes data) public {

        require(sigV.length == 3);
        require(sigR.length == 3);
        require(sigS.length == 3);
    
        uint8 recovered;
        
        // Follows ERC191 signature scheme: https://github.com/ethereum/EIPs/issues/191
        bytes32 txHash = keccak256(byte(0x19), byte(0), this, destination, value, data, nonce);
    
        if (owner1 == ecrecover(txHash, sigV[0], sigR[0], sigS[0])) recovered++; 
        if (owner2 == ecrecover(txHash, sigV[1], sigR[1], sigS[1])) recovered++; 
        if (owner3 == ecrecover(txHash, sigV[2], sigR[2], sigS[2])) recovered++; 
        
        require(recovered >= threshold);
        nonce = nonce + 1;

        require(destination.call.value(value)(data));
      
    }
    
    function () public payable {}    
    
}
