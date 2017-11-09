pragma solidity 0.4.18;

contract SimplestWallet {
    
    // hardcode addresses and threshold at time of deployment.
    address constant public owner0 = 0xdeaddeaddeaddeaddeaddeaddeaddeaddeaddead; 
    address constant public owner1 = 0xcafecafecafecafecafecafecafecafecafecafe;
    address constant public owner2 = 0xbeefbeefbeefbeefbeefbeefbeefbeefbeefbeef;
    uint8 constant public threshold = 2;
    uint256 public nonce;
    
    function execute(uint8[] sigV, bytes32[] sigR, bytes32[] sigS, address destination, uint value, bytes data) public {

        require(sigV.length == 3);
        require(sigR.length == 3);
        require(sigS.length == 3);
    
        uint8 recovered;
        
        // Follows ERC191 signature scheme: https://github.com/ethereum/EIPs/issues/191
        bytes32 txHash = keccak256(byte(0x19), byte(0), this, destination, value, data, nonce);
    
        if (owner0 == ecrecover(txHash, sigV[0], sigR[0], sigS[0])) recovered++; 
        if (owner1 == ecrecover(txHash, sigV[1], sigR[1], sigS[1])) recovered++; 
        if (owner2 == ecrecover(txHash, sigV[2], sigR[2], sigS[2])) recovered++; 
        
        require(recovered >= threshold);
        nonce = nonce + 1;

        require(destination.call.value(value)(data));
      
    }
    
    function () public payable {}    
    
}
