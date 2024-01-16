// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {scholarshipCredit} from "./MockErc.sol";

contract ScholarshipCreditContract is Ownable, ERC20 {
    mapping(address studentaddress => uint256 credit) public studentCredit;
    mapping(address merchantAddress => bool Merchant) public isMerchant;

    error invalidCredit();

    constructor(
        address owner_
    ) Ownable(owner_) ERC20("ScholarshipCredit", "SC") {
        _mint(owner_, 1000000 * 10 ** 18);
    }

    //This function assigns credits to student getting the scholarship
    function grantScholarship(
        address studentAddress,
        uint256 credits
    ) public onlyOwner {
        require(balanceOf(msg.sender) > credits, "not enough balance");
        require(
            studentAddress != address(0),
            "student address cannot be a zero address"
        );
        studentCredit[studentAddress] += credits;
        _transfer(msg.sender, studentAddress, credits);
    }

    //This function is used to register a new merchant who can receive credits from students
    function registerMerchantAddress(address merchantAddress) public onlyOwner {
        isMerchant[merchantAddress] = true;
    }

    //This function is used to deregister an existing merchant
    function deregisterMerchantAddress(
        address merchantAddress
    ) public onlyOwner {
        isMerchant[merchantAddress] = false;
    }

    //This function is used to revoke the scholarship of a student
    function revokeScholarship(address studentAddress) public onlyOwner {
        uint256 unspentCredit = studentCredit[studentAddress];
        if (unspentCredit > 0) {
            _transfer(studentAddress, address(this), unspentCredit);
            _burn(address(this), unspentCredit);
        } else revert invalidCredit();
        delete studentCredit[studentAddress];
    }

    //Students can use this function to transfer credits only to registered merchants
    function spend(address merchantAddress, uint256 amount) public {
        require(isMerchant[merchantAddress], "Address not a merchant");
        require(studentCredit[msg.sender] > amount, "Not a scholar Or ");
        require(msg.sender != merchantAddress, "student cannot be merchant");
        studentCredit[msg.sender] -= amount;
        _transfer(msg.sender, merchantAddress, amount);
    }

    //This function is used to see the available credits assigned.
    function checkBalance() public view returns (uint256) {
        return balanceOf(msg.sender);
    }

    function getContractBalance() public view returns (uint256) {
        return balanceOf(address(this));
    }

    receive() external payable {
        revert();
    }
}
