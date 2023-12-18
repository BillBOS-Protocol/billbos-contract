import { ethers } from "hardhat";
import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";

describe("BillBOSCore", () => {
  const mockAds = {
    name: "mockAds1",
    imageCID: "cid123",
    newTabLink: "http://localhost:3000",
    widgetLink: "",
    isInteractive: false,
  };
  async function bbCompoundAdapterFixture(
    billBOS: string,
    usdtAddress: string
  ) {
    const [owner] = await ethers.getSigners();
    const MockCompound = await ethers.getContractFactory("MockCompound");
    const BBCompoundAdapter = await ethers.getContractFactory(
      "BBCompoundAdapter"
    );

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

    return { billBOS, mockCompound, bbCompoundAdapter };
  }

  async function billBOSCoreFixture(usdtAddress: string) {
    const [owner] = await ethers.getSigners();
    const BillBOSCore = await ethers.getContractFactory("BillBOSCore");
    const mockInitial = "0xF28cAc2532d77826C725C6092A15E98a50c79FD0";
    const billBOSCore = await BillBOSCore.connect(owner).deploy(
      mockInitial,
      usdtAddress
    );
    return { owner, billBOSCore };
  }

  async function bothFixture() {
    const [owner, player1, player2] = await ethers.getSigners();
    const MockUSDT = await ethers.getContractFactory("MockERC20");
    const mockUSDT = await MockUSDT.connect(owner).deploy("USDT");
    await mockUSDT.waitForDeployment();
    const usdtAddress = await mockUSDT.getAddress();

    const { billBOSCore } = await billBOSCoreFixture(usdtAddress);
    const { mockCompound, bbCompoundAdapter } = await bbCompoundAdapterFixture(
      await billBOSCore.getAddress(),
      usdtAddress
    );

    const bbCompoundAdapterAddress = await bbCompoundAdapter.getAddress();
    await billBOSCore
      .connect(owner)
      .setBillbosAdaptorAddress(bbCompoundAdapterAddress);

    await (
      await mockUSDT
        .connect(owner)
        .mint(await mockCompound.getAddress(), ethers.parseEther("10000000"))
    ).wait();

    await (
      await mockUSDT
        .connect(owner)
        .mint(owner, ethers.parseEther("1000000000000000"))
    ).wait();

    await (
      await mockUSDT
        .connect(owner)
        .approve(await billBOSCore.getAddress(), ethers.parseEther("10000000"))
    ).wait();

    return {
      billBOSCore,
      owner,
      mockUSDT,
      mockCompound,
      bbCompoundAdapter,
      player1,
      player2,
    };
  }

  describe("BillBOSCore Setup", () => {
    it("should be deploy", async () => {
      await loadFixture(bothFixture);
    });

    it("should be connect with bbCompoundAdapter contract", async () => {
      const { billBOSCore, owner, bbCompoundAdapter, mockUSDT } =
        await loadFixture(bothFixture);
      const bbCompoundAdapterAddress = await bbCompoundAdapter.getAddress();
      expect(await billBOSCore.billbosAdaptorAddress()).to.equal(
        bbCompoundAdapterAddress
      );
      expect(await billBOSCore.stakedTokenAddress()).to.equal(
        await mockUSDT.getAddress()
      );
    });
  });

  describe("BillBOSCore Ads", () => {
    it("should be reverted adsId doesn't exist", async () => {
      const { billBOSCore, owner } = await loadFixture(bothFixture);
      await expect(
        billBOSCore.connect(owner).updateAds(1, mockAds)
      ).to.be.revertedWith("BillBOSCore: ads does not exist in billbos");
    });
    it("should be update ads", async () => {
      const { billBOSCore, owner } = await loadFixture(bothFixture);
      await billBOSCore
        .connect(owner)
        .createAds(mockAds, ethers.parseEther("10"));
      const mockAdsUpdate = {
        name: "mockAds2",
        imageCID: "cid123",
        newTabLink: "http://localhost:3000",
        widgetLink: "",
        isInteractive: false,
      };
      await billBOSCore.connect(owner).updateAds(0, mockAdsUpdate);
      expect((await billBOSCore.adsContent(0))[0]).to.equal(
        Object.values(mockAdsUpdate)[0]
      );
    });
    describe("BillBOSCore Ads Create", () => {
      it("should be create new ads", async () => {
        const { billBOSCore, owner } = await loadFixture(bothFixture);

        await billBOSCore
          .connect(owner)
          .createAds(mockAds, ethers.parseEther("1"));
        expect(await billBOSCore.adsIdLast()).to.equal(1);
        expect((await billBOSCore.adsContent(0))[0]).to.equal(
          Object.values(mockAds)[0]
        );
        expect(await billBOSCore.totalStakedBalanceLast()).to.equal(
          ethers.parseEther("1")
        );
        expect(await billBOSCore.adsStakedBalance(0)).to.equal(
          ethers.parseEther("1")
        );
      });
      it("should revert if amount is less than 0", async () => {
        const { billBOSCore, owner } = await loadFixture(bothFixture);
        await expect(
          billBOSCore.connect(owner).createAds(mockAds, 0)
        ).to.be.revertedWith("BillBOSCore: amount must be more than 0");
      });
    });
  });

  describe("BillBOSCore Boost/Unboost", () => {
    it("should be boost ads", async () => {
      const { billBOSCore, owner } = await loadFixture(bothFixture);
      // adsId 1
      await billBOSCore.connect(owner).createAds(mockAds, 100);
      // adsId 2
      await billBOSCore.connect(owner).createAds(mockAds, 50);
      await billBOSCore.connect(owner).boost(0, 100);
      expect(await billBOSCore.totalStakedBalanceLast()).to.equal(250);
      expect(await billBOSCore.adsStakedBalance(0)).to.equal(200);
    });
    it("should be unboost ads", async () => {
      const { billBOSCore, owner } = await loadFixture(bothFixture);
      // adsId 1
      await billBOSCore.connect(owner).createAds(mockAds, 100);
      // adsId 2
      await billBOSCore.connect(owner).createAds(mockAds, 50);
      await billBOSCore.connect(owner).unboost(0, 50);
      expect(await billBOSCore.totalStakedBalanceLast()).to.equal(100);
      expect(await billBOSCore.adsStakedBalance(0)).to.equal(50);
    });
    it("should be reverted if unboost is not enough", async () => {
      const { billBOSCore, owner } = await loadFixture(bothFixture);
      // adsId 1
      await billBOSCore.connect(owner).createAds(mockAds, 100);
      // adsId 2
      await billBOSCore.connect(owner).createAds(mockAds, 50);
      await expect(
        billBOSCore.connect(owner).unboost(0, 200)
      ).to.be.revertedWith(
        "BillBOSCore: this ads is not enough staked balance"
      );
    });
    it("should be unboostAll ads", async () => {
      const { billBOSCore, owner } = await loadFixture(bothFixture);
      // adsId 1
      await billBOSCore.connect(owner).createAds(mockAds, 100);
      // adsId 2
      await billBOSCore.connect(owner).createAds(mockAds, 50);
      await billBOSCore.connect(owner).unboostAll(0);
      expect(await billBOSCore.totalStakedBalanceLast()).to.equal(50);
      expect(await billBOSCore.adsStakedBalance(0)).to.equal(0);
    });
  });

  describe("BillBOSCore Upload Report", () => {
    it("should be upload report", async () => {
      const { billBOSCore, owner } = await loadFixture(bothFixture);
      await billBOSCore
        .connect(owner)
        .createAds(mockAds, ethers.parseEther("1000000"));
      await billBOSCore
        .connect(owner)
        .uploadAdsReport(
          [
            "0x9A0d1aEBFfd101c236faA674b3c581dfE4418f9b",
            "0x400dff6cBa74dc4d69EB7dEE0E37293541607b5F",
          ],
          [100, 200],
          300
        );
      expect(await billBOSCore.webpageOwnerIdLast()).to.equal(2);
      expect(await billBOSCore.monthCount()).to.equal(1);
    });
    it("should be index webpage owner is not duplicate", async () => {
      const { billBOSCore, owner } = await loadFixture(bothFixture);
      await billBOSCore
        .connect(owner)
        .uploadAdsReport(
          [
            "0x9A0d1aEBFfd101c236faA674b3c581dfE4418f9b",
            "0x400dff6cBa74dc4d69EB7dEE0E37293541607b5F",
          ],
          [100, 200],
          300
        );
      await billBOSCore
        .connect(owner)
        .uploadAdsReport(
          [
            "0x9A0d1aEBFfd101c236faA674b3c581dfE4418f9b",
            "0x400dff6cBa74dc4d69EB7dEE0E37293541607b5F",
            "0x945b11D39FE18459C890c0e7B95b03D27549ed17",
          ],
          [100, 200, 300],
          600
        );
      expect(await billBOSCore.webpageOwnerIdLast()).to.equal(3);
      expect(await billBOSCore.monthCount()).to.equal(2);
    });
    it("should be reverted if length of webpage owner and view count records is not equal", async () => {
      const { billBOSCore, owner } = await loadFixture(bothFixture);
      await expect(
        billBOSCore
          .connect(owner)
          .uploadAdsReport(
            [
              "0x9A0d1aEBFfd101c236faA674b3c581dfE4418f9b",
              "0x9A0d1aEBFfd101c236faA674b3c581dfE4418f9b",
            ],
            [100, 200, 300],
            600
          )
      ).to.be.revertedWith(
        "BillBOSCore: length of webpageOwner and count is not equal"
      );
    });
  });

  describe("BillBOSCore Claim", () => {
    it("should be claim", async () => {
      // TODO: add when upload success
      const { billBOSCore, owner, mockUSDT, player1, player2 } =
        await loadFixture(bothFixture);

      const minute = 60;
      const hour = minute * 60;
      const day = hour * 24;
      const dayStaked = 365;
      const stakingAmount = 1000;
      const expectedReturn = 1100;
      const stakeAmount = ethers.parseEther(stakingAmount.toString());

      await mockUSDT.connect(owner).mint(player1.address, stakeAmount);
      await mockUSDT
        .connect(player1)
        .approve(await billBOSCore.getAddress(), stakeAmount);
      await billBOSCore.connect(player1).createAds(mockAds, stakeAmount);

      await time.increase(dayStaked * day);

      const player2Address = await player2.getAddress();

      await billBOSCore
        .connect(owner)
        .uploadAdsReport(
          [player2Address, "0x400dff6cBa74dc4d69EB7dEE0E37293541607b5F"],
          [100, 100],
          200
        );
      console.log(
        ethers.formatEther((await billBOSCore.getReward(player2Address))[0])
      );
      console.log(
        ethers.formatEther(await billBOSCore.totalEarningBalanceLast())
      );
    });
    it("should be reverted if claim is not enough", async () => {
      const { billBOSCore, owner } = await loadFixture(bothFixture);
      billBOSCore.connect(owner).createAds(mockAds, 100);
      await expect(billBOSCore.connect(owner).claimReward()).to.be.revertedWith(
        "BillBOSCore: this webpageOwner is not enough reward"
      );
    });
  });
});
