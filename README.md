# Mama Mia's Pizza NFT Contract

## Overview
Mama Mia's Pizza is an Italian-themed NFT collection representing artisanal pizza NFTs with unique attributes inspired by classic Italian flavors and styles. This smart contract allows users to mint, manage, and trade these NFTs on the Stacks blockchain.

### Key Features
- **Customizable Pizza Attributes**: Each NFT is randomly generated with unique traits, including crust type, toppings, size, sauce, and rarity.
- **Special Traits**: Pizzas can have characteristics like vegetarian, spicy, and cheesy.
- **Whitelist and Public Minting**: Special pricing for whitelist participants.
- **Royalty Payments**: A 5% royalty fee is applied on secondary sales.
- **Collection Reveal**: Metadata can be updated to reveal the full collection.

---

## Contract Details

### Non-Fungible Token
The contract defines a non-fungible token (NFT) called `mama-mia`.

### Storage Variables
1. **NFT Attributes**: Stored in `pizza-attributes` for characteristics like crust, topping, size, sauce, and rarity.
2. **NFT Traits**: Stored in `pizza-traits` for specific boolean traits (e.g., vegetarian, spicy).
3. **Token Counter**: Tracks the total number of minted tokens.
4. **Minting Prices**: Public mint price (0.5 STX) and whitelist mint price (0.25 STX).
5. **Maximum Supply**: Capped at 1,000 tokens.
6. **Base URI**: URL for metadata, initially hidden.
7. **Whitelist**: Addresses eligible for discounted minting.
8. **Royalties**: 5% fee applied on resale transactions.

---

## Functions

### Read-Only Functions
1. **`get-last-token-id`**: Returns the ID of the last minted token.
2. **`get-owner(token-id)`**: Returns the owner of a given token.
3. **`get-pizza-attributes(token-id)`**: Retrieves the attributes of a specific pizza NFT.
4. **`get-pizza-traits(token-id)`**: Retrieves the traits of a specific pizza NFT.
5. **`is-whitelisted(address)`**: Checks if an address is on the whitelist.

### Public Functions

#### Minting
1. **`mint-pizza`**:
   - Mints a new pizza NFT.
   - Generates random attributes and traits.
   - Requires a payment of 0.5 STX.

2. **`whitelist-mint`**:
   - Allows whitelisted addresses to mint a pizza NFT at a discounted price of 0.25 STX.

#### Token Management
3. **`transfer(token-id, sender, recipient)`**:
   - Transfers ownership of a token.
   - Applies a 5% royalty fee on secondary sales.

#### Administrative
4. **`set-mint-price(new-price)`**: Updates the mint price.
5. **`set-whitelist-mint-price(new-price)`**: Updates the whitelist mint price.
6. **`add-to-whitelist(address)`**: Adds an address to the whitelist.
7. **`remove-from-whitelist(address)`**: Removes an address from the whitelist.
8. **`set-base-uri(new-base-uri)`**: Sets the base URI for metadata.
9. **`reveal-collection`**: Updates metadata to reveal the collection.
10. **`set-royalty-percent(new-percent)`**: Updates the royalty percentage.
11. **`withdraw-funds`**: Allows the contract owner to withdraw all funds.

---

## Constants
- **Contract Owner**: The address that deployed the contract.
- **Errors**:
  - `err-sold-out`: Max supply reached.
  - `err-insufficient-funds`: Insufficient STX for minting.
  - `err-not-owner`: Caller is not the owner.
  - `err-already-minted`: Token already minted.
  - `err-not-whitelisted`: Address not on the whitelist.
  - `err-invalid-token`: Token ID does not exist.
  - `err-not-revealed`: Metadata not yet revealed.
  - `err-invalid-percent`: Invalid royalty percentage.

---

## Usage Guide

### Minting Pizzas
1. Call `mint-pizza` or `whitelist-mint` with the appropriate STX payment.
2. After minting, query the pizza's attributes using `get-pizza-attributes`.

### Transferring Tokens
1. Use the `transfer` function to transfer tokens to another user.
2. Secondary sales automatically apply the royalty fee.

### Administration
- Update minting prices, whitelist addresses, or metadata using the administrative functions.
- Withdraw contract funds using `withdraw-funds`.

---

## License
This contract is licensed under an open-source license. Use and modify as needed with attribution to Mama Mia's Pizza NFT creators.