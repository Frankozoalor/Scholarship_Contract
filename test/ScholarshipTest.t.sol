// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ScholarshipCreditContract} from "../src/ScholarshipCreditContract.sol";

contract ScholarshipTest is Test {
    ScholarshipCreditContract public scholarshipcreditcontract;
    address owner = makeAddr("owner");
    address student1 = makeAddr("student1");
    address student2 = makeAddr("student2");
    address student3 = makeAddr("student3");
    address Merchant1 = makeAddr("Merchant1");
    address Merchant2 = makeAddr("Merchant2");

    function setUp() public {
        scholarshipcreditcontract = new ScholarshipCreditContract(owner);
    }

    function testOwnerInitialBalance() public {
        vm.startPrank(owner);
        uint256 ownerBalance = scholarshipcreditcontract.checkBalance();
        console.log(ownerBalance);
        assertEq(ownerBalance, 1000000 * 1e18);
        vm.stopPrank();
    }

    function testContractBalance() public {
        // vm.startPrank(address(this));
        uint256 contractBalance = scholarshipcreditcontract
            .getContractBalance();
        console.log(contractBalance);
        assertEq(contractBalance, 100 * 1e18);
        //vm.stopPrank();
    }

    function testgrantScholarship() public {
        vm.startPrank(owner);
        scholarshipcreditcontract.grantScholarship(student1, 100 * 1e18);
        assertEq(
            scholarshipcreditcontract.balanceOf(owner),
            (1000000 - 100) * 1e18
        );
        assertEq(scholarshipcreditcontract.balanceOf(student1), 100 * 1e18);
        vm.stopPrank();
    }

    function testregisterMerchantAddress() public {
        vm.startPrank(owner);
        scholarshipcreditcontract.registerMerchantAddress(Merchant1);
        bool isMerchant = scholarshipcreditcontract.isMerchant(Merchant1);
        assertEq(isMerchant, true);
    }

    function testSpend() public {
        vm.startPrank(owner);
        scholarshipcreditcontract.grantScholarship(student1, 100 * 1e18);
        scholarshipcreditcontract.registerMerchantAddress(Merchant1);
        vm.stopPrank();
        vm.startPrank(student1);
        scholarshipcreditcontract.spend(Merchant1, 50 * 1e18);
        assertEq(scholarshipcreditcontract.balanceOf(Merchant1), 50 * 1e18);
        assertEq(scholarshipcreditcontract.studentCredit(student1), 50 * 1e18);
    }

    function testRevokeScholarship() public {
        vm.startPrank(owner);
        scholarshipcreditcontract.grantScholarship(student1, 100 * 1e18);
        scholarshipcreditcontract.registerMerchantAddress(Merchant1);
        vm.stopPrank();
        vm.startPrank(student1);
        scholarshipcreditcontract.spend(Merchant1, 50 * 1e18);
        vm.stopPrank();
        vm.startPrank(owner);
        scholarshipcreditcontract.revokeScholarship(student1);
        uint256 newcontractBalance = scholarshipcreditcontract
            .getContractBalance();
        assertEq(newcontractBalance, 0);
        assertEq(scholarshipcreditcontract.studentCredit(student1), 0);
    }
}
