/*
 *  MultiSigSafe Test Suite
 *
 */


const lightwallet = require('eth-lightwallet');
const leftPad = require('left-pad');
const BigNumber = require('bignumber.js');
const Promise = require('bluebird');
const solsha3 = require('solidity-sha3').default;

const MSS = artifacts.require('./MultiSigSafe.sol');
const TestRegistry = artifacts.require('./TestRegistry.sol');

const web3SendTransaction = Promise.promisify(web3.eth.sendTransaction);
const web3GetBalance = Promise.promisify(web3.eth.getBalance);
const ether = a => web3.fromWei(a, 'ether').toFixed(6);
const nullAcct = '0x0';

contract('MultiSigSafe', (accounts) => {

    let acct;
    let keystore;
    let keyFromPw;
    let destination;

    const createSigs = (signers, multisigAddr, nonce, destinationAddr, value, data) => {

        const input = `${'0x1900'}${
            multisigAddr.slice(2)}${
            destinationAddr.slice(2)}${
            leftPad(value.toString('16'), '64', '0')}${
            data.slice(2)}${
            leftPad(nonce.toString('16'), '64', '0')}`;

        const hash = solsha3(input);

        const sigV = [];
        const sigR = [];
        const sigS = [];

        for (let i = 0; i < signers.length; i += 1) {

            let sig;
            if (signers[i] === nullAcct) {

                sig = { v: 0, r: leftPad('', '64', '0'), s: leftPad('', '64', '0'), };

            } else {

                sig = lightwallet.signing.signMsgHash(keystore, keyFromPw, hash, signers[i]);

            }
            sigV.push(sig.v);
            sigR.push(`0x${sig.r.toString('hex')}`);
            sigS.push(`0x${sig.s.toString('hex')}`);

        }

        return {
            sigV,
            sigR,
            sigS,
        };

    };

    const executeSendSuccess = async function (signers, done) {

        const multisig = await MSS.new({ from: accounts[0], });
        const sendValue = web3.toWei(new BigNumber(0.01), 'ether');
        const fundValue = web3.toWei(new BigNumber(0.1), 'ether');

        destination = solsha3(Math.random()).slice(0, 42);

        // Receive funds
        await web3SendTransaction({ from: accounts[0], to: multisig.address, value: fundValue, });

        let nonce = await multisig.nonce.call();
        assert.equal(nonce.toNumber(), 0, 'nonce should be 0');

        let owner = await multisig.owner0.call();
        assert.equal(accounts[0], owner, `owner0 should be ${accounts[0]}`);
        owner = await multisig.owner1.call();
        assert.equal(accounts[1], owner, `owner1 should be ${accounts[1]}`);
        owner = await multisig.owner2.call();
        assert.equal(accounts[2], owner, `owner2 should be ${accounts[2]}`);
        let bal = await web3GetBalance(multisig.address);
        assert.equal(ether(bal), ether(fundValue), `multisig balance should be ${ether(fundValue)}`);

        let sigs = createSigs(signers, multisig.address, nonce, destination, sendValue, '0x');

        await multisig.execute(sigs.sigV, sigs.sigR, sigs.sigS, destination, sendValue, '0x', { from: accounts[0], gasLimit: 1000000, });

        // Check funds sent
        bal = await web3GetBalance(destination);
        assert.equal(ether(bal), ether(sendValue), `1. balance should be ${sendValue.toString()}`);

        // Check nonce updated
        nonce = await multisig.nonce.call();
        assert.equal(nonce.toNumber(), 1, 'nonce should be 1');

        // Send again
        sigs = createSigs(signers, multisig.address, nonce, destination, sendValue, '0x');
        await multisig.execute(sigs.sigV, sigs.sigR, sigs.sigS, destination, sendValue, '0x', { from: accounts[0], gasLimit: 1000000, });

        // Check funds
        bal = await web3GetBalance(destination);
        assert.equal(ether(bal), ether(sendValue.times(2)), `2. balance should be ${sendValue.times(2).toString()}`);

        // Check nonce updated
        nonce = await multisig.nonce.call();
        assert.equal(nonce.toNumber(), 2, '3. nonce should be 2');

        // Test contract interactions
        const reg = await TestRegistry.new({ from: accounts[0], });

        const number = 12345;
        const data = `0x${lightwallet.txutils._encodeFunctionTxData('register', ['uint256'], [number])}`;

        sigs = createSigs(signers, multisig.address, nonce, reg.address, sendValue, data);
        await multisig.execute(sigs.sigV, sigs.sigR, sigs.sigS, reg.address, sendValue, data, { from: accounts[0], gasLimit: 1000000, });

        // Check that number has been set in registry
        const numFromRegistry = await reg.registry(multisig.address);
        assert.equal(numFromRegistry.toNumber(), number);

        // Check funds in registry
        bal = await web3GetBalance(reg.address);
        assert.equal(bal.toString(), sendValue.toString());

        // Check nonce updated
        nonce = await multisig.nonce.call();
        assert.equal(nonce.toNumber(), 3);

        done();

    };

    const executeSendFailure = async function (signers, done) {

        const multisig = await MSS.new({ from: accounts[0], });
        const value = web3.toWei(new BigNumber(0.1), 'ether');
        const value2 = web3.toWei(new BigNumber(2), 'ether');

        const nonce = await multisig.nonce.call();

        assert.equal(nonce.toNumber(), 0);

        // Receive funds
        await web3SendTransaction({ from: accounts[0], to: multisig.address, value: value2, });

        const sigs = createSigs(signers, multisig.address, nonce, destination, value, '0x');

        let errMsg = '';
        try {

            await multisig.execute(sigs.sigV, sigs.sigR, sigs.sigS, destination, value, '0x', { from: accounts[0], gasLimit: 1000000, });

        } catch (error) {

            errMsg = error.message;

        }

        assert.equal(errMsg, 'VM Exception while processing transaction: invalid opcode', 'Test did not throw');

        done();

    };

    before((done) => {

        const seed = 'candy maple cake sugar pudding cream honey rich smooth crumble sweet treat';

        lightwallet.keystore.createVault({
            hdPathString: "m/44'/60'/0'/0",
            seedPhrase: seed,
            password: 'test',
            salt: 'testsalt',
        }, (err, ks) => {

            keystore = ks;
            keystore.keyFromPassword('test', (err2, kFPw) => {

                keyFromPw = kFPw;

                keystore.generateNewAddress(keyFromPw, 10);
                const acctWithout0x = keystore.getAddresses();
                acct = acctWithout0x.map(a => `0x${a}`);
                // acct.sort();
                acct.map((a, i) => {

                    console.log(`Account ${i}: ${a}`);

                });
                done();

            });

        });

    });


    describe('3 signers, threshold 2', () => {

        it('should succeed with signers 0, 1', (done) => {

            const signers = [acct[0], acct[1], nullAcct];
            executeSendSuccess(signers, done);

        });

        it('should succeed with signers 0, 2', (done) => {

            const signers = [acct[0], nullAcct, acct[2]];
            executeSendSuccess(signers, done);

        });

        it('should succeed with signers 1, 2', (done) => {

            const signers = [nullAcct, acct[1], acct[2]];
            executeSendSuccess(signers, done);

        });

        it('should succeed with signers 0, 1, 2', (done) => {

            const signers = [acct[0], acct[1], acct[2]];
            executeSendSuccess(signers, done);

        });

        it('should fail due to non-owner signer', (done) => {

            const signers = [acct[0], nullAcct, acct[3]];
            executeSendFailure(signers, done);

        });

        it('should fail with more signers than threshold', (done) => {

            executeSendFailure(acct.slice(0, 4), done);

        });

        it('should fail with fewer signers than threshold', (done) => {

            executeSendFailure([acct[0]], done);

        });

        it('should fail with one signer signing twice', (done) => {

            executeSendFailure([acct[0], acct[0], nullAcct], done);

        });

        it('should fail with signers in wrong order', (done) => {

            const signers = [acct[1], acct[0], nullAcct];
            executeSendFailure(signers, done);

        });

    });

});

