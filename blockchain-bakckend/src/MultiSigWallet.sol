//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
/** 
The wallet owners can

submit a transaction
approve and revoke approval of pending transcations
anyone can execute a transcation after enough owners has approved it.

*/
contract MultiSigWallet {
 event Deposit(address indexed sender, uint amount,uint balance);
 event SubmitTx(address indexed owner, uint indexed txIndex,address indexed to,uint value,bytes data);
 event ConfirmTX(address indexed owner, uint indexed txIndex);
 event Revoke(address indexed owner, uint indexed txIndex);
 event ExecuteTrx(address indexed owner, uint indexed txindex);

 struct Transaction {
  address to;
  uint value;
  bytes data;
  bool executed;
  uint numConfirmations;
 }

 address[] public owners;
 mapping(address => bool) public isOwner;
 uint public numConfirmationsRequired;
// mapping from tx index => owner => bool
    mapping(uint => mapping(address => bool)) public isConfirmed;

    Transaction[] public transactions;
    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier txExists(uint _txIndex) {
        require(_txIndex< transactions.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _;
    }
 constructor(address[] memory _owners, uint _numConfirmationsRequired){
  require(_owners.length > 0, "owners must be greater han zero");
  require(_numConfirmationsRequired > 0 && _numConfirmationsRequired <= _owners.length, "invlid number required confirmations");

  for(uint i =0; i < _owners.length; i++){
   address owner = _owners[i];
   require(owner != address(0));
   require(!isOwner[owner], "owner not unique");
   owners.push(owner);
  }

 numConfirmationsRequired = _numConfirmationsRequired;
 }

  receive() external payable {
   emit Deposit(msg.sender, msg.value, address(this).balance);
  }

 function submitTransaction(address _to, uint _value, bytes memory _data) public onlyOwner{
  uint txIndex = transactions.length;
  Transaction storage txx = transactions[txIndex];
  (txx.to, txx.value, txx.data, txx.executed, txx.numConfirmations) = (_to, _value, _data, false, 0);
  transactions.push(txx);
 
 emit SubmitTx(msg.sender, txIndex, _to, _value, _data);
 }

 function confirmTransac(uint _txIndex) public onlyOwnertxExists(_txIndex) notExecuted(_txIndex) notConfirmed(_txIndex){
  Transaction storage txx = transactions[_txIndex];
  txx.numConfirmations += 1;
  isConfirmed[_txIndex][msg.sender] = true;

  emit ConfirmTX(msg.sender, _txIndex);
 }
}