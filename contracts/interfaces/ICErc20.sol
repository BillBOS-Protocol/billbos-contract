// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface ICErc20 {
    function mint(uint256 mintAmount) external returns (uint);

    function redeemUnderlying(uint redeemAmount) external returns (uint);

    function balanceOfUnderlying(address owner) external view returns (uint256);
}
