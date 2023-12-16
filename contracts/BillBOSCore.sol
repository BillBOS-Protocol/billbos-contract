// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IBillBOSCore.sol";
import "./interfaces/IBillBOSAdaptor.sol";

contract BillBOSCore is IBillBOSCore, Ownable {
    // State
    address public billbosAdaptorAddress;
    uint8 public constant RANKING_LENGTH = 10;
    uint256 public monthCount = 0;
    uint256 public adsIdLast = 0;
    mapping(address => uint256[]) public adsId; // aders -> adsId
    mapping(uint256 => AdsContent) public adsContent; // adsId -> AdsContent
    mapping(uint256 => uint256) public adsStakedBalance; // adsId -> stakedBalance
    mapping(address => uint256) public monthClaimedReward; // webpageOwner(encoded) -> claimedReward
    mapping(uint256 => MonthlyResult) public monthResult; // month -> viewCount and reward
    uint256[RANKING_LENGTH] public rankingAdsId;

    constructor(address _billbosAdaptorAddress) Ownable(msg.sender) {
        billbosAdaptorAddress = _billbosAdaptorAddress;
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
    function top10Ads() external view returns (AdsRes[] memory) {
        AdsRes[] memory adsContentTop10 = new AdsRes[](RANKING_LENGTH);
        for (uint8 i = 0; i < RANKING_LENGTH; i++) {
            adsContentTop10[i] = AdsRes({
                adsContent: adsContent[rankingAdsId[i]],
                adsStakedBalance: adsStakedBalance[rankingAdsId[i]]
            });
        }
        return adsContentTop10;
    }

    function getAdsUser(address _ader) external view returns (AdsRes[] memory) {
        uint256[] memory myAdsId = adsId[_ader];
        AdsRes[] memory myAds = new AdsRes[](myAdsId.length);
        for (uint256 i = 0; i < myAdsId.length; i++) {
            myAds[i] = AdsRes({
                adsContent: adsContent[myAdsId[i]],
                adsStakedBalance: adsStakedBalance[myAdsId[i]]
            });
        }
        return myAds;
    }

    function getClaimUser(
        address _webpageOwner
    ) external view returns (uint256, uint256) {
        uint256 reward = _claimReward(_webpageOwner);
        return (reward, monthClaimedReward[_webpageOwner]);
    }

    function setBillbosAdaptorAddress(
        address _billbosAdaptorAddress
    ) external onlyOwner {
        billbosAdaptorAddress = _billbosAdaptorAddress;
    }

    // Method: Process
    function createAds(
        AdsContent calldata _ads,
        uint256 _amount
    ) external returns (uint256 _adsIdLast) {
        _adsIdLast = adsIdLast + 1;
        adsId[msg.sender].push(_adsIdLast);
        adsContent[_adsIdLast] = _ads;
        if (_amount > 0) {
            _boost(_amount);
            adsStakedBalance[_adsIdLast] = _amount;
            sortAds(_adsIdLast, _amount);
        }
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

    // TODO: hide ads from billbosAdaptorAddress
    function hideAds(uint256 _adsId) external adsIdExist(_adsId) {}

    function sortAds(
        uint256 _adsId,
        uint256 _amount
    ) internal adsIdExist(_adsId) {
        uint256[RANKING_LENGTH] memory _rankingAdsId = rankingAdsId;
        uint256[RANKING_LENGTH] memory newRankingAdsId;

        for (uint256 i = 0; i < _rankingAdsId.length; i++) {
            if (adsStakedBalance[_rankingAdsId[i]] < _amount) {
                newRankingAdsId[i] = _adsId;
                newRankingAdsId[i + 1] = _rankingAdsId[i];
                i = i + 1;
            } else {
                newRankingAdsId[i] = _rankingAdsId[i];
            }
        }
        rankingAdsId = newRankingAdsId;
    }

    function _boost(uint256 _amount) internal {
        IBillBOSAdaptor(billbosAdaptorAddress).stake(_amount);
    }

    function boost(
        uint256 _adsId,
        uint256 _amount
    ) external adsIdExist(_adsId) {
        _boost(_amount);
        uint256 newAdsStakedBalance = adsStakedBalance[_adsId] + _amount;
        adsStakedBalance[_adsId] = newAdsStakedBalance;
        sortAds(_adsId, newAdsStakedBalance);
    }

    function _unboost(uint256 _amount) internal {
        IBillBOSAdaptor(billbosAdaptorAddress).unstake(msg.sender, _amount);
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
        uint256 newAdsStakedBalance = adsStakedBalance[_adsId] - _amount;
        adsStakedBalance[_adsId] = newAdsStakedBalance;
        sortAds(_adsId, newAdsStakedBalance);
    }

    function unboostAll(uint256 _adsId) external adsIdExist(_adsId) {
        require(
            adsStakedBalance[_adsId] > 0,
            "BillBOSCore: this ads is not enough staked balance"
        );
        _unboost(adsStakedBalance[_adsId]);
        sortAds(_adsId, 0);
        adsStakedBalance[_adsId] = 0;
    }

    function _claimReward(address _webpageOwner) public view returns (uint256) {
        uint256 _monthClaimedReward = monthClaimedReward[_webpageOwner];
        uint256 _monthCount = monthCount;
        uint256 reward = 0;
        for (uint256 i = _monthClaimedReward; i < _monthCount; i++) {
            MonthlyResult memory _monthResult = monthResult[i];
            for (uint256 j = 0; j < _monthResult.webpageOwner.length; j++) {
                if (_monthResult.webpageOwner[j] == _webpageOwner) {
                    reward +=
                        (_monthResult.reward * _monthResult.viewCount[j]) /
                        _monthResult.totalViewCount;
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
        IBillBOSAdaptor(billbosAdaptorAddress).claimReward(msg.sender, reward);
        monthClaimedReward[msg.sender] = monthCount;
    }

    function uploadAdsReport(
        address[] calldata _webpageOwner,
        uint256[] calldata _viewCount,
        uint256 _reward,
        uint256 _totalViewCount
    ) external onlyOwner returns (uint256 _monthCount) {
        require(
            _webpageOwner.length == _viewCount.length,
            "BillBOSCore: length of webpageOwner and count is not equal"
        );
        _monthCount = monthCount + 1;
        monthResult[_monthCount] = MonthlyResult({
            webpageOwner: _webpageOwner,
            viewCount: _viewCount,
            reward: _reward,
            totalViewCount: _totalViewCount
        });
        return _monthCount;
    }
}
