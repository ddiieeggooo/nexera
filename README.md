TECHNICAL DOCUMENT :

ERC-7208, usage and paradigme.

The most important thing that differentiates ERC-7208 from other token factories, is that the data can be stored on-chain and can be upradeable. In order to do so, I separated the management smart contracts from the data smart contracts. If needed, they can call each other. However, this separation allows us to manage the logic without modifying the storage and handle data efficiently without unnecessary computation.
It also secures the storage by only enabling managers to decide who can write data, and at the same time data can be read by everyone.

The ERC-7208 could become some kind of layer zero for other tokens standards so they can keep their security, compliance and/or non-fungibility, and at the same time benefits from the inheritance of an adaptable token.

Design decisions.

The first thought is "How can I store those data on chain ?" and then "How that much data can be handled on-chain ?" And then I discovered the DataPoints.sol file from ERC-7208 and I thought that's where a big part of the wizardry happens. I was confronted with an error I already encounter, the "stack too deep" error but it's something that layer 2 of Ethereum would handle without spending too much in gas fees.

Approach to Utilizing ERC-7208 Architecture Patterns

I leveraged ERC-7208's modular design to separate concerns:

    Identity Management: Issuing on-chain identities to attendees using IdentityManager and IdentityDataObject contracts.
    Voting System: Allowing identities to cast votes anonymously through the VotingManager and storing votes in the VoteDataObject.
    Profit Sharing: Distributing profits to eligible voters using the ProfitSharingManager and tracking claims with ProfitDataObject.

This architecture ensures that each component can be upgraded or modified independently without affecting the overall system.
Test Suite
Functions List
/IdentityDataObject.sol

    write
    read
    setDataIndexImplementation

/IdentityManager.sol

    setTicketManager
    issueIdentity
    getIdentityOwner

/ProfitDataObject.sol

    setDataIndexImplementation
    read
    write

/ProfitSharingManager.sol

    setWinningFilm
    claimProfit
    calculateProfitShare
    getTotalWinners

/TicketManager.sol

    purchaseTicket
    withdrawFunds
    setTicketPrice

/VoteDataObject.sol

    setDataIndexImplementation
    read
    write

/VotingManager.sol

    castVote

Testing Approach

I designed a suite of tests to validate the functionality of each component, focusing on the critical aspects outlined in the challenge:

    On-Chain Identity Issuance:
        Testing that an identity is correctly issued when a ticket is purchased.
        Verifying that the identity data is stored securely and can be retrieved.
        Ensuring that only ticket holders receive identities.

    Voting Mechanism:
        Verifying that each identity can cast only one vote.
        Ensuring that votes are recorded correctly and remain anonymous.
        Testing that duplicate voting is prevented and appropriately handled.

    Profit-Sharing Distribution:
        Simulating the selection of the winning film.
        Testing that only those who voted for the winning film can claim their profit share.
        Verifying the correct calculation and distribution of profits based on the number of eligible voters.

Sample Test Cases

    test_PurchaseTicket():
        Verifies that a ticket purchase results in identity issuance.
        Checks that the purchaser's address is associated with an identity token.

    test_CastVote():
        Ensures that a valid identity can cast a vote for a film.
        Confirms that attempting to vote again results in a revert with the appropriate error message.

    test_ClaimProfit():
        Simulates the scenario where a winning film is set.
        Tests that voters for the winning film can claim their profit.
        Ensures that non-voters or those who voted for other films cannot claim profits.

How to Verify Compilation and Test Success

To verify that the repository compiles and the tests pass, run the following commands in your terminal:

mkdir ~/nexerachallenge  
cd nexerachallenge  
git clone git@github.com:ddiieeggooo/nexera.git  
cd nexera  
curl -L https://foundry.paradigm.xyz | bash  
foundryup  
forge install OpenZeppelin/openzeppelin-contracts  
forge test -v  
