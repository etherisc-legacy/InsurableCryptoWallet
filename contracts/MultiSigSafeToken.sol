pragma solidity 0.4.18;

contract TokenTransfer {
    function transfer(address destination, uint256 value);                      // define function for TokenTransfer
}

contract TokenAddressBook {
    mapping (bytes32 => address) tokenAddressBook;  
    function set(uint8 tokenAddressCounter, address tokenAddressInit) {
        tokenAddressBook[keccak256(tokenAddressCounter)] = tokenAddressInit;    // define set function for tokenAddressBook
        }   
    function get(uint8 tokenNumber) constant returns(address) {                 // define get function for tokenAddressBook
        return tokenAddressBook[keccak256(tokenNumber)];
        }                                
}

contract MultiSigSafe {
     
    // INITIALIZING OWNERS
    address constant public owner0 = 0x627306090abaB3A6e1400e9345bC60c78a8BEf57;        //address of owner0
    address constant public owner1 = 0xf17f52151EbEF6C7334FAD080c5704D77216b732;        //address of owner1
    address constant public owner2 = 0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef;        //address of owner2

    // INITIALIZING DESTINATION 
    address constant public destination0 = 0x821aea9a577a9b44299b9c15c88cf3087f3b5544;  //address of destination wallet0
    address constant public destination1 = 0x0d1d4e623d10f9fba5db95830f7d3839406c6af2;  //address of destination wallet1
    address constant public destination2 = 0x2932b7a2355d6fecc4b5c0b6bd44cc31df247a2e;  //address of destination wallet2
  
    // INITIALIZING GLOBAL PUBLIC VARIABLES
    uint8 constant public threshold = 2;                // Number of valid signatures for executing Tx
    uint256 constant public ethlimit = 1000*10**18;     // Limit of one ETH Tx; modify at deploy time if needed
    uint256 constant public tokenlimit = 1000;          // Limit of one TOKEN Tx; modify at deploy time if needed
    uint256 public nonce;                               // to prevent multiple Tx executions
    uint8 public tokenAddressCounter;                   // for token address counting, tokenAddressBook

    function execute(uint8[] sigV, bytes32[] sigR, bytes32[] sigS, uint8 destinationNumber, uint256 ethvalue, uint8 tokenNumber, uint256 tokenvalue, uint8 setTokenAddress, address tokenAddressInit ) public {

        // VALIDATE INPUTS
        require(ethvalue <= ethlimit);                  // check ethvalue below limits
        require(tokenvalue <= tokenlimit);              // check tokenvalue below limits
        require(destinationNumber < 3);                 // check destinationNumber within limits
        require(sigV.length == 3 && sigR.length == 3 && sigS.length == 3);
       
        // INITIALIZING LOCAL VARIABLES
        address destination = this;                     // init destination, walletaddress
        address tokenAddress = this;                    // init destination, walletaddress
        uint8 recovered = 0;                            // init recovered

        // VERIFYING OWNERS
        // Follows ERC191 signature scheme: https://github.com/ethereum/EIPs/issues/191
        bytes32 txHash = keccak256(byte(0x19), byte(0), this, destinationNumber, ethvalue, tokenNumber, tokenvalue, setTokenAddress, nonce); // calculate hash

        // count recovered if signature of owner0 is valid         
        if (owner0 == ecrecover(txHash, sigV[0], sigR[0], sigS[0])) recovered = recovered + 1; // count recovered if signature of owner0 is valid  
        if (owner1 == ecrecover(txHash, sigV[1], sigR[1], sigS[1])) recovered = recovered + 1; // count recovered if signature of owner1 is valid  
        if (owner2 == ecrecover(txHash, sigV[2], sigR[2], sigS[2])) recovered = recovered + 1; // count recovered if signature of owner2 is valid  
  
        // VALIDATE CONFIGURATION
        require(recovered >= threshold);                                        // validate configuration

        // CHECK AND CHOOSING DESTINATION
        if (destinationNumber == 0) { destination = destination0; }
        else if (destinationNumber == 1) { destination = destination1; }
        else if (destinationNumber == 2) { destination = destination2; }

        // CHECK AND CHOOSING TOKEN ADDRESS
        if (tokenvalue > 0 && ethvalue == 0 && setTokenAddress == 0) {          // check for token Tx        
            TokenAddressBook tok1 = TokenAddressBook(this);
            tokenAddress = tok1.get(tokenNumber);                               // choosing tokenAddress by tokenNumber
        }
        
        // NONCE
        nonce = nonce + 1;                                                      // count nonce to avoid multiple executions

        // SENDING Tx
        if (tokenvalue == 0 && ethvalue > 0 && setTokenAddress == 0) {          // verify tokenvalue == 0 and ethvalue > 0 and no tokenAddressset for ETH Tx
            require(destination.call.value(ethvalue)(0x0));                          // send ETH Tx, throws if not successfull
        } 

        if (tokenvalue > 0 && ethvalue == 0 && setTokenAddress == 0) {          // verify tokenvalue > 0 and ethvalue == 0 and no tokenAddressset for Token Tx
            TokenTransfer tok2 = TokenTransfer(tokenAddress);
            require(tok2.transfer(destination, tokenvalue));                    // send Token Tx,
        }

        // SET TOKENADDRESS
        require (tokenAddressCounter < 256);                                    // check max. no of contracts in tokenAddressbook, uint8
        if (tokenvalue == 0 && ethvalue == 0 && setTokenAddress == 1) {         // verify tokenvalue == 0 and ethvalue == 0 and tokenAddressset set for tokenAddressInit
            TokenAddressBook tok3 = TokenAddressBook(this);
            tok3.set(tokenAddressCounter, tokenAddressInit);                    // set new tokenAddress 
            tokenAddressCounter = tokenAddressCounter++;                        // count tokenAddressCounter for next setting                       
        } 
    }

    function () public payable {}     

}