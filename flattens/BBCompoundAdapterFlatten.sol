// Sources flattened with hardhat v2.19.2 https://hardhat.org

// SPDX-License-Identifier: UNLICENSED

// File contracts/interfaces/IBBAdapter.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IBBAdapter {
    function setBillBOS(address _newBillBOS) external;

    function stake(uint256 _amount) external;

    function unstake(uint256 _amount) external;

    function getStakedBalance() external view returns (uint256);
}

// File contracts/interfaces/ICErc20.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface ICErc20 {
    function mint(uint256 mintAmount) external returns (uint);

    function redeemUnderlying(uint redeemAmount) external returns (uint);

    function balanceOfUnderlying(address owner) external view returns (uint256);
}

// File contracts/interfaces/IERC20.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

// File contracts/BBCompoundAdapter.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Import Compound's interfaces

contract BBCompoundAdapter is IBBAdapter {
    address public billBOS;
    IERC20 public token;
    ICErc20 public cToken;

    modifier onlyBillBOS() {
        require(msg.sender == billBOS, "Caller is not BillBOS");
        _;
    }

    constructor(
        address _tokenAddress,
        address _cTokenAddress,
        address _billBOS
    ) {
        token = IERC20(_tokenAddress);
        cToken = ICErc20(_cTokenAddress);
        billBOS = _billBOS;
    }

    function setBillBOS(address _newBillBOS) external onlyBillBOS {
        require(_newBillBOS != address(0), "Invalid address");
        billBOS = _newBillBOS;
    }

    // Function to stake tokens
    function stake(uint256 _amount) external onlyBillBOS {
        // Transfer tokens from BillBOS contract to this contract
        require(
            token.transferFrom(billBOS, address(this), _amount),
            "Transfer failed"
        );
        // Approve the Compound cToken to spend tokens on behalf of this contract
        require(token.approve(address(cToken), _amount), "Approval failed");
        // Mint cTokens by supplying ERC20 tokens to the Compound protocol
        require(cToken.mint(_amount) == 0, "Stake failed");
    }

    // Function to unstake tokens
    function unstake(uint256 _amount) external onlyBillBOS {
        // Redeem cTokens to get back ERC20 tokens from the Compound protocol
        require(cToken.redeemUnderlying(_amount) == 0, "Unstake failed");
        // Transfer redeemed tokens back to the BillBOS contract
        require(token.transfer(billBOS, _amount), "Transfer failed");
    }

    // Function to get the current balance of cTokens staked
    function getStakedBalance() external view returns (uint256) {
        return cToken.balanceOfUnderlying(address(this));
    }
}
