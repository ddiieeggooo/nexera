// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "../interfaces/IDataIndex.sol";
import "../interfaces/IDataObject.sol";
import "../utils/DataPoints.sol";
import "openzeppelin-contracts/contracts/utils/Context.sol";

/**
 * @title VotingManager
 * @dev Manages the voting process in compliance with ERC-7208.
 */
contract VotingManager {
    IDataIndex public dataIndex;
    IDataObject public voteDataObject;
    IDataObject public identityDataObject;

    // Mapping from film IDs to existence (for validation)
    mapping(uint256 => bool) public validFilms;

    // Event emitted when a vote is cast
    event VoteCast(DataPoint indexed dp, uint256 indexed filmId);

    /**
     * @dev Constructor sets up the DataIndex, VoteDataObject, and IdentityDataObject contracts.
     * @param _dataIndex The address of the DataIndex contract.
     * @param _voteDataObject The address of the VoteDataObject contract.
     * @param _identityDataObject The address of the IdentityDataObject contract.
     * @param filmIds The list of valid film IDs.
     */
    constructor(
        address _dataIndex,
        address _voteDataObject,
        address _identityDataObject,
        uint256[] memory filmIds
    ) {
        dataIndex = IDataIndex(_dataIndex);
        voteDataObject = IDataObject(_voteDataObject);
        identityDataObject = IDataObject(_identityDataObject);

        // Initialize valid films
        for (uint256 i = 0; i < filmIds.length; i++) {
            validFilms[filmIds[i]] = true;
        }
    }

    /**
     * @dev Allows an identity holder to cast a vote.
     * @param dp The DataPoint ID of the identity.
     * @param filmId The ID of the film being voted for.
     */
    function castVote(DataPoint dp, uint256 filmId) external {
        require(validFilms[filmId], "Invalid film ID");

        // Verify that the caller is the owner of the DataPoint
        bytes memory identityResult = dataIndex.read(address(identityDataObject), dp, bytes4(keccak256("getIdentity()")), "");
        address owner = abi.decode(identityResult, (address));
        require(owner == msg.sender, "Not the identity owner");

        // Check if a vote has already been cast
        bytes memory voteResult = dataIndex.read(address(voteDataObject), dp, bytes4(keccak256("getVote()")), "");
        uint256 existingVote = abi.decode(voteResult, (uint256));
        require(existingVote == 0, "Vote already cast");

        // Store the vote in the VoteDataObject via the Data Index
        bytes memory data = abi.encode(msg.sender, filmId);
        dataIndex.write(address(voteDataObject), dp, bytes4(keccak256("storeVote(address,uint256)")), data);

        emit VoteCast(dp, filmId);
    }
}
