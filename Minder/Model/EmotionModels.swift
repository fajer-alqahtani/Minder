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

import SwiftUI

import SwiftUI

enum Emotion: String, CaseIterable, Codable {
    case calm
    case confused
    case sad
    case agitated
    case anxious
    case tired
    case unknown

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

    /// Literal English text – Xcode can auto-extract these.
    var localizedTitle: LocalizedStringKey {
        switch self {
        case .calm: return "Calm"
        case .confused: return "Confused"
        case .sad: return "Sad"
        case .agitated: return "Agitated"
        case .anxious: return "Anxious"
        case .tired: return "Tired"
        case .unknown: return "Don't know"
        }
    }
}



enum Intensity: String, CaseIterable, Codable {
    case mild
    case moderate
    case strong
}

extension Intensity {
    var localizedTitle: LocalizedStringKey {
        switch self {
        case .mild: return "Mild"
        case .moderate: return "Moderate"
        case .strong: return "Strong"
        }
    }
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
