// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/IBillBOSCore.sol";
import "./interfaces/IBBAdapter.sol";

contract BillBOSCore is IBillBOSCore, Ownable {
    // State
    address public billbosAdaptorAddress;
    address public stakedTokenAddress;
    address public devAddress;
    uint256 public count = 0;
    uint256 public adsIdLast = 0;
    uint256 public webpageOwnerIdLast = 0; // start from 1
    uint256 public totalStakedBalanceLast = 0;
    uint256 public totalEarningBalanceLast = 0;
    uint256 public platformBalance = 0;
    mapping(address => uint256[]) public adsId; // adsOwner -> adsId
    mapping(uint256 => AdsContent) public adsContent; // adsId -> AdsContent
    mapping(uint256 => uint256) public adsStakedBalance; // adsId -> stakedBalance
    mapping(address => uint256) public claimedRewardCount; // webpageOwner -> claimedReward
    mapping(uint256 => MonthlyResult) private monthResult; // month -> viewCount and reward
    mapping(address => uint256) private webpageOwnerId; //  webpageOwner -> webpageOwnerId

    constructor(
        address _billbosAdaptorAddress,
        address _stakedTokenAddress,
        address _devAddress
    ) Ownable(msg.sender) {
        billbosAdaptorAddress = _billbosAdaptorAddress;
        stakedTokenAddress = _stakedTokenAddress;
        devAddress = _devAddress;
    }

    // Method: Modifier
    modifier adsIdExist(uint256 _adsId) {
        require(
            _adsId <= adsIdLast,
            "BillBOSCore: ads does not exist in billbos"
        );
        _;
    }

    // Method: Getter-Setter

    function getAdsUser(
        address _adsOwner
    ) external view returns (AdsRes[] memory) {
        uint256[] memory myAdsId = adsId[_adsOwner];
        AdsRes[] memory myAds = new AdsRes[](myAdsId.length);
        for (uint256 i = 0; i < myAdsId.length; i++) {
            myAds[i] = AdsRes({
                adsId: myAdsId[i],
                adsContent: adsContent[myAdsId[i]],
                adsStakedBalance: adsStakedBalance[myAdsId[i]]
            });
        }
        return myAds;
    }

    function getReward(
        address _webpageOwner
    ) external view returns (uint256, uint256) {
        uint256 reward = _claimReward(_webpageOwner);
        return (reward, claimedRewardCount[_webpageOwner]);
    }

    function setBillbosAdaptorAddress(
        address _billbosAdaptorAddress
    ) external onlyOwner {
        billbosAdaptorAddress = _billbosAdaptorAddress;
    }

    function getActiveAds() external view returns (AdsRes[] memory) {
        AdsRes[] memory adsTemp = new AdsRes[](adsIdLast);
        uint256 activeLength = 0;
        for (uint256 i = 0; i < adsIdLast; i++) {
            if (adsStakedBalance[i] <= 0) continue;
            adsTemp[activeLength] = AdsRes({
                adsId: i,
                adsContent: adsContent[i],
                adsStakedBalance: adsStakedBalance[i]
            });
            activeLength++;
        }
        AdsRes[] memory ads = new AdsRes[](activeLength);
        for (uint256 i = 0; i < activeLength; i++) {
            ads[i] = adsTemp[i];
        }
        return ads;
    }

    function getTotalEarningPerUser(
        address _webpageOwner
    ) external view returns (uint256) {
        uint256 _count = count;
        uint256 earning = 0;
        for (uint256 i = 0; i < _count; i++) {
            MonthlyResult memory _monthResult = monthResult[i];
            if (webpageOwnerId[_webpageOwner] != 0) {
                earning +=
                    (_monthResult.reward *
                        _monthResult.viewCount[
                            webpageOwnerId[_webpageOwner] - 1
                        ]) /
                    _monthResult.totalViewCount;
                continue;
            }
            for (uint256 j = 0; j < _monthResult.webpageOwner.length; j++) {
                if (_monthResult.webpageOwner[j] == _webpageOwner) {
                    earning +=
                        (_monthResult.reward * _monthResult.viewCount[j]) /
                        _monthResult.totalViewCount;
                    break;
                }
            }
        }
        return earning;
    }

    function getCurrentEarning() external view returns (uint256) {
        return
            IBBAdapter(billbosAdaptorAddress).getStakedBalance() -
            totalStakedBalanceLast -
            totalEarningBalanceLast;
    }

    // Method: Process
    function createAds(
        AdsContent calldata _ads,
        uint256 _amount
    ) external returns (uint256) {
        require(_amount > 0, "BillBOSCore: amount must be more than 0");
        uint256 _adsIdLast = adsIdLast;
        adsId[msg.sender].push(_adsIdLast);
        adsContent[_adsIdLast] = _ads;
        _boost(_amount);
        adsStakedBalance[_adsIdLast] = _amount;
        totalStakedBalanceLast += _amount;
        adsIdLast = _adsIdLast + 1;
        return adsIdLast;
    }

    function updateAds(
        uint256 _adsId,
        AdsContent calldata _ads
    ) external adsIdExist(_adsId) {
        uint256[] memory _adsIds = adsId[msg.sender];
        for (uint256 i = 0; i < _adsIds.length; i++) {
            require(
                _adsId <= _adsIds[i],
                "BillBOSCore: ads does not found in your ads"
            );
            if (_adsId == _adsIds[i]) {
                adsContent[_adsId] = _ads;
                break;
            }
        }
    }

    function _boost(uint256 _amount) internal {
        IERC20(stakedTokenAddress).approve(billbosAdaptorAddress, _amount);
        IERC20(stakedTokenAddress).transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        IBBAdapter(billbosAdaptorAddress).stake(_amount);
    }

    function _unboost(uint256 _amount) internal {
        IBBAdapter(billbosAdaptorAddress).unstake(_amount);
        IERC20(stakedTokenAddress).transfer(msg.sender, _amount);
    }

    function boost(
        uint256 _adsId,
        uint256 _amount
    ) external adsIdExist(_adsId) {
        _boost(_amount);
        totalStakedBalanceLast += _amount;
        adsStakedBalance[_adsId] += _amount;
    }

    function unboost(
        uint256 _adsId,
        uint256 _amount
    ) external adsIdExist(_adsId) {
        require(
            adsStakedBalance[_adsId] >= _amount,
            "BillBOSCore: this ads is not enough staked balance"
        );
        _unboost(_amount);
        totalStakedBalanceLast -= _amount;
        adsStakedBalance[_adsId] -= _amount;
    }

    function unboostAll(uint256 _adsId) external adsIdExist(_adsId) {
        require(
            adsStakedBalance[_adsId] > 0,
            "BillBOSCore: this ads is not enough staked balance"
        );
        _unboost(adsStakedBalance[_adsId]);
        totalStakedBalanceLast -= adsStakedBalance[_adsId];
        adsStakedBalance[_adsId] = 0;
    }

    function _claimReward(address _webpageOwner) public view returns (uint256) {
        uint256 _claimedRewardCount = claimedRewardCount[_webpageOwner];
        uint256 _count = count;
        uint256 reward = 0;
        for (uint256 i = _claimedRewardCount; i < _count; i++) {
            MonthlyResult memory _monthResult = monthResult[i];
            if (webpageOwnerId[_webpageOwner] != 0) {
                reward +=
                    (_monthResult.reward *
                        _monthResult.viewCount[
                            webpageOwnerId[_webpageOwner] - 1
                        ]) /
                    _monthResult.totalViewCount;
                continue;
            }
            for (uint256 j = 0; j < _monthResult.webpageOwner.length; j++) {
                if (_monthResult.webpageOwner[j] == _webpageOwner) {
                    reward +=
                        (_monthResult.reward * _monthResult.viewCount[j]) /
                        _monthResult.totalViewCount;
                    break;
                }
            }
        }
        return reward;
    }

    function claimReward() external {
        uint256 reward = _claimReward(msg.sender);
        require(
            reward > 0,
            "BillBOSCore: this webpageOwner is not enough reward"
        );
        _unboost(reward);
        claimedRewardCount[msg.sender] = count;
    }

    function uploadAdsReport(
        address[] calldata _webpageOwner,
        uint256[] calldata _viewCount,
        uint256 _totalViewCount
    ) external onlyOwner returns (uint256) {
        require(
            _webpageOwner.length == _viewCount.length,
            "BillBOSCore: length of webpageOwner and count is not equal"
        );
        uint256 _count = count;
        uint256 reward = IBBAdapter(billbosAdaptorAddress).getStakedBalance() -
            totalStakedBalanceLast -
            totalEarningBalanceLast;
        // TODO: set fee 50% to platform and webpage owner
        platformBalance += reward / 2;
        monthResult[_count] = MonthlyResult({
            webpageOwner: _webpageOwner,
            viewCount: _viewCount,
            reward: reward - reward / 2,
            totalViewCount: _totalViewCount
        });
        totalEarningBalanceLast += reward;
        for (uint256 i = webpageOwnerIdLast; i < _webpageOwner.length; i++) {
            webpageOwnerIdLast += 1;
            webpageOwnerId[_webpageOwner[i]] = webpageOwnerIdLast;
        }
        count = _count + 1;
        return _count;
    }

    function claimPlatformReward() external onlyOwner {
        IERC20(stakedTokenAddress).transfer(devAddress, platformBalance);
        platformBalance = 0;
    }

    function setDevAddress(address _devAddress) external onlyOwner {
        devAddress = _devAddress;
    }
}
