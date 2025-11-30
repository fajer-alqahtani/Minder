//
//  MedicationViewModel.swift
//  Minder
//
//  Created by Areeg Altaiyah on 29/11/2025.
//

import Foundation
import Combine
import SwiftData

@Observable
class MedicationViewModel {
    var medicineName: String = ""
    var dosage: Int = 0
    var selectedTime: TimeOfDay? = nil
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    var isConfirmEnabled: Bool {
        !medicineName.isEmpty && dosage > 0 && selectedTime != nil
    }
    
    func confirmMedication() {
        let medication = Medication(
            name: medicineName,
            dosage: dosage,
            timeOfDay: selectedTime
        )
        
        // Save to SwiftData
        modelContext.insert(medication)
        
        print("✅ Saved to SwiftData: \(medication.name) - \(medication.dosage)mg - \(medication.timeOfDay?.rawValue ?? "No time")")

        // Clear the form
        resetForm()
    }
    
    func selectTime(_ time: TimeOfDay) {
        selectedTime = time
    }
    
    func resetForm() {
        medicineName = ""
        dosage = 0
        selectedTime = nil
    }
    
    func navigateBack() {
        // Handle navigation back
    }
}
