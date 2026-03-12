import SwiftUI

struct CircularProgressView: View {
    var progress: Double // Value between 0.0 and 1.0
    var progressColor: Color = .blue
    var backgroundColor: Color = .gray.opacity(0.2)
    var fontSize: Int

    var body: some View {
        
        let currentColor = progress >= 1.0 ? Color.green : progressColor
        
        ZStack {
            Circle()
                .stroke(backgroundColor, lineWidth: 6) // Background track

            Circle()
                .trim(from: 0.0, to: progress) // Progress indicator
                .stroke(currentColor, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                .rotationEffect(.degrees(270)) // Start from top
                .animation(.linear(duration: 1.2), value: progress) // Smooth animation
            
            // ← Aquí agregas el texto dentro del círculo
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: CGFloat(fontSize)))
                            .bold()
        }
    }
}
