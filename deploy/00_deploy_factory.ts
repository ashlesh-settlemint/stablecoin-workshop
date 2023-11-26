import { DeployFunction } from "hardhat-deploy/types";

const migrate: DeployFunction = async ({
  getNamedAccounts,
  deployments: { deploy },
  config,
  network,
}) => {
  const { deployer } = await getNamedAccounts();
  if (!deployer) {
    console.error(
      "\n\nERROR!\n\nThe node you are deploying to does not have access to a private key to sign this transaction. Add a private key in this application and activate it on the node you deployed this Smart Contract Set IDE on. If a private key already exists in this application, ensure that it is activated on the node you deployed this Smart Contract Set IDE on.\n\n"
    );
    process.exit(1);
  }

  await deploy("StableCoinFactory", {
    from: deployer,
    args: [deployer],
    log: true,
  });

  return true;
};

export default migrate;

migrate.id = "00_deploy_factory";
migrate.tags = ["StableCoinFactory"];
