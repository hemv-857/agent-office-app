// AnimationHelpers.swift
import SwiftUI

// MARK: - Animation Extensions
extension View {
    func pulseAnimation(isActive: Bool) -> some View {
        self.scaleEffect(isActive ? 1.05 : 1.0)
            .animation(isActive ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: isActive)
    }

    func shimmer(isActive: Bool) -> some View {
        self.overlay(
            LinearGradient(
                colors: [.clear, .white.opacity(0.3), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .offset(x: isActive ? 200 : -200)
            .animation(isActive ? .linear(duration: 1.5).repeatForever(autoreverses: false) : .default, value: isActive)
        )
        .clipped()
    }

    func fadeIn(duration: Double = 0.3) -> some View {
        self.transition(.opacity.combined(with: .move(edge: .bottom)))
            .animation(.easeIn(duration: duration), value: UUID())
    }

    func slideIn(edge: Edge = .leading, duration: Double = 0.3) -> some View {
        self.transition(.move(edge: edge).combined(with: .opacity))
            .animation(.easeOut(duration: duration), value: UUID())
    }

    func bounceAnimation() -> some View {
        self.transition(.scale.combined(with: .opacity))
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: UUID())
    }

    func heartbeatAnimation(isActive: Bool) -> some View {
        self.scaleEffect(isActive ? 1.1 : 1.0)
            .animation(isActive ? .easeInOut(duration: 0.2).repeatForever(autoreverses: true) : .default, value: isActive)
    }
}

// MARK: - Custom Animations
struct ShakeAnimation: ViewModifier {
    @State private var shake = false

    func body(content: Content) -> some View {
        content
            .offset(x: shake ? 5 : 0)
            .animation(shake ? .easeInOut(duration: 0.1).repeatForever(autoreverses: true) : .default, value: shake)
            .onAppear { shake = true }
    }
}

struct RotateAnimation: ViewModifier {
    @State private var rotate = false

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotate ? 360 : 0))
            .animation(rotate ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: rotate)
            .onAppear { rotate = true }
    }
}

struct GradientAnimation: ViewModifier {
    @State private var startPoint = UnitPoint(x: 0, y: 0)

    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [.blue, .purple, .pink, .orange],
                    startPoint: startPoint,
                    endPoint: UnitPoint(x: 1 - startPoint.x, y: 1 - startPoint.y)
                )
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: startPoint)
            )
            .onAppear { startPoint = UnitPoint(x: 1, y: 1) }
    }
}

// MARK: - View Modifiers
extension View {
    func shake() -> some View {
        modifier(ShakeAnimation())
    }

    func rotate() -> some View {
        modifier(RotateAnimation())
    }

    func gradient() -> some View {
        modifier(GradientAnimation())
    }
}

// MARK: - Loading States
enum LoadingState {
    case idle
    case loading
    case success
    case error(String)
}

struct LoadingView: View {
    let state: LoadingState
    let message: String

    var body: some View {
        switch state {
        case .idle:
            EmptyView()
        case .loading:
            HStack(spacing: 8) {
                ProgressView()
                    .scaleEffect(0.8)
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        case .success:
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        case .error(let errorMessage):
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.red)
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}

// MARK: - Skeleton Loading
struct SkeletonView: View {
    @State private var shimmer = false
    var width: CGFloat = 100
    var height: CGFloat = 20
    var cornerRadius: CGFloat = 4

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray.opacity(0.2))
            .frame(width: width, height: height)
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.4), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: shimmer ? width : -width)
                .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: shimmer)
            )
            .onAppear { shimmer = true }
    }
}
