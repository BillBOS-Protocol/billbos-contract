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

describe("BillBOSCore", () => {
  async function bbCompoundAdapterFixture(billBOS: string) {
    const [owner] = await ethers.getSigners();
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
      billBOS
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

  async function billBOSCoreFixture() {
    const [owner] = await ethers.getSigners();
    const BillBOSCore = await ethers.getContractFactory("BillBOSCore");
    const mockInitial = "0xF28cAc2532d77826C725C6092A15E98a50c79FD0";
    const billBOSCore = await BillBOSCore.connect(owner).deploy(mockInitial);
    return { owner, billBOSCore };
  }

  async function bothFixture() {
    const { billBOSCore, owner } = await billBOSCoreFixture();
    const { mockUSDT, mockCompound, bbCompoundAdapter } =
      await bbCompoundAdapterFixture(await billBOSCore.getAddress());
    return { billBOSCore, owner, mockUSDT, mockCompound, bbCompoundAdapter };
  }

  describe("BillBOSCore Setup", () => {
    it("should be deploy", async () => {
      await loadFixture(billBOSCoreFixture);
    });

    it("should be connect with bbCompoundAdapter contract", async () => {
      const { billBOSCore, owner, bbCompoundAdapter } = await loadFixture(
        bothFixture
      );
      const bbCompoundAdapterAddress = await bbCompoundAdapter.getAddress();
      await billBOSCore
        .connect(owner)
        .setBillbosAdaptorAddress(bbCompoundAdapterAddress);
      expect(await billBOSCore.billbosAdaptorAddress()).to.equal(
        bbCompoundAdapterAddress
      );
    });
  });

  describe("BillBOSCore Ads", () => {
    const mockAds = {
      name: "mockAds1",
      imageCID: "cid123",
      newTabLink: "http://localhost:3000",
      widgetLink: "",
      isInteractive: false,
    };
    describe("BillBOSCore Ads Create", () => {});
    it("should be create new ads", async () => {
      const { billBOSCore, owner } = await loadFixture(billBOSCoreFixture);
      await billBOSCore.connect(owner).createAds(mockAds, 1);
    });
    it("should revert if amount is less than 0", async () => {
      const { billBOSCore, owner } = await loadFixture(billBOSCoreFixture);
      await expect(
        billBOSCore.connect(owner).createAds(mockAds, 0)
      ).to.be.revertedWith("BillBOSCore: amount must be more than 0");
    });
    it("should be update ads", async () => {});
  });

  describe("BillBOSCore Boost/Unboost", () => {});

  describe("BillBOSCore Claim", () => {});

  // it("should work", async () => {
  //   const { billBOS, mockUSDT, bbCompoundAdapter } = await loadFixture(
  //     bbCompoundAdapterFixture
  //   );

  //   const stakeAmount = ethers.parseEther(stakingAmount.toString());

  //   // const usdtBeforeStake = await mockUSDT.balanceOf(billBOS.address);

  //   // console.log(
  //   //   "USDT balance of billBOS (Before Stake): ",
  //   //   ethers.formatEther(usdtBeforeStake)
  //   // );

  //   await (
  //     await mockUSDT
  //       .connect(billBOS)
  //       .approve(bbCompoundAdapter.getAddress(), stakeAmount)
  //   ).wait();

  //   await (await bbCompoundAdapter.connect(billBOS).stake(stakeAmount)).wait();

  //   await time.increase(dayStaked * day);

  //   const balanceInMockCompoundAfter =
  //     await bbCompoundAdapter.getStakedBalance();

  //   await (
  //     await bbCompoundAdapter
  //       .connect(billBOS)
  //       .unstake(balanceInMockCompoundAfter)
  //   ).wait();

  //   const usdtAfterStake = await mockUSDT.balanceOf(billBOS.address);

  //   // console.log(
  //   //   "USDT balance of billBOS (After UnStake): ",
  //   //   ethers.formatEther(usdtAfterStake)
  //   // );

  //   expect(+ethers.formatEther(usdtAfterStake)).to.equal(expectedReturn);
  // });
});
