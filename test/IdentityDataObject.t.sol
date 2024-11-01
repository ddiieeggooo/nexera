// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test} from "forge-std/Test.sol";
import {IdentityDataObject} from "src/contracts/main/IdentityDataObject.sol";
import {IDataIndex} from "src/contracts/interfaces/IDataIndex.sol";
import {IDataPointRegistry} from "src/contracts/interfaces/IDataPointRegistry.sol";
import {DataPoints, DataPoint} from "src/contracts/utils/DataPoints.sol";
import {DataIndex} from "src/contracts/DataIndex.sol";
import {DataPointRegistry} from "src/contracts/DataPointRegistry.sol";
import {ChainidTools} from "src/contracts/utils/ChainidTools.sol";

contract IdentityDataObjectTest is Test {
    IdentityDataObject public identityDataObject;
    DataIndex public dataIndex;
    DataPointRegistry public dataPointRegistry;

    DataPoint public dp;
    address public owner;

    function setUp() public {
        // Deploy DataPointRegistry and DataIndex
        dataPointRegistry = new DataPointRegistry();
        dataIndex = new DataIndex();

        // Deploy IdentityDataObject
        identityDataObject = new IdentityDataObject();

        // Allocate a DataPoint
        dp = dataPointRegistry.allocate(address(this));

        // Set DataIndex implementation in IdentityDataObject
        identityDataObject.setDataIndexImplementation(dp, dataIndex);

        // Grant admin role to this contract for the DataPoint
        dataPointRegistry.grantAdminRole(dp, address(this));

        // Allow this contract as DataManager for the DataPoint in DataIndex
        dataIndex.allowDataManager(dp, address(this), true);

        owner = address(this);
    }

    function test_SetDataIndexImplementation() public {
        // Attempt to set DataIndex implementation as non-admin
        vm.prank(address(0x1234));
        vm.expectRevert("Not DataPoint admin");
        identityDataObject.setDataIndexImplementation(dp, dataIndex);

        // Set DataIndex implementation as admin
        identityDataObject.setDataIndexImplementation(dp, dataIndex);
    }

    function test_Write() public {
        // Prepare data to write
        bytes memory data = abi.encode(owner);

        // Write data via DataIndex
        dataIndex.write(
            address(identityDataObject),
            dp,
            bytes4(keccak256("storeIdentity(address)")),
            data
        );

        // Read back the data to verify
        bytes memory result = identityDataObject.read(dp, bytes4(keccak256("getIdentity()")), "");
        address storedOwner = abi.decode(result, (address));
        assertEq(storedOwner, owner);
    }

    function test_Read() public {
        // Write data first
        bytes memory data = abi.encode(owner);
        dataIndex.write(
            address(identityDataObject),
            dp,
            bytes4(keccak256("storeIdentity(address)")),
            data
        );

        // Read data
        bytes memory result = identityDataObject.read(dp, bytes4(keccak256("getIdentity()")), "");
        address storedOwner = abi.decode(result, (address));
        assertEq(storedOwner, owner);
    }
}
