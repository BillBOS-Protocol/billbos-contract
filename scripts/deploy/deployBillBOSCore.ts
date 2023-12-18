import { ethers } from "hardhat";

import { setAddress, getAddress } from "../../utils/address.util";

export async function deployBillBOSCore(tokenAddress?: string) {
  const [owner] = await ethers.getSigners();

  const BillBOSCore = await ethers.getContractFactory("BillBOSCore", owner);
  const billBOSAdapterAddress =
    getAddress("bBCompoundAdapter") ??
    "0x0165878A594ca255338adfa4d48449f69242Eb8F";
  const _tokenAddress = tokenAddress ?? getAddress("mockERC20");
  if (!_tokenAddress) {
    throw new Error("Please deploy MockERC20 first");
  }
  const billBOSCore = await BillBOSCore.deploy(
    billBOSAdapterAddress,
    _tokenAddress
  );

  await billBOSCore.waitForDeployment();

  const billBOSCoreAddress = await billBOSCore.getAddress();

  setAddress("billBOSCore", billBOSCoreAddress);

  console.log(`Deployed billBOSCore to ${billBOSCoreAddress}`);

  return billBOSCore;
}

// deployBillBOSCore().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });
