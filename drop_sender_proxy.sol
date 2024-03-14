// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;


import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "./MultiSigAdmin.sol";


contract TrustedSenderProxy is MultiSigAdmin,ERC1967Proxy {

	uint256 private upgradeId;
	bool public upgradeStatus;


	constructor(
    	address logic,
    	bytes memory data,
		address[] memory owners, 
		uint256 required
	)
    	ERC1967Proxy(logic, data)
		MultiSigAdmin(owners, required)
	{
    	//This constructor is intentionally left empty for ERC1967Proxy pattern.
	}

	receive() external payable {
    	revert("Fallback function not allowed");
	}

	function shutUpgrade()
    	external
	{
    	// Toggles the upgrade status back to off
    	upgradeStatus = false;
	}

	function submitUpgrade(address newLogicContractAddress)
    	external
    	_onlyOwner
    	returns (uint256 transactionId)
	{
    	// Encode the function call data for the submitTransaction function
    	bytes memory data = abi.encodeWithSignature(
        	"upgradeTo(address)",
        	newLogicContractAddress
    	);
    	transactionId = _submitTransaction(
        	_implementation(),
        	0,
        	data
    	);
    	// To keep track of the upgrade transaction Id in the future
		upgradeId = transactionId;
		upgradeStatus = true;
	}

	function submitAdminWithdrawal() 
		external
		_onlyOwner
		returns(uint256 transactionId)
	{

    	// Specify the destination address (msg.sender in this case)
    	address destination = msg.sender;

    	// Specify the amount to withdraw (entire balance)
    	uint256 value = address(this).balance;

    	require(value > 0, "No balance to withdraw");

    	// Encode the function call data for the submitTransaction function
    	bytes memory data = abi.encodeWithSignature(
        	"executeAdminWithdrawal(address, uint256)",
        	destination,
        	value
    	);
    	transactionId = _submitTransaction(
        	address(this),
        	0,
        	data
    	);

	}

	function executeAdminWithdrawal(address recipient, uint256 amount)
    	internal 
	{
    	(bool success, ) = recipient.call{value: amount}("");
    	require(success, "Failed to send Ether");

    	// Optionally emit an event indicating the withdrawal
    	// emit Withdrawal(msg.sender, balance);
	}


	/**
		getter functions
	**/
    // Getter function to retrieve the values of upgrade details for the implementation contract
    function getUpgradeDetails() external view returns (uint256, bool, uint256) {
        return (upgradeId, upgradeStatus, requiredConfirmations);
    }

    function getConfirmationCount(uint256 transactionId) external view returns (uint256) {
		return transactions[transactionId].confirmations;
    }

}
