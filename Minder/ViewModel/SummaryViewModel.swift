//
//  SummaryViewModel.swift
//  Minder
//
//  Created by Najla on 09/06/1447 AH.
//

import SwiftUI
import Combine

final class SummaryViewModel: ObservableObject {

    @Published var title = "Your Care Overview"
    @Published var dateRangeText = "1 Dec 2026 – 7 Dec 2026"
    @Published var selectedPeriod: SummaryPeriod = .weekly

    @Published var emotionalStatus: EmotionalStatusSummary
    @Published var mealsWeek: [MealDay]
    @Published var medications: [MedicationSection]

    init() {
        emotionalStatus = EmotionalStatusSummary(
            value: 0.45,
            label: "Happier",
            categories: [
                EmotionCategory(name: "Joyful",   color: Color("ourYellow")),
                EmotionCategory(name: "Saddness", color: Color("ourGrey")),
                EmotionCategory(name: "Angry",    color: Color("AccentColor"))
            ]
        )


        mealsWeek = [
            MealDay(isCompleted: true),
            MealDay(isCompleted: true),
            MealDay(isCompleted: true),
            MealDay(isCompleted: true),
            MealDay(isCompleted: false),
            MealDay(isCompleted: false),
            MealDay(isCompleted: false)
        ]

        medications = [

            /// Morning card background → soft yellow
            MedicationSection(
                period: .morning,
                iconName: "sun.max.fill",
                backgroundColor: Color("ourYellow").opacity(0.10),
                items: [
                    MedicationItem(name: "Heart pill", count: 4),
                    MedicationItem(name: "Heart pill", count: 4)
                ]
            ),

            /// Evening card background → soft accent (lavender/blue)
            MedicationSection(
                period: .evening,
                iconName: "moon.fill",
                backgroundColor: Color("AccentColor").opacity(0.10),
                items: [
                    MedicationItem(name: "Heart pill", count: 3),
                    MedicationItem(name: "diabetes pill", count: 3)
                ]
            )
        ]
    }

    func changePeriod(_ period: SummaryPeriod) {
        selectedPeriod = period
    }
}
