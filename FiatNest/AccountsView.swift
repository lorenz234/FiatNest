import SwiftUI

struct RoundButton: View {
    let imageName: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: imageName)
                            .foregroundColor(.blue)
                            .font(.system(size: 24))
                    )
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct AccountsView: View {
    let balance: Double
    
    var body: some View {
        VStack {
            Spacer()
            Text("€\(balance, specifier: "%.2f")")
                .font(.system(size: 48, weight: .medium))
                .padding(.bottom, 40)
            
            HStack(spacing: 25) {
                RoundButton(imageName: "plus.circle.fill", title: "Add Money") {
                    // Add money action
                }
                
                RoundButton(imageName: "arrow.left.arrow.right.circle.fill", title: "Move") {
                    // Move action
                }
                
                RoundButton(imageName: "list.bullet.circle.fill", title: "Details") {
                    // Details action
                }
                
                RoundButton(imageName: "ellipsis.circle.fill", title: "More") {
                    // More action
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
} 