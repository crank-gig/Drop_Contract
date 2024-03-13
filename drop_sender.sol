// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;



import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";



contract TrustedSenderV1 is UUPSUpgradeable{
	uint256 private constant FEE_PERCENT = 2;

	event SentToRecipient(
    	address indexed sender, 
    	address indexed recipient, 
    	uint256 amount, 
    	uint256 fee
	);


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




	/*
		Utility Functionalities
	*/


	function _authorizeUpgrade(address) internal override {


		//retrieving necessary data from the proxy contract
    	(bool success, bytes memory data) = msg.sender.call(abi.encodeWithSignature("getUpgradeDetails()"));
        require(success, "External call failed");

		// Decode the returned data to get the values
        (uint256 upgradeIdValue, bool upgradeStatusValue, uint256 requiredConfirmationsValue) = abi.decode(data, (uint256, bool, uint256));

		
    	//requires that the upgradeChecker of the proxy is true; 	
		//which means the upgrade hasn't ended
		require(upgradeStatusValue, "No upgrade in process");
		//require(proxyContract.transactions(upgradeId).confirmations >= requiredConfirmationsValue, "Not enough confirmations");

		// Toggles the upgrade status back to off
		//proxyAddress.shutUpgrade();
	}



	/*
		function isOwnerFromProxy(address potentialOwner) 
			external 
			view 
			returns (bool) 
		{
			TrustedSenderProxy proxyContract = TrustedSenderProxy(proxyAddress);
			return proxyContract.isOwner(potentialOwner);

		}
	*/

}
