//
//  RecoverySegmentedControl.swift
//  EverForm
//
//  Created by Assistant on 07/12/2025.
//

import SwiftUI

struct RecoverySegmentedControl: View {
    @Binding var selection: RecoveryTimeRange
    @Namespace private var namespace
    
    private let options = RecoveryTimeRange.allCases
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selection = option
                    }
                } label: {
                    ZStack {
                        if selection == option {
                            Capsule()
                                .fill(DesignSystem.Colors.accent)
                                .matchedGeometryEffect(id: "selection", in: namespace)
                        }
                        
                        Text(option.rawValue)
                            .font(.app(.button))
                            .foregroundStyle(selection == option ? .white : DesignSystem.Colors.textSecondary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 24)
                            .contentShape(Rectangle())
                    }
                }
            }
        }
        .padding(4)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
