# BendDAO Protocol V2

---

## What are BendDAO Protocol V2?

TBD

---

## Contracts overview

TBD

---

## Documentation

TBD

---

## Audits

TBD

---

## Bug bounty

A bug bounty is open on Immunefi. The rewards and scope are defined [here](https://immunefi.com/bounty/benddao/).

---

## Deployment Addresses

TBD

---

## Importing package

Using npm:

```bash
npm install @benddao/bend-v2
```

Using forge:

```bash
forge install @benddao/bend-v2@v1.0.0
```

Using git submodules:

```bash
git submodule add @benddao/bend-v2@v1.0.0 lib/bend-v2
```

---

## Testing with [Foundry](https://github.com/foundry-rs/foundry) 🔨

For testing, make sure `yarn` and `foundry` are installed.

Alternatively, if you only want to set up

Refer to the `env.example` for the required environment variable.

```bash
npm run test
```

---

## Testing with Hardhat

Only a few tests are run with Hardhat.

Just run:

```bash
yarn test:hardhat
```

---

## Test coverage

Test coverage is reported using [foundry](https://github.com/foundry-rs/foundry) coverage with [lcov](https://github.com/linux-test-project/lcov) report formatting (and optionally, [genhtml](https://manpages.ubuntu.com/manpages/xenial/man1/genhtml.1.html) transformer).

To generate the `lcov` report, run the following:

```bash
npm run coverage:forge
```

The report is then usable either:

- via [Coverage Gutters](https://marketplace.visualstudio.com/items?itemName=ryanluker.vscode-coverage-gutters) following [this tutorial](https://mirror.xyz/devanon.eth/RrDvKPnlD-pmpuW7hQeR5wWdVjklrpOgPCOA-PJkWFU)
- via HTML, using `npm run coverage:html` to transform the report and opening `coverage/index.html`

---

## Storage seatbelt

2 CI pipelines are currently running on every PR to check that the changes introduced are not modifying the storage layout of proxied smart contracts in an unsafe way:

- [storage-layout.sh](./scripts/storage-layout.sh) checks that the latest foundry storage layout snapshot is identical to the committed storage layout snapshot
- [foundry-storage-check](https://github.com/Rubilmax/foundry-storage-diff) is in test phase and will progressively replace the snapshot check

In the case the storage layout snapshots checked by `storage-layout.sh` are not identical, the developer must commit the updated storage layout snapshot stored under [snapshots/](./snapshots/) by running:

- `npm run storage-layout-generate` with the appropriate protocol parameters

---

## Deployment & Upgrades

### Network mode (default)

Run the Foundry deployment script with:

```bash
npm run deploy:goerli
```

### Local mode

First start a local EVM:

```bash
npm run anvil:goerli
```

Then run the Foundry deployment script in a separate shell:

```bash
npm run deploy:local
```

---

## Questions & Feedback

For any questions or feedback, you can send an email to [developer@benddao.xyz](mailto:developer@benddao.xyz).

---

## Licensing

The code is under the Business Source License 1.1, see [`LICENSE`](./LICENSE).
