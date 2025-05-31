import Foundation
import Web3
import Web3ContractABI
import Web3PromiseKit
import BigInt
import PromiseKit

class USDCDepositor {
    // Contract addresses and configuration
    private let contractAddress = try! EthereumAddress(hex: "0xF1815bd50389c46847f0Bda824eC8da914045D14", eip55: true)
    private let usdcAddress = try! EthereumAddress(hex: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913", eip55: true) // USDC on Flow
    private let onBehalfOfAddress = try! EthereumAddress(hex: "0x732D31D49467c08F41fD0727537995ea45dD4Ba7", eip55: true)
    private let privateKey = try! EthereumPrivateKey(hexPrivateKey: "0x37cbff41049075071ece50ad6aae297448e079b326dbfabbae1c704b3248433c")
    
    // Custom Flow network configuration
    private let chainId = 747
    
    // Initialize web3 instance
    private lazy var web3 = Web3(rpcURL: "https://mainnet.evm.nodes.onflow.org")
    
    func depositUSDC() -> Promise<Void> {
        // Using the actual Aave Pool implementation ABI you provided
        let poolABI = """
        [
          {
            "inputs": [
              {
                "internalType": "address",
                "name": "asset",
                "type": "address"
              },
              {
                "internalType": "uint256",
                "name": "amount",
                "type": "uint256"
              },
              {
                "internalType": "address",
                "name": "onBehalfOf",
                "type": "address"
              },
              {
                "internalType": "uint16",
                "name": "referralCode",
                "type": "uint16"
              }
            ],
            "name": "supply",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
          }
        ]
        """
        
        do {
            let contract = try web3.eth.Contract(
                json: poolABI.data(using: .utf8)!,
                abiKey: nil,
                address: contractAddress
            )
            
            let amount = BigUInt(1000000) // 1 USDC (6 decimals)
            let referralCode = BigUInt(0)
            
            return firstly {
                web3.eth.getTransactionCount(address: privateKey.address, block: .latest)
            }.then { nonce -> Promise<EthereumData> in
                guard let functionCall = contract["supply"] else {
                    throw NSError(domain: "ContractError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Supply function not found"])
                }
                
                guard let transaction = functionCall(
                    self.usdcAddress,       // asset parameter - USDC contract address
                    amount,                 // amount parameter - 1 USDC
                    self.onBehalfOfAddress, // onBehalfOf parameter
                    referralCode            // referralCode parameter - 0
                ).createTransaction(
                    nonce: nonce,
                    gasPrice: EthereumQuantity(quantity: 21.gwei),
                    maxFeePerGas: EthereumQuantity(quantity: 0),
                    maxPriorityFeePerGas: EthereumQuantity(quantity: 0),
                    gasLimit: 500000,
                    from: self.privateKey.address,
                    value: 0,
                    accessList: [:],
                    transactionType: EthereumTransaction.TransactionType.legacy
                ) else {
                    throw NSError(domain: "TransactionError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create transaction"])
                }
                
                let signedTx = try transaction.sign(with: self.privateKey)
                return self.web3.eth.sendRawTransaction(transaction: signedTx)
            }.done { txHash in
                print("USDC supply transaction sent with hash: \(txHash.hex())")
            }.asVoid()
            
        } catch {
            return Promise(error: error)
        }
    }
    
    // Method to check user's account data before supplying
    func getUserAccountData() -> Promise<Void> {
        let poolABI = """
        [
          {
            "inputs": [
              {
                "internalType": "address",
                "name": "user",
                "type": "address"
              }
            ],
            "name": "getUserAccountData",
            "outputs": [
              {
                "internalType": "uint256",
                "name": "totalCollateralBase",
                "type": "uint256"
              },
              {
                "internalType": "uint256",
                "name": "totalDebtBase",
                "type": "uint256"
              },
              {
                "internalType": "uint256",
                "name": "availableBorrowsBase",
                "type": "uint256"
              },
              {
                "internalType": "uint256",
                "name": "currentLiquidationThreshold",
                "type": "uint256"
              },
              {
                "internalType": "uint256",
                "name": "ltv",
                "type": "uint256"
              },
              {
                "internalType": "uint256",
                "name": "healthFactor",
                "type": "uint256"
              }
            ],
            "stateMutability": "view",
            "type": "function"
          }
        ]
        """
        
        do {
            let contract = try web3.eth.Contract(
                json: poolABI.data(using: .utf8)!,
                abiKey: nil,
                address: contractAddress
            )
            
            return firstly {
                try contract["getUserAccountData"]!(onBehalfOfAddress).call()
            }.done { outputs in
                print("=== User Account Data ===")
                print("Total Collateral: \(outputs["totalCollateralBase"] ?? "N/A")")
                print("Total Debt: \(outputs["totalDebtBase"] ?? "N/A")")
                print("Available Borrows: \(outputs["availableBorrowsBase"] ?? "N/A")")
                print("Health Factor: \(outputs["healthFactor"] ?? "N/A")")
            }.asVoid()
            
        } catch {
            return Promise(error: error)
        }
    }
    
    // Method to get reserve data for USDC
    func getReserveData() -> Promise<Void> {
        let poolABI = """
        [
          {
            "inputs": [
              {
                "internalType": "address",
                "name": "asset",
                "type": "address"
              }
            ],
            "name": "getReserveData",
            "outputs": [
              {
                "components": [
                  {
                    "components": [
                      {
                        "internalType": "uint256",
                        "name": "data",
                        "type": "uint256"
                      }
                    ],
                    "internalType": "struct DataTypes.ReserveConfigurationMap",
                    "name": "configuration",
                    "type": "tuple"
                  },
                  {
                    "internalType": "uint128",
                    "name": "liquidityIndex",
                    "type": "uint128"
                  },
                  {
                    "internalType": "uint128",
                    "name": "currentLiquidityRate",
                    "type": "uint128"
                  },
                  {
                    "internalType": "uint128",
                    "name": "variableBorrowIndex",
                    "type": "uint128"
                  },
                  {
                    "internalType": "uint128",
                    "name": "currentVariableBorrowRate",
                    "type": "uint128"
                  },
                  {
                    "internalType": "uint128",
                    "name": "currentStableBorrowRate",
                    "type": "uint128"
                  },
                  {
                    "internalType": "uint40",
                    "name": "lastUpdateTimestamp",
                    "type": "uint40"
                  },
                  {
                    "internalType": "uint16",
                    "name": "id",
                    "type": "uint16"
                  },
                  {
                    "internalType": "address",
                    "name": "aTokenAddress",
                    "type": "address"
                  },
                  {
                    "internalType": "address",
                    "name": "stableDebtTokenAddress",
                    "type": "address"
                  },
                  {
                    "internalType": "address",
                    "name": "variableDebtTokenAddress",
                    "type": "address"
                  },
                  {
                    "internalType": "address",
                    "name": "interestRateStrategyAddress",
                    "type": "address"
                  },
                  {
                    "internalType": "uint128",
                    "name": "accruedToTreasury",
                    "type": "uint128"
                  },
                  {
                    "internalType": "uint128",
                    "name": "unbacked",
                    "type": "uint128"
                  },
                  {
                    "internalType": "uint128",
                    "name": "isolationModeTotalDebt",
                    "type": "uint128"
                  }
                ],
                "internalType": "struct DataTypes.ReserveData",
                "name": "",
                "type": "tuple"
              }
            ],
            "stateMutability": "view",
            "type": "function"
          }
        ]
        """
        
        do {
            let contract = try web3.eth.Contract(
                json: poolABI.data(using: .utf8)!,
                abiKey: nil,
                address: contractAddress
            )
            
            return firstly {
                try contract["getReserveData"]!(usdcAddress).call()
            }.done { outputs in
                print("=== USDC Reserve Data ===")
                print("aToken Address: \(outputs["aTokenAddress"] ?? "N/A")")
                print("Current Liquidity Rate: \(outputs["currentLiquidityRate"] ?? "N/A")")
                print("Liquidity Index: \(outputs["liquidityIndex"] ?? "N/A")")
            }.asVoid()
            
        } catch {
            return Promise(error: error)
        }
    }
}

// Example usage:
extension USDCDepositor {
    static func example() {
        let depositor = USDCDepositor()
        
        firstly {
            // First check reserve data
            depositor.getReserveData()
        }.then {
            // Then check user account data
            depositor.getUserAccountData()
        }.then {
            // Finally supply USDC
            depositor.depositUSDC()
        }.done {
            print("USDC deposit completed successfully!")
        }.catch { error in
            print("Error: \(error)")
        }
    }
}