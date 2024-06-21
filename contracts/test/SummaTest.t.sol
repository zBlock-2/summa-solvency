// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {VmSafe} from "forge-std/Vm.sol";
import "../src/Summa.sol";
import "../src/VerifyingKey.sol";
import "../src/interfaces/IVerifier.sol";
import "../src/interfaces/IInclusionVerifier.sol";
import "../src/GrandSumVerifier.sol";
import "../src/SnarkVerifier.sol";
import "../src/InclusionVerifier.sol";

contract SummaTest is Test {
    
    struct commitmentStruct{
        bytes snarkProof;
        bytes grandSumProof;
        uint256[] totalBalances;
        uint256 timestamp;
    }

    struct inclusionCalldataStruct{
        uint256 timestamp;
        bytes inclusionProof;
        uint256[] challenges;
        uint256[] values;
    }

    VmSafe.Wallet exchangeOwnerWallet;
    address userAddress;
    Summa summaContract;
    Halo2VerifyingKey _verificationKeyContract;
    Verifier _polynomialInterpolationVerifier;
    GrandSumVerifier _grandSumVerifier;
    InclusionVerifier _inclusionVerifier;
    string[] cryptocurrencyNames;
    string[] cryptocurrencyChains;
    uint8 balanceByteRange;
    uint8 numberOfCurrencies;
    function setUp() public {
        // set the number of currencies in the proof
        numberOfCurrencies = 2;

        // uncomment this code if you need to generate the Snark Verfifier Contract
        //bool genVerifier = generateDymanicVerifier();

        // uncomment this code if you need to generate the commitments and proofs
        // bool genCP = generateCommitmentsWithProofs();

        //Set up user accounts
        exchangeOwnerWallet = vm.createWallet("exchangeOwnerWallet");
        userAddress = makeAddr("userAddress");

        //Set up string arrays
        cryptocurrencyNames = new string[] (2);
        cryptocurrencyNames[0] = "ABC";
        cryptocurrencyNames[1] = "ABC";

        cryptocurrencyChains = new string[] (2);
        cryptocurrencyChains[0] = "ETH";
        cryptocurrencyChains[1] = "ETH";

        //Set the byte range
        balanceByteRange = 8;

        _verificationKeyContract = new Halo2VerifyingKey();
        _polynomialInterpolationVerifier = new Verifier();
        _grandSumVerifier = new GrandSumVerifier();
        _inclusionVerifier = new InclusionVerifier();
        summaContract = new Summa(address(_verificationKeyContract),
            IVerifier(address(_polynomialInterpolationVerifier)),
            IVerifier(address(_grandSumVerifier)),
            IInclusionVerifier(address( _inclusionVerifier)),
            cryptocurrencyNames,
            cryptocurrencyChains,
            balanceByteRange);

        //now sign a message as the exchange and submit proof of ownership
        Summa.AddressOwnershipProof[] memory _addressOwnershipProofs = new Summa.AddressOwnershipProof[] (1);
        _addressOwnershipProofs[0].cexAddress = string(abi.encode(exchangeOwnerWallet.addr));
        _addressOwnershipProofs[0].chain = "ETH";
        // sign a message as the exchangeOwner address
        
        string memory strMessage = "Summa proof of solvency for CryptoExchange";
        bytes32 digest = keccak256("Summa proof of solvency for CryptoExchange");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(exchangeOwnerWallet, digest);
        bytes memory _signature = abi.encodePacked(r, s, v);

        // continue setup of address ownership proof
        _addressOwnershipProofs[0].signature = _signature;
        _addressOwnershipProofs[0].message = abi.encode(strMessage);

        //now submit proof of ownership
        summaContract.submitProofOfAddressOwnership(_addressOwnershipProofs);
    }

    function testSummaFlowFullHappyPath() public {
        console.log("[+] Starting test testSummaFlowFullHappyPath");
        console.log("[+] Submitting Commitment proof");
        commitmentStruct memory cStruct = getCommitmentProofValues();
        summaContract.submitCommitment(
            cStruct.snarkProof,
            cStruct.grandSumProof,
            cStruct.totalBalances,
            cStruct.timestamp
        );
        console.log("[+] ##COMPLETED## - Submitting Commitment proof");
        console.log("[+] Submitting Inclusion proof");
        inclusionCalldataStruct memory icStruct = getInclusionProofValues();
        summaContract.verifyInclusionProof(
            icStruct.timestamp,
            icStruct.inclusionProof,
            icStruct.challenges,
            icStruct.values
        );
        console.log("[+] ##COMPLETED## - Submitting Inclusion proof");
        console.log("[+] Running testSummaFlowFullHappyPath completed!");
    }

    function testSummaFlowFullWrongTimeStamp() public {
        console.log("[+] Starting test testSummaFlowFullWrongTimeStamp");
        console.log("[+] Submitting Commitment proof");
        commitmentStruct memory cStruct = getCommitmentProofValues();
        summaContract.submitCommitment(
            cStruct.snarkProof,
            cStruct.grandSumProof,
            cStruct.totalBalances,
            cStruct.timestamp
        );
        console.log("[+] ##COMPLETED## - Submitting Commitment proof");
        console.log("[+] Submitting Inclusion proof");
        inclusionCalldataStruct memory icStruct = getInclusionProofValues();
        icStruct.timestamp = 2;
        console.log("[+] Expect revert due to incorrect timestamp");
        vm.expectRevert();
        summaContract.verifyInclusionProof(
            icStruct.timestamp,
            icStruct.inclusionProof,
            icStruct.challenges,
            icStruct.values
        );
        console.log("[+] ##COMPLETED## - Submitting Inclusion proof");
        console.log("[+] Running testSummaFlowFullWrongTimeStamps completed!");
    }

    function testSummaFuzzInclusionTimeStamp(uint256 _timeStamp) public {
        vm.assume(_timeStamp != 1);
        commitmentStruct memory cStruct = getCommitmentProofValues();
        summaContract.submitCommitment(
            cStruct.snarkProof,
            cStruct.grandSumProof,
            cStruct.totalBalances,
            cStruct.timestamp
        );

        inclusionCalldataStruct memory icStruct = getInclusionProofValues();
        vm.expectRevert();
        summaContract.verifyInclusionProof(
            _timeStamp,
            icStruct.inclusionProof,
            icStruct.challenges,
            icStruct.values
        );

    }

    function testSummaFuzzInclusionChallenges(uint256 challenge1,uint256 challenge2,uint256 challenge3,uint256 challenge4) public {

        commitmentStruct memory cStruct = getCommitmentProofValues();
        summaContract.submitCommitment(
            cStruct.snarkProof,
            cStruct.grandSumProof,
            cStruct.totalBalances,
            cStruct.timestamp
        );

        inclusionCalldataStruct memory icStruct = getInclusionProofValues();
        uint256[] memory _challenges = new uint256[] (4);
        _challenges[0] = challenge1;
        _challenges[1] = challenge2;
        _challenges[2] = challenge3;
        _challenges[3] = challenge4;
        vm.expectRevert();
        summaContract.verifyInclusionProof(
            icStruct.timestamp,
            icStruct.inclusionProof,
            _challenges,
            icStruct.values
        );
    }

    function testSummaFuzzInclusionValues(uint256 userValue1,uint256 userValue2,uint256 userValue3) public {
        
        commitmentStruct memory cStruct = getCommitmentProofValues();
        summaContract.submitCommitment(
            cStruct.snarkProof,
            cStruct.grandSumProof,
            cStruct.totalBalances,
            cStruct.timestamp
        );

        inclusionCalldataStruct memory icStruct = getInclusionProofValues();
        uint256[] memory _userValues = new uint256[] (numberOfCurrencies + 1);
        _userValues[0] = userValue1;
        _userValues[1] = userValue2;
        _userValues[2] = userValue3;
        vm.expectRevert();
        summaContract.verifyInclusionProof(
            icStruct.timestamp,
            icStruct.inclusionProof,
            icStruct.challenges,
            _userValues
        );

    }

    function testSummaFuzzInclusionValues(bytes calldata inBytes) public {
        
        commitmentStruct memory cStruct = getCommitmentProofValues();
        summaContract.submitCommitment(
            cStruct.snarkProof,
            cStruct.grandSumProof,
            cStruct.totalBalances,
            cStruct.timestamp
        );

        inclusionCalldataStruct memory icStruct = getInclusionProofValues();
        
        vm.expectRevert();
        summaContract.verifyInclusionProof(
            icStruct.timestamp,
            inBytes,
            icStruct.challenges,
            icStruct.values
        );

    }


    function generateDymanicVerifier() public returns (bool) {
        
        // now generate the verfier by calling the script using ffi
        string[] memory ffi_command = new string[] (1);
        ffi_command[0] = "./scripts/generateVerfier.sh";

        bytes memory commandResponse = vm.ffi(ffi_command);
        console.log(string(commandResponse));
        return true;

    }

    function generateCommitmentsWithProofs() public returns (bool) {
        
        // now generate the commitments and proofs by calling the script using ffi
        string[] memory ffi_command = new string[] (1);
        ffi_command[0] = "./scripts/generateCommitmentsWithProofs.sh";

        bytes memory commandResponse = vm.ffi(ffi_command);
        console.log(string(commandResponse));
        return true;

    }

    function getCommitmentProofValues() public returns (commitmentStruct memory) {
        
        // now read the values from the file called commitment_solidity_calldata.json
        string memory commitmentFile = vm.readFile("../prover/bin/commitment_solidity_calldata.json");

        commitmentStruct memory cStruct;

        bytes memory _snarkProof = abi.decode(vm.parseJson(commitmentFile,".range_check_snark_proof"),(bytes));
        bytes memory _grandsumProof = abi.decode(vm.parseJson(commitmentFile,".grand_sums_batch_proof"),(bytes));
        uint256[] memory _totalBalances = new uint256[] (numberOfCurrencies);
        bytes[] memory _totalBalanceBytes = new bytes[](numberOfCurrencies);
        bytes memory _totalBytesEntry = vm.parseJson(commitmentFile,".total_balances");
        _totalBalanceBytes = abi.decode(_totalBytesEntry,(bytes[]));

        for(uint256 i;i<numberOfCurrencies;i++){
            _totalBalances[i] = vm.parseUint(vm.toString(_totalBalanceBytes[i]));
        }
        
        cStruct.snarkProof = _snarkProof;
        cStruct.grandSumProof = _grandsumProof;
        cStruct.totalBalances = _totalBalances;
        cStruct.timestamp = 1;
        return cStruct;

    }

    function getInclusionProofValues() public returns (inclusionCalldataStruct memory) {
        
        // now read the values from the file called inclusion_proof_solidity_calldata.json
        string memory inclusionFile = vm.readFile("../prover/bin/inclusion_proof_solidity_calldata.json");

        inclusionCalldataStruct memory icStruct;

        bytes memory _inclusionProof = abi.decode(vm.parseJson(inclusionFile,".proof"),(bytes));

        bytes32[] memory _totalChallengeBytes = new bytes32[](4);
        uint256[] memory _challenges = new uint256[] (4);

        uint256[] memory _userValues = new uint256[] (numberOfCurrencies + 1);
        bytes[] memory _totalUserValueBytes = new bytes[](numberOfCurrencies + 1);

        bytes memory _totalUserValueEntry = vm.parseJson(inclusionFile,".user_values");
        bytes memory _totalChallengeEntry = vm.parseJson(inclusionFile,".challenges");
        
        _totalUserValueBytes = abi.decode(_totalUserValueEntry,(bytes[]));
        
        _totalChallengeBytes = abi.decode(_totalChallengeEntry,(bytes32[]));
        
        for(uint256 i;i< numberOfCurrencies + 1;i++){
            _userValues[i] = vm.parseUint(vm.toString(_totalUserValueBytes[i]));
        }
        
        for(uint256 j;j< 4;j++){
            _challenges[j] = vm.parseUint(vm.toString(_totalChallengeBytes[j]));
        }
        
        icStruct.timestamp = 1;
        icStruct.inclusionProof = _inclusionProof;
        icStruct.challenges = _challenges;
        icStruct.values = _userValues;
        return icStruct;

    }

    function getUserProofValues() public returns (inclusionCalldataStruct memory) {
        
        // now read the values from the file called user_0_proof.json
        string memory inclusionFile = vm.readFile("../backend/user_0_proof.json");

        inclusionCalldataStruct memory icStruct;

        bytes memory _inclusionProof = abi.decode(vm.parseJson(inclusionFile,".proof_calldata"),(bytes));

        bytes32[] memory _totalChallengeBytes = new bytes32[](4);
        uint256[] memory _challenges = new uint256[] (4);

        uint256[] memory _userValues = new uint256[] (numberOfCurrencies + 1);
        bytes[] memory _totalUserValueBytes = new bytes[](numberOfCurrencies + 1);

        bytes memory _totalUserValueEntry = vm.parseJson(inclusionFile,".input_values");
        bytes memory _totalChallengeEntry = vm.parseJson(inclusionFile,".challenge_s_g2");
        
        _totalUserValueBytes = abi.decode(_totalUserValueEntry,(bytes[]));
        
        _totalChallengeBytes = abi.decode(_totalChallengeEntry,(bytes32[]));
        
        for(uint256 i;i< numberOfCurrencies + 1;i++){
            _userValues[i] = vm.parseUint(vm.toString(_totalUserValueBytes[i]));
        }
        
        for(uint256 j;j< 4;j++){
            _challenges[j] = vm.parseUint(vm.toString(_totalChallengeBytes[j]));
        }
        
        icStruct.timestamp = 1;
        icStruct.inclusionProof = _inclusionProof;
        icStruct.challenges = _challenges;
        icStruct.values = _userValues;
        return icStruct;

    }

    
}
