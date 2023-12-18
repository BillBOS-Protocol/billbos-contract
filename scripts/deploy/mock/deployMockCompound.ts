import { ethers } from "hardhat";

import { setAddress, getAddress } from "../../../utils/address.util";

export async function deployMockCompound(tokenAddress ?: string) {
  const [owner] = await ethers.getSigners();

  const MockCompound = await ethers.getContractFactory("MockCompound", owner);
  const _tokenAddress = tokenAddress ?? getAddress("mockERC20");
  if (!_tokenAddress) throw new Error("mockERC20 address not found");
  const mockCompound = await MockCompound.deploy(_tokenAddress, 10);


  await mockCompound.waitForDeployment();

  const mockCompoundAddress = await mockCompound.getAddress();

  setAddress("mockCompound", mockCompoundAddress);

  console.log(`Deployed mockCompound to ${mockCompoundAddress}`);

  return mockCompound;
}

// deployMockCompound().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });