// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.22;

// import {Test} from "forge-std/Test.sol";
// import {ProfitDataObject} from "../contracts/ProfitDataObject.sol";
// import {IDataIndex} from "../contracts/interfaces/IDataIndex.sol";
// import {DataIndex} from "../contracts/DataIndex.sol";
// import {IDataPointRegistry} from "../contracts/interfaces/IDataPointRegistry.sol";
// import {DataPointRegistry} from "../contracts/DataPointRegistry.sol";
// import {DataPoints, DataPoint} from "../contracts/utils/DataPoints.sol";

// contract ProfitDataObjectTest is Test {
//     ProfitDataObject public profitDataObject;
//     DataIndex public dataIndex;
//     DataPointRegistry public dataPointRegistry;

//     DataPoint public dp;

//     function setUp() public {
//         // Deploy DataPointRegistry and DataIndex
//         dataPointRegistry = new DataPointRegistry();
//         dataIndex = new DataIndex();

//         // Deploy ProfitDataObject
//         profitDataObject = new ProfitDataObject();

//         // Allocate a DataPoint
//         dp = dataPointRegistry.allocate(address(this));

//         // Set DataIndex implementation in ProfitDataObject
//         profitDataObject.setDataIndexImplementation(dp, dataIndex);

//         // Grant admin role to this contract for the DataPoint
//         dataPointRegistry.grantAdminRole(dp, address(this));

//         // Allow this contract as DataManager for the DataPoint in DataIndex
//         dataIndex.allowDataManager(dp, address(this), true);
//     }

//     function test_SetDataIndexImplementation() public {
//         // Attempt to set DataIndex implementation as non-admin
//         vm.prank(address(0x1234));
//         vm.expectRevert("Not DataPoint admin");
//         profitDataObject.setDataIndexImplementation(dp, dataIndex);

//         // Set DataIndex implementation as admin
//         profitDataObject.setDataIndexImplementation(dp, dataIndex);
//     }

//     function test_Write() public {
//         // Mark profit as claimed
//         dataIndex.write(
//             address(profitDataObject),
//             dp,
//             bytes4(keccak256("claimProfit()")),
//             ""
//         );

//         // Verify that profit is marked as claimed
//         bytes memory result = profitDataObject.read(dp, bytes4(keccak256("isProfitClaimed()")), "");
//         bool isClaimed = abi.decode(result, (bool));
//         assertTrue(isClaimed);
//     }

//     function test_Read() public {
//         // Initially, profit should not be claimed
//         bytes memory result = profitDataObject.read(dp, bytes4(keccak256("isProfitClaimed()")), "");
//         bool isClaimed = abi.decode(result, (bool));
//         assertFalse(isClaimed);

//         // Mark profit as claimed
//         dataIndex.write(
//             address(profitDataObject),
//             dp,
//             bytes4(keccak256("claimProfit()")),
//             ""
//         );

//         // Read again to verify
//         result = profitDataObject.read(dp, bytes4(keccak256("isProfitClaimed()")), "");
//         isClaimed = abi.decode(result, (bool));
//         assertTrue(isClaimed);
//     }
// }
