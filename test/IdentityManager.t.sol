// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test} from "forge-std/Test.sol";
import {IdentityManager} from "src/contracts/main/IdentityManager.sol";
import {IDataIndex} from "src/contracts/interfaces/IDataIndex.sol";
import {IDataPointRegistry} from "src/contracts/interfaces/IDataPointRegistry.sol";
import {IDataObject} from "src/contracts/interfaces/IDataObject.sol";
import {IdentityDataObject} from "src/contracts/main/IdentityDataObject.sol";
import {DataIndex} from "src/contracts/DataIndex.sol";
import {DataPointRegistry} from "src/contracts/DataPointRegistry.sol";
import {DataPoints, DataPoint} from "src/contracts/utils/DataPoints.sol";
// import {OwnableUnauthorizedAccount} from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract IdentityManagerTest is Test {
    IdentityManager public identityManager;
    IdentityDataObject public identityDataObject;
    DataIndex public dataIndex;
    DataPointRegistry public dataPointRegistry;
    address public ticketManager = address(0x1234);
    // Mapping from DataPoint to owner address
    mapping(DataPoint => address) public identityOwners;

    function setUp() public {
        // Deploy contracts
        dataPointRegistry = new DataPointRegistry();
        dataIndex = new DataIndex();
        identityDataObject = new IdentityDataObject();

        // Deploy IdentityManager
        identityManager = new IdentityManager(
            address(dataPointRegistry),
            address(dataIndex),
            address(identityDataObject),
            address(this) // initialOwner
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

        // Verify that the owner is correctly stored
        address owner = identityManager.identityOwners(dp);
        assertEq(owner, address(0xDEAD));
    }

    function test_GetIdentityOwner() public {
        // TicketManager issues an identity
        vm.prank(ticketManager);
        DataPoint dp = identityManager.issueIdentity(address(0xDEAD));

        // Get identity owner via IdentityManager
        address owner = identityManager.getIdentityOwner(dp);
        assertEq(owner, address(0xDEAD));
    }

    function test_AttendeeStoresIdentityData() public {
        // TicketManager issues an identity
        vm.prank(ticketManager);
        DataPoint dp = identityManager.issueIdentity(address(this));

        // Attendee stores their identity data
        identityManager.storeIdentityData(dp);

        // Retrieve the identity data
        bytes memory result = dataIndex.read(
            address(identityDataObject),
            dp,
            bytes4(keccak256("getIdentity()")),
            ""
        );
        address storedOwner = abi.decode(result, (address));
        assertEq(storedOwner, address(this));
    }
}
