import Foundation
import Web3
import Web3ContractABI
import Web3PromiseKit
import BigInt
import PromiseKit

class USDCDepositor {
    // Contract addresses and configuration - CORRECTED
    private let poolContractAddress = try! EthereumAddress(hex: "0xbC92aaC2DBBF42215248B5688eB3D3d2b32F2c8d", eip55: true) // Pool contract with supply function
    private let usdcAddress = try! EthereumAddress(hex: "0xF1815bd50389c46847f0Bda824eC8da914045D14", eip55: true) // USDC ERC20 token
    private let onBehalfOfAddress = try! EthereumAddress(hex: "0x732D31D49467c08F41fD0727537995ea45dD4Ba7", eip55: true)
    
    // Private key loaded securely from environment
    private let privateKey: EthereumPrivateKey
    
    // Custom Flow network configuration
    private let chainId = 747
    
    // Initialize web3 instance
    private lazy var web3 = Web3(rpcURL: "https://mainnet.evm.nodes.onflow.org")
    
    // MARK: - Initialization with Secure Key Loading
    
    init() throws {
        // Load private key from environment variables
        self.privateKey = try Self.loadPrivateKeyFromEnvironment()
    }
    
    // MARK: - Secure Private Key Loading
    
    /// Load private key from environment variables
    private static func loadPrivateKeyFromEnvironment() throws -> EthereumPrivateKey {
        guard let privateKeyHex = ProcessInfo.processInfo.environment["ETHEREUM_PRIVATE_KEY"] else {
            throw PrivateKeyError.environmentVariableNotFound("ETHEREUM_PRIVATE_KEY")
        }
        
        guard !privateKeyHex.isEmpty else {
            throw PrivateKeyError.emptyPrivateKey
        }
        
        // Validate the key format
        let cleanedKey = privateKeyHex.hasPrefix("0x") ? privateKeyHex : "0x" + privateKeyHex
        
        guard cleanedKey.count == 66 else { // 0x + 64 hex characters
            throw PrivateKeyError.invalidKeyFormat
        }
        
        do {
            return try EthereumPrivateKey(hexPrivateKey: cleanedKey)
        } catch {
            throw PrivateKeyError.invalidKey(error.localizedDescription)
        }
    }
    
    // MARK: - Deposit Functions
    
    func depositUSDC() -> Promise<Void> {
        print("🚀 Starting USDC deposit process...")
        print("🏦 Pool Contract Address: \(poolContractAddress.hex(eip55: true))")
        print("💰 USDC Token Address: \(usdcAddress.hex(eip55: true))")
        print("👤 On Behalf Of: \(onBehalfOfAddress.hex(eip55: true))")
        print("🔑 From Address: \(privateKey.address.hex(eip55: true))")
        print("🌐 Chain ID: \(chainId)")
        
        // First, let's test basic connectivity and check if we have the right addresses
        return firstly {
            self.testConnection()
        }.then {
            self.checkAccountBalance()
        }.then {
            self.validateUSDCAddress()
        }.then {
            self.getTransactionCount()
        }.then { nonce -> Promise<EthereumData> in
            return try self.createAndSendTransaction(nonce: nonce)
        }.done { txHash in
            print("✅ Transaction sent successfully!")
            print("📜 Transaction Hash: \(txHash.hex())")
        }
    }
    
    private func testConnection() -> Promise<Void> {
        print("🔍 Testing connection to Flow network...")
        
        return firstly {
            web3.net.version()
        }.done { version in
            print("✅ Connected to network. Chain ID: \(version)")
        }.recover { error -> Promise<Void> in
            print("❌ Network connection failed: \(error)")
            throw DepositError.networkError(error.localizedDescription)
        }
    }
    
    private func checkAccountBalance() -> Promise<Void> {
        print("💰 Checking account balance...")
        
        return firstly {
            web3.eth.getBalance(address: privateKey.address, block: .latest)
        }.done { balance in
            let ethBalance = Double(balance.quantity) / 1e18
            print("💳 Account Balance: \(ethBalance) FLOW")
            
            if balance.quantity == 0 {
                throw DepositError.insufficientBalance
            }
        }.recover { error -> Promise<Void> in
            print("❌ Balance check failed: \(error)")
            throw DepositError.balanceCheckFailed(error.localizedDescription)
        }
    }
    
    private func validateUSDCAddress() -> Promise<Void> {
        print("🔍 Validating USDC token contract...")
        
        return firstly {
            web3.eth.getCode(address: usdcAddress, block: .latest)
        }.then { usdcCode -> Promise<EthereumData> in
            if usdcCode.bytes.isEmpty {
                print("❌ USDC token contract not found at: \(self.usdcAddress.hex(eip55: true))")
                throw DepositError.contractNotFound("USDC token contract not deployed")
            } else {
                print("✅ USDC token contract found with \(usdcCode.bytes.count) bytes of code")
            }
            
            // Also validate the pool contract
            return self.web3.eth.getCode(address: self.poolContractAddress, block: .latest)
        }.done { poolCode in
            if poolCode.bytes.isEmpty {
                print("❌ Pool contract not found at: \(self.poolContractAddress.hex(eip55: true))")
                throw DepositError.contractNotFound("Pool contract not deployed")
            } else {
                print("✅ Pool contract found with \(poolCode.bytes.count) bytes of code")
            }
        }.asVoid()
    }
    
    private func getTransactionCount() -> Promise<EthereumQuantity> {
        print("🔢 Getting transaction count (nonce)...")
        
        return firstly {
            web3.eth.getTransactionCount(address: privateKey.address, block: .latest)
        }.get { nonce in
            print("📝 Current nonce: \(nonce.quantity)")
        }.recover { error -> Promise<EthereumQuantity> in
            print("❌ Failed to get nonce: \(error)")
            throw DepositError.nonceError(error.localizedDescription)
        }
    }
    
    private func createAndSendTransaction(nonce: EthereumQuantity) throws -> Promise<EthereumData> {
        print("🔨 Creating transaction...")
        
        // Using proper ABI for the supply function
        let supplyABI = """
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
                json: supplyABI.data(using: .utf8)!,
                abiKey: nil,
                address: poolContractAddress // Use the pool contract address
            )
            
            let amount = BigUInt(1000000) // 1 USDC (6 decimals)
            let referralCode = BigUInt(0)
            
            print("📊 Transaction Parameters:")
            print("   • Pool Contract: \(poolContractAddress.hex(eip55: true))")
            print("   • Asset (USDC): \(usdcAddress.hex(eip55: true))")
            print("   • Amount: \(amount) (1 USDC)")
            print("   • OnBehalfOf: \(onBehalfOfAddress.hex(eip55: true))")
            print("   • ReferralCode: \(referralCode)")
            print("   • Nonce: \(nonce.quantity)")
            
            guard let functionCall = contract["supply"] else {
                throw DepositError.contractError("Supply function not found in ABI")
            }
            
            print("⚙️ Creating transaction with gas settings...")
            
            guard let transaction = functionCall(
                self.usdcAddress,       // asset parameter - USDC token address
                amount,                 // amount parameter
                self.onBehalfOfAddress, // onBehalfOf parameter
                referralCode            // referralCode parameter
            ).createTransaction(
                nonce: nonce,
                gasPrice: EthereumQuantity(quantity: 1.gwei),
                maxFeePerGas: EthereumQuantity(quantity: 0),
                maxPriorityFeePerGas: EthereumQuantity(quantity: 0),
                gasLimit: EthereumQuantity(quantity: BigUInt(300000)),
                from: self.privateKey.address,
                value: EthereumQuantity(quantity: BigUInt(0)),
                accessList: [:],
                transactionType: EthereumTransaction.TransactionType.legacy
            ) else {
                throw DepositError.transactionCreationFailed
            }
            
            print("🔐 Signing transaction...")
            let signedTx = try transaction.sign(with: self.privateKey, chainId: EthereumQuantity(quantity: BigUInt(self.chainId)))
            print("✅ Transaction signed successfully")
            
            print("📡 Sending transaction to network...")
            return firstly {
                self.web3.eth.sendRawTransaction(transaction: signedTx)
            }.recover { error -> Promise<EthereumData> in
                print("❌ Transaction send failed: \(error)")
                print("📝 Detailed error: \(error.localizedDescription)")
                print("🔍 Error type: \(type(of: error))")
                throw DepositError.transactionSendFailed(error.localizedDescription)
            }
            
        } catch {
            print("❌ Transaction creation error: \(error)")
            throw DepositError.contractError(error.localizedDescription)
        }
    }
    
    // Method to find the correct USDC address on Flow
    func findUSDCAddress() -> Promise<Void> {
        print("🔍 Searching for USDC contract on Flow EVM...")
        
        // Based on research, Flow EVM uses bridged tokens
        // Let's check some common patterns for bridged USDC addresses
        let possibleUSDCAddresses = [
            "0xd3bF53DAC106A0290B0483EcBC89d40FcC961f3e", // WFLOW (known)
            "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48", // Ethereum USDC (for reference)
            "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913", // Current guess
        ]
        
        let promises = possibleUSDCAddresses.compactMap { address -> Promise<(String, Bool)>? in
            guard let ethAddress = try? EthereumAddress(hex: address, eip55: true) else { return nil }
            
            return firstly {
                self.web3.eth.getCode(address: ethAddress, block: .latest)
            }.map { code -> (String, Bool) in
                let hasCode = !code.bytes.isEmpty
                print("📋 Address \(address): \(hasCode ? "✅ Has contract code (\(code.bytes.count) bytes)" : "❌ No code")")
                return (address, hasCode)
            }.recover { _ -> Promise<(String, Bool)> in
                return Promise.value((address, false))
            }
        }
        
        return firstly {
            when(fulfilled: promises)
        }.done { results in
            let contractAddresses = results.filter { $0.1 }.map { $0.0 }
            print("🎯 Found \(contractAddresses.count) contracts with code")
            
            if contractAddresses.isEmpty {
                print("⚠️ No USDC contracts found. You may need to:")
                print("   1. Find the correct USDC contract address for Flow EVM")
                print("   2. Bridge USDC from Ethereum to Flow EVM first")
                print("   3. Check if USDC is available on Flow EVM mainnet")
            }
        }
    }
    
    // Comprehensive diagnostic method
    func runDiagnostics() -> Promise<Void> {
        print("🏥 Running comprehensive diagnostics...")
        
        return firstly {
            self.testConnection()
        }.then {
            self.checkAccountBalance()
        }.then {
            self.findUSDCAddress()
        }.done {
            print("✅ Diagnostics completed!")
        }
    }
}

// MARK: - Error Types

enum PrivateKeyError: LocalizedError {
    case environmentVariableNotFound(String)
    case emptyPrivateKey
    case invalidKeyFormat
    case invalidKey(String)
    
    var errorDescription: String? {
        switch self {
        case .environmentVariableNotFound(let varName):
            return "Environment variable '\(varName)' not found"
        case .emptyPrivateKey:
            return "Private key is empty"
        case .invalidKeyFormat:
            return "Private key must be 64 hex characters (optionally prefixed with 0x)"
        case .invalidKey(let details):
            return "Invalid private key: \(details)"
        }
    }
}

enum DepositError: LocalizedError {
    case networkError(String)
    case insufficientBalance
    case balanceCheckFailed(String)
    case nonceError(String)
    case contractError(String)
    case contractNotFound(String)
    case transactionCreationFailed
    case transactionSendFailed(String)
    case incorrectUSDCAddress
    
    var errorDescription: String? {
        switch self {
        case .networkError(let details):
            return "Network connection failed: \(details)"
        case .insufficientBalance:
            return "Insufficient FLOW balance for gas fees"
        case .balanceCheckFailed(let details):
            return "Could not check account balance: \(details)"
        case .nonceError(let details):
            return "Could not get transaction nonce: \(details)"
        case .contractError(let details):
            return "Smart contract error: \(details)"
        case .contractNotFound(let details):
            return "Contract not found: \(details)"
        case .transactionCreationFailed:
            return "Failed to create transaction"
        case .transactionSendFailed(let details):
            return "Failed to send transaction: \(details)"
        case .incorrectUSDCAddress:
            return "Incorrect USDC contract address for Flow EVM"
        }
    }
}