// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.22;

// import {Test} from "forge-std/Test.sol";
// import {VoteDataObject} from "../contracts/VoteDataObject.sol";
// import {IDataIndex} from "../contracts/interfaces/IDataIndex.sol";
// import {DataIndex} from "../contracts/DataIndex.sol";
// import {IDataPointRegistry} from "../contracts/interfaces/IDataPointRegistry.sol";
// import {DataPointRegistry} from "../contracts/DataPointRegistry.sol";
// import {DataPoints, DataPoint} from "../contracts/utils/DataPoints.sol";

// contract VoteDataObjectTest is Test {
//     VoteDataObject public voteDataObject;
//     DataIndex public dataIndex;
//     DataPointRegistry public dataPointRegistry;

//     DataPoint public dp;

//     function setUp() public {
//         // Deploy DataPointRegistry and DataIndex
//         dataPointRegistry = new DataPointRegistry();
//         dataIndex = new DataIndex();

//         // Deploy VoteDataObject
//         voteDataObject = new VoteDataObject();

//         // Allocate a DataPoint
//         dp = dataPointRegistry.allocate(address(this));

//         // Set DataIndex implementation in VoteDataObject
//         voteDataObject.setDataIndexImplementation(dp, dataIndex);

//         // Grant admin role to this contract for the DataPoint
//         dataPointRegistry.grantAdminRole(dp, address(this));

//         // Allow this contract as DataManager for the DataPoint in DataIndex
//         dataIndex.allowDataManager(dp, address(this), true);
//     }

//     function test_SetDataIndexImplementation() public {
//         // Attempt to set DataIndex implementation as non-admin
//         vm.prank(address(0x1234));
//         vm.expectRevert("Not DataPoint admin");
//         voteDataObject.setDataIndexImplementation(dp, dataIndex);

//         // Set DataIndex implementation as admin
//         voteDataObject.setDataIndexImplementation(dp, dataIndex);
//     }

//     function test_Write() public {
//         // Store a vote
//         bytes memory voteData = abi.encode(address(this), uint256(1));
//         dataIndex.write(
//             address(voteDataObject),
//             dp,
//             bytes4(keccak256("storeVote(address,uint256)")),
//             voteData
//         );

//         // Read back the vote to verify
//         bytes memory result = voteDataObject.read(dp, bytes4(keccak256("getVote()")), "");
//         uint256 filmId = abi.decode(result, (uint256));
//         assertEq(filmId, 1);
//     }

//     function test_Read() public {
//         // Store a vote
//         bytes memory voteData = abi.encode(address(this), uint256(2));
//         dataIndex.write(
//             address(voteDataObject),
//             dp,
//             bytes4(keccak256("storeVote(address,uint256)")),
//             voteData
//         );

//         // Read back the voter
//         bytes memory result = voteDataObject.read(dp, bytes4(keccak256("getVoter()")), "");
//         address voter = abi.decode(result, (address));
//         assertEq(voter, address(this));
//     }
// }
