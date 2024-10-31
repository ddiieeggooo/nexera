// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./IdentityManager.sol";
import "../interfaces/IDataIndex.sol";
import "../interfaces/IDataPointRegistry.sol";
import "../interfaces/IDataObject.sol";
import "../utils/DataPoints.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title TicketManager
 * @dev Manages ticket sales and issues identities upon purchase.
 */
contract TicketManager is Ownable {
    IdentityManager public identityManager;
    uint256 public ticketPrice;
    address initialOwner;
    mapping(address => bool) public hasPurchasedTicket;

    // Event emitted when a ticket is purchased
    event TicketPurchased(address indexed buyer, DataPoint indexed dp);

    /**
     * @dev Constructor sets up the IdentityManager and ticket price.
     * @param _identityManager The address of the IdentityManager contract.
     * @param _ticketPrice The price of a ticket in wei.
     */
    constructor(address _identityManager, uint256 _ticketPrice) Ownable(initialOwner) {
        identityManager = IdentityManager(_identityManager);
        ticketPrice = _ticketPrice;
    }

    /**
     * @dev Allows a user to purchase a ticket and receive an identity.
     */
    function purchaseTicket() external payable {
        require(msg.value == ticketPrice, "Incorrect ticket price");
        require(!hasPurchasedTicket[msg.sender], "Ticket already purchased");

        // Mark the ticket as purchased
        hasPurchasedTicket[msg.sender] = true;

        // Issue an identity to the buyer via the IdentityManager
        DataPoint dp = identityManager.issueIdentity(msg.sender);

        emit TicketPurchased(msg.sender, dp);
    }

    /**
     * @dev Allows the owner to withdraw funds from ticket sales.
     */
    function withdrawFunds() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    /**
     * @dev Allows the owner to set a new ticket price.
     * @param _newPrice The new ticket price in wei.
     */
    function setTicketPrice(uint256 _newPrice) external onlyOwner {
        ticketPrice = _newPrice;
    }
}
