import SwiftUI

struct SplashView: View {
    @State private var animationProgress: CGFloat = 0
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var loaderRotation: Double = 0
    
    var body: some View {
        ZStack {
            LinearGradient.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(AppColors.white.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "plus.forwardslash.minus")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(AppColors.white)
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    
                    Text("QuickDiscount")
                        .font(.jostBold(32))
                        .foregroundColor(AppColors.white)
                        .opacity(textOpacity)
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(AppColors.white.opacity(0.3), lineWidth: 3)
                            .frame(width: 50, height: 50)
                        
                        Circle()
                            .trim(from: 0, to: animationProgress)
                            .stroke(
                                AngularGradient(
                                    colors: [AppColors.white, AppColors.lightBlue, AppColors.white],
                                    center: .center,
                                    startAngle: .degrees(0),
                                    endAngle: .degrees(360)
                                ),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                            )
                            .frame(width: 50, height: 50)
                            .rotationEffect(.degrees(loaderRotation))
                    }
                    
                    Text("Loading...")
                        .font(.jostRegular(16))
                        .foregroundColor(AppColors.white.opacity(0.8))
                }
                .padding(.bottom, 50)
            }
            .padding()
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.8)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
            textOpacity = 1.0
        }
        
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
            loaderRotation = 360
        }
        
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            animationProgress = 0.8
        }
    }
}

struct AlternativeSplashView: View {
    @State private var showLogo = false
    @State private var showTitle = false
    @State private var loadingProgress: CGFloat = 0
    @State private var particles: [Particle] = []
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(spacing: 30) {
                Spacer()
                
                ZStack {
                    ForEach(particles, id: \.id) { particle in
                        Circle()
                            .fill(AppColors.white.opacity(particle.opacity))
                            .frame(width: particle.size, height: particle.size)
                            .position(particle.position)
                            .opacity(showLogo ? 1 : 0)
                    }
                    
                    if showLogo {
                        VStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [AppColors.lightBlue.opacity(0.3), Color.clear],
                                            center: .center,
                                            startRadius: 10,
                                            endRadius: 80
                                        )
                                    )
                                    .frame(width: 160, height: 160)
                                
                                Circle()
                                    .fill(AppColors.white.opacity(0.15))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "plus.forwardslash.minus")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(AppColors.white)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                
                if showTitle {
                    VStack(spacing: 8) {
                        Text("QuickDiscount")
                            .font(.jostBold(28))
                            .foregroundColor(AppColors.white)
                        
                        Text("Calculator")
                            .font(.jostLight(18))
                            .foregroundColor(AppColors.white.opacity(0.8))
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    ProgressBar(progress: loadingProgress)
                        .frame(height: 4)
                        .frame(maxWidth: 200)
                    
                    Text("Initializing...")
                        .font(.jostRegular(14))
                        .foregroundColor(AppColors.white.opacity(0.7))
                }
                .padding(.bottom, 40)
            }
            .padding()
        }
        .onAppear {
            startComplexAnimation()
        }
    }
    
    private func startComplexAnimation() {
        particles = generateParticles()
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            showLogo = true
        }
        
        withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
            showTitle = true
        }
        
        withAnimation(.easeInOut(duration: 2.0).delay(0.8)) {
            loadingProgress = 1.0
        }
        
        animateParticles()
    }
    
    private func generateParticles() -> [Particle] {
        return (0..<20).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 50...350),
                    y: CGFloat.random(in: 200...600)
                ),
                size: CGFloat.random(in: 2...6),
                opacity: Double.random(in: 0.3...0.8)
            )
        }
    }
    
    private func animateParticles() {
        for i in particles.indices {
            withAnimation(
                .easeInOut(duration: Double.random(in: 2...4))
                .repeatForever(autoreverses: true)
                .delay(Double.random(in: 0...1))
            ) {
                particles[i].position.y += CGFloat.random(in: -50...50)
                particles[i].opacity = Double.random(in: 0.1...0.9)
            }
        }
    }
}

struct Particle {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    var opacity: Double
}

struct AnimatedBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: animateGradient 
                ? [AppColors.deepBlue, AppColors.primaryBlue, AppColors.lightBlue]
                : [AppColors.primaryBlue, AppColors.deepBlue, AppColors.primaryBlue],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

struct ProgressBar: View {
    let progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppColors.white.opacity(0.3))
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.lightBlue, AppColors.white],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress)
            }
        }
    }
}

#Preview("Simple Splash") {
    SplashView()
}

#Preview("Complex Splash") {
    AlternativeSplashView()
}

