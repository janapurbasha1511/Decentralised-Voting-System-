# Decentralized Voting System

A tamper-proof, allowlist-based election running on a local Ethereum network. Built as a mini project for the Blockchain Technology course.

**Authors:** Aryan Soman Nair (24215204) and Purbasha Jana (24215219), Christ (Deemed to be) University

## What it does

A Solidity smart contract runs the whole election:

- **Setup phase:** the admin adds candidates and registers voter wallets (the allowlist).
- **Admin-triggered voting:** the admin calls `startVoting(minutes)`. Setup is then permanently locked.
- **One vote per wallet:** only allowlisted addresses can vote, and only once.
- **Time-locked results:** `getResults()` reverts until the voting window has ended.

## Tools used

| Tool | Role |
|---|---|
| Solidity | Smart contract language |
| Hardhat | Local Ethereum blockchain (chain ID 31337) |
| MetaMask | Wallet that signs every transaction |
| Remix IDE | Compile, deploy and call the contract |
| HTML + ethers.js | Voting front end |

## Project structure

```
contracts/Voting.sol            the smart contract
frontend/voting-frontend.html   voter-facing page
docs/                           project presentation
hardhat.config.ts               Hardhat network config
```

## How to run

1. **Install Node.js**, then in the project folder run `npm install`.
2. **Start the local chain:** `npx hardhat node` (keep this terminal open). It prints 20 funded test accounts.
3. **Set up MetaMask:** add a network with RPC `http://127.0.0.1:8545`, chain ID `31337`, symbol `ETH`. Import a few of the Hardhat test accounts (one as Admin, two as voters, one left unregistered).
4. **Deploy in Remix:** open `contracts/Voting.sol` in [remix.ethereum.org](https://remix.ethereum.org), compile it, choose *Browser Extension → MetaMask* as the environment, and deploy as Admin. Copy the contract address.
5. **Configure the election as Admin:** call `addCandidate`, `addVoter` (for each voter) and `startVoting(minutes)`.
6. **Serve the front end:** from the `frontend` folder run `python -m http.server 5500` and open `http://localhost:5500/voting-frontend.html`.
7. Paste the contract address into the page, click **Save**, then **Connect Wallet** and vote.

> The Hardhat test accounts and keys are the same on every install and are public. Never send real funds to them.

## Known limitations

- **Block timestamp delay:** Hardhat only mines a block when a transaction arrives, so `block.timestamp` and `timeRemaining()` can lag behind real time. Force a block with:
  ```
  curl -X POST http://127.0.0.1:8545 -H "Content-Type: application/json" -d "{\"jsonrpc\":\"2.0\",\"method\":\"evm_mine\",\"params\":[],\"id\":1}"
  ```
- After restarting the Hardhat node, the chain resets: redeploy the contract, and re-import MetaMask accounts if transactions fail with nonce errors.
- Vote counts are stored publicly on-chain during voting; the time-lock hides them only from the contract's API. Commit-reveal would give true secrecy.
- A single admin controls the voter allowlist, which is a central point of trust.
- Voting windows cannot be extended once started.

## Future scope

- **Multi-admin approval (M-of-N):** adding voters, removing voters and starting the vote would require several admins to approve before the action runs.
- **Admins on separate devices:** run the node with `npx hardhat node --hostname 0.0.0.0` so each admin signs from their own laptop on the same LAN.
- **Real network:** deploy to a permissioned consortium chain or a public Ethereum testnet so no single machine hosts the chain.
- Commit-reveal ballots and identity-linked voter registration.
