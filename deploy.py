
import os
import solcx
import json
from web3 import Web3
import dotenv
import requests
import time

"""Todo...:
Add Gas limit
Check if contract is actually deployed before publishing
Check if publishing was successfull
"""


dotenv.load_dotenv()

#Necessary for relative paths
abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)
os.chdir(dname)

#Get String of Solidity Code
with open(r"./SimpleEscrows.sol", "r") as f:
    SimpleEscrows_code_string = f.read()

# Compile the solidity Code
compiled_sol = solcx.compile_standard({
    "language" : "Solidity",
    "sources" : {"SimpleEscrows.sol":{"content":SimpleEscrows_code_string}},
    "settings": {
            "outputSelection":{
                "*": {"*":["abi","metadata", "evm.bytecode", "evm.sourceMap"]}
}}})
#Save Compiled Object as Json (Just to find bytecode and abi)
with open("compiledSimpleEscrows.json", "w") as f:
    json.dump(compiled_sol, f)
#get bytecode and abi
bytecode = compiled_sol["contracts"]["SimpleEscrows.sol"]["SimpleEscrows"]["evm"]["bytecode"]["object"]
abi = compiled_sol["contracts"]["SimpleEscrows.sol"]["SimpleEscrows"]["abi"]

# Connect to local simulated Blockchain (Ganache) and deploy 
infura_api_key = os.getenv("INFURA_API_KEY")

w3 = Web3(Web3.HTTPProvider(f"https://sepolia.infura.io/v3/{infura_api_key}"))

chain_id = int(os.getenv("CHAIN_ID"))

# Put address into dotenv obsly
my_address = os.getenv("MY_ADDRESS") # address to deploy from
private_key = os.getenv("PRIVATE_KEY") 
 # Create Contract Object "SimpleEscrows" = Name of the Contract
SimpleEscrows = w3.eth.contract(abi=abi, bytecode=bytecode)
 # Build Transaction
nonce = w3.eth.get_transaction_count(my_address)
transaction = SimpleEscrows.constructor().buildTransaction({"chainId":chain_id,"from":my_address, "nonce":nonce})
 # Sign Transaction
signed_transaction = w3.eth.account.sign_transaction(transaction, private_key=private_key)
 # Send Transaction
print("Deploying Contract...")

transaction_hash = w3.eth.send_raw_transaction(signed_transaction.rawTransaction)
tx_receipt = w3.eth.wait_for_transaction_receipt(transaction_hash)
print(tx_receipt)
print("Contract deployed successfully.")

# Publish and Verify source
# Make sure that contract is really deployed here
# before publishing, otherwise publishing fails...

# Better solution would be to add a while loop for publishing,
#  checking if contract is on Chain

# 15 sec is normally sufficient for sepolia,
# most probably not for MainNet
time.sleep(15)



etherscan_api_url = "https://api-sepolia.etherscan.io/api"
etherscan_api_key = os.getenv("ETHERSCAN_TOKEN")



params = {
    "format":"x-www-form-urlencoded",
    "apikey":etherscan_api_key,
    "module":"contract",
    "action":"verifysourcecode",
    "contractaddress": tx_receipt["contractAddress"],
    "contractname":"SimpleEscrows",
    "codeformat":"solidity-single-file",
    "compilerversion":"v"+str(solcx.get_solc_version(with_commit_hash=True)),
    "optimizationused":0,
    "sourceCode": SimpleEscrows_code_string

}
print("Publishing source...")
resp = requests.post(etherscan_api_url,params=params)
print(resp)
print(resp.content)


print(tx_receipt["contractAddress"])

