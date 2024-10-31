// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "../interfaces/IDataIndex.sol";
import "../interfaces/IDataPointRegistry.sol";
import "../interfaces/IDataObject.sol";
import "../utils/DataPoints.sol";
import "../utils/ChainidTools.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @title IdentityManager
 * @dev Manages identity issuance using ERC-7208 standard.
 */
contract IdentityManager is Ownable {
    IDataPointRegistry public dataPointRegistry;
    IDataIndex public dataIndex;
    IDataObject public identityDataObject;

    // Event emitted when an identity is issued
    event IdentityIssued(address indexed to, DataPoint indexed dp);

    /**
     * @dev Constructor sets up the DataPointRegistry, DataIndex, and IdentityDataObject contracts.
     * @param _dataPointRegistry The address of the DataPointRegistry contract.
     * @param _dataIndex The address of the DataIndex contract.
     * @param _identityDataObject The address of the IdentityDataObject contract.
     */
    constructor(
        address _dataPointRegistry,
        address _dataIndex,
        address _identityDataObject
    ) Ownable(_msgSender()) {
        dataPointRegistry = IDataPointRegistry(_dataPointRegistry);
        dataIndex = IDataIndex(_dataIndex);
        identityDataObject = IDataObject(_identityDataObject);
    }

    /**
     * @dev Issues a new identity to the specified address.
     * @param to The address receiving the identity.
     * @return dp The DataPoint ID of the stored identity.
     */
    function issueIdentity(address to) external onlyOwner returns (DataPoint dp) {
        // Allocate a new DataPoint for the attendee
        dp = dataPointRegistry.allocate(to);

        // Grant this contract as an admin for the DataPoint
        dataPointRegistry.grantAdminRole(dp, address(this));

        // Allow this contract as a Data Manager for the DataPoint in the Data Index
        dataIndex.allowDataManager(dp, address(this), true);

        // Store the identity data in the IdentityDataObject via the Data Index
        // Here, we can store any necessary identity data. For simplicity, we'll store the attendee's address.
        bytes memory data = abi.encode(to);
        dataIndex.write(address(identityDataObject), dp, bytes4(keccak256("storeIdentity(address)")), data);

        emit IdentityIssued(to, dp);
    }

    /**
     * @dev Retrieves the owner of a given DataPoint.
     * @param dp The DataPoint to query.
     * @return owner The address of the identity owner.
     */
    function getIdentityOwner(DataPoint dp) external view returns (address owner) {
        bytes memory result = dataIndex.read(address(identityDataObject), dp, bytes4(keccak256("getIdentity()")), "");
        owner = abi.decode(result, (address));
    }
}
