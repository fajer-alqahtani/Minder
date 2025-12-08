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
        guard isFormComplete, let intensity = selectedIntensity else { return }

        let newLog = EmotionLog(
            emotions: selectedEmotions,
            intensity: intensity,
            note: optionalNote
        )
        
        context.insert(newLog)
        
        print("✅ Saved EmotionLog:")
        print("   emotions:", selectedEmotions.map { $0.localizedTitle })
        print("   intensity:", intensity.rawValue)
        print("   notes:", optionalNote)
        print("   at:", newLog.timestamp)
        
        showSaveAlert = true
        resetForm()
    }

    
    func resetForm() {
        selectedEmotions.removeAll()
        selectedIntensity = nil
        optionalNote = ""
        showSaveAlert = false
    }
}
