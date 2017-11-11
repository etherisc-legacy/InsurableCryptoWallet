# Proposal for insurable Multisig Safe ###

We propose a multisig wallet which is reliable enough to store 
values larger than USD 1M and is insurable at the same time.

## Design principles ##

* Minimal functionality: 
  * *Principle:* Only a minimum function set should be implemented.
  Usability should be provided in a possible frontend, but not in the contract itself.
  * *Rationale:* By reducing the amount of code and entry points, we radically decrease the attack surface.
  Code which is left out, cannot be attacked.

* Minimum use of language constructs:
  * *Principle:* Only a minimium subset of solidity language constructs should be used.
  * *Rationale:* See above. We only use the following subset:
    * Function calls
    * `if` - `then` - `else`
    * Addition
    * `transfer`
    * `throw` 

* No modifiable configuration: 
  The configuration should be fixed at deploy time.

