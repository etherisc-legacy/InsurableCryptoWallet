# Proposal for an Insurable Crypto Wallet (ICW) ###

We propose a multisig wallet which is reliable enough to store 
values larger than USD 1M and is insurable at the same time.

## Design principles ##

* Minimal functionality
* Minimum use of language constructs
* No modifiable configuration
* Auditable configuration
* Minimum state

A detailed specification can be found in [specification.md](specification.md)

Thanks to Christian Lundkvist, who provided the [underlying idea](https://github.com/christianlundkvist/simple-multisig), and
Vitalik Buterin who [implemented it in Viper](https://github.com/ethereum/viper/blob/master/examples/wallet/wallet.v.py)
