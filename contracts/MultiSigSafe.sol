pragma solidity 0.4.18;

contract MultiSigSafe {
    
    // INITIALIZING OWNERS
    address constant public owner0 = 0x627306090abaB3A6e1400e9345bC60c78a8BEf57; //address of owner0
    address constant public owner1 = 0xf17f52151EbEF6C7334FAD080c5704D77216b732; //address of owner1
    address constant public owner2 = 0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef; //address of owner2

    // INITIALIZING DESTINATIONS
    address constant public destination0 = 0x821aEa9a577a9b44299B9c15c88cf3087F3b5544; //address of destination wallet0
    address constant public destination1 = 0x0d1d4e623D10F9FBA5Db95830F7d3839406C6AF2; //address of destination wallet1
    address constant public destination2 = 0x2932b7A2355D6fecc4b5c0B6BD44cC31df247a2e; //address of destination wallet2

    // INITIALIZING TOKENS
    address constant public token0 = 0x821aEa9a577a9b44299B9c15c88cf3087F3b5544; //address of token0
    address constant public token1 = 0x0d1d4e623D10F9FBA5Db95830F7d3839406C6AF2; //address of token1
    address constant public token2 = 0x2932b7A2355D6fecc4b5c0B6BD44cC31df247a2e; //address of token2

    // INITIALIZING GLOBAL PUBLIC VARIABLES
    uint8 constant public threshold = 2;            // Number of valid signatures for executing Tx
    uint256 constant public ethlimit = 1000*10**18; // Limit of one ETH Tx
    uint256 constant public tokenlimit = 1000;      // Limit of one Token Tx
    uint256 public nonce;                           // to prevent multiple Tx executions

// --> start debug
    event LogUint8(string message, uint8 _uint8);
    event LogBytes32(string message, bytes32 _bytes32);
    event LogUint256(string message, uint256 _uint256);
    event LogBytes(string message, bytes _bytes);
    event LogAddress(string message, address _address);
// --> end debug

    function execute(uint8[] sigV, bytes32[] sigR, bytes32[] sigS, uint8 destinationNumber, uint256 value, bytes data) public {
 
 // --> start debug
        LogAddress('Multisig Address', this);
        LogUint8('sigV0', sigV[0]);
        LogUint8('sigV1', sigV[1]);
        LogUint8('sigV2', sigV[2]);
        LogBytes32('sigR0', sigR[0]);
        LogBytes32('sigR1', sigR[1]);
        LogBytes32('sigR2', sigR[2]);
        LogBytes32('sigS0', sigS[0]);
        LogBytes32('sigS1', sigS[1]);
        LogBytes32('sigS2', sigS[2]);
        LogUint8('destN', destinationNumber);
        LogUint256('value', value);
        LogBytes('data', data);
// --> end debug
 
        // VALIDATE INPUTS
        require(value <= ethlimit);         // check value within limits
        require(destinationNumber <= 2);    // check destinationNumber within limits
        require(sigV.length == 3 && sigR.length == 3 && sigS.length == 3);
        require(data.length == 2)
        require(data[0]<=2);
        require(data[1]<=tokenlimit)

        // INITIALIZING LOCAL VARIABLES
        address destination = this;         // init destination, walletaddress
        address tokendestination = this;    // init destination, walletaddress
        uint8 recovered = 0;                // init recovered
        uint8 tokenNumber = data[0];        // init tokenNumber

        // CHECK AND CHOOSING DESTINATION
        if (destinationNumber == 0) { destination = destination0; }
        else if (destinationNumber == 1) { destination = destination1; }
        else if (destinationNumber == 2) { destination = destination2; }

        LogAddress('Destination: ', destination);

        // CHECK AND CHOOSING TOKEN
        if (tokenNumber == 0) { tokendestination = token0; }
        else if (tokenNumber == 1) { tokendestination = token1; }
        else if (tokenNumber == 2) { tokendestination = token2; }

        LogAddress('TokenDestination: ', tokendestination);

        // VERIFYING OWNERS
        // Follows ERC191 signature scheme: https://github.com/ethereum/EIPs/issues/191
        bytes32 txHash = keccak256(byte(0x19), byte(0), this, destination, value, data, nonce); // calculate txHash
        LogBytes32('txHash', txHash);

        if (owner0 == ecrecover(txHash, sigV[0], sigR[0], sigS[0])) recovered = recovered + 1; // count recovered if signature of owner0 is valid         
        if (owner1 == ecrecover(txHash, sigV[1], sigR[1], sigS[1])) recovered = recovered + 1; // count recovered if signature of owner1 is valid
        if (owner2 == ecrecover(txHash, sigV[2], sigR[2], sigS[2])) recovered = recovered + 1; // count recovered if signature of owner2 is valid
  
        LogUint8('recovered', recovered);      

        // VALIDATE CONFIGURATION
        require(recovered >= threshold);    // validate configuration

        // NONCE
        nonce = nonce + 1;                  // count nonce to avoid multiple Tx executions

        // SENDING Tx
        if data[1] == 0 (require(destination.call.value(value)(data)));                     // send ETH Tx, throws if not successfull
        if data[1] > 0 (require(tokendestination.call.transfer(destination,data[2])));      // send Token Tx, throws if not successfull
           
    }

    function () public payable {}     

}