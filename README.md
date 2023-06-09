# DUAToken

Is our token for Ethereum and other ethereum/ERC20 compatible chains. It has the following functionalities:

* minting
* burning
* pausing
* blacklisting
* adding minter, burner, and admin roles
* self-destructing minting, burning, pausing, adding minter and adding admin functionalities

The contract inherits from OpenZeppelin's `ERC20`, `ERC20Burnable`, `AccessControl`, and `ERC20Pausable`.

## Functional Requirements

### Variables

`_cap`: The cap or maximum total supply of the token.

**Caution**: Turning the variables below to false, is an irreversible process.

`_destructPause`: A boolean to destruct the pause and unpause functionalities for the token.

`_destructMint`: A boolean to destruct the mint function for the token.

`_destructBurn`: A boolean to destruct the burn function for the token.

`_destructAddMinter`: A boolean to destruct the addMinter (can't add new minters) function for the token.

`_destructAddAdmin`: A boolean to destruct the addAdmin (can't add new admins) function for the token.

## Functions

`constructor(string memory name, string memory symbol, address adminRole, address minterRole, address burnerRole, uint256 cap_)`: Constructor that initializes the token with its name, symbol, admin, minter, and burner role addresses and max total supply of the token. It also initiates \_destructPause, \_destructMint, \_destructBurn, \_destructAddMinter and \_destructAddAdmin to false.

`mint(address to, uint256 amount)`: Mint new tokens. Only accessible by the minter role. Checks if the minting functionality has been self-destructed before calling the normal \_mint function.

`burn(uint256 amount)`: Burn tokens. Only accessible by the burner role. Checks if the burning functionality has been self-destructed before calling the normal \_burn function.

`pause()`: Pause the token. Only accessible by the admin role. Checks if the pausing functionality has been self-destructed before calling the normal \_pause function.

`unpause()`: Unpause the token. Only accessible by the admin role. Checks if the unpausing functionality has been self-destructed before calling the normal \_unpause function.

`addToBlacklist(address account)`: Add an address to the blacklist. Only accessible by the admin role.

`removeFromBlacklist(address account)`: Remove an address from the blacklist. Only accessible by the admin role.

`addMinter(address account)`: Add an address to the minter role. Only accessible by the admin role. Checks if the addMinter functionality has been self-destructed before granting the MINTER\_ROLE.

`addBurner(address account)`: Add an address to the burner role. Only accessible by the admin role.

`addAdmin(address account)`: Add an address to the admin role. Only accessible by the admin role. Checks if the addAdmin functionality has been self-destructed before granting the ADMIN\_ROLE.

`cap()`: Returns the cap on the token's total supply.

`_beforeTokenTransfer(address from, address to, uint256 amount)`: Checks if (to and from) addresses are blacklisted before calling normal \_beforeTokenTransfer.

`_mint(address account, uint256 amount)`: Mint new tokens. Checks if the address is blacklisted and the cap is reached before calling normal \_mint.

`_burn(address account, uint256 amount)`: Burn tokens. Checks if the address is blacklisted before calling normal \_burn.

Note: The self-destruct functions are irreversible and should be used with caution.

## Roles

The contract defines the following roles:

`MINTER_ROLE`: The role that allows minting new tokens.

`BURNER_ROLE`: The role that allows burning tokens.

`ADMIN_ROLE`: The role that allows pausing the token, adding new minters, new burners and admins, and self-destructing functions.

`BLACKLISTED_ROLE`: The role that blacklists addresses from transferring tokens.

## Events

### SelfDestructed Event

The SelfDestructed event is emitted in a Solidity contract and is used to indicate the self-destruction of specific functionalities within the contract. The event provides information about the type of functionality that has been self-destructed through an integer parameter.

### Functionality Codes

The `SelfDestructed` event uses an integer parameter to represent different functionality codes, which are as follows:

- 0: All functionalities
- 1: Pause functionality
- 2: Minting functionality
- 3: Burning functionality
- 4: Add Minter addresses functionality
- 5: Adding new Admins functionality

### Usage

The `SelfDestructed` event is triggered by calling the corresponding self-destruct functions in the contract, such as `selfDestructAllRoles()`, `selfDestructPause()`, `selfDestructMint()`, `selfDestructBurn()`, `selfDestructAddMinter()`, and `selfDestructAddAdmin()`. These functions can only be accessed by an admin role, as indicated by the `onlyRole(ADMIN_ROLE)` modifier.

When one of these functions is called and the self-destruction of a specific functionality is successful, the corresponding functionality code is passed as an argument to the SelfDestructed event. This allows external parties to listen for the event and take appropriate actions based on the functionality that has been self-destructed.

### Purpose

The purpose of the SelfDestructed event is to provide transparency and information about the self-destruction of specific functionalities within the contract. It allows external parties to be notified when a functionality has been self-destructed and take necessary actions accordingly. This event can be used for auditing, monitoring, and tracking the changes in the contract's functionalities over time.

Note: It is important to exercise caution when using self-destruct functions, as they permanently remove functionalities from the contract and cannot be undone. Proper security measures and permissions should be implemented to ensure that only authorized parties can trigger the self-destruction of functionalities within the contract.

## Dependencies

The contract imports the following OpenZeppelin contracts:

`ERC20.sol`: The basic ERC20 token contract.

`ERC20Burnable.sol`: The contract that allows burning tokens.

`ERC20Pausable.sol`: The contract that allows pausing the token.

`AccessControl.sol`: The contract that manages roles and role-based access control.


## How to Deploy

1. Configure networks at `hardhat.config.ts`
2. Add credentials at `.envexample`, copy `.envexample` to `.env`
3. Run the deployment script `npx hardhat run scripts/deploytETHToken --network YOURNETWORK`

## Tests
1. Can be run using `npx hardhat test test/ETH_DUA.ts`
