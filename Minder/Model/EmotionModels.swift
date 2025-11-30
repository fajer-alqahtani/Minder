//
//  EmotionModels.swift
//  Minder
//
//  Created by Fajer alQahtani on 05/06/1447 AH.
//

import Foundation
import SwiftData
import SwiftUI
//hello
// --- THE DATA ENUMS ---
// These define the options available in the app.

enum Emotion: String, CaseIterable, Codable {
    case calm = "Calm"
    case confused = "Confused"
    case sad = "Sad"
    case agitated = "Agitated"
    case anxious = "Anxious"
    case tired = "Tired"
    case unknown = "Don't Know"

    var icon: String {
        switch self {
        case .calm: return "☁️"
        case .confused: return "🌀"
        case .sad: return "🌧"
        case .agitated: return "⚡️"
        case .anxious: return "〰️"
        case .tired: return "🌙"
        case .unknown: return "❓"
        }
    }
}

enum Intensity: String, CaseIterable, Codable {
    case mild = "Mild"
    case moderate = "Moderate"
    case strong = "Strong"
}

// --- THE SWIFTDATA MODEL ---
// This is the actual object that gets saved to the database.

@Model
final class EmotionLog {
    var id: UUID
    var timestamp: Date
    var emotions: [Emotion] // SwiftData handles arrays of Codable enums automatically
    var intensity: Intensity
    var note: String?
    
    init(emotions: Set<Emotion>, intensity: Intensity, note: String? = nil) {
        self.id = UUID()
        self.timestamp = Date()
        self.emotions = Array(emotions) // Convert Set to Array for storage
        self.intensity = intensity
        self.note = note
    }
}
