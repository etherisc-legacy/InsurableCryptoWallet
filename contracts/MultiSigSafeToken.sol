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
    TokenTransfer token;

    event LogBool(string _msg, bool _bool);
    event LogAddress(string _msg, address _address);
    event LogUint8(string _msg, uint8 _uint8);
    event LogUint256(string _msg, uint256 _uint256);
    event LogBytes32(string _msg, bytes32 _bytes32);


    function execute(uint8[] sigV, bytes32[] sigR, bytes32[] sigS, uint256 value, bool tokenTransfer, address tokenAddress) public {

        // VALIDATE INPUTS
        require(value <= limit);                        // check value below limits
        require(sigV.length == 3 && sigR.length == 3 && sigS.length == 3);
        require(msg.sender == owner0 || msg.sender == owner1 || msg.sender == owner2);
        
        LogAddress('MultiSig Address', this);
        LogUint256('Nonce: ', nonce);
        LogUint256('Value: ', value);
        LogBool('tokenTransfer', tokenTransfer);
        LogUint256('sigV.length: ', sigV.length);
        LogUint256('sigR.length: ', sigR.length);
        LogUint256('sigS.length: ', sigS.length);
        LogAddress('msg.sender: ', msg.sender);


        // INITIALIZING LOCAL VARIABLES
        uint8 recovered = 0;                            // init recovered

        // VERIFYING OWNERS
        // Follows ERC191 signature scheme: https://github.com/ethereum/EIPs/issues/191
        bytes32 txHash = keccak256(byte(0x19), byte(0), this, nonce, value, tokenTransfer); // calculate hash
        LogBytes32('txHash', txHash);

        // count recovered if signature of owner0 is valid         
        if (owner0 == ecrecover(txHash, sigV[0], sigR[0], sigS[0])) {recovered = recovered + 1;} // count recovered if signature of owner0 is valid  
        if (owner1 == ecrecover(txHash, sigV[1], sigR[1], sigS[1])) {recovered = recovered + 1;} // count recovered if signature of owner1 is valid  
        if (owner2 == ecrecover(txHash, sigV[2], sigR[2], sigS[2])) {recovered = recovered + 1;} // count recovered if signature of owner2 is valid  
  
        // VALIDATE CONFIGURATION
        // require(recovered >= threshold);               // validate configuration
        LogUint8('recovered: ', recovered);

        // CHECK AND CHOOSING origin
        if (tokenTransfer) {
            token = TokenTransfer(tokenAddress);
            require(token.transfer(msg.sender, value));
        } else {
            msg.sender.transfer(value);
        } 
    }

    function () public payable {}     

}