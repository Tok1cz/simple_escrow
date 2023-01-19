# simple_escrow
A simple Escrow contract creator with deployment script with automatic publication.

The contract is very basic and serves as an academic example. **Not** meant for production.

Currently set for TestNet deployment on Sepolia.

CAUTION:: The deployment script has no gas limit.



Install the necessary libraries. Especially
```
solcx
web3
dotenv
```

Add your credentials to the ```.env```file. (update the template txt and save as all files, with name ".env")

You need an Ethereum address and private key.
For Sepolia the chain Id is 11155111.

For node access, you need an API key for your HTTP Provider, I use infura. Creating an account is free.
For publishing and verifying the source code of the contract, you need an Etherscan API key. Creating an account is also free here.

Run ```deploy.py``` to deploy the contract. 


_Written and tested in Python 3.8.8 on Windows 11. 01/2023_
