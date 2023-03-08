// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyToken {
    string public name = "tranpo";
    string public symbol = "TNP";
    uint256 public decimals = 18;
    uint256 public totalSupply = 100000000 * 10**decimals;
    uint256 public minimumSupply = 10000 * 10**decimals;
    uint256 public maxTransactionFee = 100; // 10% in basis points (1000 / 10000)
    uint256 public buyTransactionFee = 50; // 0.5% in basis points (50 / 10000)
    uint256 public sellTransactionFee = 90; // 0.9% in basis points (90 / 10000)
    uint256 public circulatingSupply;
    mapping(address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        circulatingSupply = totalSupply;
    }

    function transfer(address to, uint256 value) external returns (bool success) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        _transfer(msg.sender, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "Invalid address");
        require(value > 0, "Invalid value");
        require(balanceOf[from] >= value, "Insufficient balance");

        uint256 transactionFee;
        if (from == address(this) || to == address(this)) {
            transactionFee = 0;
        } else if (from == address(0)) {
            // Minting
            circulatingSupply += value;
            require(circulatingSupply >= minimumSupply, "Minimum supply not reached");
            transactionFee = 0;
        } else if (to == address(0)) {
            // Burning
            circulatingSupply -= value;
            transactionFee = 0;
            emit Burn(from, value);
        } else if (to == address(this)) {
            // Buying
            transactionFee = (value * buyTransactionFee) / 10000;
            require(value + transactionFee <= balanceOf[from], "Insufficient balance");
            balanceOf[from] -= value + transactionFee;
            balanceOf[to] += value;
            circulatingSupply += transactionFee;
        } else if (from == address(this)) {
            // Selling
            transactionFee = (value * sellTransactionFee) / 10000;
            require(value + transactionFee <= balanceOf[from], "Insufficient balance");
            balanceOf[from] -= value + transactionFee;
            balanceOf[to] += value;
            circulatingSupply += transactionFee;
        } else {
            // Transfer
            transactionFee = (value * maxTransactionFee) / 10000;
            require(value + transactionFee <= balanceOf[from], "Insufficient balance");
            balanceOf[from] -= value + transactionFee;
            balanceOf[to] += value;
            circulatingSupply += transactionFee;
        }

        emit Transfer(from, to, value);
        if (transactionFee > 0) {
            emit Transfer(from, address(this), transactionFee);
        }
    }
}
