// SPDX-License-Identifier: MIT
// File: contracts/SimpleEscrows.sol



pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

/**
 * @title SimpleEscrow
 * @dev Create basic Escrow contracts:
 Basic Use-Case:
 Funder creates Escrow contract:
    - Funder pays specific amount (value to be transfered)
    - Funder specifies Agent (Address of Account on Network)
    - Funder specifies Receiver (Address of Account on Network
The Agent can release the transaction money (in a real life situation, when a earlier specified 
condition is met e.g. Arrival of goods at warehouse of funder
The money is transfered to the Receivers account.
The Agent receives the transaction costs back to his account
 */

contract SimpleEscrows{
    uint256 id;
    address owner;
    struct Escrow{
        address payable funder;
        address payable agent;
        address payable receiver;
        uint256 balance;
        uint256 deployment_time;
        bool open;
    }
    mapping (uint256 => Escrow) Escrows;
    uint256[] used_ids;

     constructor(){
        owner = msg.sender;
        id = 1;
     }

    //  modifier AgentOnly(uint _id){
    //       Escrow memory escrow = getEscrow(_id);
    //       require(msg.sender==escrow.agent && escrow.open);
    //      _;
    //  }
     
     function CreateEscrow(
          address payable funder, address payable agent,
           address payable receiver)
      payable public{
        Escrow memory escrow;
        escrow = Escrow(funder,agent,receiver,msg.value,block.timestamp,true);
        Escrows[id] = escrow;
        used_ids.push(id);
        id++;
        //increment the number of all 3 addresses in the storage address=>numbercontracts mapping
     }

     function getEscrow(uint256 _id) internal view returns(Escrow storage){ // make internal, change to hash!!
         return Escrows[_id];
     }
    function showEscrow(uint256 _id) public view returns(Escrow memory){ // change to hash!
         return Escrows[_id];
     }
     function getEscrowBalance(uint256 _id) public view returns(uint256){
         //change to hash, adjust for Agent Compensation
         return Escrows[_id].balance;
     }
     
     function getLastEscrows(uint length) public view returns(Escrow[] memory){
        //not optimal if the length is to high returns empty escrows - fix by shrinking arrays (if not to expensive) 
         require(length>0);
                 if (length > used_ids.length){
            length=used_ids.length;
        }
        Escrow[] memory escrows = new Escrow[] (length); 
         address sender = msg.sender;
            uint current_index = 0;
         for (uint256 i=used_ids.length; i>0; i--){ // This looks retarded, but it is not, i>=0 does not work bc Integer Loopback!!!
             Escrow memory escrow = Escrows[used_ids[i-1]];
             if (sender==escrow.funder || sender==escrow.agent || sender==escrow.receiver){
                 escrows[current_index] = escrow;
                 current_index++;
                 if (current_index==length){
                     break;
                 }
             }}
        
        return escrows;
     }
    function getLastOpenEscrows(uint length) public view returns(Escrow[] memory){
        //not optimal if the length is to high returns empty escrows - fix by shrinking arrays (if not to expensive) 
        require(length>0);
        if (length > used_ids.length){
            length=used_ids.length;
        }
        Escrow[] memory escrows = new Escrow[] (length); 
         address sender = msg.sender;
            uint current_index = 0;
         for (uint256 i=used_ids.length; i>0; i--){ // This looks retarded, but it is not, i>=0 does not work bc Integer Loopback!!!
             Escrow memory escrow = Escrows[used_ids[i-1]];
             if ( (escrow.open==true) && (sender==escrow.funder || sender==escrow.agent || sender==escrow.receiver)){
                 escrows[current_index] = escrow;
                 current_index++;
                 if (current_index==length){
                     break;
                 }
             }}
        // if there is no open Escrow an array with empty escrows of the specified 
        //length will be returned -> this might not be optimal...
        return escrows;
     }

     function release(uint _id) public returns(bool success){ //replace id with hash later on
         // not using AgentOnly for performance - otherwise had to initialise other Escrow
         success=false; 
         Escrow storage escrow = getEscrow(_id);
         require(msg.sender==escrow.agent && escrow.open);
         escrow.receiver.transfer(escrow.balance);
         escrow.balance=0;
         escrow.open=false;
         success=true;
         return success;
     }

     function reverse(uint _id) public returns(bool success){//replace id with hash later on
         success=false; 
         Escrow storage escrow = getEscrow(_id);
         require(msg.sender==escrow.agent && escrow.open);
         escrow.funder.transfer(escrow.balance);
         escrow.balance=0;
         escrow.open=false;
         success=true;
         return success;
     }

     function dispense(uint _id, uint _value) public returns(bool success){ //replace id,hash
         success=false; 
         Escrow storage escrow = getEscrow(_id);
         require(msg.sender==escrow.receiver && escrow.open);
         if(_value>=escrow.balance){
         escrow.funder.transfer(escrow.balance);
         escrow.balance = 0;
         escrow.open=false; // Change this if there is an Agent Compensation
         success=true;
         
         }
         else{
             escrow.balance=escrow.balance-_value;
             escrow.funder.transfer(_value);
             success=true;
         }
         return success;

     }

     function raise(uint _id) public payable returns(bool success){ //replace id,hash
        success=false; 
        Escrow storage escrow = getEscrow(_id);
        require(msg.sender==escrow.funder && escrow.open);
        uint256 _value = msg.value;
         escrow.balance+=_value;
         success=true;
         return success;
 }
 
 }