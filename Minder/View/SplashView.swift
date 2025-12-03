//
//  SplashView.swift
//  Minder
//
//  Created by Fajer alQahtani on 09/06/1447 AH.
//
import SwiftUI
import SwiftData

struct SplashView: View {
    @State private var showMain = false
    @State private var revealInder = false
    @State private var showTagline = false   // NEW: controls tagline animation

    private let splashDuration: Double = 2.5

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.92, green: 0.94, blue: 0.98),
                    Color.white
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {

                Spacer()

                // ===== LOGO + TAGLINE =====
                VStack(spacing: 10) {

                    // LOGO ROW
                    HStack(spacing: 0) {

                        // Big M logo
                        Image("MinderMark")
                            .resizable()
                            .renderingMode(.original)
                            .scaledToFit()
                            .frame(width: 160, height: 70)

                        // “inder” with slow left→right reveal
                        Text("inder")
                            .font(.system(size: 58, weight: .semibold))
                            .foregroundColor(Color(red: 0.16, green: 0.17, blue: 0.23))
                            .mask(
                                HStack {
                                    Rectangle()
                                        .frame(width: revealInder ? 220 : 0)
                                        .animation(
                                            .easeOut(duration: 1.8).delay(0.4),
                                            value: revealInder
                                        )
                                    Spacer()
                                }
                            )
                            .clipped()
                    }

                    // TAGLINE – fades & slides in
                    HStack(spacing: 0) {
                        Text("For You, ")
                            .font(.system(size: 20, weight: .regular))
                        Text("For Them.")
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .foregroundColor(Color(red: 0.16, green: 0.17, blue: 0.23).opacity(0.85))
                    .opacity(showTagline ? 1 : 0)
                    .offset(y: showTagline ? 0 : 10)   // small slide up
                    .animation(
                        .easeOut(duration: 0.7).delay(1.2),
                        value: showTagline
                    )
                }

                Spacer()
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            // start logo animation
            revealInder = true
            showTagline = true

            // go to main screen
            DispatchQueue.main.asyncAfter(deadline: .now() + splashDuration) {
                withAnimation {
                    showMain = true
                }
            }
        }
        .fullScreenCover(isPresented: $showMain) {
            MainPage()
                .modelContainer(for: EmotionLog.self)
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
            .modelContainer(for: EmotionLog.self, inMemory: true)
    }
}
