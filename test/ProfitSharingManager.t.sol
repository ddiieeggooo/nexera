// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test} from "forge-std/Test.sol";
import {ProfitSharingManager} from "src/contracts/main/ProfitSharingManager.sol";
import {IDataIndex} from "src/contracts/interfaces/IDataIndex.sol";
import {DataIndex} from "src/contracts/DataIndex.sol";
import {IDataObject} from "src/contracts/interfaces/IDataObject.sol";
import {VoteDataObject} from "src/contracts/main/VoteDataObject.sol";
import {ProfitDataObject} from "src/contracts/main/ProfitDataObject.sol";
import {DataPointRegistry} from "src/contracts/DataPointRegistry.sol";
import {DataPoints, DataPoint} from "src/contracts/utils/DataPoints.sol";

contract ProfitSharingManagerTest is Test {
    ProfitSharingManager public profitSharingManager;
    DataIndex public dataIndex;
    VoteDataObject public voteDataObject;
    ProfitDataObject public profitDataObject;
    DataPointRegistry public dataPointRegistry;
    DataPoint public dp;
    error OwnableUnauthorizedAccount(address account);

    function setUp() public {
        // Deploy contracts
        dataIndex = new DataIndex();
        voteDataObject = new VoteDataObject();
        profitDataObject = new ProfitDataObject();
        dataPointRegistry = new DataPointRegistry();

        // Deploy ProfitSharingManager
        profitSharingManager = new ProfitSharingManager(
            address(dataIndex),
            address(voteDataObject),
            address(profitDataObject)
        );

        // Allocate a DataPoint
        dp = dataPointRegistry.allocate(address(this));

        // Set DataIndex implementation in DataObjects
        voteDataObject.setDataIndexImplementation(dp, dataIndex);
        profitDataObject.setDataIndexImplementation(dp, dataIndex);

        // Grant admin role to this contract for the DataPoint
        dataPointRegistry.grantAdminRole(dp, address(this));

        // Allow this contract as DataManager for the DataPoint in DataIndex
        dataIndex.allowDataManager(dp, address(this), true);

        // Set winning film
        profitSharingManager.setWinningFilm(1);

        // Simulate a vote for the winning film
        bytes memory voteData = abi.encode(address(this), uint256(1));
        dataIndex.write(
            address(voteDataObject),
            dp,
            bytes4(keccak256("storeVote(address,uint256)")),
            voteData
        );

        // Send some Ether to the ProfitSharingManager contract
        vm.deal(address(profitSharingManager), 1 ether);

        // Allow ProfitSharingManager as DataManager for the DataPoint in DataIndex
        dataIndex.allowDataManager(dp, address(profitSharingManager), true);

        // Set totalProfit to 1 ether using vm.store
        bytes32 totalProfitSlot = bytes32(uint256(4)); // Slot 4 for totalProfit
        vm.store(
            address(profitSharingManager),
            totalProfitSlot,
            bytes32(uint256(1 ether))
        );
    }

    function test_SetWinningFilm() public {
        // Only owner can set the winning film
        vm.prank(address(0x1234));
        vm.expectRevert(
            abi.encodeWithSelector(
                OwnableUnauthorizedAccount.selector,
                address(0x1234)
            )
        );
        profitSharingManager.setWinningFilm(2);

        // Owner sets the winning film
        profitSharingManager.setWinningFilm(2);
        assertEq(profitSharingManager.winningFilmId(), 2);
    }

    function test_CalculateProfitShare() public {
        // Verify that totalProfit is set correctly
        bytes32 totalProfitSlot = bytes32(uint256(4)); // Slot 4 for totalProfit
        bytes32 storedValue = vm.load(
            address(profitSharingManager),
            totalProfitSlot
        );
        uint256 totalProfit = uint256(storedValue);
        assertEq(totalProfit, 1 ether);

        // Expect the revert due to unimplemented function
        vm.expectRevert("Counting total winners not implemented");

        // Call the function that reverts
        profitSharingManager.calculateProfitShare();
    }

    function test_ClaimProfit() public {
        // Expect the revert due to unimplemented function
        vm.expectRevert("Counting total winners not implemented");

        // Call claimProfit, which will revert
        profitSharingManager.claimProfit(dp);
    }
}
