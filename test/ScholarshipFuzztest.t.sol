// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ScholarshipCreditContract} from "../src/ScholarshipCreditContract.sol";

contract ScholarshipTestFuzz is Test {
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

    function testContractBalance() private {
        uint256 contractBalance = scholarshipcreditcontract
            .getContractBalance();
        console.log(contractBalance);
        assertEq(contractBalance, 0);
    }

    function testFuzz_grantScholarship(
        address student,
        uint256 credits
    ) public {
        vm.startPrank(owner);
        vm.assume(student != address(0));
        uint256 c;
        c = bound(credits, 10 * 1e18, 100 * 1e18);
        console.log(c);

        scholarshipcreditcontract.grantScholarship(student, c);
        assertEq(
            scholarshipcreditcontract.balanceOf(owner),
            (1000000 * 1e18 - c)
        );
        assertEq(scholarshipcreditcontract.balanceOf(student), c);
        vm.stopPrank();
    }

    function testFuzz_registerMerchantAddress(address merchant) public {
        vm.startPrank(owner);
        vm.assume(merchant != address(0));
        scholarshipcreditcontract.registerMerchantAddress(merchant);
        bool isMerchant = scholarshipcreditcontract.isMerchant(merchant);
        assertEq(isMerchant, true);
    }

    function testFuzz_spend(address merchant, uint256 credits) public {
        vm.startPrank(owner);
        vm.assume(merchant != address(0));
        uint256 c;
        c = bound(credits, 10 * 1e18, 50 * 1e18);
        scholarshipcreditcontract.grantScholarship(student1, 100 * 1e18);
        scholarshipcreditcontract.registerMerchantAddress(merchant);
        vm.stopPrank();
        vm.startPrank(student1);
        scholarshipcreditcontract.spend(merchant, 50 * 1e18);
        assertEq(scholarshipcreditcontract.balanceOf(merchant), 50 * 1e18);
        assertEq(scholarshipcreditcontract.studentCredit(student1), 50 * 1e18);
    }

    function testFuzz_RevokeScholarship(address student) public {
        vm.startPrank(owner);
        vm.assume(student != address(0));
        scholarshipcreditcontract.grantScholarship(student, 100 * 1e18);
        scholarshipcreditcontract.registerMerchantAddress(Merchant1);
        vm.stopPrank();
        vm.startPrank(student);
        scholarshipcreditcontract.spend(Merchant1, 50 * 1e18);
        vm.stopPrank();
        vm.startPrank(owner);
        scholarshipcreditcontract.revokeScholarship(student);
        uint256 newcontractBalance = scholarshipcreditcontract
            .getContractBalance();
        assertEq(newcontractBalance, 0);
        assertEq(scholarshipcreditcontract.studentCredit(student), 0);
    }
}
