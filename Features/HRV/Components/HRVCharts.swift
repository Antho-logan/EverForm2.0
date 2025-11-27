//
//  HRVCharts.swift
//  EverForm
//
//  Created by Assistant on 24/11/2025.
//

// TODO: Candidate for removal – appears unused in current EverForm flow.
import SwiftUI

struct HRVLineChart: View {
  let data: [Double]
  let lineColor: Color
  let showGradient: Bool

  var body: some View {
    GeometryReader { geometry in
      let width = geometry.size.width
      let height = geometry.size.height

      if data.count > 1 {
        let minVal = data.min() ?? 0
        let maxVal = data.max() ?? 1
        let range = maxVal - minVal

        // Add 10% padding to the range for better visuals
        let padding = range * 0.1
        let displayMin = minVal - padding
        let displayMax = maxVal + padding
        let displayRange = displayMax - displayMin

        // Safe range to avoid division by zero
        let safeRange = displayRange == 0 ? 1 : displayRange

        let points: [CGPoint] = data.enumerated().map { index, value in
          let x = width * CGFloat(index) / CGFloat(data.count - 1)
          // Invert Y because 0 is at top
          let normalizedValue = (value - displayMin) / safeRange
          let y = height * (1 - CGFloat(normalizedValue))
          return CGPoint(x: x, y: y)
        }

        ZStack {
          // Gradient Fill
          if showGradient {
            Path { path in
              path.move(to: CGPoint(x: 0, y: height))
              for point in points {
                path.addLine(to: point)
              }
              path.addLine(to: CGPoint(x: width, y: height))
              path.closeSubpath()
            }
            .fill(
              LinearGradient(
                colors: [lineColor.opacity(0.3), lineColor.opacity(0.0)],
                startPoint: .top,
                endPoint: .bottom
              )
            )
          }

          // Line
          Path { path in
            path.move(to: points[0])
            for i in 1..<points.count {
              // Simple straight lines for now, could use curves
              path.addLine(to: points[i])
            }
          }
          .stroke(lineColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
      }
    }
  }
}

struct MicroSparkline: View {
  let data: [Double]
  let color: Color

  var body: some View {
    HRVLineChart(data: data, lineColor: color, showGradient: false)
  }
}
