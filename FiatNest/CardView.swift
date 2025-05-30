import SwiftUI

struct CreditCardView: View {
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: 200)
                .shadow(color: .gray.opacity(0.4), radius: 8, x: 0, y: 4)
            
            VStack(alignment: .leading) {
                // Chip image
                Image(systemName: "creditcard.and.123")
                    .font(.system(size: 32))
                    .foregroundColor(.white.opacity(0.85))
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
                        Text("John Doe")
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
                            .foregroundColor(.blue)
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
                }
            }
        }
    }
}

struct AddCardView: View {
    @State private var showingCardSelection = false
    
    var body: some View {
        VStack(spacing: 20) {
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 40))
                )
            
            Text("Add New Card")
                .font(.title2)
                .fontWeight(.medium)
            
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
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
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
                .fill(Color.blue.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(.blue)
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

struct CardView: View {
    @State private var currentPage = 1
    @GestureState private var dragOffset: CGFloat = 0
    
    // Sample expenses data
    let expenses = [
        (merchantName: "Starbucks", date: "Today, 10:30 AM", amount: 4.50, icon: "cup.and.saucer.fill"),
        (merchantName: "Amazon", date: "Yesterday", amount: 29.99, icon: "cart.fill"),
        (merchantName: "Netflix", date: "May 28", amount: 17.99, icon: "play.tv.fill")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Color.gray.opacity(0.05).ignoresSafeArea()
                
                // Scrolling content
                ScrollView {
                    ZStack {
                        // Horizontal sliding views
                        HStack(spacing: 0) {
                            // Add Card View
                            AddCardView()
                                .frame(width: geometry.size.width)
                            
                            // Main Card View
                            VStack(spacing: 20) {
                                CreditCardView()
                                    .padding(.top)
                                
                                // Action Buttons
                                HStack(spacing: 30) {
                                    CardActionButton(icon: "doc.text.fill", title: "Details") {
                                        // Show details action
                                    }
                                    
                                    CardActionButton(icon: "snowflake", title: "Freeze") {
                                        // Freeze card action
                                    }
                                    
                                    CardActionButton(icon: "gearshape.fill", title: "Settings") {
                                        // Settings action
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
                                        ForEach(expenses, id: \.merchantName) { expense in
                                            ExpenseRow(
                                                merchantName: expense.merchantName,
                                                date: expense.date,
                                                amount: expense.amount,
                                                icon: expense.icon
                                            )
                                            .padding(.horizontal)
                                            
                                            if expense.merchantName != expenses.last?.merchantName {
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
                            .frame(width: geometry.size.width)
                        }
                        .offset(x: -CGFloat(currentPage) * geometry.size.width + dragOffset)
                    }
                }
            }
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        let threshold = geometry.size.width * 0.25
                        if value.translation.width > threshold {
                            currentPage = 0 // Swipe right to Add Card
                        } else if value.translation.width < -threshold {
                            currentPage = 1 // Swipe left to Main Card
                        }
                    }
            )
            .animation(.interactiveSpring(), value: dragOffset)
            .animation(.interactiveSpring(), value: currentPage)
        }
    }
} 