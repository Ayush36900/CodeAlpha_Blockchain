// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiSend {
    // Payable function to send Ether to multiple addresses equally
    function sendEther(address[] memory recipients) public payable {
        uint totalRecipients = recipients.length;
        require(totalRecipients > 0, "No recipients provided");
        require(msg.value > 0, "No Ether sent");

        uint amountPerRecipient = msg.value / totalRecipients;
        require(amountPerRecipient > 0, "Not enough Ether to split");

        for (uint i = 0; i < totalRecipients; i++) {
            payable(recipients[i]).transfer(amountPerRecipient);
        }
    }
}
