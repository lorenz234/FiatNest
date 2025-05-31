import Foundation

// MARK: - Response Models
struct BlockscoutResponse: Codable {
    let items: [TokenTransfer]
}

// MARK: - Balance Response Models
struct TokenBalanceResponse: Codable {
    let token: TokenInfo
    let value: String
}

struct TokenInfo: Codable {
    let address: String
    let decimals: String
    let name: String
    let symbol: String
}

struct TokenTransfer: Codable {
    let timestamp: String
    let total: TokenAmount
    let method: String
    let to: AddressInfo
}

struct TokenAmount: Codable {
    let decimals: String
    let value: String
}

struct AddressInfo: Codable {
    let hash: String
    let name: String?
    let implementations: [Implementation]?
}

struct Implementation: Codable {
    let name: String
}

// MARK: - Formatted Transaction
struct FormattedTransaction: Identifiable {
    let id = UUID()
    let merchantName: String
    let date: String
    let amount: Double
    let icon: String
    
    // List of possible icons for random assignment
    static let possibleIcons = [
        // Finance & Blockchain
        "creditcard.fill",
        "building.columns.fill",
        "building.2.fill",
        "network",
        "link",
        "cube.box.fill",
        
        // Shopping & Retail
        "cart.fill",
        "bag.fill",
        "gift.fill",
        "tshirt.fill",
        
        // Food & Dining
        "cup.and.saucer.fill",
        "fork.knife",
        "takeoutbag.and.cup.and.straw.fill",
        "wineglass.fill",
        
        // Transportation
        "car.fill",
        "bus.fill",
        "airplane",
        "fuelpump.fill",
        
        // Entertainment
        "play.tv.fill",
        "gamecontroller.fill",
        "music.note",
        "ticket.fill",
        
        // Services
        "cross.fill",
        "house.fill",
        "scissors",
        "phone.fill",
        
        // Utilities
        "bolt.fill",
        "wifi",
        "drop.fill",
        "flame.fill"
    ]
}

class BlockscoutService {
    static let shared = BlockscoutService()
    
    private let baseURL = "https://gnosis.blockscout.com/api/v2"
    private let walletAddress = "0x55809E0CDF350A5F7E6ed163D7C596170256dFa0"
    private let tokenAddress = "0x420CA0f9B9b604cE0fd9C18EF134C705e5Fa3430"
    
    // Flow USDC Configuration
    private let flowBaseURL = "https://evm.flowscan.io/api/v2"
    private let flowWalletAddress = "0x732D31D49467c08F41fD0727537995ea45dD4Ba7"
    private let flowUSDCAddress = "0x49c6b2799aF2Db7404b930F24471dD961CFE18b7"
    
    func fetchCardBalance() async throws -> Double {
        let urlString = "\(baseURL)/addresses/\(walletAddress)/token-balances"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let balances = try JSONDecoder().decode([TokenBalanceResponse].self, from: data)
        
        // Find our specific token balance
        guard let tokenBalance = balances.first(where: { $0.token.address.lowercased() == tokenAddress.lowercased() }) else {
            throw NSError(domain: "BlockscoutService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Token not found"])
        }
        
        // Convert value to Double and divide by 10^18 (for 18 decimals)
        let value = Double(tokenBalance.value) ?? 0
        return value / pow(10, 18)
    }
    
    func fetchTransactions() async throws -> [FormattedTransaction] {
        let urlString = "\(baseURL)/addresses/\(walletAddress)/token-transfers?type=ERC-20&filter=from&token=\(tokenAddress)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(BlockscoutResponse.self, from: data)
        
        return formatTransactions(response.items)
    }
    
    private func formatTransactions(_ transfers: [TokenTransfer]) -> [FormattedTransaction] {
        return transfers.map { transfer in
            // Convert value and decimals to Double
            let value = Double(transfer.total.value) ?? 0
            let decimals = Double(transfer.total.decimals) ?? 18
            let amount = value / pow(10, decimals)
            
            // Format date
            let dateFormatter = ISO8601DateFormatter()
            let date = dateFormatter.date(from: transfer.timestamp) ?? Date()
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            let displayDate = displayFormatter.string(from: date)
            
            // Get merchant name from API response
            let merchantName = transfer.to.implementations?.first?.name ?? 
                             transfer.to.name ?? 
                             "Unknown Contract"
            
            // Random icon
            let icon = FormattedTransaction.possibleIcons.randomElement() ?? "creditcard.fill"
            
            return FormattedTransaction(
                merchantName: merchantName,
                date: displayDate,
                amount: amount,
                icon: icon
            )
        }
    }
    
    func fetchFlowUSDCBalance() async throws -> Double {
        let urlString = "\(flowBaseURL)/addresses/\(flowWalletAddress)/token-balances"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let balances = try JSONDecoder().decode([TokenBalanceResponse].self, from: data)
        
        // Find Flow USDC balance
        guard let tokenBalance = balances.first(where: { $0.token.address.lowercased() == flowUSDCAddress.lowercased() }) else {
            throw NSError(domain: "BlockscoutService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Flow USDC token not found"])
        }
        
        // Convert value to Double and divide by 10^6 (USDC has 6 decimals)
        let value = Double(tokenBalance.value) ?? 0
        return value / pow(10, 6)
    }
}
