import SwiftUI

public struct ChipButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    public init(_ title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                }
                .scaleEffect(isSelected ? 1.02 : 1.0)
                .opacity(isSelected ? 1.0 : 0.8)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
        .animation(UX.Anim.fast, value: isSelected)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// Multi-select chip group
public struct ChipGroup<T: Hashable & CaseIterable & RawRepresentable>: View where T.RawValue == String {
    let title: String
    @Binding var selection: Set<T>
    let options: [T]
    
    public init(_ title: String, selection: Binding<Set<T>>, options: [T] = Array(T.allCases)) {
        self.title = title
        self._selection = selection
        self.options = options
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 120), spacing: 8)
            ], spacing: 8) {
                ForEach(options, id: \.self) { option in
                    ChipButton(
                        option.rawValue,
                        isSelected: selection.contains(option)
                    ) {
                        if selection.contains(option) {
                            selection.remove(option)
                        } else {
                            selection.insert(option)
                        }
                    }
                }
            }
        }
    }
}

// Single-select chip group
public struct SingleChipGroup<T: Hashable & CaseIterable & RawRepresentable>: View where T.RawValue == String {
    let title: String
    @Binding var selection: T
    let options: [T]
    
    public init(_ title: String, selection: Binding<T>, options: [T] = Array(T.allCases)) {
        self.title = title
        self._selection = selection
        self.options = options
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 120), spacing: 8)
            ], spacing: 8) {
                ForEach(options, id: \.self) { option in
                    ChipButton(
                        option.rawValue,
                        isSelected: selection == option
                    ) {
                        selection = option
                    }
                }
            }
        }
    }
}
