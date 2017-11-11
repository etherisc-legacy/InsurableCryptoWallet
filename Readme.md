# Proposal for insurable Multisig Safe ###

We propose a multisig wallet which is reliable enough to store 
values larger than USD 1M and is insurable at the same time.

## Design principles ##

* Minimal functionality: 
  * *Principle:* Only a minimum function set should be implemented.
  Usability should be provided in a possible frontend, but not in the contract itself.
  The contract is a fixed two-of-three multisig which accepts three pre-signed transactions.
  If two of the three pre-signed transactions fit to two of the three predefined owner addresses,
  the transaction is executed.
  * *Rationale:* By reducing the amount of code and entry points, we radically decrease the attack surface.
  Code which is left out, cannot be attacked.

* Minimum use of language constructs:
  * *Principle:* Only a minimium subset of solidity language constructs should be used.
  * *Rationale:* See above. We only use the following subset:
    * Function calls
    * Sequential statements
    * Conditional statements: `if` - `then` - `else`
    * Addition
    * `transfer`
    * Assignment
    * `require`

* No modifiable configuration: 
  * *Principle:* The configuration should be fixed at deploy time. All addresses are hardcoded and cannot be changed.

* Auditable configuration
  * *Principle:* The configuration should be easy auditable. All configuration parameters can be
  simply read via public functions
  * *Rationale:* After deployment, the sanity of the deployed contract can be easily checked, before any
  values are stored in the 

* Minimum state
  * *Principle:* 
  * *Rationale:* 

## Analyis ##

The wallet has no constructor. It has 10 entry points, 9 of which are read-only. 
The only state-modyfing function is the function `execute` with 11 parameters.
The first 9 parameters contain 

## FAQ ##

* Why 