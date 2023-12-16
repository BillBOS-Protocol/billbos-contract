// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBillBOSAdaptor {
    function stake(uint256 amount) external;
    function unstake(address receiver, uint256 amount) external;
    function claimReward(address recevier, uint256 amount) external;
}
