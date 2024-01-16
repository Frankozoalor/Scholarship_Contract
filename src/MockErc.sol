// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract scholarshipCredit is ERC20 {
    constructor() ERC20("ScholarshipCredit", "SC") {}
}
