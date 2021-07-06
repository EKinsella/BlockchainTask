// SPDX-License-Identifier: MIT
pragma solidity >0.5.3;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
  //add minter variable
  address public minter;

  //add minter changed event
  event MinterChangedEvent(address indexed from, address to);

  constructor() public payable ERC20("D.B.C.", "DBC") {
    //assign initial minter
    minter = msg.sender;
  }

  //Add pass minter role function
  function passMinterRole(address dBank) public returns (bool)
  {
    require(msg.sender ==  minter, 'Error');
    minter = dBank;

    event MinterChangedEvent(msg.sender, dBank);
    return true;
  }

  function mint(address account, uint256 amount) public {
    //check if msg.sender have minter role
    require(msg.sender == minter);
		_mint(account, amount);
	}
}