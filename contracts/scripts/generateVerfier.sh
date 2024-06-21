#!/bin/bash
echo "[+] Running cargo command to generate verfier"
(cd ../prover && cargo run --bin generate_verifier)
echo "[+] Running cargo command to generate verfier"