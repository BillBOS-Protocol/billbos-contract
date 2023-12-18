// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

// Import Compound's interfaces
import "./interfaces/IBBAdapter.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/ICErc20.sol";

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
