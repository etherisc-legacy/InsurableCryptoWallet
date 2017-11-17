pragma solidity 0.4.18;

contract TokenTransfer {
    function transfer(address origin, uint256 value) public returns (bool _success);                      // define function for TokenTransfer
}

contract MultiSigSafe {
     
    // INITIALIZING OWNERS. Every owner corresponds to a hardware device
    address constant public owner0 = 0x627306090abaB3A6e1400e9345bC60c78a8BEf57;        //address of owner0
    address constant public owner1 = 0xf17f52151EbEF6C7334FAD080c5704D77216b732;        //address of owner1
    address constant public owner2 = 0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef;        //address of owner2

    // INITIALIZING origin 
    address constant public origin0 = 0x821aea9a577a9b44299b9c15c88cf3087f3b5544;  //address of origin wallet 0
    address constant public origin1 = 0x0d1d4e623d10f9fba5db95830f7d3839406c6af2;  //address of origin wallet 1
    address constant public origin2 = 0x2932b7a2355d6fecc4b5c0b6bd44cc31df247a2e;  //address of origin wallet 2
  
    // INITIALIZING GLOBAL PUBLIC VARIABLES
    uint8 constant public threshold = 2;                // Number of valid signatures for executing Tx
    uint256 constant public limit = 1000*10**18;        // Value limit of one Tx; modify at deploy time if needed
    uint256 public nonce;                               // to prevent multiple Tx executions

    function execute(uint8[] sigV, bytes32[] sigR, bytes32[] sigS, uint256 value, bool tokenTransfer, address tokenAddress) public {

        // VALIDATE INPUTS
        require(value <= limit);                        // check value below limits
        require(index < 3);
        require(sigV.length == 3 && sigR.length == 3 && sigS.length == 3);
        require(msg.sender == origin0 || msg.sender == origin1 || msg.sender == origin2);
       
        // INITIALIZING LOCAL VARIABLES
        address origin = this;                          // init origin, walletaddress
        uint8 recovered = 0;                            // init recovered

        // VERIFYING OWNERS
        // Follows ERC191 signature scheme: https://github.com/ethereum/EIPs/issues/191
        bytes32 txHash = keccak256(byte(0x19), byte(0), this, value, tokenTransfer, nonce); // calculate hash

        // count recovered if signature of owner0 is valid         
        if (owner0 == ecrecover(txHash, sigV[0], sigR[0], sigS[0])) {recovered = recovered + 1;} // count recovered if signature of owner0 is valid  
        if (owner1 == ecrecover(txHash, sigV[1], sigR[1], sigS[1])) {recovered = recovered + 1;} // count recovered if signature of owner1 is valid  
        if (owner2 == ecrecover(txHash, sigV[2], sigR[2], sigS[2])) {recovered = recovered + 1;} // count recovered if signature of owner2 is valid  
  
        // VALIDATE CONFIGURATION
        require(recovered >= threshold);                                        // validate configuration

        // CHECK AND CHOOSING origin
        if (tokenTransfer) {
            TokenTransfer token = TokenTransfer(tokenAddress);
            require(token.transfer(value, msg.sender));
        } else {
            msg.sender.transfer(value);
        } 
    }

    function () public payable {}     

}