#!/bin/bash

# Deployment script for cTipJar on Celo Sepolia Testnet
# This script deploys the cTipJar contract using Foundry

set -e  # Exit on any error

# Load environment variables from .env file
if [ -f ".env" ]; then
    source .env
fi

# Network details
RPC_URL="${CELO_SEPOLIA_RPC_URL:-https://forno.celo-sepolia.celo-testnet.org}"
CHAIN_ID=11142220
EXPLORER_URL="https://celo-sepolia.blockscout.com"
VERIFIER="blockscout"
VERIFIER_URL="${EXPLORER_URL}/api"

# Contract addresses (update these as needed)
# cUSD on Celo Sepolia: 0x2F25deB3848C207fc8E0c34035B3Ba7fC157602B3 (confirm latest)
CUSD_ADDRESS="${CUSD_ADDRESS:-0x2F25deB3848C207fc8E0c34035B3Ba7fC157602B3}"
OWNER_ADDRESS="${OWNER_ADDRESS:-$ADDRESS}"  # Use ADDRESS from .env if not set

# Private key (set via env var or prompt)
# Using Foundry keystore account 'celoKey'
ACCOUNT_NAME="${ACCOUNT_NAME:-celoKey}"

# Prompt for OWNER_ADDRESS if not set
if [ -z "$OWNER_ADDRESS" ]; then
    echo "Enter the owner address for the tip jar:"
    read -r OWNER_ADDRESS
fi

# Validate inputs
if [ -z "$OWNER_ADDRESS" ]; then
    echo "Error: OWNER_ADDRESS not set."
    exit 1
fi

echo "Deploying cTipJar to Celo Sepolia..."
echo "RPC: $RPC_URL"
echo "Chain ID: $CHAIN_ID"
echo "cUSD Address: $CUSD_ADDRESS"
echo "Owner Address: $OWNER_ADDRESS"
echo "Account: $ACCOUNT_NAME"
echo "Explorer: $EXPLORER_URL"
echo "You will be prompted to enter the password for the keystore account."

# Export env vars for the script
# export CUSD_ADDRESS
# export OWNER_ADDRESS

# Run the deployment
source .env && forge script script/DeploycTipJar.s.sol \
    --rpc-url "$RPC_URL" \
    --account "$ACCOUNT_NAME" \
    --sender "$ADDRESS" \
    --broadcast \
    --verify \
    --verifier "$VERIFIER" \
    --verifier-url "$VERIFIER_URL" \
    --chain-id "$CHAIN_ID"

echo "Deployment complete! Check the explorer for the contract address."