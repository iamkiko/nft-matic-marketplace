# NFT Marketplace on MATIC Testnet

[Source](https://dev.to/dabit3/building-scalable-full-stack-apps-on-ethereum-with-polygon-2cfb)

## NB/Gotchas:
a) When deploying with `npx hardhat run scripts/deploy` be sure to update your deployment addresses in `config.js`

b) Create a .env and populate it with your `POLYGON_ENDPOINT` (usually from Infura) and `PRIVATE_KEY` from Metamask under your account settings

c) If you receive a `Error: MetaMask - RPC Error: Internal JSON-RPC error` then ensure your wallet and codebase are using the same Mumbai RPC Testnet
