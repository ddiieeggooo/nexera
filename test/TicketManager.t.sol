// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test} from "forge-std/Test.sol";
import {TicketManager} from "src/contracts/main/TicketManager.sol";
import {IdentityManager} from "src/contracts/main/IdentityManager.sol";
import {IdentityDataObject} from "src/contracts/main/IdentityDataObject.sol";
import {IDataIndex} from "src/contracts/interfaces/IDataIndex.sol";
import {DataIndex} from "src/contracts/DataIndex.sol";
import {IDataPointRegistry} from "src/contracts/interfaces/IDataPointRegistry.sol";
import {DataPointRegistry} from "src/contracts/DataPointRegistry.sol";

contract TicketManagerTest is Test {
    TicketManager public ticketManager;
    IdentityManager public identityManager;
    IdentityDataObject public identityDataObject;
    DataIndex public dataIndex;
    DataPointRegistry public dataPointRegistry;
    uint256 public ticketPrice = 1 ether;

    // Define the custom error
    error OwnableUnauthorizedAccount(address account);

    function setUp() public {
        // Deploy contracts
        dataPointRegistry = new DataPointRegistry();
        dataIndex = new DataIndex();
        identityDataObject = new IdentityDataObject();

        // Deploy IdentityManager with initial owner
        identityManager = new IdentityManager(
            address(dataPointRegistry),
            address(dataIndex),
            address(identityDataObject),
            address(this) // initial owner
        );

        // Deploy TicketManager with initial owner
        ticketManager = new TicketManager(
            address(identityManager),
            1 ether,
            address(this) // initial owner
        );

        // Set ticketManager in IdentityManager using vm.store
        bytes32 ticketManagerSlot = bytes32(uint256(4)); // Slot 4 for ticketManager
        vm.store(
            address(identityManager),
            ticketManagerSlot,
            bytes32(uint256(uint160(address(ticketManager))))
        );
    }

    function test_PurchaseTicket() public {
        // Purchase a ticket
        vm.deal(address(this), 2 ether); // Fund the test contract
        ticketManager.purchaseTicket{value: ticketPrice}();

        // Verify that the ticket is marked as purchased
        bool hasTicket = ticketManager.hasPurchasedTicket(address(this));
        assertTrue(hasTicket);
    }

    function test_WithdrawFunds() public {
        // Purchase a ticket
        vm.deal(address(this), 2 ether);
        ticketManager.purchaseTicket{value: ticketPrice}();

        // Withdraw funds as non-owner should fail
        vm.prank(address(0x1234));
        vm.expectRevert(
            abi.encodeWithSelector(
                OwnableUnauthorizedAccount.selector,
                address(0x1234)
            )
        );
        ticketManager.withdrawFunds();

        // Withdraw funds as owner
        uint256 ownerBalanceBefore = address(this).balance;
        ticketManager.withdrawFunds();
        uint256 ownerBalanceAfter = address(this).balance;

        assertEq(ownerBalanceAfter - ownerBalanceBefore, ticketPrice);
    }

    function test_SetTicketPrice() public {
        // Only owner can set ticket price
        vm.prank(address(0x1234));
        vm.expectRevert(
            abi.encodeWithSelector(
                OwnableUnauthorizedAccount.selector,
                address(0x1234)
            )
        );
        ticketManager.setTicketPrice(2 ether);

        // Owner sets the ticket price
        ticketManager.setTicketPrice(2 ether);
        assertEq(ticketManager.ticketPrice(), 2 ether);
    }

    receive() external payable {}
}
