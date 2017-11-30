pragma solidity 0.4.18;

import './SafeMath.sol';
import './ERC20Token.sol';

// This contract is only used for testing purposes.

contract TestToken is ERC20Token {

    using SafeMath for uint256;

    uint256 totalSupply;
    
    event Mint(address indexed to, uint256 amount);

    /**
    * @dev Function to mint tokens
    * @param _to The address that will receive the minted tokens.
    * @param _amount The amount of tokens to mint.
    * @return A boolean that indicates if the operation was successful.
    */
    function mint(address _to, uint256 _amount) public returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }

}
