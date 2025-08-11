// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CryptoLock {
    mapping(address => uint) public balances;
    mapping(address => uint) public unlockTime;

    event Deposited(address indexed user, uint amount, uint unlockTime);
    event Withdrawn(address indexed user, uint amount);

    // Deposit ETH and set a lock duration (seconds)
    function deposit(uint lockDurationSeconds) external payable {
        require(msg.value > 0, "Send ETH to deposit");
        require(lockDurationSeconds > 0, "Lock duration must be > 0");

        // update balance & unlock time (if user deposits again, extend to later time)
        balances[msg.sender] += msg.value;
        uint newUnlock = block.timestamp + lockDurationSeconds;
        if (newUnlock > unlockTime[msg.sender]) {
            unlockTime[msg.sender] = newUnlock;
        }

        emit Deposited(msg.sender, msg.value, unlockTime[msg.sender]);
    }

    // Withdraw after lock time has passed
    function withdraw() external {
        uint amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");
        require(block.timestamp >= unlockTime[msg.sender], "Lock time not passed");

        // effects
        balances[msg.sender] = 0;
        unlockTime[msg.sender] = 0;

        // interaction
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    // helper view to check remaining lock time (0 if can withdraw or no deposit)
    function remainingLockTime(address user) external view returns (uint) {
        if (block.timestamp >= unlockTime[user]) return 0;
        return unlockTime[user] - block.timestamp;
    }
}
