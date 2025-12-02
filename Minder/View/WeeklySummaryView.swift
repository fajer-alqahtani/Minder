//
//  WeeklySummaryView.swift
//  Minder
//
//  Created by Fajer alQahtani on 11/06/1447 AH.
//

import SwiftUI
import SwiftData
import Charts // <--- Apple's native charting framework

struct WeeklySummaryView: View {
    // 1. Fetch ALL logs from the database
    @Query(sort: \EmotionLog.timestamp, order: .reverse) private var allLogs: [EmotionLog]
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Header
            VStack(spacing: 5) {
                Text("Weekly Insights")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.minderDark)
                Text("Last 7 Days")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.top)
            
            if weeklyEmotionCounts.isEmpty {
                // Empty State
                ContentUnavailableView(
                    "No Data Yet",
                    systemImage: "chart.pie",
                    description: Text("Check in for a few days to see patterns.")
                )
            } else {
                // 2. THE PIE CHART
                Chart(weeklyEmotionCounts, id: \.emotion) { dataItem in
                    SectorMark(
                        angle: .value("Count", dataItem.count),
                        innerRadius: .ratio(0.5), // Makes it a Donut Chart (optional)
                        angularInset: 2 // Spacing between slices
                    )
                    .cornerRadius(5)
                    .foregroundStyle(colorFor(emotion: dataItem.emotion))
                    .annotation(position: .overlay) {
                        Text("\(dataItem.count)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .frame(height: 250) // Set the size of the chart
                .padding()
                
                // 3. LEGEND (List of emotions)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Breakdown")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    ForEach(weeklyEmotionCounts, id: \.emotion) { dataItem in
                        HStack {
                            Circle()
                                .fill(colorFor(emotion: dataItem.emotion))
                                .frame(width: 10, height: 10)
                            
                            Text(dataItem.emotion.rawValue)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("\(dataItem.count) times")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5)
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .background(Color.minderLight.edgesIgnoringSafeArea(.all))
    }
    
    // MARK: - Data Logic
    
    // A simple struct to hold our counted data
    struct EmotionData {
        let emotion: Emotion
        let count: Int
    }
    
    // Computed property to filter and count the last 7 days
    var weeklyEmotionCounts: [EmotionData] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        // 1. Filter logs from the last 7 days
        let recentLogs = allLogs.filter { $0.timestamp >= sevenDaysAgo }
        
        // 2. Flatten the arrays (because one log can have multiple emotions)
        let allEmotions = recentLogs.flatMap { $0.emotions }
        
        // 3. Count occurrences
        let counts = Dictionary(grouping: allEmotions, by: { $0 }).mapValues { $0.count }
        
        // 4. Convert to array and sort
        return counts.map { EmotionData(emotion: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count } // Show most frequent first
    }
    
    // Helper for Colors (Matches your theme)
    func colorFor(emotion: Emotion) -> Color {
        switch emotion {
        case .calm: return Color(red: 0.82, green: 0.91, blue: 0.96)
        case .confused: return Color(red: 0.98, green: 0.83, blue: 0.71)
        case .sad: return Color(red: 0.88, green: 0.88, blue: 0.88)
        case .agitated: return Color(red: 1.0, green: 0.7, blue: 0.7)
        case .anxious: return Color(red: 0.85, green: 0.8, blue: 0.95)
        case .tired: return Color(red: 0.79, green: 0.89, blue: 0.77)
        case .unknown: return Color.gray
        }
    }
}

// Preview
#Preview {
    WeeklySummaryView()
        .modelContainer(for: EmotionLog.self, inMemory: true)
}
