//
//  EmotionalStatusViewModel.swift
//  Minder
//
//  Created by Fajer alQahtani on 05/06/1447 AH.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
class EmotionalStatusViewModel {
    // MARK: - Properties (State)
    var selectedEmotions: Set<Emotion> = []
    var selectedIntensity: Intensity? = nil
    var optionalNote: String = ""
    var showSaveAlert: Bool = false
    
    // MARK: - Validation
    var isFormComplete: Bool {
        // User must pick at least one emotion AND an intensity
        return !selectedEmotions.isEmpty && selectedIntensity != nil
    }
    
    // MARK: - Intents (Actions)
    
    func toggleEmotion(_ emotion: Emotion) {
        // Animation logic is handled in the View, state logic is here
        if selectedEmotions.contains(emotion) {
            selectedEmotions.remove(emotion)
            // If they deselect everything, reset intensity to keep UI clean
            if selectedEmotions.isEmpty {
                selectedIntensity = nil
            }
        } else {
            selectedEmotions.insert(emotion)
        }
    }
    
    func selectIntensity(_ intensity: Intensity) {
        self.selectedIntensity = intensity
    }
    
    // MARK: - Database Logic
    func saveEntry(context: ModelContext) {
        guard let intensity = selectedIntensity else { return }
        
        // 1. Create the new Log object
        let newLog = EmotionLog(
            emotions: selectedEmotions,
            intensity: intensity,
            note: optionalNote.isEmpty ? nil : optionalNote
        )
        
        // 2. Insert into SwiftData Context
        context.insert(newLog)
        
        // 3. Trigger success UI
        showSaveAlert = true
        
        print("✅ Saved to SwiftData: \(newLog.emotions.map { $0.rawValue }) - \(newLog.intensity.rawValue)")
    }
    
    func resetForm() {
        selectedEmotions.removeAll()
        selectedIntensity = nil
        optionalNote = ""
        showSaveAlert = false
    }
}
