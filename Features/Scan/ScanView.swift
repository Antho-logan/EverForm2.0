import SwiftUI

struct ScanView: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Scan Food")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(EFTheme.text(scheme))
                    .frame(maxWidth: .infinity, alignment: .leading)

                SegmentedTabs()

                EFCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Calorie & Macros").font(.headline).foregroundStyle(EFTheme.text(scheme))
                        Text("Scan barcode or nutrition label for accurate calorie and macro information")
                            .font(.subheadline).foregroundStyle(EFTheme.muted(scheme))
                        Button("Generate Mock Result") {}
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                            .background(Color.green)
                            .foregroundStyle(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        Button("Import Photo") {}
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.green))
                            .foregroundStyle(Color.green)
                    }
                }

                EFCard {
                    VStack(spacing: 12) {
                        Image(systemName: "viewfinder").font(.largeTitle).foregroundStyle(EFTheme.muted(scheme))
                        Text("Nothing scanned yet").font(.headline).foregroundStyle(EFTheme.text(scheme))
                        Text("Try a mock result to see how it works").font(.subheadline).foregroundStyle(EFTheme.muted(scheme))
                    }.frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .background(EFTheme.background(scheme).ignoresSafeArea())
    }
}

private struct SegmentedTabs: View {
    @Environment(\.colorScheme) private var scheme
    @State private var idx = 0
    let items = ["Calorie","Ingredients","Plate AI"]
    var body: some View {
        HStack(spacing: 8) {
            ForEach(items.indices, id: \.self) { i in
                Text(items[i])
                    .font(.subheadline.weight(i == idx ? .bold : .regular))
                    .foregroundStyle(i == idx ? EFTheme.text(scheme) : EFTheme.muted(scheme))
                    .padding(.vertical, 8).padding(.horizontal, 14)
                    .background(EFTheme.surface(scheme).opacity(i == idx ? 1 : 0.7))
                    .clipShape(Capsule())
                    .onTapGesture { idx = i }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
