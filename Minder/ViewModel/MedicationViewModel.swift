//
//  MedicationViewModel.swift
//  Minder
//
//  Created by Areeg Altaiyah on 29/11/2025.
//

import Foundation
import Combine

class MedicationViewModel: ObservableObject {
    @Published var medicineName: String = ""
    @Published var dosage: Int = 0
    @Published var selectedTime: Medication.TimeOfDay? = nil
    
    var isConfirmEnabled: Bool {
        !medicineName.isEmpty && dosage > 0 && selectedTime != nil
    }
    
    func confirmMedication() {
        let medication = Medication(
            name: medicineName,
            dosage: dosage,
            timeOfDay: selectedTime
        )
        // Handle medication confirmation (save to database, etc.)
        print("Medication confirmed: \(medication)")
    }
    
    func selectTime(_ time: Medication.TimeOfDay) {
        selectedTime = time
    }
    
    func navigateBack() {
        // Handle navigation back
    }
}
