# Cryptozombies course and SimpleStorage  example

This repo contains 

- the cryptozombies courses updated to solidity 0.8.19 jun 2024
- SimpleStorge minimal contract that only stores a value via getter / setter

Solidity has to be before 0.8.20 because https://ethereum.stackexchange.com/questions/150281/invalid-opcode-opcode-0x5f-not-defined/161747#161747

- contracts are managed by truffle (build, deploy, console)
- frontent at /web3 folder, simplestorage demo and cryptozombies demo

(I removed temorary the limit of 1 per uses, at ZombieFactory.sol)

# Notes

- The .json on truffle build folder contract definitiois
  i.e. ZombieOwnership.json and SimpleStorage.json

# truffle console example to call smart contract

truffle console

// you will see a CLI

//create  a var to store an instance of the contract
truffle(development)> let instance = await StoreValue.deployed()

//set stored value to 42 
truffle(development)> instance.set(42)

//get stored value
truffle(development)> instance.get()

# notes

hardcoded contract addresees are on my local ganache server so it can be leaked XD
