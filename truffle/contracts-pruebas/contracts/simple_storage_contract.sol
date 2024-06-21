// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SimpleStorage {
    uint256 private _storedData;

    // Constructor: Initializes _storedData to zero
    constructor() {
        _storedData = 0;
    }

    // Function to set the stored data
    function set(uint256 x) public {
        _storedData = x;
    }

    // Function to get the stored data
    function get() public view returns (uint256) {
        return _storedData;
    }
}
