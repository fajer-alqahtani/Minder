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
                        
                        // MinderM + Date under it
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
                        
                    }
                    .padding(.top, -70)
                    
                    Spacer()
                }
                .padding()
                
                VStack(spacing: 12) {
                    NavigationLink(
                        destination:
                            MedicationView()
                    ) {
                        HStack(spacing: 12) {
                            Image(systemName: "pills.fill")
                                .font(.system(size: 20))

                            Text("Medications")
                                .font(.subheadline)
                                .bold()
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
                            Text("Meals Page") //  Just a placeholder, replace with MealsView() when available
                    ) {
                        HStack(spacing: 12) {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 20))

                            Text("Meals")
                                .font(.subheadline)
                                .bold()
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
                                .font(.subheadline)
                                .bold()
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
                            Text("Summary Trial Page") //  Just a placeholder, replace with SummaryView() when available
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
