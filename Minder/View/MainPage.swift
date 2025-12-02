//
//  Untitled.swift
//  Minder
//
//  Created by Sarah Khalid Almalki on 10/06/1447 AH.
//

import SwiftUI
import Foundation

struct MainPage: View {

    @StateObject private var viewModel = MainPageViewModel()

    var body: some View {
        NavigationStack{
            ZStack {
                // MAIN CONTENT
                VStack {
                    ZStack(alignment: .topTrailing) {
                        
                        // Background card + overlays
                        RoundedRectangle(cornerRadius: 50)
                            .fill(Color.accentColor)
                            .frame(width: 387, height: 340)
                        
                        // MinderM + DATE under it (top-left)
                            .overlay(alignment: .topLeading) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Image("MinderMark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 100)
                                    
                                    Text(viewModel.formattedDate)
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.white.opacity(0.9))
                                    
                                    // greeting
                                    Text(viewModel.greeting)
                                        .font(.title)
                                        .foregroundColor(.ourDarkGrey)
                                    Text("Let’s start today’s record.")
                                        .font(.title)
                                        .bold()
                                        .foregroundColor(.ourDarkGrey)
                                    
                                }
                                .padding(.leading, 20)
                                .padding(.top, 50)
                            }
                        
                        // Settings button (top-right)
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    viewModel.didTapSettings()
                                } label: {
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(Color.ourGrey)
                                        .frame(width: 28, height: 28)
                                }
                                .padding(.trailing, 24)
                                .padding(.top, 80)
                            }
                    }
                    .padding(.top, -70)
                    
                    Spacer()
                }
                .padding()
                
                // POPUP OVERLAY
                if viewModel.isShowingSettings {
                    // dimmed background
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            viewModel.closeSettings()
                        }
                    
                    // popup card
                    VStack(spacing: 16) {
                        Text("Settings")
                            .font(.headline)
                        
                        Button("Close") {
                            viewModel.closeSettings()
                        }
                        .padding(.top, 8)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(.systemBackground))
                    )
                    .frame(maxWidth: 320)
                    .shadow(radius: 20)
                }
                
                VStack(spacing: 12) {
                    NavigationLink(
                                            destination:
                                                MedicationView()
                                        ) {
                                            HStack(spacing: 12) {
                                                Image(systemName: "pills.fill")
                                                    .font(.system(size: 20))

                                                Text("Medications")
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(.ourDarkGrey)

                                                Spacer()

                                                Image(systemName: "chevron.right")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding(.vertical, 26)
                                            .padding(.horizontal, 20)
                                            .background(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .fill(Color(.systemGray6))
                                            )
                                            .frame(width: 290)  // control rectangle width
                                        }
                                        .buttonStyle(.plain)
                                        .padding(.top, 240)
                    
                    NavigationLink(
                                           destination:
                                               Text("Meals Page") //  Just a placeholder, I need to write the view name example: Meals View()
                                       ) {
                                           HStack(spacing: 12) {
                                               Image(systemName: "fork.knife")
                                                   .font(.system(size: 20))

                                               Text("Meals")
                                                   .font(.system(size: 16, weight: .semibold))
                                                   .foregroundColor(.ourDarkGrey)

                                               Spacer()

                                               Image(systemName: "chevron.right")
                                                   .font(.system(size: 14))
                                                   .foregroundColor(.secondary)
                                           }
                                           .padding(.vertical, 26)
                                           .padding(.horizontal, 20)
                                           .background(
                                               RoundedRectangle(cornerRadius: 14)
                                                   .fill(Color(.systemGray6))
                                           )
                                           .frame(width: 290)
                                       }
                                       .buttonStyle(.plain)
                                       .padding(.top, 30)
                    
                    
                    NavigationLink(
                                           destination:
                                               EmotionalStatusView()
                                       ) {
                                           HStack(spacing: 12) {
                                               Image(systemName: "heart.text.square.fill")
                                                   .font(.system(size: 20))

                                               Text("Emotional Status")
                                                   .font(.system(size: 16, weight: .semibold))
                                                   .foregroundColor(.ourDarkGrey)

                                               Spacer()

                                               Image(systemName: "chevron.right")
                                                   .font(.system(size: 14))
                                                   .foregroundColor(.secondary)
                                           }
                                           .padding(.vertical, 26)
                                           .padding(.horizontal, 20)
                                           .background(
                                               RoundedRectangle(cornerRadius: 14)
                                                   .fill(Color(.systemGray6))
                                           )
                                           .frame(width: 290)
                                       }
                                       .buttonStyle(.plain)
                                       .padding(.top, 30)
                    
                    NavigationLink(
                        destination:
                            Text("Summary Trial Page") //  Just a placeholder, I need to write the view name example: Emotional View()
                    ) {
                        Text("Summary")
                            .font(Font.title)
                            .foregroundColor(.white)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 100)
                            .background(Color(.ourGrey))
                            .clipShape(Capsule())
                    }
                    .padding(.top, 80)
                    .buttonStyle(.plain)

                }
                .padding(.top, 70)
                
                
            }
        }
    }
}

#Preview {
    MainPage()
}
