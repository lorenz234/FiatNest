import SwiftUI
import Charts

struct CreditCardView: View {
    let balance: Double
    
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.customDarkGreen, Color.customGreen]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: 200)
                .shadow(color: .gray.opacity(0.4), radius: 8, x: 0, y: 4)
            
            VStack(alignment: .leading) {
                HStack {
                    // Balance in top left
                    Text("€\(balance, specifier: "%.2f")")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Chip image
                    Image(systemName: "creditcard.and.123")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.85))
                }
                .padding(.bottom, 30)
                
                // Card number
                Text("•••• •••• •••• 4242")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("CARD HOLDER")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.7))
                        Text("Lorenz Lehmann")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("EXPIRES")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.7))
                        Text("05/28")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
    }
}

struct CardActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 50, height: 50)
                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    .overlay(
                        Image(systemName: icon)
                            .foregroundColor(.customDarkGreen)
                            .font(.system(size: 20))
                    )
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct CardOption: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let imageName: String
    let color: Color
}

struct CardSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    let cardOptions = [
        CardOption(
            name: "Metamask Card",
            description: "Connect your Metamask wallet and spend crypto anywhere",
            imageName: "metamask-preview",
            color: .orange
        ),
        CardOption(
            name: "Ramp Stablecoin Card",
            description: "Use your stablecoins for everyday purchases",
            imageName: "ramp-preview",
            color: .blue
        ),
        CardOption(
            name: "Gemini Bitcoin Card",
            description: "Spend Bitcoin and earn crypto rewards",
            imageName: "gemini-preview",
            color: .purple
        ),
        CardOption(
            name: "Ether.Fi Card",
            description: "The first card for liquid staking derivatives",
            imageName: "etherfi-preview",
            color: .cyan
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(cardOptions) { card in
                        Button(action: {
                            // Handle card selection
                            dismiss()
                        }) {
                            HStack(spacing: 16) {
                                // Card preview image (placeholder)
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(card.color.opacity(0.1))
                                    .frame(width: 80, height: 50)
                                    .overlay(
                                        // Placeholder for actual card image
                                        Image(systemName: "creditcard.fill")
                                            .foregroundColor(card.color)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(card.name)
                                        .font(.headline)
                                    
                                    Text(card.description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .background(Color.gray.opacity(0.05))
            .navigationTitle("Select a Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.customDarkGreen)
                }
            }
        }
        .tint(.customDarkGreen)
    }
}

struct AddCardView: View {
    @State private var showingCardSelection = false
    
    var body: some View {
        VStack(spacing: 20) {
            Circle()
                .fill(Color.customGreen.opacity(0.1))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.customDarkGreen)
                )
            
            Text("Add New Card")
                .font(.title2)
                .foregroundColor(.customDarkGreen)
            
            Text("Connect any stablecoin card to your account")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                showingCardSelection = true
            }) {
                Text("Add Card")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.customDarkGreen, lineWidth: 2)
                    )
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .sheet(isPresented: $showingCardSelection) {
                CardSelectionView()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.05))
    }
}

struct ExpenseRow: View {
    let merchantName: String
    let date: String
    let amount: Double
    let icon: String
    
    var body: some View {
        HStack {
            // Icon
            Circle()
                .fill(Color.customOrange.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(.customOrange)
                        .font(.system(size: 20))
                )
            
            // Merchant and date
            VStack(alignment: .leading, spacing: 4) {
                Text(merchantName)
                    .font(.system(size: 17, weight: .medium))
                Text(date)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Amount
            Text("€\(amount, specifier: "%.2f")")
                .font(.system(size: 17, weight: .medium))
        }
        .padding(.vertical, 8)
    }
}

struct AddMoneyToCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var cardBalance: Double
    @Binding var savingsBalance: Double
    @State private var amount: String = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Source account info
                VStack(alignment: .leading, spacing: 8) {
                    Text("From Savings Account")
                        .font(.headline)
                    Text("Available Balance: €\(savingsBalance, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                // Destination card info
                VStack(alignment: .leading, spacing: 8) {
                    Text("To Card")
                        .font(.headline)
                    Text("Current Card Balance: €\(cardBalance, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Transfer Amount")
                        .font(.headline)
                    TextField("Enter amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: amount) { oldValue, newValue in
                            let filtered = newValue.filter { "0123456789.".contains($0) }
                            if filtered != newValue {
                                amount = filtered
                            }
                        }
                }
                .padding()
                
                Button(action: {
                    if let amountDouble = Double(amount),
                       amountDouble > 0,
                       amountDouble <= savingsBalance {
                        cardBalance += amountDouble
                        savingsBalance -= amountDouble  // Deduct from savings
                        dismiss()
                    } else {
                        showingError = true
                    }
                }) {
                    Text("Transfer from Savings")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.customOrange.opacity(0.5))
                        .cornerRadius(12)
                }
                .padding()
                .alert("Invalid Amount", isPresented: $showingError) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("Please enter a valid amount that doesn't exceed your savings balance.")
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Transfer to Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct BalanceHistoryPoint: Identifiable {
    let id = UUID()
    let date: Date
    let balance: Double
}

struct DetailsView: View {
    @Environment(\.dismiss) private var dismiss
    let cardBalance: Double
    
    // Dummy data for the chart
    private let balanceHistory: [BalanceHistoryPoint] = {
        let calendar = Calendar.current
        let today = Date()
        var points: [BalanceHistoryPoint] = []
        
        for day in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -day, to: today) {
                // Create some random variation around the current balance
                let randomVariation = Double.random(in: -50...50)
                points.append(BalanceHistoryPoint(date: date, balance: 2500 + randomVariation))
            }
        }
        return points.reversed()
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Current Balance Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Balance")
                            .font(.headline)
                        Text("€\(cardBalance, specifier: "%.2f")")
                            .font(.system(size: 32, weight: .bold))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Balance History Chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Balance History")
                            .font(.headline)
                        
                        Chart(balanceHistory) { point in
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("Balance", point.balance)
                            )
                            .foregroundStyle(Color.customOrange)
                            
                            AreaMark(
                                x: .value("Date", point.date),
                                y: .value("Balance", point.balance)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.customOrange.opacity(0.3), .customOrange.opacity(0.1)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                        .frame(height: 200)
                        .chartYScale(domain: 2000...3000)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Blockchain Explorer Link
                    VStack(alignment: .leading, spacing: 8) {
                        Text("View on Blockscout")
                            .font(.headline)
                        
                        Text("0x55809E0CDF350A5F7E6ed163D7C596170256dFa0")
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .padding(.vertical, 4)
                        
                        Link(destination: URL(string: "https://gnosis.blockscout.com/address/0x55809E0CDF350A5F7E6ed163D7C596170256dFa0")!) {
                            HStack {
                                Text("View on Blockscout")
                                    .foregroundColor(.blue)
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                .padding()
            }
            .navigationTitle("Card Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

@Observable
final class CardViewModel: Sendable {
    private let stateManager = StateManager()
    
    var transactions: [FormattedTransaction] {
        get async {
            await stateManager.transactions
        }
    }
    
    var cardBalance: Double {
        get async {
            await stateManager.cardBalance
        }
    }
    
    func loadData() {
        Task { @MainActor in
            do {
                async let transactionsFetch = BlockscoutService.shared.fetchTransactions()
                async let balanceFetch = BlockscoutService.shared.fetchCardBalance()
                
                let (transactions, balance) = try await (transactionsFetch, balanceFetch)
                
                await stateManager.setTransactions(transactions)
                await stateManager.setBalance(balance)
            } catch {
                print("Error fetching data: \(error)")
            }
        }
    }
    
    actor StateManager: Sendable {
        var transactions: [FormattedTransaction] = []
        var cardBalance: Double = 0.0
        
        func setTransactions(_ newTransactions: [FormattedTransaction]) {
            transactions = newTransactions
        }
        
        func setBalance(_ newBalance: Double) {
            cardBalance = newBalance
        }
    }
}

struct CardView: View {
    @State private var viewModel = CardViewModel()
    @State private var currentPage = 0
    @GestureState private var dragOffset: CGFloat = 0
    @Binding var savingsBalance: Double
    @State private var showingAddMoney = false
    @State private var showingDetails = false
    @State private var currentBalance: Double = 0.0
    @State private var currentTransactions: [FormattedTransaction] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.gray.opacity(0.05).ignoresSafeArea()
                
                HStack(spacing: 0) {
                    // AddCardView page
                    AddCardView()
                        .frame(width: geometry.size.width)
                    
                    // Card and Transactions page
                    ScrollView {
                        VStack(spacing: 20) {
                            CreditCardView(balance: currentBalance)
                                .padding(.top)
                            
                            // Action Buttons
                            HStack(spacing: 30) {
                                CardActionButton(icon: "plus.circle.fill", title: "Add Money") {
                                    showingAddMoney = true
                                }
                                
                                CardActionButton(icon: "snowflake", title: "Freeze") {
                                    // Freeze card action
                                }
                                
                                CardActionButton(icon: "gearshape.fill", title: "Settings") {
                                    // Settings action
                                }
                                
                                CardActionButton(icon: "list.bullet.rectangle.fill", title: "Details") {
                                    showingDetails = true
                                }
                            }
                            .padding(.vertical)
                            
                            // Expenses section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recent Transactions")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 0) {
                                    ForEach(currentTransactions) { transaction in
                                        ExpenseRow(
                                            merchantName: transaction.merchantName,
                                            date: transaction.date,
                                            amount: transaction.amount,
                                            icon: transaction.icon
                                        )
                                        .padding(.horizontal)
                                        
                                        if transaction.id != currentTransactions.last?.id {
                                            Divider()
                                                .padding(.horizontal)
                                        }
                                    }
                                }
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
                                .padding(.horizontal)
                            }
                            
                            Spacer(minLength: 100)
                        }
                    }
                    .frame(width: geometry.size.width)
                }
                .offset(x: -CGFloat(currentPage) * geometry.size.width + dragOffset)
            }
            .sheet(isPresented: $showingAddMoney) {
                AddMoneyToCardView(
                    cardBalance: .constant(currentBalance), // This needs to be updated to handle async updates
                    savingsBalance: $savingsBalance
                )
            }
            .sheet(isPresented: $showingDetails) {
                DetailsView(cardBalance: currentBalance)
            }
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        let threshold = geometry.size.width * 0.25
                        if value.translation.width > threshold {
                            currentPage = max(0, currentPage - 1)
                        } else if value.translation.width < -threshold {
                            currentPage = min(1, currentPage + 1)
                        }
                    }
            )
            .animation(.interactiveSpring(), value: dragOffset)
            .animation(.interactiveSpring(), value: currentPage)
            .task {
                viewModel.loadData()
                // Start continuous updates
                let stream = AsyncStream<Void> { continuation in
                    Task {
                        while true {
                            continuation.yield()
                            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                        }
                    }
                }
                
                for await _ in stream {
                    async let balance = viewModel.cardBalance
                    async let transactions = viewModel.transactions
                    let (newBalance, newTransactions) = await (balance, transactions)
                    currentBalance = newBalance
                    currentTransactions = newTransactions
                }
            }
        }
    }
} 