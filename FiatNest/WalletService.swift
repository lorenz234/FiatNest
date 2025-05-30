import Foundation
import Web3
import Security

class WalletService {
    private let keychainPrivateKeyKey = "com.fiatnest.wallet.privatekey"
    private let keychainPublicKeyKey = "com.fiatnest.wallet.publickey"
    
    func createWallet() throws -> (publicKey: String, privateKey: String) {
        // Generate new wallet
        let privateKey = try EthereumPrivateKey()
        let publicKey = privateKey.address.hex(eip55: true)
        
        // Save private key to keychain
        let privateKeyData = privateKey.rawPrivateKey
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainPrivateKeyKey,
            kSecValueData as String: privateKeyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecAttrService as String: "FiatNest"
        ]
        
        // Delete any existing key before saving
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status: status)
        }
        
        // Save public key to keychain
        let publicKeyQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainPublicKeyKey,
            kSecValueData as String: publicKey.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecAttrService as String: "FiatNest"
        ]
        
        SecItemDelete(publicKeyQuery as CFDictionary)
        let publicKeyStatus = SecItemAdd(publicKeyQuery as CFDictionary, nil)
        guard publicKeyStatus == errSecSuccess else {
            throw KeychainError.saveFailed(status: publicKeyStatus)
        }
        
        return (publicKey: publicKey, privateKey: privateKey.rawPrivateKey.toHexString())
    }
    
    func getStoredWallet() throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainPublicKeyKey,
            kSecReturnData as String: true,
            kSecAttrService as String: "FiatNest",
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let publicKey = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return publicKey
    }
}

enum KeychainError: Error {
    case saveFailed(status: OSStatus)
    case readFailed(status: OSStatus)
    case walletCreationFailed
} 
