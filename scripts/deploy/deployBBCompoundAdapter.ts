import { ethers } from "hardhat";

import { setAddress, getAddress } from "../../utils/address.util";

export async function deployBBCompoundAdapter(
  tokenAddress?: string,
  cTokenAddress?: string,
  billBOSCoreAddress?: string
) {
  const [owner] = await ethers.getSigners();

  const BBCompoundAdapter = await ethers.getContractFactory(
    "BBCompoundAdapter",
    owner
  );
  const _tokenAddress = tokenAddress ?? getAddress("mockERC20");
  const _cTokenAddress = cTokenAddress ?? getAddress("mockCompound");
  const _billBOSCoreAddress = billBOSCoreAddress ?? getAddress("billBOSCore");
  if (!_tokenAddress || !_cTokenAddress || !_billBOSCoreAddress)
    throw new Error("mockERC20, cToken, and billBOSCore address is not found");
  const bBCompoundAdapter = await BBCompoundAdapter.deploy(
    _tokenAddress,
    _cTokenAddress,
    _billBOSCoreAddress
  );

  await bBCompoundAdapter.waitForDeployment();

  const bBCompoundAdapterAddress = await bBCompoundAdapter.getAddress();

  setAddress("bBCompoundAdapter", bBCompoundAdapterAddress);

  console.log(`Deployed bBCompoundAdapterAddress to ${bBCompoundAdapterAddress}`);

  return bBCompoundAdapter;
}

// deployBBCompoundAdapter().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });
