import { ethers } from "hardhat";
import { deployBBCompoundAdapter } from "./deployBBCompoundAdapter";
import { deployBillBOSCore } from "./deployBillBOSCore";
import { deployMockCompound } from "./mock/deployMockCompound";
import { deployMockERC20 } from "./mock/deployMockERC20";

async function main() {
  const mockERC20 = await deployMockERC20();
  const mockCompound = await deployMockCompound();
  const billBOSCore = await deployBillBOSCore();
  const bBCompoundAdapter = await deployBBCompoundAdapter();
  await billBOSCore.setBillbosAdaptorAddress(
    await bBCompoundAdapter.getAddress()
  );
  await mockERC20.mint(
    await mockCompound.getAddress(),
    ethers.parseEther("1000000")
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
