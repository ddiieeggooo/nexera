// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.22;

// import {Test} from "forge-std/Test.sol";
// import {ProfitSharingManager} from "../contracts/ProfitSharingManager.sol";
// import {IDataIndex} from "../contracts/interfaces/IDataIndex.sol";
// import {DataIndex} from "../contracts/DataIndex.sol";
// import {IDataObject} from "../contracts/interfaces/IDataObject.sol";
// import {VoteDataObject} from "../contracts/VoteDataObject.sol";
// import {ProfitDataObject} from "../contracts/ProfitDataObject.sol";
// import {DataPointRegistry} from "../contracts/DataPointRegistry.sol";
// import {DataPoints, DataPoint} from "../contracts/utils/DataPoints.sol";

// contract ProfitSharingManagerTest is Test {
//     ProfitSharingManager public profitSharingManager;
//     DataIndex public dataIndex;
//     VoteDataObject public voteDataObject;
//     ProfitDataObject public profitDataObject;
//     DataPointRegistry public dataPointRegistry;

//     DataPoint public dp;

//     function setUp() public {
//         // Deploy contracts
//         dataIndex = new DataIndex();
//         voteDataObject = new VoteDataObject();
//         profitDataObject = new ProfitDataObject();
//         dataPointRegistry = new DataPointRegistry();

//         // Deploy ProfitSharingManager
//         profitSharingManager = new ProfitSharingManager(
//             address(dataIndex),
//             address(voteDataObject),
//             address(profitDataObject)
//         );

//         // Allocate a DataPoint
//         dp = dataPointRegistry.allocate(address(this));

//         // Set DataIndex implementation in DataObjects
//         voteDataObject.setDataIndexImplementation(dp, dataIndex);
//         profitDataObject.setDataIndexImplementation(dp, dataIndex);

//         // Grant admin role to this contract for the DataPoint
//         dataPointRegistry.grantAdminRole(dp, address(this));

//         // Allow this contract as DataManager for the DataPoint in DataIndex
//         dataIndex.allowDataManager(dp, address(this), true);

//         // Set winning film
//         profitSharingManager.setWinningFilm(1);

//         // Simulate a vote for the winning film
//         bytes memory voteData = abi.encode(address(this), uint256(1));
//         dataIndex.write(
//             address(voteDataObject),
//             dp,
//             bytes4(keccak256("storeVote(address,uint256)")),
//             voteData
//         );

//         // Send some Ether to the ProfitSharingManager contract
//         vm.deal(address(profitSharingManager), 1 ether);
//         profitSharingManager.totalProfit = 1 ether;
//     }

//     function test_SetWinningFilm() public {
//         // Only owner can set the winning film
//         vm.prank(address(0x1234));
//         vm.expectRevert("Ownable: caller is not the owner");
//         profitSharingManager.setWinningFilm(2);

//         // Owner sets the winning film
//         profitSharingManager.setWinningFilm(2);
//         assertEq(profitSharingManager.winningFilmId(), 2);
//     }

//     function test_CalculateProfitShare() public {
//         // Implement getTotalWinners() to return 1 for testing
//         // Here we can override the function in the test
//         uint256 share = profitSharingManager.calculateProfitShare();
//         assertEq(share, 1 ether);
//     }

//     function test_ClaimProfit() public {
//         // Implement getTotalWinners() to return 1 for testing
//         // Call claimProfit
//         profitSharingManager.claimProfit(dp);

//         // Verify that profit is marked as claimed
//         bytes memory result = profitDataObject.read(dp, bytes4(keccak256("isProfitClaimed()")), "");
//         bool isClaimed = abi.decode(result, (bool));
//         assertTrue(isClaimed);
//     }
// }
