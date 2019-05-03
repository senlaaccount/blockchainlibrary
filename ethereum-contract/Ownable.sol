pragma solidity ^0.5.1;


contract Ownable 
{
    address private candidate;
    address public owner;
    
    mapping(address => bool) public admins;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
	
    modifier onlyAdmin {
        require(msg.sender == owner || admins[msg.sender]);
        _;
    }
	
    constructor () public 
	{
        owner = msg.sender;
    }

    function changeOwner(address newOwner) public 
	{
        require(msg.sender == owner);
        candidate = newOwner;
    }
    
    function confirmOwner() public 
	{
        require(candidate == msg.sender); 
        owner = candidate;
    }
	
    function addAdmin(address addr) external 
	{
        require(msg.sender == owner);
        admins[addr] = true;
    }

    function removeAdmin(address addr) external
	{
        require(msg.sender == owner);
        admins[addr] = false;
    }
}
