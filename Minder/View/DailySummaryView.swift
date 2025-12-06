//
//  DailySummaryView.swift
//  Minder
//
//  Created by Fajer alQahtani on 11/06/1447 AH.
//

import SwiftUI
import SwiftData
import Charts

struct DailySummaryView: View {
    // 1. Fetch ALL logs (we will filter them in code)
    @Query(sort: \EmotionLog.timestamp, order: .reverse) private var allLogs: [EmotionLog]
    
    // Environment to dismiss the sheet
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            
            // MARK: - Header
            ZStack {
                Text("Today's Insights")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.minderDark)
                
                // Close button (X)
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
            }
            .padding(.top, 20)
            .padding(.horizontal)
            
            if dailyEmotionCounts.isEmpty {
                // Empty State
                ContentUnavailableView(
                    "No Data Today",
                    systemImage: "calendar.badge.clock",
                    description: Text("Record an emotional check-in to see the chart.")
                )
            } else {
                // MARK: - THE PIE CHART
                Chart(dailyEmotionCounts, id: \.emotion) { dataItem in
                    SectorMark(
                        angle: .value("Count", dataItem.count),
                        innerRadius: .ratio(0.6), // Donut style
                        angularInset: 2
                    )
                    .cornerRadius(5)
                    .foregroundStyle(colorFor(emotion: dataItem.emotion))
                    .annotation(position: .overlay) {
                        // Only show number if slice is big enough
                        if dataItem.count > 0 {
                            Text("\(dataItem.count)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(height: 220)
                .padding()
                
                // MARK: - LEGEND
                VStack(alignment: .leading, spacing: 12) {
                    Text("Today's Breakdown")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    ForEach(dailyEmotionCounts, id: \.emotion) { dataItem in
                        HStack {
                            // Color dot
                            Circle()
                                .fill(colorFor(emotion: dataItem.emotion))
                                .frame(width: 12, height: 12)
                            
                            // Emotion Name
                            Text(dataItem.emotion.rawValue)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            // Count
                            Text("\(dataItem.count)x")
                                .bold()
                                .foregroundColor(.minderDark)
                        }
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .background(Color.minderLight.edgesIgnoringSafeArea(.all))
    }
    
    // MARK: - Data Logic
    
    struct EmotionData {
        let emotion: Emotion
        let count: Int
    }
    
    // Computed property: Filters logs for TODAY ONLY
    var dailyEmotionCounts: [EmotionData] {
        // 1. Filter for logs where timestamp is "in today"
        let todayLogs = allLogs.filter { Calendar.current.isDateInToday($0.timestamp) }
        
        // 2. Flatten (extract emotions from logs)
        let allEmotions = todayLogs.flatMap { $0.emotions }
        
        // 3. Count them
        let counts = Dictionary(grouping: allEmotions, by: { $0 }).mapValues { $0.count }
        
        // 4. Return sorted array
        return counts.map { EmotionData(emotion: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    // Helper Colors
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

#Preview {
    DailySummaryView()
        .modelContainer(for: EmotionLog.self, inMemory: true)
}
