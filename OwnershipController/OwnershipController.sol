// SPDX-License-Identifier: MIT
// Telegram: https://t.me/ChubbyShibaBSC

pragma solidity ^0.8.0;

import "AccessControl.sol";
import "Ownable.sol";

// Dummy contract for interface with onlyOwner functions
interface IChubbyShiba {

	function excludeFromReward(address account) external;

	function includeInReward(address account) external;
	
	function excludeFromFee(address account) external;
	
	function includeInFee(address account) external;
	
	function setTaxFeePercent(uint256 taxFee) external;
	
	function setLiquidityFeePercent(uint256 liquidityFee) external;

	function setSwapAndLiquifyEnabled(bool _enabled) external;

	function setMaxTxPercent(uint256 maxTxPercent) external;

	function renounceOwnership() external;
}

// Basic BEP20 interface with transfer
interface IBEP20 {
	function transfer(address recipient, uint256 amount) external;
}

// Contract to hold ownership of ChubbyShiba
contract OwnershipController is AccessControl, Ownable {
	bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

	/**
	 * @dev Initializes the contract
	 */
	constructor() {
		_setRoleAdmin(EXECUTOR_ROLE, EXECUTOR_ROLE);

		// deployer + self administration
		_setupRole(EXECUTOR_ROLE, _msgSender());
		_setupRole(EXECUTOR_ROLE, address(this));
	}

	/**
	 * @dev Contract might receive/hold BNB
	 */
	receive() external payable {}

	// Withdraw BNB
	function withdraw(uint amount) public virtual onlyRole(EXECUTOR_ROLE) {
		require(amount <= address(this).balance);
		payable(owner()).transfer(amount);
	}

	// Transfer BEP20 tokens from the address
	function transferTokens(address token, uint256 amount) public virtual onlyRole(EXECUTOR_ROLE) {
		IBEP20(token).transfer(owner(), amount);
	}

	// Call excludeFromReward on target contract
	function excludeFromReward(address target, address account) public virtual onlyRole(EXECUTOR_ROLE) {
		IChubbyShiba(target).excludeFromFee(account);
	}

	// Call includeInReward on target contract
	function includeInReward(address target, address account) public virtual onlyRole(EXECUTOR_ROLE) {
		IChubbyShiba(target).includeInReward(account);
	}
	
	// Call excludeFromFee on target contract
	function excludeFromFee(address target, address account) public virtual onlyRole(EXECUTOR_ROLE) {
		IChubbyShiba(target).excludeFromFee(account);
	}
	
	// Call includeInFee on target contract
	function includeInFee(address target, address account) public virtual onlyRole(EXECUTOR_ROLE) {
		IChubbyShiba(target).includeInFee(account);
	}
	
	// Call setTaxFeePercent on target contract with maximum value of 10
	function setTaxFeePercent(address target, uint256 taxFee) public virtual onlyRole(EXECUTOR_ROLE) {
		require(taxFee <= 10, "OwnershipController: taxFee must be less than or equal to 10");
		IChubbyShiba(target).setTaxFeePercent(taxFee);
	}
	
	// Call setLiquidityFeePercent on target contract with maximum value of 10
	function setLiquidityFeePercent(address target, uint256 liquidityFee) public virtual onlyRole(EXECUTOR_ROLE) {
		require(liquidityFee <= 10, "OwnershipController: liquidityFee must be less than or equal to 10");
		IChubbyShiba(target).setLiquidityFeePercent(liquidityFee);
	}

	// Call setSwapAndLiquifyEnabled on target contract
	function setSwapAndLiquifyEnabled(address target, bool _enabled) public virtual onlyRole(EXECUTOR_ROLE) {
		IChubbyShiba(target).setSwapAndLiquifyEnabled(_enabled);
	}

	// Call setMaxTxPercent on target contract with minimum value of 1
	function setMaxTxPercent(address target, uint256 maxTxPercent) public virtual onlyRole(EXECUTOR_ROLE) {
		require(maxTxPercent > 0, "OwnershipController: maxTxPercent must be greater than 0");
		IChubbyShiba(target).setMaxTxPercent(maxTxPercent);
	}

	// Call renounceOwnership on targetContract
	function renounceTargetOwnership(address target) public virtual onlyRole(EXECUTOR_ROLE) {
		IChubbyShiba(target).renounceOwnership();
	}
}