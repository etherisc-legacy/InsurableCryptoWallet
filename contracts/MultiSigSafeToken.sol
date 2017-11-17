pragma solidity 0.4.18;

contract TokenTransfer {
    function transfer(address destination, uint256 value) public returns (bool _success);                      // define function for TokenTransfer
}

contract MultiSigSafe {
     
    // INITIALIZING OWNERS. Every owner corresponds to a hardware device
    address constant public owner0 = 0x627306090abaB3A6e1400e9345bC60c78a8BEf57;        //address of owner0
    address constant public owner1 = 0xf17f52151EbEF6C7334FAD080c5704D77216b732;        //address of owner1
    address constant public owner2 = 0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef;        //address of owner2

    // INITIALIZING DESTINATION 
    address constant public interact0 = 0x821aea9a577a9b44299b9c15c88cf3087f3b5544;  //address of interact wallet 0
    address constant public interact1 = 0x0d1d4e623d10f9fba5db95830f7d3839406c6af2;  //address of interact wallet 1
    address constant public interact2 = 0x2932b7a2355d6fecc4b5c0b6bd44cc31df247a2e;  //address of interact wallet 2
  
    // INITIALIZING GLOBAL PUBLIC VARIABLES
    uint8 constant public threshold = 2;                // Number of valid signatures for executing Tx
    uint256 constant public ethlimit = 1000*10**18;     // Limit of one ETH Tx; modify at deploy time if needed
    uint256 public nonce;                               // to prevent multiple Tx executions
    address public tokenAddress;                   // for token address counting, tokenAddressBook

    modifier onlyInteract {
        require(msg.sender == interact0 || msg.sender == interact1 || msg.sender == interact2);
        _;
    }

    function setTokenAddress(address _tokenAddress) public onlyInteract {
        tokenAddress = _tokenAddress;
    }

    function execute(uint8[] sigV, bytes32[] sigR, bytes32[] sigS, uint8 index, uint256 value, bool tokenTransfer) public onlyInteract {

        // VALIDATE INPUTS
        require(value <= limit);                        // check value below limits
        require(index <= 3);
        require(sigV.length == 3 && sigR.length == 3 && sigS.length == 3);
       
        if (tokenAddress != address(0x0)) {
            token = tokenAddress;
        }

        // INITIALIZING LOCAL VARIABLES
        address destination = this;                     // init destination, walletaddress
        address tokenAddress = this;                    // init destination, walletaddress
        uint8 recovered = 0;                            // init recovered

        // VERIFYING OWNERS
        // Follows ERC191 signature scheme: https://github.com/ethereum/EIPs/issues/191
        bytes32 txHash = keccak256(byte(0x19), byte(0), this, destinationNumber, ethvalue, tokenNumber, tokenvalue, nonce); // calculate hash

        // count recovered if signature of owner0 is valid         
        if (owner0 == ecrecover(txHash, sigV[0], sigR[0], sigS[0])) {recovered = recovered + 1;} // count recovered if signature of owner0 is valid  
        if (owner1 == ecrecover(txHash, sigV[1], sigR[1], sigS[1])) {recovered = recovered + 1;} // count recovered if signature of owner1 is valid  
        if (owner2 == ecrecover(txHash, sigV[2], sigR[2], sigS[2])) {recovered = recovered + 1;} // count recovered if signature of owner2 is valid  
  
        // VALIDATE CONFIGURATION
        require(recovered >= threshold);                                        // validate configuration

        // CHECK AND CHOOSING DESTINATION
        if (index == 0) { destination = interact0; }
        else if (index == 1) { destination = interact1; }
        else if (index == 2) { destination = interact2; }

        if (tokenTransfer) {
            TokenTransfer token = TokenTransfer(tokenAddress);
            require(token.transfer(value, destination));
        } else {
            destination.transfer(value);
        } 
    }

    function execute(uint8[] sigV, bytes32[] sigR, bytes32[] sigS, uint8 index, uint256 value) public onlyInteract {
        execute(sigV, sigR, sigS, index, value, false);
    }

    function () public payable {}     

}