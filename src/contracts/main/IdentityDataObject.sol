// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "../interfaces/IDataObject.sol";
import "../interfaces/IDataIndex.sol";
import "../interfaces/IDataPointRegistry.sol";
import "../utils/DataPoints.sol";
import "openzeppelin-contracts/contracts/utils/Context.sol";

/**
 * @title IdentityDataObject
 * @dev Stores identity data in compliance with ERC-7208.
 */
contract IdentityDataObject is IDataObject {
    // Mapping from DataPoint to identity data (e.g., owner address)
    mapping(DataPoint => address) private _identities;

    // Data Index implementation
    IDataIndex private _dataIndex;

    /**
     * @dev Sets the DataIndex implementation.
     * @param dp The DataPoint identifier.
     * @param newImpl The new DataIndex implementation address.
     */
    function setDataIndexImplementation(DataPoint dp, IDataIndex newImpl) external override {
        // Ensure only the DataPoint admin can set the DataIndex implementation
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
        if (operation == bytes4(keccak256("getIdentity()"))) {
            address owner = _identities[dp];
            return abi.encode(owner);
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

        if (operation == bytes4(keccak256("storeIdentity(address)"))) {
            address to = abi.decode(data, (address));
            _identities[dp] = to;
            return "";
        } else {
            revert("Unknown write operation");
        }
    }
}
