// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test} from "forge-std/Test.sol";
import {VotingManager} from "src/contracts/main/VotingManager.sol";
import {IDataIndex} from "src/contracts/interfaces/IDataIndex.sol";
import {DataIndex} from "src/contracts/DataIndex.sol";
import {IDataObject} from "src/contracts/interfaces/IDataObject.sol";
import {VoteDataObject} from "src/contracts/main/VoteDataObject.sol";
import {IdentityDataObject} from "src/contracts/main/IdentityDataObject.sol";
import {DataPointRegistry} from "src/contracts/DataPointRegistry.sol";
import {DataPoints, DataPoint} from "src/contracts/utils/DataPoints.sol";

contract VotingManagerTest is Test {
    VotingManager public votingManager;
    DataIndex public dataIndex;
    VoteDataObject public voteDataObject;
    IdentityDataObject public identityDataObject;
    DataPointRegistry public dataPointRegistry;

    DataPoint public dp;

    function setUp() public {
        // Deploy contracts
        dataIndex = new DataIndex();
        voteDataObject = new VoteDataObject();
        identityDataObject = new IdentityDataObject();
        dataPointRegistry = new DataPointRegistry();

        // Prepare film IDs
        uint256[] memory filmIds = new uint256[](2);
        filmIds[0] = 1;
        filmIds[1] = 2;

        // Deploy VotingManager
        votingManager = new VotingManager(
            address(dataIndex),
            address(voteDataObject),
            address(identityDataObject),
            filmIds
        );

        // Allocate a DataPoint
        dp = dataPointRegistry.allocate(address(this));

        // Set DataIndex implementation in DataObjects
        voteDataObject.setDataIndexImplementation(dp, dataIndex);
        identityDataObject.setDataIndexImplementation(dp, dataIndex);

        // Grant admin role to this contract for the DataPoint
        dataPointRegistry.grantAdminRole(dp, address(this));

        // Allow this contract as DataManager for the DataPoint in DataIndex
        dataIndex.allowDataManager(dp, address(this), true);

        // **Allow VotingManager as DataManager for the DataPoint**
        dataIndex.allowDataManager(dp, address(votingManager), true);

        // Store identity data
        bytes memory identityData = abi.encode(address(this));
        dataIndex.write(
            address(identityDataObject),
            dp,
            bytes4(keccak256("storeIdentity(address)")),
            identityData
        );
    }

    function test_CastVote() public {
        // Cast a vote for filmId 1
        votingManager.castVote(dp, 1);

        // Attempt to cast another vote should fail
        vm.expectRevert("Vote already cast");
        votingManager.castVote(dp, 2);

        // Verify the vote
        bytes memory result = voteDataObject.read(
            dp,
            bytes4(keccak256("getVote()")),
            ""
        );
        uint256 filmId = abi.decode(result, (uint256));
        assertEq(filmId, 1);
    }
}
