// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "../interfaces/IDataIndex.sol";
import "../interfaces/IDataPointRegistry.sol";
import "../interfaces/IDataObject.sol";
import "../utils/DataPoints.sol";
import "../utils/ChainidTools.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title IdentityManager
 * @dev Manages identity issuance using ERC-7208 standard.
 */
//

contract IdentityManager is Ownable {
    IDataPointRegistry public dataPointRegistry;
    IDataIndex public dataIndex;
    IDataObject public identityDataObject;
    address public ticketManager;
    // Mapping from DataPoint to owner address
    mapping(DataPoint => address) public identityOwners;

    // Event emitted when an identity is issued
    event IdentityIssued(address indexed to, DataPoint indexed dp);

    /**
     * @dev Modifier to restrict functions to the TicketManager contract.
     */
    modifier onlyTicketManager() {
        require(msg.sender == ticketManager, "Caller is not TicketManager");
        _;
    }

    /**
     * @dev Constructor sets up the DataPointRegistry, DataIndex, and IdentityDataObject contracts.
     * @param _dataPointRegistry The address of the DataPointRegistry contract.
     * @param _dataIndex The address of the DataIndex contract.
     * @param _identityDataObject The address of the IdentityDataObject contract.
     * @param initialOwner The address to set as the initial owner.
     */
    constructor(
        address _dataPointRegistry,
        address _dataIndex,
        address _identityDataObject,
        address initialOwner
    ) Ownable(initialOwner) {
        dataPointRegistry = IDataPointRegistry(_dataPointRegistry);
        dataIndex = IDataIndex(_dataIndex);
        identityDataObject = IDataObject(_identityDataObject);
    }

    /**
     * @dev Sets the TicketManager contract address.
     * @param _ticketManager The address of the TicketManager contract.
     */
    function setTicketManager(address _ticketManager) external onlyOwner {
        ticketManager = _ticketManager;
    }

    /**
     * @dev Issues a new identity to the specified address.
     * @param to The address receiving the identity.
     * @return dp The DataPoint ID of the stored identity.
     */
    function issueIdentity(
        address to
    ) external onlyTicketManager returns (DataPoint dp) {
        // Allocate a new DataPoint for the attendee
        dp = dataPointRegistry.allocate(to);

        // Store the owner in the mapping
        identityOwners[dp] = to;

        // Emit event
        emit IdentityIssued(to, dp);
    }

    /**
     * @dev Retrieves the owner of a given DataPoint.
     * @param dp The DataPoint to query.
     * @return owner The address of the identity owner.
     */
    function getIdentityOwner(
        DataPoint dp
    ) external view returns (address owner) {
        owner = identityOwners[dp];
    }

    function storeIdentityData(DataPoint dp) external {
        // Verify that the caller is the owner of the DataPoint
        require(
            identityOwners[dp] == msg.sender,
            "Caller is not DataPoint owner"
        );

        // Allow the caller as a DataManager for their DataPoint in the DataIndex
        dataIndex.allowDataManager(dp, msg.sender, true);

        // Store the identity data in the IdentityDataObject via the Data Index
        bytes memory data = abi.encode(msg.sender);
        dataIndex.write(
            address(identityDataObject),
            dp,
            bytes4(keccak256("storeIdentity(address)")),
            data
        );
    }
}
