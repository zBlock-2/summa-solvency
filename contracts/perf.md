### Gas report

Before:
| **Category** | **Contract/Method** | **Min** | **Max** | **Avg** | **# calls** | **usd (avg)** | **% of limit** |
|--------------|--------------------------------------------|---------|---------|---------|-------------|---------------|----------------|
| Methods | | | | | | | |
| | GrandSumVerifier - verifyProof | - | - | 271155 | 2 | - | |
| | Summa - submitCommitment | - | - | 1068958 | 5 | - | |
| | Summa - submitProofOfAddressOwnership | - | - | 700479 | 3 | - | |
| Deployments | | | | | | | |
| | GrandSumVerifier | - | - | 277127 | | - | 0.9% |
| | InclusionVerifier | - | - | 284887 | | - | 0.9% |
| | src/DummyVerifyingKey.sol:Halo2VerifyingKey | - | - | 266321 | | - | 0.9% |
| | src/VerifyingKey.sol:Halo2VerifyingKey | - | - | 350335 | | - | 1.2% |
| | Summa | - | - | 1961848 | | - | 6.5% |
| | Verifier | - | - | 1907494 | | - | 6.4% |

after:

| **Category** | **Contract/Method**                         | **Min** | **Max** | **Avg** | **# calls** | **usd (avg)** | **% of limit** |
| ------------ | ------------------------------------------- | ------- | ------- | ------- | ----------- | ------------- | -------------- |
| Methods      |                                             |         |         |         |             |               |                |
|              | GrandSumVerifier - verifyProof              | -       | -       | 271140  | 2           | -             |                |
|              | Summa - submitCommitment                    | -       | -       | 1068943 | 5           | -             |                |
|              | Summa - submitProofOfAddressOwnership       | -       | -       | 700479  | 3           | -             |                |
| Deployments  |                                             |         |         |         |             |               |                |
|              | GrandSumVerifier                            | -       | -       | 277115  |             | -             | 0.9%           |
|              | InclusionVerifier                           | -       | -       | 284923  |             | -             | 0.9%           |
|              | src/DummyVerifyingKey.sol:Halo2VerifyingKey | -       | -       | 266321  |             | -             | 0.9%           |
|              | src/VerifyingKey.sol:Halo2VerifyingKey      | -       | -       | 350335  |             | -             | 1.2%           |
|              | Summa                                       | -       | -       | 1961848 |             | -             | 6.5%           |
|              | Verifier                                    | -       | -       | 1907494 |             | -             | 6.4%           |
