// SPDX-License-Identifier: MIT
pragma solidity >=0.5.11;

import "forge-std/console.sol";

contract Hello {
    uint256 private num;
    uint256[] arr;

    constructor() {
        num = 0;
        arr.push(0);
        arr.push(1);
        arr.push(2);
        arr = [0, 1, 2, 3, 4, 5];
        // remove(3);
        console.log(arr[3]);
        arr.pop();
        console.log(arr[4]);
    }

    function run() public {
        num = 7;
        console.log(num);
    }
    // function addTwo(uint256 x, uint256 y) public pure returns (uint256) {
    //     return x + y;
    // }
}
