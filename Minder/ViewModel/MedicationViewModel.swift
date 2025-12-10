import Foundation
import Combine
import SwiftData

@Observable
class MedicationViewModel {
    var medicineName: String = ""
    var dosage: Int = 1  // ⬅️ Changed from 0 to 1 for better UX
    var selectedTime: TimeOfDay? = nil
    var selectedTimes: [TimeOfDay?] = []  // For multiple doses
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    var isConfirmEnabled: Bool {
        if dosage < 2 {
            // Single dose: check if name, dosage, and time are set
            return !medicineName.isEmpty && dosage > 0 && selectedTime != nil
        } else {
            // Multiple doses: check if all times are selected and no duplicates
            let validTimes = selectedTimes.compactMap { $0 }
            return !medicineName.isEmpty && dosage > 0 &&
                   validTimes.count == dosage &&
                   Set(validTimes).count == validTimes.count  // No duplicates
        }
    }
    
    func confirmMedication() {
        let medication: Medication
        
        if dosage < 2 {
            // Single dose
            medication = Medication(
                name: medicineName,
                dosage: dosage,
                timeOfDay: selectedTime
            )
        } else {
            // Multiple doses
            let times = selectedTimes.compactMap { $0 }
            medication = Medication(
                name: medicineName,
                dosage: dosage,
                dosageTimes: times
            )
        }
        
        print("🔵 BEFORE INSERT - Creating medication: \(medication.name)")
        
        // Save to SwiftData
        modelContext.insert(medication)
        
        print("🟡 AFTER INSERT - About to save...")
        
        // CRITICAL: Explicitly save the context
        do {
            try modelContext.save()
            if dosage < 2 {
                print("✅ SAVE SUCCESS: \(medication.name) - \(medication.dosage) pill - \(medication.timeOfDay?.rawValue ?? "No time")")
            } else {
                let timesStr = medication.dosageTimes.map { $0.rawValue }.joined(separator: ", ")
                print("✅ SAVE SUCCESS: \(medication.name) - \(medication.dosage) pills - Times: \(timesStr)")
            }
            
            // Verify it's in the context
            let descriptor = FetchDescriptor<Medication>()
            let allMeds = try modelContext.fetch(descriptor)
            print("📊 Total medications in context: \(allMeds.count)")
            for med in allMeds {
                if med.dosage < 2 {
                    print("   - \(med.name) (\(med.timeOfDay?.rawValue ?? "nil"))")
                } else {
                    let times = med.dosageTimes.map { $0.rawValue }.joined(separator: ", ")
                    print("   - \(med.name) (Times: \(times))")
                }
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
    
    func selectTimeForDosage(index: Int, time: TimeOfDay) {
        // Prevent duplicate time selection
        if selectedTimes.contains(where: { $0 == time }) {
            print("⚠️ This time is already selected for another dose")
            return
        }
        
        while selectedTimes.count <= index {
            selectedTimes.append(nil)
        }
        selectedTimes[index] = time
    }
    
    func resetForm() {
        medicineName = ""
        dosage = 1
        selectedTime = nil
        selectedTimes = []
    }
}
