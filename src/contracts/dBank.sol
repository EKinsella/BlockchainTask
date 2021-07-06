// SPDX-License-Identifier: MIT
pragma solidity >0.5.3;

import "./Token.sol";

contract dBank {

  //assign Token contract to variable
  Token private token;

  //add mappings
  mapping(address => uint) public depositTimeStart;
  mapping(address => uint) public etherBalanceOfAccount;
  mapping(address => uint) public collateral;
  mapping(address => bool) public isDepositedFunds;
  mapping(address => bool) public hasActiveLoan;

  //add events
  event Deposit(address indexed user, uint etherAmount, uint hodlingTime);
  event Withdraw(address indexed user, uint etherAmount, uint hodlingTime, uint interest);
  event Borrow(address indexed user, uint collateralAmount, uint borrowedAmount);
  event Payoff(address indexed user, uint fee);
  //pass as constructor argument deployed Token contract
  constructor() public {
    //assign token deployed contract to variable
    token = _token;
  }

  function deposit() payable public {
    //check if msg.sender didn't already deposited funds
    require(isDepositedFunds[msg.sender] == false, 'Error');
    //check if msg.value is >= than 0.01 ETH
    require(msg.value>= 0.01, 'Error');
    //increase msg.sender ether deposit balance
    etherBalanceOfAccount[msg.sender] = etherBalanceOfAccount[msg.sender] + msg.value;
    //start msg.sender hodling time
    depositTimeStart[msg.sender] = depositTimeStart[msg.sender] + block.timestamp;
    //set msg.sender deposit status to true
    isDepositedFunds[msg.sender] = true;
    //emit Deposit event
    emit Deposit(msg.sender, msg.value, block.timestamp);
  }

  function withdraw() public {
    //check if msg.sender deposit status is true
    require(isDepositedFunds[msg.sender] == true, 'Error');
    //assign msg.sender ether deposit balance to variable for event
    //msg.sender = etherBalanceOfAccount[msg.sender];
    uint depositBalance = etherBalanceOfAccount[msg.sender];
    //check user's hodl time
    uint hodlTime = block.timestamp - depositTimeStart[msg.sender];

    //calc interest per second
    uint interestPerSecond = 60 * (etherBalanceOfAccount[msg.sender] /.01 );
    //calc accrued interest
    uint accruedInterest = interestPerSecond * hodlTime;
    //send eth to user
    msg.sender.transfer(etherBalanceOfAccount[msg.sender]);
    //send interest in tokens to user
    token.mint(msg.sender, accruedInterest);
    //reset depositer data
    depositTimeStart[msg.sender] = 0;
    //emit event
    emit Withdraw(msg.sender, depositBalance, hodlTime, accruedInterest);
  }

  function borrow() payable public {
    //check if collateral is >= than 0.01 ETH
    require(msg.data >= 0.01);
    //check if user doesn't have active loan
    require(hasActiveLoan[msg.sender] == true);
    //add msg.value to ether collateral
    collateral[msg.sender] = collateral[msg.sender] + msg.value;
    //calc tokens amount to mint, 50% of msg.value
    uint tokensAmountToMint = collateral[msg.sender] * 0.5;
    //mint&send tokens to user
    token.mint(msg.sender, tokensAmountToMint);
    //activate borrower's loan status
    hasActiveLoan[msg.sender] = true;
    //emit event
    emit Borrow(msg.sender, collateral[msg.sender], tokensAmountToMint);
  }

  function payOff() public {
    //check if loan is active
    require(hasActiveLoan[msg.sender] == true);
    //transfer tokens from user back to the contract
    require(token.transfer(msg.sender, address(this)));
    //calc fee
    uint fee = collateral[msg.sender] * .01;
    //send user's collateral minus fee
    msg.sender.transfer(collateralAmount[msg.sender] - fee);
    //reset borrower's data
    collateral[msg.sender] = 0;

    //emit event
    emit Payoff(msg.sender, fee);
  }
}