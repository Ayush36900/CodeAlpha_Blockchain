// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Storage {
    uint public value;

    // Events to log changes
    event ValueIncremented(uint newValue);
    event ValueDecremented(uint newValue);

    // First function
    function Increment() public {
        value++;
        emit ValueIncremented(value);
    }

    // Second function
    function Decrement() public {
        require(value > 0, "Value already at zero");
        value--;
        emit ValueDecremented(value);
    }
}
