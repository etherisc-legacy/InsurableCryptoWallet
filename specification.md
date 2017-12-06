# Specification for an Insurable Crypto Wallet (ICW)

Authors: Philipp Terhorst, Christoph Mussenbrock.

## Summary
We provide a generic specification for an Insurable Crypto Wallet (ICW), as well as some sample implementations. 
We consider the overall process, including handling, operation, developing, insurance, etc.
We invite the community to add comments, questions, proposals to enhance this specification.
You can add comments and pull request. 

### Structure of this document

This document has XX parts.
1. We describe the target user group; who should use the wallet we specifiy in this document.
2. We describe what is insured and what not.
3. We describe some fundamental ideas which we follow.
4. We outline the safety concept.
5. The actual specification is a list of requirements which any implementation has to fulfill.
6. We provide a first example of an implementation.

The document describes the technical side of the wallet.
Out of the scope of this document are all insurance related issues, like the amount of coverage, the structure
of primary insurance / reinsurance, pricing and all economic issues. 

## Table of Contents
[TOC]

## Abbreviations
* ICW   Insurable Crypto Wallet
* MSS   MultiSigSafe (special multisig for storage of large amounts of current
* MSW   MultiSigWallet
* HD    Air-gapped hardware device (for air-gapped signature of tx)
* FMEA  Failure mode and effects analysis
* EVM   Ethereum virtual machine
* ETH   Ether
* Tx    Transaction
* MWx   MultiSigWallet No. x
* TAx   Token address No. x


## Target group

With this specification, we target "large" wallets which keep high amounts of ether or tokens.
We assume that the frequence of access is low, while the security requirements are maximal.
The focus is therefore on creating a maximally secure wallet, not an "easy to use" wallet.

Rationale:
We aim to explore which design supports maximum security. Creating a high security wallet will teach us also
valuable lessons how to build secure, easy-to-use every-day-wallets. Its the same philosophy like Formula 1 in 
motorsport: You learn how to build the best every day cars if you engage in building the cars with the highest
requirements, not the other way round.

## Scope of insured perils

### Insured

We want to insure losses of the ICW caused by:

* Losses caused by unauthorized assets transfer
  (Example: wallet is hacked, funds are under control of unauthorized party)
  An unauthorized transfer is characterized by a transfer which is not following the predefined flow of control
  in the wallet.
* Losses caused by software faults or attacks leading to inaccessibility of funds
  (Example: wallet/funds are inaccessible, but funds are not under control of unauthorized party)

### Not insured

Not insured are:

* Losses caused by authorized assets transfers (signatures are from the ICW owners and transfer process is according to the specification)
* Losses caused by loss of more than one owner ID together with PIN/ recovery phrase or together with a similar recovery mechanism, in our case one of the  air-gapped devices
* Losses caused by reasons which are external to the wallet system, e.g. “DAO hack” or hard forks 
* Losses caused by market price changes
* Losses caused by handling errors, e.g. mistakes in the amount to be transferred
* Losses caused by situations in which one signer blocks the other. [FOOTNOTE: Example: Alice and Bob are legitimate owners of a multisig, but they don’t trust each other - maybe they are even hostile. The wallet contains a large heritage where 50% is due to Alice and 50% is due to Bob. Now they need 2 Transactions to transfer 50% of the value to Alice and 50% to Bob. 
Problem: Alice signs “her” Transaction and Bob signs “his” transaction. Both send their Tx to the other party. But now they are in a dilemma: If Alice signs Bob’s message, Bob could be tempted not to sign Alice’s Tx and vice versa, leading either to a deadlock or to one party prey on the other.
The problem can be solved by using an escrow contract, so it’s no constraint not to insure such a situation.]

### Claims management

Ideally, we implement methods which enable us to detect an insurable event on- or off-chain.
Example: 

* If the sequence of EVM instructions follows the predefined pattern, we assume that the transaction was authorized.
* If we detect a sequence of EVM instructions which do not follow the predefined pattern, and which lead to a transfer of funds, we assume a "hack".
* If a properly authorized transaction does not lead to transfer of funds, we assume the funds are inaccessible. 

## Overall design principles

The basic principle is to reduce functionality, complexity and attack points in the overall process. We accept that the result will be a bit more inflexible, less configurable, but clearly defined, easy to test and in the best case formal verifiable.

### Components

The MSS consists of the following components:

1. Core wallet - a super-secure smart contract
2. Air-gapped devices - these keep the private keys which never leave the device. 1. + 2. form the first line of defense.
3. Standard Multisig Receiver Wallets - these are the sole possible receiver of funds or tokens and form the second line of defense.
4. Web-Interface - the web-interface leads the user through the process. It is not considered safe, but just adds a good user experience to the process.
5. Monitoring environment - used to monitor funds and "ring the bells" in case any suspicious activitiy is noticed. This is the third line of defense.

### Safety Concept

* We consider a “safe wallet” not only a piece of software code, but rather a (complex) system consisting of owners, keys, key storing devices, smart contracts, blockchain nodes, ethereum virtual machine (EVM), network access, processes, etc.
* We consider everything as unsafe which is not completely under control of the insurance or the insured parties. 
* We surround the assets to be protected by multiple, independent lines of defense. An attacker has to break all lines of defense to gain control over the assets.
    * First line of defense: The MSS + airgapped devices
    * Second line of defense: Standard multisig wallets which are the only receiver of funds and tokens from the MSS
    * Third line of defense: We will also consider a network of "red phones" at all relevant exchanges to block funds if first and second line of defense are broken.
* We build the safety concept on three pillars: 
    * First pillar: safe design. The wallet and all other technical components should be maximally secure by design.
    * Second pillar: transparency and audits. The manufacturing of all components is transparent and open source. Additionally, we will perform external audits, because while the open source community has many eyeballs, you cannot expect completeness. Therefore, we will engage paid external auditors to give all components maximum of credibility
    * Third pillar: secure operating environment. We will establish rules for safe operation and build up a operations and monitoring service which will help or even enforce all involved parties to maintain operational safety.
* We use hard coded destination addresses. Every asset can only be transferred out of the ICW to another address under control of the ower (e.g. a separate standard MultiSigWallet). This means, assets can only be transferred to a “third person” with two Tx.
* We use hard coded owners. Every ICW can only execute Tx if sufficient number of owner send a signature ICW. Technically, owners can only be air-gapped devices.
* We use airgapped devices as signing devices (these have to be constructed; currently, no airgapped devices exist which comply with this specification). Thus, at least two hardware components, connected to the MultiSigSafe (MSS), have to be physically stolen or compromised to get access to the MSS. This means, before you will have access to MSS, you have to steal two physically devices, which must fit to the MSS from (in the best case) two locations all over the world; additionally, you have to break a standard multisig wallet. 
* We use a minimum of two owners to sign a Tx.
* We use additional standard safety mechanisms to prevent replay and other attacks, like nonce, limits, etc.
* We build the system as simple as possible with only the essential functionality. This means:
    * No reconfiguration. Once initialized, the wallets parameters cannot be changed. If you want to change the parameters, you simply deploy a new wallet.
    * No address handling. In the interaction with the core wallet, the user should never need to transfer / input / copy&paste addresses. Instead, the user should simply input small numbers (values, indexes).
    * The airgapped device should be maximally simple: Only two buttons and an LCD display to output a QR-Code and text.

Return to safe state:

* If any part of the system breaks or gets compromised, e.g. a lost owner ID / airgapped device, we will return to a safe state by a complete reinstall of the system: new airgapped devices, newly deployed smart contracts, then move the funds in the fresh system.


## Specification

An “Insurable Crypto Wallet” is a system of components, which enable one or more users to store large amounts of assets in a secure way. Thus, the ICW follows the following Overall Safety Concept. We formally require the following components with the described properties.

### Components

An ICW has to consist of the following components:

1. MultiSigSafe smart contract ("MSS", safe execution of multiply signed transactions)
2. Air-gapped devices (safe creation of signatures)
3. Multisig receiver wallet (safe, implementation different from MultiSigSafe)
4. Webinterface (unsafe, support user in the process)
5. Monitoring infrastructure

#### Requirements for 1.: MSS

1. No reconfiguration possible
2. All addresses hard-coded
3. Minium principle: Minimum functions, minimum lines of code, minimum used language constructs, minimum used EVM codes
4. Use of pre-signed transactions
5. Complete input validation
6. Support of formal verification (e.g. formal specification, proof)

Additionally, some or all of the following:

* Hard coded owner addresses (air-gapped devices)
* Hard coded destination addresses (e.g. MultiSigWallets)
* Hard coded token addresses, alternative token address book, see remark no. 1.
* Input Validation Check (define and check input boundaries)
* Initialize all local variables with “safe” values
* Verifying owners and validate configuration (e.g. 2oo3), as first step
* Execute Transaction

Programming principles:

* No loops, reduced language subset
* Simple functions
* Formal provable
* Compiler result can be verified against source code.

Remark No. 1: Due to variable token transfer, which cannot be controlled by MSS owners, the token contract addresses must be more flexible. Today, there two optional ways to get token address flexible: Send individual address for each Tx ore choose token address out of a token address book by “number”, e.g. no. “1” for token contract address 1. In actual setup, the token contract addresses are hard coded in the MSS. As we know, this is not a practical way, but in this early stage, best way to describe principles.

#### Requirements for 2.: Airgapped Devices

1. Input over minimum number of buttons
2. Output over display (QR-Code or similar)
3. One-time initialization, no reconfiguration

Additionally, all or some of the following:

* No interfaces (only for battery)
* One display for QR-Code 
  The signed transaction is displayed as QR-Code on the display of the HD (Airgapped device)
    * MSS address
    * Signature
    * Configuration (e.g. 2oo3)
    * Nonce 
  The format of the information contained in the QR-Code is such that it can be used without processing from a web interface.
* Pin-Protected (low level), protection against undesired usage.
* IP67
* EMC according EN61326
* Environmental according to EN60068-2
* The HD device has only 2 input channels: two simple buttons and 1 output channel: an LCD Display.
* The HD can be initialized and generates a Private Key in a secure enclave. The Private Key never leaves the secure enclave. 
* Recovery mechanisms like display of seed phrases etc can be integrated like in the ledger device
* The HD can sign standardized messages with the following parameters:
    * Address of the HD
    * An integer “value”
    * A boolean flag “tokenTransfer”
    * b. and c. can be input by the user via two simple buttons.
    * The signed message is displayed as QR-Code together with the input parameters on an LCD-Display.

Remark No. 2: Until air-gapped devices are available, which comply with our specification, we will optionally use a Ledger Nano with web interface instead of an air-gap device, with same functionality. This will raise safety level enormously in comparison to state today. In a second step, we or others will develop specialized air-gap devices which are optimized for use with the MSS.

#### Requirements for 3.: Multisig Receiver Wallets
1. Ability to transfer funds to any destination
2. Minimum principle

#### Requirements for 4.: Web-Interface
1. Support user in setup of airgapped devices and deployment of MSS.
2. Check functionality of MSS and airgapped devices.
3. Support user in preparation and execution of transaction
4. Support user in monitoring transactions (Transaction list)

The web-interface serves as a source of information (displaying balances, etc.) and as a tool to merge two or three signatures and send them as payload to an ethereum node and then to the MSS smart contract.
Only web-cam scanning of air-gapped device QR-Code
Automatically scanning for further Tx
Automatically sending call of contract with collected signatures
T.B.D: The “sender” address of the Tx has to be discussed (in a future version, the MSS contract could pay the gas costs)

#### Requirements for 5.: Monitoring infrastructure
1. Agents which continuously watch MSS 
2. Detection of malicious activities (e.g. failed transactions, improper calls etc.)
3. Tracking of breaches (taint analysis of wallet hacks)


### General Functional Aspects

* Long term storage of ETH
* Long term storage of tokens

### General Development Aspects

* Developing processes according to functional safety standards (e.g. IEC61508)
* Following programming rules
* Poka yoke
* Minimize, only necessary functions
* Avoid handling failures
* Systematic validation and verification approach (FMEA, Testing, etc.)

### General Assumptions

* Correctness of EVM (to be proven)
* Correctness of MSS (to be proven)
* No equal addresses
* Ability to send Tx to blockchain via a ethereum node


## Implementation Proposal

### General Setup

* 2 Participants Alice & Bob
* 1 MultiSigSafe, for value storage (MSS), configured in 2oo3 (at minimum two owners must sign the Tx)
* 1 MultiSigWallet (e.g. Gnosis style), for daily usage (MW1)
* 1 MultiSigWallet (e.g. Gnosis style), for daily usage (MW2)
* 1 MultiSigWallet (e.g. Gnosis style), for backup in case of compromised, broken MW1 and MW2 (MW3)
* 3 air-gapped hardware devices for creating signatures (HD1, HD2, HD3), one is kept as rescue in case one device is lost or compromised. Functions of the Hardware device:
* Initialize: A fresh device can generate a private key, store it in the secure enclave and password-protect it.
* Enter transaction: A transaction consists of 4 Values: 
    * Nonce (the HD will store the nonce and increment it for convenience, but the nonce can be increased or decreased by the user)
    * Value (Value of transaction in terms of ETH or # of tokens
    * DestinationIndex (a value from 1-3, addressing one of the hardcoded addresses)
    * TokenTransfer (boolean, indicating whether a token transfer takes place)
* Etherisc homepage, Web-Interface
* List of token contracts, within the MSS is token holder, (TA1, TA2, TAx) (see remark no. 1)

### General Linking

* MSS can only transfer value to destination address MW1, MW2 or MW3. Destination addresses are “hard coded” in MSS
* MSS can only be activated by the owners HD1, HD2 or HD3, according to the specified architecture, in this example 2oo3. Owner addresses are “hard coded” in MSS
* MSS can only send Tx to the token, listed in the token contract list. Token contract addresses are “hard coded” in this example (Remark: they may be more flexible in future, eg token address book)

### Workflow
#### Initialization

* Hard code addresses of MW1 - MW3 in the MSS smart contract
* Hard code addresses of HD1 - HD3 in the MSS smart contract
* Hard code addresses of token addresses (see remark no. 1)
* deploy & check that everything is ok.
* Transfer Funds / Tokens to MSS.

#### Transfer ETH
Alice & Bob decide to transfer an amount of 100 ETH out of the MSS.

Alice Procedure:

* Alice takes the air-gapped device (HD1) and activates it by PIN input
* Alice choose ETH Tx in the air-gapped device
* Alice chooses MW1 by type in the air-gapped device (HD1)
* Air-gapped device (HD1) asks Alice for choosing the destination wallet (MW1, MW2 or MW3
* Air-gapped device (HD1) asks Alice for ETH amount 
* Alice type in the air-gapped device (HD1) 100 ETH
* Air-gapped device (HD1) asks Alice for nonce
* Alice type in the air-gapped device nonce = 10
* Air-gapped device (HD1) generates signature considering owner, MW, ETH, nonce
* Air-gapped device (HD1) generates a QR-Code with signature
* Alice opens the browser on her computer
* Alice surfs to etherisc.webinterface.mss 
* Alice holds the display of the air-gapped device (HD1) in front of the web cam of her computer. 
* The etherisc.webinterface.mss scans the QR-Code and gives feedback in case of successful scan.
* Alice closes browser
* Alice shuts off the air-gapped device HD1

Bob Procedure:

* Like Alice, only with air-gapped device HD2
* etherisc.webinterface.mss now sees out of the QR-Codes (by checking MSS address and nonce) of Alice and Bob, that both scans belongs to the same MSS, with the same nonce and with sufficient numbers of scans (in this case HD1 and HD2)
* etherisc.webinterface.mss generates the Tx for call execute of the MSS
* etherisc.webinterface.mss sends Tx on the blockchain automatically
* MSS contract receives Tx and do the following checks:
* MSS validates input
* MSS validates owners and architecture
* MSS execute Tx
* 100 ETH are transferred from the MSS to MW1

#### Token Transfer
Alice & Bob decide to transfer an amount of 100 tokens out of the MSS.

Alice Procedure:

* Alice takes the air-gapped device (HD1) and activates it by PIN input
* Alice choose token Tx in the air-gapped device
* Air-gapped device (HD1) asks Alice for choosing the destination wallet (MW1, MW2 or MW3
* Alice chooses MW1 by type in the air-gapped device (HD1)
* Air-gapped device (HD1) asks Alice for choosing the token contract address (TA1, TA2 or TA3)
* Alice chooses TA1 by type in the air-gapped device (HD1)
* Air-gapped device (HD1) asks Alice for token amount 
* Alice type in the air-gapped device (HD1) 100 tokens
* Air-gapped device (HD1) asks Alice for nonce
* Alice type in the air-gapped device nonce = 11
* Air-gapped device (HD1) generates signature considering owner, MW, TA, TokenValue, nonce
* Air-gapped device (HD1) generates a QR-Code with signature
* Alice opens the browser on her computer
* Alice surfs to etherisc.webinterface.mss 
* Alice holds the display of the air-gapped device (HD1) in front of the web cam of her computer. 
* The etherisc.webinterface.mss scans the QR-Code and gives feedback in case of successful scan.
* Alice closes browser
* Alice shuts off the air-gapped device HD1

Bob Procedure

* Like Alice, only with air-gapped device HD2
* etherisc.webinterface.mss now sees out of the QR-Codes (by checking MSS address and nonce) of Alice and Bob, that both scans belongs to the same MSS, with the same nonce and with sufficient numbers of scans (in this case HD1 and HD2)
* etherisc.webinterface.mss generates the Tx for call execute of the MSS
* etherisc.webinterface.mss sends Tx on the blockchain automatically
* MSS contract receives Tx and do the following checks:
* MSS validates input
* MSS validates owners and architecture
* MSS execute Tx token
* 100 token are transferred from the MSS to MW1

## Appendix

We provide two sample implemenations. These should not be considered as working code, 
please don't store money in them! Rather, we see them as starting point for a discussion 
of this specification.

* [MSS 1. Example](../MSS_spec/contracts/MultiSigSafeToken_ForSpec.sol)
* [MSS 2. Example](../master/contracts/MultiSigSafeToken.sol) 


