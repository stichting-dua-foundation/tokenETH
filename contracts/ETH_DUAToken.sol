// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


contract DUAToken is ERC20, ERC20Burnable, AccessControl, ERC20Pausable {
    /*
    * @dev The DUAToken contract is an ERC20 token with the following functionalities:
        * - minting
        * - burning
        * - pausing
        * - blacklisting
        * - adding minter, burner and admin roles
        * - self-destructing minting, burning, pausing, adding minter and adding admin functionalities
    */
    
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant BLACKLISTED_ROLE = keccak256("BLACKLISTED_ROLE");

    bool private _destructPause; //destruct the pause and unpause functionalities for the token. WARNING: this is irreversible
    bool private _destructMint; //destruct the mint function for the token. WARNING: this is irreversible
    bool private _destructBurn; //destruct the burn function for the token. WARNING: this is irreversible
    bool private _destructAddMinter; //destruct the addMinter (can't add new minters) function for the token. WARNING: this is irreversible
    bool private _destructAddAdmin; //destruct the addAdmin (can't add new admins) function for the token. WARNING: this is irreversible

    // The cap or max total supply of the token.
    uint256 private immutable _cap;

    /**
     * @dev initiates the token with its name, symbol, admin, minter and burner role addresses and max total supply of the token. It also initiates _destructPause, _destructMint, _destructBurn, _destructAddMinter and _destructAddAdmin to false.
     */

    constructor(string memory name, string memory symbol, uint256 cap_, address adminRole, address minterRole, address burnerRole) ERC20(name, symbol) {
        require(cap_ > 0, "DUA: cap is 0");
        _cap = cap_;

        _setupRole(ADMIN_ROLE, adminRole);
        _setupRole(MINTER_ROLE, minterRole);
        _setupRole(BURNER_ROLE, burnerRole);
        _setupRole(DEFAULT_ADMIN_ROLE, adminRole);

    }

    /**
    *  @dev emits an event for self destruction of particular functionality.
    */

    event SelfDestructed(string functionality);

    /**
    *  @dev Checks if the minting functionality has been self-destructed. If not, it calls the normal _mint function, only accessible by the minter role.
    */
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        require(!_destructMint, "Minting functionality has been self-destructed");
        _mint(to, amount);
    }

    /**
    *  @dev Checks if the burning functionality has been self-destructed. If not, it calls the normal _burn function, only accessible by the burner role.
    */

    function burn(uint256 amount) public virtual override onlyRole(BURNER_ROLE){
        require(!_destructBurn, "Burning functionality has been self-destructed");
        _burn(_msgSender(), amount);
    }

    /**
    *  @dev Checks if the pausing functionality has been self-destructed. If not, it calls the normal _pause function, only accessible by the admin role.
    */

    function pause() public onlyRole(ADMIN_ROLE) {
        require(!_destructPause, "Pausable functionality has been self-destructed");
        _pause();
    }

    /**
    *  @dev Checks if the unpausing functionality has been self-destructed. If not, it calls the normal _unpause function, only accessible by the admin role.
    */

    function unpause() public onlyRole(ADMIN_ROLE) {
        require(!_destructPause, "Pausable functionality has been self-destructed");
        _unpause();
    }

    /**
    *  @dev adds an address to the blacklist. Only accessible by the admin role.
    */

    function addToBlacklist(address account) public onlyRole(ADMIN_ROLE) {
        _grantRole(BLACKLISTED_ROLE, account);
    }

    /**
    *  @dev removes an address to the blacklist. Only accessible by the admin role.
    */

    function removeFromBlacklist(address account) public onlyRole(ADMIN_ROLE) {
        _revokeRole(BLACKLISTED_ROLE, account);
    }


    /**
    *  @dev adds an address to the minter role. Only accessible by the admin role.
    */

    function addMinter(address account) public onlyRole(ADMIN_ROLE) {
        require(!_destructAddMinter, "Minter addition functionality has been self-destructed");
        _grantRole(MINTER_ROLE, account);
    }

    /**
    *  @dev adds an address to the burner role. Only accessible by the admin role.
    */

    function addBurner(address account) public onlyRole(ADMIN_ROLE) {
        _grantRole(BURNER_ROLE, account);
    }

    /**
    *  @dev adds an address to the admin role. Only accessible by the admin role.
    */

    function addAdmin(address account) public onlyRole(ADMIN_ROLE) {
        require(!_destructAddAdmin, "Admin addition functionality has been self-destructed");
        _grantRole(ADMIN_ROLE, account);
    }


     /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() external view virtual returns (uint256) {
        return _cap;
    }

    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     * @dev Checks if (to and from) addresses are blacklisted and calls normal _beforeTokenTransfer.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) whenNotPaused internal virtual override(ERC20, ERC20Pausable) {
        require(!hasRole(BLACKLISTED_ROLE, msg.sender), "Token transfer refused. msg.sender is blacklisted.");
        require(!hasRole(BLACKLISTED_ROLE, from), "Token transfer refused. Sender is blacklisted.");
        require(!hasRole(BLACKLISTED_ROLE, to), "Token transfer refused. Receiver is blacklisted.");
    }

    /**
     * @dev See {ERC20-_mint}.
     * @dev Checks if address is blacklisted and cap is reached and calls normal _mint.
     */

    function _mint(address account, uint256 amount) whenNotPaused internal virtual override(ERC20) {
        require(!hasRole(BLACKLISTED_ROLE, account), "Mint refused. Address is blacklisted.");
        require(totalSupply() + amount <= _cap, "DUA: cap exceeded");
        super._mint(account, amount);
    }
    
    /**
     * @dev See {ERC20-_burn}.
     * @dev Checks if address is blacklisted and calls normal _burn.
     */
    function _burn(address account, uint256 amount) whenNotPaused internal virtual override(ERC20) {
        require(!hasRole(BLACKLISTED_ROLE, account), "Burn refused. Address is blacklisted.");
        super._burn(account, amount);
    }

    /**
     * @dev See {ERC20-_afterTokenTransfer}.
     * @dev Calls normal _afterTokenTransfer.
     */

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20) {
        super._afterTokenTransfer(from, to, amount);
    }


    /* WARNING: IRREVERSIBLE FUNCTIONS */

    /**
    *  @dev Self-destructs the adding minters, adding new admins, minting, burning and pausability functionality. Only accessible by the admin role.
    */

    function selfDestructAllRoles() public onlyRole(ADMIN_ROLE) {
        _destructPause = true;
        _destructMint = true;
        _destructBurn = true;
        _destructAddMinter = true;
        _destructAddAdmin = true;
        emit SelfDestructed("All Roles");
    }

    /**
    *  @dev Self-destructs the pausing functionality. Only accessible by the admin role.
    */

    function selfDestructPause() public onlyRole(ADMIN_ROLE) {
        _destructPause = true;
        emit SelfDestructed("Pause");
    }

    /**
    *  @dev Self-destructs the minting functionality. Only accessible by the admin role.
    */

    function selfDestructMint() public onlyRole(ADMIN_ROLE) {
        _destructMint = true;
        emit SelfDestructed("Mint");
    }

    /**
    *  @dev Self-destructs the burning functionality. Only accessible by the admin role.
    */
    function selfDestructBurn() public onlyRole(ADMIN_ROLE) {
        _destructBurn = true;
        emit SelfDestructed("Burn");
    }

    /**
    *  @dev Self-destructs the add new Minter addresses functionality. Only accessible by the admin role.
    */
    function selfDestructAddMinter() public onlyRole(ADMIN_ROLE) {
        _destructAddMinter = true;
        emit SelfDestructed("Add Minter");
    }

    /**
    *  @dev Self-destructs the adding new admins. Only accessible by the admin role.
    */
    function selfDestructAddAdmin() public onlyRole(ADMIN_ROLE) {
        _destructAddAdmin = true;
        emit SelfDestructed("Add Admin");
    }

}


