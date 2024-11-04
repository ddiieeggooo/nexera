TECHNICAL DOCUMENT :

ERC-7208, usage and paradigme.

The most important thing that differentiates ERC-7208 from other token factories, is that the data can be stored on-chain and can be upradeable. In order to do so, I separated the management smart contracts from the data smart contracts. If needed, they can call each other. However, this separation allows us to manage the logic without modifying the storage and handle data efficiently without unnecessary computation.
It also secures the storage by only enabling managers to decide who can write data, and at the same time data can be read by everyone.

The ERC-7208 could become some kind of layer zero for other tokens standards so they can keep their security, compliance and/or non-fungibility, and at the same time benefits from the inheritance of an adaptable token.

Design decisions.

The first thought is "How can I store those data on chain ?" and then "How that much data can be handled on-chain ?" And then I discovered the DataPoints.sol file from ERC-7208 and I thought that's where a big part of the wizardry happens.

I encountered the "stack too deep" error, a problem I had faced before, due to the complexity and depth of function calls. I enabled the intermediate representation so it can compile. I think that Ethereum Layer 2 solutions can handle larger amounts of data more efficiently, which could be leveraged to optimize gas costs in a production environment.

TEST SUIT :

functions list:

/IdentityDataObject.sol :
write
read
setDataIndexImplementation

/IdentityManager.sol :
setTicketManager
issueIdentity
getIdentityOwner

/ProfitDataObject.sol :
setDataIndexImplementation
read
write

/ProfitSharingManager.sol :
setWinningFilm
claimProfit
calculateProfitShare
getTotalWinners

/TicketManager.sol :
purchaseTicket
withdrawFunds
setTicketPrice

/VoteDataObject.sol :
setDataIndexImplementation
read
write

/VotingManager.sol  :
castVote

To verify that the repository compile and the tests pass :

from your terminal run those commands :

mkdir ~/nexerachallenge
cd nexerachallenge
git clone git@github.com:ddiieeggooo/nexera.git
cd nexera
curl -L https://foundry.paradigm.xyz | bash
foundryup
forge install OpenZeppelin/openzeppelin-contracts
forge test -v
