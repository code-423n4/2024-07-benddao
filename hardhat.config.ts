import * as dotenv from 'dotenv';
import fs from 'fs';

import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import 'hardhat-preprocessor';

// Support for foundry remappings: https://book.getfoundry.sh/config/hardhat
const remappings = fs
  .readFileSync('remappings.txt', 'utf8')
  .split('\n')
  .filter(Boolean)
  .map((line) => line.trim().split('='));

dotenv.config({ path: './.env.local' });

const config: HardhatUserConfig = {
  solidity: '0.8.25',
  preprocess: {
    eachLine: () => ({
      transform: (line) => {
        if (line.match(/^\s*import /i)) remappings.forEach(([find, replace]) => (line = line.replace(find, replace)));
        return line;
      },
    }),
  },
  paths: {
    sources: './src',
    tests: './test/hardhat',
  },
};

export default config;
