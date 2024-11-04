TECHNICAL DOCUMENT :

ERC-7208, usage and paradigme.

The most important thing that differentiate ERC-7208 from other token factories, is that the data can be stored on chain and can be upradeable. In order to do so, I separated the management smart contracts from the data smart contracts. If needed, they can call each others, but the separation make possible to manage the logic without having to modify the storage, or handle the data without the use of superfluous computation.
It also secures the storage by only enabling managers to decide who can write data, and at the same time data can be read by everyone.

The ERC-7208 could become some kind of layer zero for other tokens standards so they can keep their security, compliance and/or non-fungibility, and at the same time benefits from the inheritance of an adaptable token.

Design decisions.

The first thought is "How can I store those data on chain ?" and then "How that much data can be handled on-chain ?" And then I discovered the DataPoints.sol file from ERC-7208 and I thought that's where a big part of the wizardry happens. I was confronted with an error I already encounter, the "stack too deep" error but it's something that layer 2 of Ethereum would handle without spending too much in gas fees.

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
