# Lottery-Smart-Contract-V2
Second version of lottery smart contract using Chainlink VRF to select a random winning participant

**How it works:**
- Manager can open/close the lottery at anytime, except closing when there is existing participant playing
- Users need to pay 0.01 ETH to enter the lottery
- A minimum of 3 players required to pick the lottery winner
- Manager (contract creator) will use Chainlink VRF to randomly pick the winner
- No user can enter the lottery when the manager is selecting the winner
- The lottery balance will be transferred to the winner's address (with a 10% reduction for manager fee)

**Deployed on Sepolia Testnet**

Contract: 0xB6f4a026a92684f6ec186DAF6b2f029dcBA4063e

[View on Etherscan](https://sepolia.etherscan.io/address/0xB6f4a026a92684f6ec186DAF6b2f029dcBA4063e)
