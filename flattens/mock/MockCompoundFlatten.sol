// Sources flattened with hardhat v2.19.2 https://hardhat.org

// SPDX-License-Identifier: MIT AND UNLICENSED

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


// File contracts/mock/MockCompund.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;


contract MockCompound is ICErc20 {
    IERC20 public token;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public depositTimestamp;

    uint256 public APY;

    constructor(address _tokenAddress, uint256 _apy) {
        token = IERC20(_tokenAddress);
        APY = _apy;
    }

    function calculateInterest(address _user) internal view returns (uint256) {
        uint256 timeElapsed = block.timestamp - depositTimestamp[_user];
        uint256 interest = (balances[_user] * APY * timeElapsed) /
            (365 days * 100);
        return interest;
    }

    function mint(uint256 _amount) external returns (uint256) {
        require(_amount > 0, "Amount must be greater than 0");

        if (balances[msg.sender] > 0) {
            uint256 interest = calculateInterest(msg.sender);
            balances[msg.sender] += interest;
        }

        require(
            token.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );

        balances[msg.sender] += _amount;
        depositTimestamp[msg.sender] = block.timestamp;
        return 0;
    }

    function redeemUnderlying(uint256 _amount) external returns (uint256) {
        uint256 interest = calculateInterest(msg.sender);

        require(
            _amount > 0 && _amount <= balances[msg.sender] + interest,
            "Invalid amount"
        );

        balances[msg.sender] += interest;
        balances[msg.sender] -= _amount;

        require(token.transfer(msg.sender, _amount), "Transfer failed");
        depositTimestamp[msg.sender] = block.timestamp;
        return 0;
    }

    function balanceOfUnderlying(
        address _user
    ) external view returns (uint256) {
        uint256 interest = calculateInterest(msg.sender);
        return balances[_user] + interest;
    }
}
