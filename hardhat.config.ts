import { defineConfig } from "hardhat/config";

export default defineConfig({
  solidity: {
    version: "0.8.34",
  },
  networks: {
    hardhat: {
      type: "edr-simulated",
      mining: {
        auto: true,
        interval: 5000
      }
    }
  }
});
