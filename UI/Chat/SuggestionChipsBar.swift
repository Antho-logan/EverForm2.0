import SwiftUI

struct SuggestionChipsBar: View {
    var chips: [String]
    var onTap: (String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(chips, id: \.self) { chip in
                    Button(action: { onTap(chip) }) {
                        Text(chip)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color(.tertiarySystemBackground))
                                    .stroke(Color(.separator), lineWidth: 0.5)
                            )
                    }
                    .frame(height: 36)
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 36)
    }
}


