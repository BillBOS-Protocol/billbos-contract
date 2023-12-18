// Sources flattened with hardhat v2.19.2 https://hardhat.org

// SPDX-License-Identifier: MIT AND UNLICENSED

// File @openzeppelin/contracts/utils/Context.sol@v5.0.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v5.0.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v5.0.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


// File contracts/interfaces/IBBAdapter.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IBBAdapter {
    function setBillBOS(address _newBillBOS) external;

    function stake(uint256 _amount) external;

    function unstake(uint256 _amount) external;

    function getStakedBalance() external view returns (uint256);
}


// File contracts/interfaces/IBillBOSCore.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.20;

interface IBillBOSCore {
    // Struct
    struct AdsContent {
        string name;
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


// File contracts/BillBOSCore.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.20;



contract BillBOSCore is IBillBOSCore, Ownable {
    // State
    address public billbosAdaptorAddress;
    address public stakedTokenAddress;
    uint256 public monthCount = 0;
    uint256 public adsIdLast = 0;
    uint256 public webpageOwnerIdLast = 0; // start from 1
    uint256 public totalStakedBalanceLast = 0;
    uint256 public totalEarningBalanceLast = 0;
    uint256 public platformBalance = 0;
    mapping(address => uint256[]) public adsId; // adsOwner -> adsId
    mapping(uint256 => AdsContent) public adsContent; // adsId -> AdsContent
    mapping(uint256 => uint256) public adsStakedBalance; // adsId -> stakedBalance
    mapping(address => uint256) public monthClaimedReward; // webpageOwner -> claimedReward
    mapping(uint256 => MonthlyResult) private monthResult; // month -> viewCount and reward
    mapping(address => uint256) private webpageOwnerId; //  webpageOwner -> webpageOwnerId

    constructor(
        address _billbosAdaptorAddress,
        address _stakedTokenAddress
    ) Ownable(msg.sender) {
        billbosAdaptorAddress = _billbosAdaptorAddress;
        stakedTokenAddress = _stakedTokenAddress;
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
        return (reward, monthClaimedReward[_webpageOwner]);
    }

    function setBillbosAdaptorAddress(
        address _billbosAdaptorAddress
    ) external onlyOwner {
        billbosAdaptorAddress = _billbosAdaptorAddress;
    }

    function getAds() external view returns (AdsRes[] memory) {
        AdsRes[] memory ads = new AdsRes[](adsIdLast);
        for (uint256 i = 0; i < adsIdLast; i++) {
            if (adsStakedBalance[i] <= 0) continue;
            ads[i] = AdsRes({
                adsId: i,
                adsContent: adsContent[i],
                adsStakedBalance: adsStakedBalance[i]
            });
        }
        return ads;
    }

    // Method: Process
    function createAds(
        AdsContent calldata _ads,
        uint256 _amount
    ) external returns (uint256 _adsIdLast) {
        require(_amount > 0, "BillBOSCore: amount must be more than 0");
        _adsIdLast = adsIdLast + 1;
        adsId[msg.sender].push(_adsIdLast);
        adsContent[_adsIdLast] = _ads;
        _boost(_amount);
        adsStakedBalance[_adsIdLast] = _amount;
        totalStakedBalanceLast += _amount;
        adsIdLast = _adsIdLast;
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
        uint256 _monthClaimedReward = monthClaimedReward[_webpageOwner];
        uint256 _monthCount = monthCount;
        uint256 reward = 0;
        for (uint256 i = _monthClaimedReward; i < _monthCount; i++) {
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
        monthClaimedReward[msg.sender] = monthCount;
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
        uint256 _monthCount = monthCount;
        uint256 reward = IBBAdapter(billbosAdaptorAddress).getStakedBalance() -
            totalStakedBalanceLast -
            totalEarningBalanceLast;
        // TODO: set fee 50% to platform and webpage owner
        platformBalance += reward / 2;
        monthResult[_monthCount] = MonthlyResult({
            webpageOwner: _webpageOwner,
            viewCount: _viewCount,
            reward: reward - reward / 2,
            totalViewCount: _totalViewCount
        });
        totalEarningBalanceLast += reward;
        for (uint256 i = webpageOwnerIdLast; i < _webpageOwner.length; i++) {
            webpageOwnerIdLast += 1;
            webpageOwnerId[_webpageOwner[i]] = i + 1;
        }
        monthCount = _monthCount + 1;
        return _monthCount;
    }
}
