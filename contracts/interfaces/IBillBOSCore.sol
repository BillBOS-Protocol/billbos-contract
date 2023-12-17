// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBillBOSCore {
    // Struct
    struct AdsContent {
        string imageCID;
        string newTabLink;
        string widgetLink;
        bool isInteractive;
    }
    struct MonthlyResult {
        address[] webpageOwner;
        uint256[] viewCount;
        uint256 reward;
        uint256 totalViewCount;
    }
    struct AdsRes {
        uint256 adsId;
        AdsContent adsContent;
        uint256 adsStakedBalance;
    }

    // State
    function billbosAdaptorAddress() external view returns (address);

    // Method Getter-Setter
    function getAdsUser(address _ader) external view returns (AdsRes[] memory);

    function getReward(
        address _webpageOwner
    ) external view returns (uint256, uint256);

    function setBillbosAdaptorAddress(address _billbosAdaptorAddress) external;

    // Method Process
    function createAds(
        AdsContent calldata _ads,
        uint256 _amount
    ) external returns (uint256);

    function updateAds(uint256 _adsId, AdsContent calldata _ads) external;

    function boost(uint256 _adsId, uint256 _amount) external;

    function unboost(uint256 _adsId, uint256 _amount) external;

    function unboostAll(uint256 _adsId) external;

    function claimReward() external;

    function uploadAdsReport(
        address[] calldata _webpageOwner,
        uint256[] calldata _viewCount,
        uint256 _totalViewCount
    ) external returns (uint256);

    // Event
}
