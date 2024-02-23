# TrustedSender Contract System

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

The TrustedSender contract system consists of two contracts: TrustedSenderV1 and TrustedSenderProxy. These contracts work together to enable secure and efficient Ether transactions with a fee deduction mechanism, along with providing multi-signature functionality for contract upgrades.

## TrustedSenderV1 Contract

The `TrustedSenderV1` contract is an upgradeable contract that facilitates sending Ether with a fee deducted and allows for contract upgrades via a multi-signature mechanism.

### Features

- Send Ether with a fee to a recipient address
- Multi-signature mechanism for contract upgrades
- Upgradeable via the UUPS pattern
- Emit events for sent transactions

### Dependencies

- OpenZeppelin Contracts: `UUPSUpgradeable.sol`
- MultiSigAdmin.sol (not provided)

### Usage

The contract provides the following functions:

- `sendToRecipient(address recipient) external payable`: Sends Ether with a fee deducted to the specified recipient address.
- `submitUpgrade(address newLogicContractAddress) external`: Submits a contract upgrade proposal.
- `setProxyAddress(address newProxyAddress) external`: Sets the proxy address for contract upgrades.
- `returnAmount() external view returns(uint256 check)`: Returns the amount variable value.

### License

This contract is licensed under the MIT License.

---

## TrustedSenderProxy Contract

The `TrustedSenderProxy` contract is an upgradeable proxy contract that facilitates withdrawing Ether to the owner's address.

### Features

- Withdraw Ether to the owner's address
- Implements an upgradeable proxy pattern
- Emit events for withdrawal transactions

### Dependencies

- OpenZeppelin Contracts: `ERC1967Proxy.sol`

### Usage

The contract provides the following functions:

- `withdrawBalanceToOwner() external`: Withdraws the entire balance to the owner's address.
- `executeWithdrawal(address recipient, uint256 amount) internal`: Executes the withdrawal transaction.
- `checkOwner() external`: Checks if the caller is the owner.
- `checkConfirmations() external`: Checks the confirmation amount.

### License

This contract is licensed under the MIT License.
