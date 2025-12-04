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
        
        // CRITICAL: Explicitly save the context
        do {
            try modelContext.save()
            print("✅ Saved to SwiftData: \(medication.name) - \(medication.dosage) pills - \(medication.timeOfDay?.rawValue ?? "No time")")
        } catch {
            print("❌ Failed to save medication: \(error.localizedDescription)")
        }

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
}
