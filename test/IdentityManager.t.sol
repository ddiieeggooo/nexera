// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test} from "forge-std/Test.sol";
import {IdentityManager} from "src/contracts/IdentityManager.sol";
import {IDataIndex} from "src/contracts/interfaces/IDataIndex.sol";
import {IDataPointRegistry} from "src/contracts/interfaces/IDataPointRegistry.sol";
import {IDataObject} from "src/contracts/interfaces/IDataObject.sol";
import {IdentityDataObject} from "src/contracts/IdentityDataObject.sol";
import {DataIndex} from "src/contracts/DataIndex.sol";
import {DataPointRegistry} from "src/contracts/DataPointRegistry.sol";

contract IdentityManagerTest is Test {
    IdentityManager public identityManager;
    IdentityDataObject public identityDataObject;
    DataIndex public dataIndex;
    DataPointRegistry public dataPointRegistry;
    address public ticketManager = address(0x1234);

    function setUp() public {
        // Deploy contracts
        dataPointRegistry = new DataPointRegistry();
        dataIndex = new DataIndex();
        identityDataObject = new IdentityDataObject();

        // Deploy IdentityManager
        identityManager = new IdentityManager(
            address(dataPointRegistry),
            address(dataIndex),
            address(identityDataObject)
        );

        // Set TicketManager
        identityManager.setTicketManager(ticketManager);
    }

    function test_SetTicketManager() public {
        // Only owner can set the TicketManager
        vm.prank(address(0x5678));
        vm.expectRevert("Ownable: caller is not the owner");
        identityManager.setTicketManager(address(0x9ABC));

        // Owner sets the TicketManager
        identityManager.setTicketManager(address(0x9ABC));
        assertEq(identityManager.ticketManager(), address(0x9ABC));
    }

    function test_IssueIdentity() public {
        // Only TicketManager can issue identities
        vm.prank(address(0x5678));
        vm.expectRevert("Caller is not TicketManager");
        identityManager.issueIdentity(address(0xDEAD));

        // TicketManager issues an identity
        vm.prank(ticketManager);
        DataPoint dp = identityManager.issueIdentity(address(0xDEAD));
        assertTrue(dp != DataPoint.wrap(bytes32(0)));
    }

    function test_GetIdentityOwner() public {
        // Issue identity
        vm.prank(ticketManager);
        DataPoint dp = identityManager.issueIdentity(address(0xDEAD));

        // Get identity owner
        address owner = identityManager.getIdentityOwner(dp);
        assertEq(owner, address(0xDEAD));
    }
}
