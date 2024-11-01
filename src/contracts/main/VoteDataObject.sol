// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "../interfaces/IDataObject.sol";
import "../interfaces/IDataIndex.sol";
import "../interfaces/IDataPointRegistry.sol";
import "../utils/DataPoints.sol";
import "openzeppelin-contracts/contracts/utils/Context.sol";

/**
 * @title VoteDataObject
 * @dev Stores voting data in compliance with ERC-7208.
 */
contract VoteDataObject is IDataObject {
    // Mapping from DataPoint to vote data
    mapping(DataPoint => uint256) private _votes;
    mapping(DataPoint => address) private _voters;

    // Data Index implementation
    IDataIndex private _dataIndex;

    /**
     * @dev Sets the DataIndex implementation.
     * @param dp The DataPoint identifier.
     * @param newImpl The new DataIndex implementation address.
     */
    function setDataIndexImplementation(DataPoint dp, IDataIndex newImpl) external override {
        (, address registry, ) = DataPoints.decode(dp);
        require(IDataPointRegistry(registry).isAdmin(dp, msg.sender), "Not DataPoint admin");

        _dataIndex = newImpl;
    }

    /**
     * @dev Reads stored data.
     * @param dp The DataPoint identifier.
     * @param operation The read operation selector.
     * @param data Operation-specific data.
     * @return Operation-specific data.
     */
    function read(DataPoint dp, bytes4 operation, bytes calldata data) external view override returns (bytes memory) {
        if (operation == bytes4(keccak256("getVote()"))) {
            uint256 filmId = _votes[dp];
            return abi.encode(filmId);
        } else if (operation == bytes4(keccak256("getVoter()"))) {
            address voter = _voters[dp];
            return abi.encode(voter);
        } else if (operation == bytes4(keccak256("getIdentityOwner()"))) {
            // Retrieve identity owner from IdentityDataObject
            // This assumes the IdentityDataObject address is known
            // Alternatively, store the IdentityDataObject address in the constructor
            revert("Identity owner retrieval not implemented");
        } else {
            revert("Unknown read operation");
        }
    }

    /**
     * @dev Stores data.
     * @param dp The DataPoint identifier.
     * @param operation The write operation selector.
     * @param data Operation-specific data.
     * @return Operation-specific data (can be empty).
     */
    function write(DataPoint dp, bytes4 operation, bytes calldata data) external override returns (bytes memory) {
        require(msg.sender == address(_dataIndex), "Caller is not DataIndex");

        if (operation == bytes4(keccak256("storeVote(address,uint256)"))) {
            (address voter, uint256 filmId) = abi.decode(data, (address, uint256));
            require(_votes[dp] == 0, "Vote already cast");
            _votes[dp] = filmId;
            _voters[dp] = voter;
            return "";
        } else {
            revert("Unknown write operation");
        }
    }
}
