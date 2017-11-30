pragma solidity 0.4.18;

contract TokenTransfer {
    // minimal subset of ERC20
    function transfer(address _to, uint256 _value) public returns (bool success); 
}

contract MultiSigSafeToken {
     
    // INITIALIZING OWNERS. Every owner corresponds to a hardware device
    address constant public owner0 = 0x627306090abaB3A6e1400e9345bC60c78a8BEf57;        //address of owner0
    address constant public owner1 = 0xf17f52151EbEF6C7334FAD080c5704D77216b732;        //address of owner1
    address constant public owner2 = 0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef;        //address of owner2

    // INITIALIZING GLOBAL PUBLIC VARIABLES
    uint8 constant public threshold = 2;                // Number of valid signatures for executing Tx
    uint256 constant public limit = 1000*10**18;        // Value limit of one Tx; modify at deploy time if needed
    uint256 public nonce;                               // to prevent multiple Tx executions

    function execute(uint8[] sigV, bytes32[] sigR, bytes32[] sigS, uint256 value, uint8 destinationIndex, address tokenAddress) public {

        address destination;

        // VALIDATE INPUTS
        require(value <= limit);                                                                    // check value within limit
        require(sigV.length == 3 && sigR.length == 3 && sigS.length == 3);
        require(destinationIndex < 3);
        require(msg.sender == owner0 || msg.sender == owner1 || msg.sender == owner2);
        
        // VERIFYING OWNERS
        // Follows ERC191 signature scheme: https://github.com/ethereum/EIPs/issues/191
        bytes32 txHash = keccak256(byte(0x19), byte(0), this, nonce, value, destinationIndex, tokenAddress != 0x0);      // calculate hash

        // count recovered if signature of owner is valid         
        uint8 recovered = 0;                                                                        // init recovered
        if (owner0 == ecrecover(txHash, sigV[0], sigR[0], sigS[0])) {recovered = recovered + 1;}    // count recovered if signature of owner0 is valid  
        if (owner1 == ecrecover(txHash, sigV[1], sigR[1], sigS[1])) {recovered = recovered + 1;}    // count recovered if signature of owner1 is valid  
        if (owner2 == ecrecover(txHash, sigV[2], sigR[2], sigS[2])) {recovered = recovered + 1;}    // count recovered if signature of owner2 is valid  
  
        // VALIDATE CONFIGURATION
        require(recovered >= threshold);

        // CHECK AND CHOOSING destination
        if (destinationIndex == 0) destination = owner0;
        if (destinationIndex == 1) destination = owner1;
        if (destinationIndex == 2) destination = owner2;

        if (tokenAddress == 0x0) {
            destination.transfer(value);
        } else {
            TokenTransfer token = TokenTransfer(tokenAddress);
            require(token.transfer(destination, value));
        } 

        nonce = nonce + 1;

    }

    function () public payable {}     

}