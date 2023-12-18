import { ethers } from "hardhat";

import { setAddress } from "../../../utils/address.util";

export async function deployMockERC20() {
  const [owner] = await ethers.getSigners();

  const MockERC20 = await ethers.getContractFactory("MockERC20", owner);
  const mockERC20 = await MockERC20.deploy('USDT');


  await mockERC20.waitForDeployment();

  const mockERC20Address = await mockERC20.getAddress();

  setAddress("mockERC20", mockERC20Address);

  console.log(`Deployed mockECR20 to ${mockERC20Address}`);

  return mockERC20;
}

// deployMockERC20().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });