solidity has to be before 0.8.20 because https://ethereum.stackexchange.com/questions/150281/invalid-opcode-opcode-0x5f-not-defined/161747#161747

# truffle consola example

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
