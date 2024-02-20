// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract TrustedSenderProxy is ERC1967Proxy {

	constructor(
    	address logic,
    	bytes memory data
	)
    	ERC1967Proxy(logic, data)
	{
    	//This constructor is intentionally left empty for ERC1967Proxy pattern.
	}

	receive() external payable {
    	revert("Fallback function not allowed");
	}

	function withdrawBalanceToOwner() external {

    	// Perform a delegate call to the Impementation to verify caller's authority
    	bytes memory ownerData = abi.encodeWithSignature(
        	"isOwnerFromProxy(address)",
        	msg.sender
    	);
    	(, bytes memory statusData) = _implementation().delegatecall(ownerData);
    	(bool result) = abi.decode(statusData, (bool));
    	require(result, "You are not authorized to call this function");

    	// Specify the destination address (msg.sender in this case)
    	address destination = msg.sender;

    	// Specify the amount to withdraw (entire balance)
    	uint256 value = address(this).balance;

    	require(value > 0, "No balance to withdraw");

    	// Encode the function call data for the submitTransaction function
    	bytes memory proxyData = abi.encodeWithSignature(
        	"executeWithdrawal(address, uint256)",
        	destination,
        	value
    	);
    	bytes memory delegateData = abi.encodeWithSignature(
        	"_submitTransaction(address,uint256,bytes)",
        	address(this),
        	0,
        	proxyData
    	);

    	// Perform a delegate call to the Implementation submitTransaction function
    	(bool success, ) = _implementation().delegatecall(delegateData);

    	require(success, "Delegatecall to implementation contract failed");
	}

	function executeWithdrawal(address recipient, uint256 amount)
    	internal 
	{
    	(bool success, ) = recipient.call{value: amount}("");
    	require(success, "Failed to send Ether");

    	// Optionally emit an event indicating the withdrawal
    	// emit Withdrawal(msg.sender, balance);
	}
}
