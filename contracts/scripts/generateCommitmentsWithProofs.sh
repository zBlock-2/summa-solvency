#!/bin/bash
echo "[+] Running cargo command to generate commitments and proofs"
(cd ../prover && cargo run --bin generate_commitment_and_proofs)
echo "[+] Running cargo command to generate commitments and proofs"