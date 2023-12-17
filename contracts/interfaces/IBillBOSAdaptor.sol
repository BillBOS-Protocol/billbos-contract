// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IBillBOSAdaptor {
    function setBillBOS(address _newBillBOS) external;

    function stake(uint256 _amount) external;

    function unstake(uint256 _amount) external;

    function getStakedBalance() external view returns (uint256);
}