// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "@/src/FundMe.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {DeployFundMe} from "@/script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; // remember this works in foundry compiler
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1; // also the built in solidity: tx.gaspriceuint256

    // set up runs before each test
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    modifier funded() {
        vm.prank(USER);
        vm.deal(USER, STARTING_BALANCE);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender() public view {
        address owner = fundMe.getOwner();
        assertEq(owner, msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        // console.log(
        //     ":rocket ~ testPriceFeedVersionIsAccurate ~ version:",
        //     version
        // );
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        // fundMe.fund(); // -> reverts as expected
        fundMe.fund{value: 1}(); // -> idem
    }

    function test_fundUpdatesFundedDataStructure() public funded {
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
    }

    function test_addsFunderToArrayOfFunders() public funded {
        assertEq(fundMe.getFunder(0), USER);
    }

    function test_onlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function test_withdrowWithSingleFunder() public funded {
        // arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // act (actions)
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        // assert
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
        assertEq(0, endingFundMeBalance);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function test_withdrawWithMultipleFunders() public funded {
        // arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // sometimes 0 address reverts

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i));
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 fundMeBalance = address(fundMe).balance;

        // act (actions)

        // uint256 gasStart = gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        // vm.prank(fundMe.getOwner(), GAS_PRICE);
        fundMe.withdraw();
        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * GAS_PRICE;
        // console.log("gasUsed:", gasUsed);

        uint256 endingOwnerBalance = fundMe.getOwner().balance;

        // assert
        assertEq(address(fundMe).balance, 0);
        assertEq(fundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function test_withdrawWithMultipleFundersCheaper() public funded {
        // arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // sometimes 0 address reverts

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i));
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 fundMeBalance = address(fundMe).balance;

        // act (actions)

        // uint256 gasStart = gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        // vm.prank(fundMe.getOwner(), GAS_PRICE);
        fundMe.cheaperWithdraw();
        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * GAS_PRICE;
        // console.log("gasUsed:", gasUsed);

        uint256 endingOwnerBalance = fundMe.getOwner().balance;

        // assert
        assertEq(address(fundMe).balance, 0);
        assertEq(fundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }
}
