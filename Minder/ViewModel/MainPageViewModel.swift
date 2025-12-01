//
//  MainPageViewModel.swift
//  Minder
//
//  Created by Sarah Khalid Almalki on 10/06/1447 AH.
//

import Foundation
import Combine

class MainPageViewModel: ObservableObject {
    @Published var isShowingSettings = false
    @Published var formattedDate: String

    init() {
        // 1) Create formatter
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"   // Monday, 17 November
        formatter.locale = Locale(identifier: "en_US") // or Locale.current

        // 2) Format "now"
        let now = Date()
        let dateString = formatter.string(from: now)

        // 3) Store it for the View
        self.formattedDate = dateString

        // 4) Print to console (for debugging)
        print("Today is: \(dateString)")
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 0..<12:
            return "\nGood morning!"
        case 12..<17:
            return "\nGood afternoon!"
        case 17..<22:
            return "\nGood evening"
        default:
            return "\nGood night"
        }
    }

    func didTapSettings() {
        isShowingSettings = true
    }

    func closeSettings() {
        isShowingSettings = false
    }
}
