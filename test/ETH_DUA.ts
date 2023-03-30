import { ethers } from "hardhat";
import { expect } from "chai";
import { DUAToken } from "../typechain";


describe("DUAToken", function () {
  let token: DUAToken;
  let user: any;
  let admin: any;
  let minter: any;
  let burner: any;

  beforeEach(async function () {
    // Deploy DUAToken contract
    const DUATokenFactory = await ethers.getContractFactory(
      "contracts/ETH_DUAToken.sol:DUAToken"
    );
    [admin, minter, burner, user] = await ethers.getSigners();

    const cap = 1000000000;
    const capWei = ethers.utils.parseEther(cap.toString());
    //constructor(string memory name, string memory symbol, address adminRole, address minterRole, address burnerRole, uint256 cap_)

    token = (await DUATokenFactory.deploy(
      "DUA",
      "DUA",
      capWei,
      admin.address,
      minter.address,
      burner.address,  
    )) as DUAToken;
    
    // Mint 1000 tokens to self

    await token.connect(minter).mint(minter.address, 1000);

    //mint to burner
    await token.connect(minter).mint(burner.address, 1000);

    /*

        const currRole = await token.hasRole(minterRole, admin.address);
        console.log("is ",admin.address, " admin? : ", currRole);
        const userRole = await token.hasRole(minterRole, user.address);
        console.log("is ", user.address, " admin? : ", userRole);
    */
  });

  it("should have the correct name and symbol", async function () {
    expect(await token.name()).to.equal("DUA");
    expect(await token.symbol()).to.equal("DUA");
  });

  it("should have a total supply of 2000 tokens", async function () {
    expect(await token.totalSupply()).to.equal(2000);
  });

  it("should allow burning of tokens by burner", async function () {
    // Burn 1000 tokens as burner
    await token.connect(burner).burn(1000);

    // Check that the total supply is now 1000
    expect(await token.totalSupply()).to.equal(1000);
  });

  it("should allow the admin to pause and unpause the contract", async function () {
    // Pause the contract
    await token.connect(admin).pause();
    expect(await token.paused()).to.equal(true);

    // Unpause the contract
    await token.connect(admin).unpause();
    expect(await token.paused()).to.equal(false);
  });

  it("shouldn't allow a non-admin to pause and unpause the contract", async function () {
    // Pause the contract
    const role = ethers.utils.keccak256(
      ethers.utils.toUtf8Bytes("ADMIN_ROLE")
    );
    const error = `AccessControl: account ${user.address} is missing role ${role}`
    // console.log("error: ", error)
     expect( token.connect(user).pause()).to.be.revertedWith(error);
    

    // Unpause the contract
     expect( token.connect(user).unpause()).to.be.revertedWith(
      error
    );
    
  });

  it("should prevent transfers when the contract is paused", async function () {

    // Pause the contract
    await token.connect(admin).pause();

    const isPaused = await token.paused();
    expect(isPaused).to.equal(true);

    // Try to transfer tokens and expect the transfer to fail

    await expect(
      token.connect(minter).transfer(user.address, 100)
    ).to.be.revertedWith("Pausable: paused");

    // Unpause the contract
    await token.connect(admin).unpause();

    // Transfer tokens after unpausing the contract
    await token.connect(minter).transfer(user.address, 100);
    expect(await token.balanceOf(user.address)).to.equal(100);
  });

   it("should fail to pause and unpause the contract", async () => {

     // Self-destruct the pause functionality
     await token.connect(admin).selfDestructPause();

     // Try to pause the contract, expecting it to revert
     await expect(token.pause()).to.be.revertedWith(
       "Pausable functionality has been self-destructed"
     );

     // Try to unpause the contract, expecting it to revert
     await expect(token.unpause()).to.be.revertedWith(
       "Pausable functionality has been self-destructed"
     );
   });

   it("should fail to mint tokens", async () => {

     // Self-destruct the mint functionality
     await token.connect(admin).selfDestructMint();

     // Try to mint tokens, expecting it to revert
     await expect(token.connect(minter).mint(user.address, 100)).to.be.revertedWith(
       "Minting functionality has been self-destructed"
     );
   });

    it("should fail to burn tokens", async () => {

        // Self-destruct the burn functionality
        await token.connect(admin).selfDestructBurn();

        // Try to burn tokens, expecting it to revert
        await expect(token.connect(burner).burn(100)).to.be.revertedWith(
          "Burning functionality has been self-destructed"
        );
    });


    it("should fail to add new minters", async () => {

        // Self-destruct the addMinter functionality
        await token.connect(admin).selfDestructAddMinter();
        
        // Try to add a new minter, expecting it to revert
        await expect(
        token.addMinter(user.address)
        ).to.be.revertedWith(
        "Minter addition functionality has been self-destructed"
        );
    });

    it("should fail to add new admins", async () => {

        // Self-destruct the addAdmin functionality
        await token.connect(admin).selfDestructAddAdmin();

        // Try to add a new admin, expecting it to revert
        await expect(
        token.addAdmin(user.address)
        ).to.be.revertedWith(
        "Admin addition functionality has been self-destructed"
        );
    });



});
