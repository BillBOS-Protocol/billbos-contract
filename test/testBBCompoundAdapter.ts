import { ethers } from "hardhat";
import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";

const minute = 60;
const hour = minute * 60;
const day = hour * 24;

const dayStaked = 365;
const stakingAmount = 1000;
const expectedReturn = 1100;

describe("BBCompoundAdapter", () => {
  async function bbCompoundAdapterFixture() {
    const [owner, billBOS] = await ethers.getSigners();
    const MockUSDT = await ethers.getContractFactory("MockERC20");
    const MockCompound = await ethers.getContractFactory("MockCompound");
    const BBCompoundAdapter = await ethers.getContractFactory(
      "BBCompoundAdapter"
    );

    const mockUSDT = await MockUSDT.connect(owner).deploy("USDT");
    await mockUSDT.waitForDeployment();
    const usdtAddress = await mockUSDT.getAddress();

    const mockCompound = await MockCompound.connect(owner).deploy(
      usdtAddress,
      "10"
    );
    await mockCompound.waitForDeployment();
    const mockCompoundAddress = await mockCompound.getAddress();

    const bbCompoundAdapter = await BBCompoundAdapter.connect(owner).deploy(
      usdtAddress,
      mockCompoundAddress,
      billBOS.address
    );
    await bbCompoundAdapter.waitForDeployment();

    await (
      await mockUSDT
        .connect(owner)
        .mint(mockCompoundAddress, ethers.parseEther("10000000"))
    ).wait();

    await (
      await mockUSDT.connect(owner).mint(billBOS, ethers.parseEther("1000"))
    ).wait();

    return { billBOS, mockUSDT, mockCompound, bbCompoundAdapter };
  }

  it("should deploy", async () => {
    await loadFixture(bbCompoundAdapterFixture);
  });

  it("should work", async () => {
    const { billBOS, mockUSDT, bbCompoundAdapter } = await loadFixture(
      bbCompoundAdapterFixture
    );

    const stakeAmount = ethers.parseEther(stakingAmount.toString());

    // const usdtBeforeStake = await mockUSDT.balanceOf(billBOS.address);

    // console.log(
    //   "USDT balance of billBOS (Before Stake): ",
    //   ethers.formatEther(usdtBeforeStake)
    // );

    await (
      await mockUSDT
        .connect(billBOS)
        .approve(bbCompoundAdapter.getAddress(), stakeAmount)
    ).wait();

    await (await bbCompoundAdapter.connect(billBOS).stake(stakeAmount)).wait();

    await time.increase(dayStaked * day);

    const balanceInMockCompoundAfter =
      await bbCompoundAdapter.getStakedBalance();

    await (
      await bbCompoundAdapter
        .connect(billBOS)
        .unstake(balanceInMockCompoundAfter)
    ).wait();

    const usdtAfterStake = await mockUSDT.balanceOf(billBOS.address);

    // console.log(
    //   "USDT balance of billBOS (After UnStake): ",
    //   ethers.formatEther(usdtAfterStake)
    // );

    expect(+ethers.formatEther(usdtAfterStake)).to.equal(expectedReturn);
  });
});
