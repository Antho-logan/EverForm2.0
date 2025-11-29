import SwiftUI

struct FeatureHeroCard: View {
    let title: String
    let subtitle: String
    let buttonTitle: String
    let onButtonTap: () -> Void
    let gradientColors: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(subtitle)
                    .font(.system(size: 17))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Button(action: onButtonTap) {
                HStack {
                    Text(buttonTitle)
                        .font(.system(size: 17, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(gradientColors.first ?? .black)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: (gradientColors.first ?? .black).opacity(0.3), radius: 20, x: 0, y: 10)
    }
}