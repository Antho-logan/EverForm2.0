//
//  FixPainResultView.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import SwiftUI

struct FixPainResultView: View {
    let plan: PainAiPlanDTO
    @Binding var isPresented: Bool

    var body: some View {
        // We use the new FixPainPlanView which manages its own structure and dismissal.
        // Note: dismissal here will pop this view (if pushed) or dismiss it (if presented).
        // If we need to close the entire flow (isPresented = false), we might need to modify FixPainPlanView
        // to accept a binding or closure, but for now we follow the requested refactor.
        FixPainPlanView(plan: plan)
    }
}
