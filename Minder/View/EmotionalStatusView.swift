//
//  EmotionalStatusView.swift
//  Minder
//
//  Created by Fajer alQahtani on 05/06/1447 AH.
//

import SwiftUI
import SwiftData

// Define Theme Colors (Based on your "Minder" brand)
extension Color {
    static let minderDark = Color(red: 0.2, green: 0.2, blue: 0.25) // Dark Navy
    static let minderLight = Color(red: 0.96, green: 0.96, blue: 0.98) // Off-white background
}

struct EmotionalStatusView: View {
    // 1. Access SwiftData Context
    @Environment(\.modelContext) private var modelContext
    
    // 2. Initialize ViewModel
    @State private var viewModel = EmotionalStatusViewModel()
    
    // NEW: State to control the Daily Summary Sheet
    @State private var showDailySummary = false

    var body: some View {
        ZStack {
            Color.minderLight.edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // Header (now includes the chart button)
                headerView

                ScrollView {
                    VStack(spacing: 25) {
                        // Section 1: Emotions
                        emotionGridView
                        
                        // Section 2: Intensity & Note (Only shows if emotion is picked)
                        if !viewModel.selectedEmotions.isEmpty {
                            intensitySection
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            
                            noteSection
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.bottom, 100) // Space for bottom button
                }
            }
            
            // Floating Save Button
            saveButtonArea
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.selectedEmotions)
        .alert("Check-in Saved", isPresented: $viewModel.showSaveAlert) {
            Button("Done") { viewModel.resetForm() }
        }
        // 👇 ADDED SHEET MODIFIER HERE
        .sheet(isPresented: $showDailySummary) {
            DailySummaryView() // Presents the daily chart view
        }
    }
}

// MARK: - UI Components Breakdown
extension EmotionalStatusView {
    
    // UPDATED: Now includes the Chart Button
    var headerView: some View {
        HStack {
            // Text on the left
            VStack(alignment: .leading, spacing: 6) {
                Text("Daily Check-in")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("How are they feeling?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.minderDark)
            }
            
            Spacer()
            
            // Chart Button on the right
            Button(action: {
                showDailySummary = true // Toggles the sheet
            }) {
                Image(systemName: "chart.pie.fill")
                    .font(.title2)
                    .foregroundColor(.minderDark)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 3)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }
    
    var emotionGridView: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 15)], spacing: 15) {
            ForEach(Emotion.allCases, id: \.self) { emotion in
                let isSelected = viewModel.selectedEmotions.contains(emotion)
                
                Button(action: { viewModel.toggleEmotion(emotion) }) {
                    HStack {
                        Text(emotion.icon).font(.title2)
                        Text(emotion.rawValue).fontWeight(.semibold).font(.title3)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    // Theme Logic: Dark Navy if selected, White if not
                    .background(isSelected ? Color.minderDark : Color.white)
                    .foregroundColor(isSelected ? .white : .minderDark)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.2), lineWidth: isSelected ? 0 : 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
                }
                .scaleEffect(isSelected ? 1.02 : 1.0)
            }
        }
        .padding(.horizontal)
    }
    
    var intensitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Intensity").font(.headline).foregroundColor(.minderDark).padding(.leading, 4)
            
            HStack(spacing: 0) {
                ForEach(Intensity.allCases, id: \.self) { intensity in
                    let isSelected = viewModel.selectedIntensity == intensity
                    
                    Button(action: { viewModel.selectIntensity(intensity) }) {
                        Text(intensity.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(isSelected ? Color.minderDark : Color.white)
                            .foregroundColor(isSelected ? .white : .gray)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5)
        }
        .padding(.horizontal)
    }
    
    var noteSection: some View {
        TextField("Add a quick note (optional)...", text: $viewModel.optionalNote, axis: .vertical)
            .lineLimit(1...5) // Allow it to expand slightly for longer notes
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5)
            .padding(.horizontal)
    }
    
    var saveButtonArea: some View {
        VStack {
            Spacer()
            Button(action: {
                viewModel.saveEntry(context: modelContext)
            }) {
                Text("CONFIRM")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(viewModel.isFormComplete ? Color.minderDark : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(43)
                    .shadow(radius: viewModel.isFormComplete ? 5 : 0)
            }
            .disabled(!viewModel.isFormComplete)
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    EmotionalStatusView()
        // Ensure EmotionLog.self is used for the container
        .modelContainer(for: EmotionLog.self, inMemory: true)
}
