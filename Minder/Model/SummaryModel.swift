//
//  SummaryData.swift
//  Minder
//
//  Created by Najla on 09/06/1447 AH.
//

import SwiftUI

enum SummaryPeriod: String, CaseIterable, Identifiable {
    case yearly = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    

    var id: String { rawValue }
}

struct EmotionCategory: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
}

struct EmotionalStatusSummary {
    let value: Double      // 0...1
    let label: String
    let categories: [EmotionCategory]
}

struct MealDay: Identifiable {
    let id = UUID()
    let isCompleted: Bool
}

struct MedicationItem: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
}

enum MedicationPeriod: String {
    case morning = "Morning"
    case evening = "Evening"
}

struct MedicationSection: Identifiable {
    let id = UUID()
    let period: MedicationPeriod
    let iconName: String
    let backgroundColor: Color
    let items: [MedicationItem]
}
