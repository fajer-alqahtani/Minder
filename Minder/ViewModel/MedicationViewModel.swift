import Foundation
import Combine
import SwiftData

@Observable
class MedicationViewModel {
    var medicineName: String = ""
    var dosage: Int = 1
    var selectedTime: TimeOfDay? = nil
    var selectedTimes: [TimeOfDay?] = []
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    var isConfirmEnabled: Bool {
        if dosage < 2 {
            return !medicineName.isEmpty && dosage > 0 && selectedTime != nil
        } else {
            // ⬅️ CHANGED: Allow duplicates, just check all slots are filled
            return !medicineName.isEmpty && dosage > 0 &&
                   selectedTimes.count == dosage &&
                   selectedTimes.allSatisfy { $0 != nil }
        }
    }
    
    func confirmMedication() {
        let medication: Medication
        
        if dosage < 2 {
            medication = Medication(
                name: medicineName,
                dosage: dosage,
                timeOfDay: selectedTime
            )
        } else {
            let times = selectedTimes.compactMap { $0 }
            medication = Medication(
                name: medicineName,
                dosage: dosage,
                dosageTimes: times
            )
        }
        
        print("🔵 BEFORE INSERT - Creating medication: \(medication.name)")
        
        modelContext.insert(medication)
        
        print("🟡 AFTER INSERT - About to save...")
        
        do {
            try modelContext.save()
            if dosage < 2 {
                print("✅ SAVE SUCCESS: \(medication.name) - \(medication.dosage) pill - \(medication.timeOfDay?.rawValue ?? "No time")")
            } else {
                let timesStr = medication.dosageTimes.map { $0.rawValue }.joined(separator: ", ")
                print("✅ SAVE SUCCESS: \(medication.name) - \(medication.dosage) pills - Times: \(timesStr)")
            }
            
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

        resetForm()
    }
    
    func selectTime(_ time: TimeOfDay) {
        selectedTime = time
    }
    
    func selectTimeForDosage(index: Int, time: TimeOfDay) {
        // ⬅️ REMOVED: Duplicate prevention - now allows morning, morning, night
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
