// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "AccessControl.sol";
import "Ownable.sol";

// Dummy contract for interface
interface IChubbyShiba {

	function excludeFromReward(address account) external;

	function includeInReward(address account) external;
	
	function excludeFromFee(address account) external;
	
	function includeInFee(address account) external;
	
	function setTaxFeePercent(uint256 taxFee) external;
	
	function setLiquidityFeePercent(uint256 liquidityFee) external;

	function setSwapAndLiquifyEnabled(bool _enabled) external;

	function renounceOwnership() external;
}

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

	function transferTokens(address target, uint256 amount) public virtual onlyRole(EXECUTOR_ROLE) {
		IBEP20(target).transfer(owner(), amount);
	}

	function excludeFromReward(address target, address account) public virtual onlyRole(EXECUTOR_ROLE) {
		IChubbyShiba(target).excludeFromFee(account);
	}

	function includeInReward(address target, address account) public virtual onlyRole(EXECUTOR_ROLE) {
		IChubbyShiba(target).includeInReward(account);
	}
	
	function excludeFromFee(address target, address account) public virtual onlyRole(EXECUTOR_ROLE) {
		IChubbyShiba(target).excludeFromFee(account);
	}
	
	function includeInFee(address target, address account) public virtual onlyRole(EXECUTOR_ROLE) {
		IChubbyShiba(target).includeInFee(account);
	}
	
	function setTaxFeePercent(address target, uint256 taxFee) public virtual onlyRole(EXECUTOR_ROLE) {
		require(taxFee <= 10, "OwnershipController: taxFee must be less than or equal to 10");
		IChubbyShiba(target).setTaxFeePercent(taxFee);
	}
	
	function setLiquidityFeePercent(address target, uint256 liquidityFee) public virtual onlyRole(EXECUTOR_ROLE) {
		require(liquidityFee <= 10, "OwnershipController: liquidityFee must be less than or equal to 10");
		IChubbyShiba(target).setLiquidityFeePercent(liquidityFee);
	}

	function setSwapAndLiquifyEnabled(address target, bool _enabled) public onlyRole(EXECUTOR_ROLE) {
		IChubbyShiba(target).setSwapAndLiquifyEnabled(_enabled);
	}

	function renounceTargetOwnership(address target) public virtual onlyRole(EXECUTOR_ROLE) {
		IChubbyShiba(target).renounceOwnership();
	}
}