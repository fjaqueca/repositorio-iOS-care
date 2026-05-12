//
//  ConfettiModifier.swift
//  CareAssistance
//
//  Created on 08/05/2026.
//
//  Sistema de celebración con 3 niveles de intensidad + shapes simbólicos.
//  NO requiere librería externa — usa CAEmitterLayer de UIKit.
//
//  Niveles:
//    .confettiLight()   → Sutil: tarea completada, examen subido (~50 partículas, 1.5s)
//    .confetti()        → Estándar: cita agendada, orden examen (~150 partículas, 2s)
//    .confettiMajor()   → Hito grande: completar programa (~300 partículas, 3s)
//
//  Shapes simbólicos:
//    .confettiHearts()  → Corazones para grupo familiar
//    .confettiStars()   → Estrellas para completar programa
//

import SwiftUI
import UIKit

// MARK: - Confetti Style

enum ConfettiStyle {
    case light      // Sutil: pocas partículas, rápido
    case standard   // Estándar (actual)
    case major      // Hito grande: muchas partículas, efecto explosivo
    case hearts     // Corazones (grupo familiar)
    case stars      // Estrellas (completar programa)
}

// MARK: - Confetti UIView

class ConfettiUIView: UIView {
    private var emitterLayer: CAEmitterLayer?

    func startConfetti(style: ConfettiStyle) {
        stopConfetti()

        switch style {
        case .light:
            startClassicConfetti(birthRate: 3, lifetime: 4, velocity: 160, duration: 1.5)
        case .standard:
            startClassicConfetti(birthRate: 6, lifetime: 6, velocity: 200, duration: 2.0)
        case .major:
            startMajorConfetti()
        case .hearts:
            startSymbolicConfetti(shapeMaker: makeHeartImage, colors: heartColors, birthRate: 5, duration: 2.5)
        case .stars:
            startSymbolicConfetti(shapeMaker: makeStarImage, colors: starColors, birthRate: 6, duration: 3.0)
        }
    }

    func stopConfetti() {
        emitterLayer?.removeFromSuperlayer()
        emitterLayer = nil
    }

    // MARK: - Classic Confetti (light / standard)

    private func startClassicConfetti(birthRate: Float, lifetime: Float, velocity: CGFloat, duration: TimeInterval) {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: bounds.midX, y: -20)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: bounds.width, height: 1)

        var cells: [CAEmitterCell] = []
        for color in brandColors {
            for shapeMaker in [makeCircleImage, makeSquareImage, makeTriangleImage] {
                let cell = makeCell(color: color, image: shapeMaker(), birthRate: birthRate, lifetime: lifetime, velocity: velocity, scale: 0.04)
                cells.append(cell)
            }
        }

        emitter.emitterCells = cells
        layer.addSublayer(emitter)
        emitterLayer = emitter

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.emitterLayer?.birthRate = 0
        }
    }

    // MARK: - Major Confetti (explosivo + lluvia)

    private func startMajorConfetti() {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: bounds.midX, y: -20)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: bounds.width, height: 1)

        var cells: [CAEmitterCell] = []

        // Lluvia densa con todas las formas
        for color in brandColors {
            for shapeMaker in [makeCircleImage, makeSquareImage, makeTriangleImage, makeStarImage] {
                let cell = makeCell(color: color, image: shapeMaker(), birthRate: 10, lifetime: 7, velocity: 250, scale: 0.05)
                cell.velocityRange = 120
                cells.append(cell)
            }
        }

        emitter.emitterCells = cells
        layer.addSublayer(emitter)
        emitterLayer = emitter

        // Burst inicial: más partículas los primeros 500ms
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.emitterLayer?.birthRate = 0.6
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.emitterLayer?.birthRate = 0
        }
    }

    // MARK: - Symbolic Confetti (hearts / stars)

    private func startSymbolicConfetti(shapeMaker: () -> UIImage?, colors: [UIColor], birthRate: Float, duration: TimeInterval) {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: bounds.midX, y: -20)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: bounds.width, height: 1)

        var cells: [CAEmitterCell] = []
        for color in colors {
            let cell = makeCell(color: color, image: shapeMaker(), birthRate: birthRate, lifetime: 5, velocity: 180, scale: 0.06)
            cell.velocityRange = 60
            cells.append(cell)
        }

        emitter.emitterCells = cells
        layer.addSublayer(emitter)
        emitterLayer = emitter

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.emitterLayer?.birthRate = 0
        }
    }

    // MARK: - Cell Factory

    private func makeCell(color: UIColor, image: UIImage?, birthRate: Float, lifetime: Float, velocity: CGFloat, scale: CGFloat) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = birthRate
        cell.lifetime = lifetime
        cell.velocity = velocity
        cell.velocityRange = 80
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 4
        cell.spin = 4
        cell.spinRange = 8
        cell.scale = scale
        cell.scaleRange = scale * 0.5
        cell.color = color.cgColor
        cell.contents = image?.cgImage
        return cell
    }

    // MARK: - Color Palettes

    private var brandColors: [UIColor] {
        [
            UIColor(red: 0.00, green: 0.73, blue: 0.86, alpha: 1.0), // #00BBDC (brand)
            UIColor(red: 1.00, green: 0.76, blue: 0.03, alpha: 1.0), // amarillo
            UIColor(red: 0.98, green: 0.36, blue: 0.35, alpha: 1.0), // rojo
            UIColor(red: 0.30, green: 0.85, blue: 0.39, alpha: 1.0), // verde
            UIColor(red: 0.61, green: 0.35, blue: 0.96, alpha: 1.0), // morado
            UIColor(red: 1.00, green: 0.58, blue: 0.00, alpha: 1.0), // naranja
        ]
    }

    private var heartColors: [UIColor] {
        [
            UIColor(red: 1.00, green: 0.30, blue: 0.40, alpha: 1.0), // rojo rosado
            UIColor(red: 1.00, green: 0.45, blue: 0.55, alpha: 1.0), // rosa fuerte
            UIColor(red: 1.00, green: 0.60, blue: 0.68, alpha: 1.0), // rosa suave
            UIColor(red: 0.90, green: 0.20, blue: 0.35, alpha: 1.0), // rojo intenso
        ]
    }

    private var starColors: [UIColor] {
        [
            UIColor(red: 1.00, green: 0.84, blue: 0.00, alpha: 1.0), // dorado
            UIColor(red: 1.00, green: 0.76, blue: 0.03, alpha: 1.0), // amarillo
            UIColor(red: 0.00, green: 0.73, blue: 0.86, alpha: 1.0), // brand cyan
            UIColor(red: 1.00, green: 0.93, blue: 0.55, alpha: 1.0), // dorado claro
        ]
    }

    // MARK: - Shape Generators

    private func makeCircleImage() -> UIImage? {
        let size = CGSize(width: 12, height: 12)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.white.setFill()
        UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    private func makeSquareImage() -> UIImage? {
        let size = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.white.setFill()
        UIBezierPath(rect: CGRect(origin: .zero, size: size)).fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    private func makeTriangleImage() -> UIImage? {
        let size = CGSize(width: 12, height: 12)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: size.width / 2, y: 0))
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.addLine(to: CGPoint(x: 0, y: size.height))
        path.close()
        UIColor.white.setFill()
        path.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    private func makeHeartImage() -> UIImage? {
        let size = CGSize(width: 16, height: 16)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let path = UIBezierPath()
        let w = size.width
        let h = size.height
        path.move(to: CGPoint(x: w * 0.5, y: h * 0.85))
        path.addCurve(to: CGPoint(x: w * 0.05, y: h * 0.35),
                       controlPoint1: CGPoint(x: w * 0.15, y: h * 0.7),
                       controlPoint2: CGPoint(x: 0, y: h * 0.55))
        path.addCurve(to: CGPoint(x: w * 0.5, y: h * 0.2),
                       controlPoint1: CGPoint(x: w * 0.1, y: h * 0.1),
                       controlPoint2: CGPoint(x: w * 0.35, y: h * 0.15))
        path.addCurve(to: CGPoint(x: w * 0.95, y: h * 0.35),
                       controlPoint1: CGPoint(x: w * 0.65, y: h * 0.15),
                       controlPoint2: CGPoint(x: w * 0.9, y: h * 0.1))
        path.addCurve(to: CGPoint(x: w * 0.5, y: h * 0.85),
                       controlPoint1: CGPoint(x: w, y: h * 0.55),
                       controlPoint2: CGPoint(x: w * 0.85, y: h * 0.7))
        path.close()
        UIColor.white.setFill()
        path.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    private func makeStarImage() -> UIImage? {
        let size = CGSize(width: 14, height: 14)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let outerRadius: CGFloat = size.width / 2
        let innerRadius: CGFloat = outerRadius * 0.4
        let points = 5
        let path = UIBezierPath()
        for i in 0..<(points * 2) {
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let angle = CGFloat(i) * .pi / CGFloat(points) - .pi / 2
            let point = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.close()
        UIColor.white.setFill()
        path.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK: - SwiftUI Wrapper

struct ConfettiRepresentable: UIViewRepresentable {
    @Binding var isActive: Bool
    var style: ConfettiStyle

    func makeUIView(context: Context) -> ConfettiUIView {
        let view = ConfettiUIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: ConfettiUIView, context: Context) {
        if isActive {
            uiView.startConfetti(style: style)
            let dismissDelay: TimeInterval = {
                switch style {
                case .light: return 2.5
                case .standard: return 3.0
                case .major, .stars: return 4.0
                case .hearts: return 3.5
                }
            }()
            DispatchQueue.main.asyncAfter(deadline: .now() + dismissDelay) {
                isActive = false
            }
        }
    }
}

// MARK: - View Modifiers

struct ConfettiModifier: ViewModifier {
    @Binding var isActive: Bool
    var style: ConfettiStyle

    func body(content: Content) -> some View {
        content
            .overlay(
                ConfettiRepresentable(isActive: $isActive, style: style)
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
            )
    }
}

extension View {
    /// Confetti estándar — cita agendada, orden examen, examen subido
    func confetti(isActive: Binding<Bool>) -> some View {
        modifier(ConfettiModifier(isActive: isActive, style: .standard))
    }

    /// Confetti sutil — tarea completada individual
    func confettiLight(isActive: Binding<Bool>) -> some View {
        modifier(ConfettiModifier(isActive: isActive, style: .light))
    }

    /// Confetti hito grande — completar programa entero
    func confettiMajor(isActive: Binding<Bool>) -> some View {
        modifier(ConfettiModifier(isActive: isActive, style: .major))
    }

    /// Corazones — grupo familiar
    func confettiHearts(isActive: Binding<Bool>) -> some View {
        modifier(ConfettiModifier(isActive: isActive, style: .hearts))
    }

    /// Estrellas doradas — completar programa
    func confettiStars(isActive: Binding<Bool>) -> some View {
        modifier(ConfettiModifier(isActive: isActive, style: .stars))
    }
}
