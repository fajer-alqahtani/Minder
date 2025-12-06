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
        
        print("🔵 BEFORE INSERT - Creating medication: \(medication.name)")
        
        // Save to SwiftData
        modelContext.insert(medication)
        
        print("🟡 AFTER INSERT - About to save...")
        
        // CRITICAL: Explicitly save the context
        do {
            try modelContext.save()
            print("✅ SAVE SUCCESS: \(medication.name) - \(medication.dosage) pills - \(medication.timeOfDay?.rawValue ?? "No time")")
            
            // Verify it's in the context
            let descriptor = FetchDescriptor<Medication>()
            let allMeds = try modelContext.fetch(descriptor)
            print("📊 Total medications in context: \(allMeds.count)")
            for med in allMeds {
                print("   - \(med.name) (\(med.timeOfDay?.rawValue ?? "nil"))")
            }
        } catch {
            print("❌ SAVE FAILED: \(error.localizedDescription)")
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
