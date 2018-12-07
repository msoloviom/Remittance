pragma solidity ^0.4.24;

contract Owned {
    address public owner;
    
    event LogChangeOwner(address owner, address newOwner);
    
    constructor() public {
        owner = msg.sender;   
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    } 

    function changeOwner(address newOwner) public onlyOwner returns (bool success) {
        owner = newOwner;
        emit LogChangeOwner(msg.sender, newOwner);
        return true;
    }
    
}