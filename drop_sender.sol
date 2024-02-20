// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;


import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "./MultiSigAdmin.sol";

contract TrustedSenderV1 is MultiSigAdmin,UUPSUpgradeable{
	uint256 private constant FEE_PERCENT = 2;

	event SentToRecipient(
    	address indexed sender, 
    	address indexed recipient, 
    	uint256 amount, 
    	uint256 fee
	);

	constructor(address[] memory owners, uint256 required)
    	MultiSigAdmin(owners, required)
	{
    	// Additional constructor logic for TrustedSenderV1, if needed
	}


	function _authorizeUpgrade(address) internal override _onlyOwner {
    	//Additional authorize upgrade logic, if needed
	}

	receive() external payable {
    	revert("Fallback function not allowed");
	}

	function sendToRecipient(address recipient) external payable {
    	require(recipient != address(0), "Invalid recipient address");
    	require(msg.value > 0, "Invalid value");

    	uint256 fee = (msg.value * FEE_PERCENT) / 100;
    	uint256 amountToSend = msg.value - fee;

    	(bool sent, ) = recipient.call{value: amountToSend}("");
    	require(sent, "Failed to send Ether to recipient");

    	emit SentToRecipient(msg.sender, recipient, amountToSend, fee);
	}


	function isOwnerFromProxy(address potentialOwner) external view returns (bool) {
    	return isOwner[potentialOwner];
	}

	function submitUpgrade(address newLogicContractAddress)
    	external
    	_onlyOwner
    	returns (uint256 transactionId)
	{
    	transactionId = transactionCount;
    	transactions[transactionId] = Transaction({
        	destination: address(this),
        	value: 0,
        	data: abi.encodeWithSignature("upgrade(address,uint256)", newLogicContractAddress, transactionId),
        	executed: false,
        	confirmations: 1
    	});
    	transactionCount++;
    	isConfirmed[transactionId][msg.sender] = true;
    	emit Confirmation(msg.sender);
	}

	function upgrade(address newLogicContractAddress, uint256 transactionId)
    	internal
	{
    	require(
        	!transactions[transactionId].executed,
        	"Transaction already executed"
    	);

    	// Perform upgrade logic here
    	(bool success, ) = proxyAddress.delegatecall(abi.encodeWithSignature("upgradeTo(address)", newLogicContractAddress));

    	if (success) {
        	transactions[transactionId].executed = true;
        	emit Execution(msg.sender, true);
    	} else {
        	// Handle the case where delegatecall failed
        	// You might revert, log an error, or take other appropriate actions
        	revert("Delegatecall failed");
    	}
	}

	function setProxyAddress(address newProxyAddress)
    	external
    	_onlyOwner
    	returns (uint256 transactionId)
	{
    	transactionId = transactionCount;
    	transactions[transactionId] = Transaction({
        	destination: address(this),
        	value: 0,
        	data: abi.encodeWithSignature("executeSetProxyAddress(address,uint256)", newProxyAddress, transactionId),
        	executed: false,
        	confirmations: 1
    	});
    	transactionCount++;
    	isConfirmed[transactionId][msg.sender] = true;
    	emit Confirmation(msg.sender);

    	if (transactions[transactionId].confirmations >= requiredConfirmations) {
        	executeTransaction(transactionId);
    	}

    	return transactionId;
	}

	function executeSetProxyAddress(address newProxyAddress, uint256 transactionId)
    	internal
	{
    	require(
        	!transactions[transactionId].executed,
        	"Transaction already executed"
    	);

    	// Perform the logic to set the proxy address
    	proxyAddress = newProxyAddress;

    	transactions[transactionId].executed = true;
    	emit Execution(msg.sender, true);
	}
}
