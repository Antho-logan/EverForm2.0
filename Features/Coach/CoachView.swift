import SwiftUI

struct CoachView: View {
    @Environment(\.colorScheme) private var scheme
    @State private var message: String = ""

    var body: some View {
        ZStack {
            EFTheme.background(scheme).ignoresSafeArea()

            VStack(spacing: 0) {
                Text("Coach")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(EFTheme.text(scheme))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                ScrollView {
                    HStack {
                        Text("Hi! I'm your EverForm coach. How can I help you today?")
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }

                // Composer
                HStack(spacing: 10) {
                    Image(systemName: "paperclip")
                    TextField("Message", text: $message)
                    Image(systemName: "mic.fill")
                    Button { } label: { Image(systemName: "paperplane.fill") }
                }
                .padding(12)
                .background(EFTheme.surface(scheme))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(EFTheme.cardStroke(scheme)))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    EFTheme.background(scheme)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
    }
}
