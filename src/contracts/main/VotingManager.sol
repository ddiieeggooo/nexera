// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "../interfaces/IDataIndex.sol";
import "../utils/DataPoints.sol";
import "../interfaces/IDataObject.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @title VotingManager
 * @dev Manages the voting process in compliance with ERC-7208.
 */
contract VotingManager is Context {
    IDataIndex public dataIndex;
    IDataObject public voteDataObject;

    // Mapping from film IDs to existence (for validation)
    mapping(uint256 => bool) public validFilms;

    // Event emitted when a vote is cast
    event VoteCast(DataPoint indexed dp, uint256 indexed filmId);

    /**
     * @dev Constructor sets up the DataIndex and VoteDataObject contracts.
     * @param _dataIndex The address of the DataIndex contract.
     * @param _voteDataObject The address of the VoteDataObject contract.
     * @param filmIds The list of valid film IDs.
     */
    constructor(
        address _dataIndex,
        address _voteDataObject,
        uint256[] memory filmIds
    ) {
        dataIndex = IDataIndex(_dataIndex);
        voteDataObject = IDataObject(_voteDataObject);

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
        bytes memory result = dataIndex.read(address(voteDataObject), dp, bytes4(keccak256("getVoter()")), "");
        address owner = abi.decode(result, (address));
        if (owner == address(0)) {
            // If no vote has been cast yet, get owner from IdentityDataObject
            bytes memory identityResult = dataIndex.read(address(voteDataObject), dp, bytes4(keccak256("getIdentityOwner()")), "");
            owner = abi.decode(identityResult, (address));
        }
        require(owner == _msgSender(), "Not the identity owner");

        // Store the vote in the VoteDataObject via the Data Index
        bytes memory data = abi.encode(_msgSender(), filmId);
        dataIndex.write(address(voteDataObject), dp, bytes4(keccak256("storeVote(address,uint256)")), data);

        emit VoteCast(dp, filmId);
    }
}
