import Foundation
import Combine
import SwiftData

@Observable
class MedicationViewModel {
    var medicineName: String = ""
    var dosage: Int = 1
    var amount: String = ""
    var selectedUnit: MedicationUnit = .mg
    var selectedTime: TimeOfDay? = nil
    var selectedTimes: [TimeOfDay?] = []
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    var isConfirmEnabled: Bool {
        let hasAmount = !amount.isEmpty && (Int(amount) ?? 0) > 0
        
        if dosage < 2 {
            return !medicineName.isEmpty && dosage > 0 && hasAmount && selectedTime != nil
        } else {
            return !medicineName.isEmpty && dosage > 0 && hasAmount &&
                   selectedTimes.count == dosage &&
                   selectedTimes.allSatisfy { $0 != nil }
        }
    }
    
    func confirmMedication() {
        let parsedAmount = Int(amount) ?? 0
        let medication: Medication
        
        if dosage < 2 {
            medication = Medication(
                name: medicineName,
                dosage: dosage,
                amount: parsedAmount,
                unit: selectedUnit,
                timeOfDay: selectedTime
            )
        } else {
            let times = selectedTimes.compactMap { $0 }
            medication = Medication(
                name: medicineName,
                dosage: dosage,
                amount: parsedAmount,
                unit: selectedUnit,
                dosageTimes: times
            )
        }
        
        print("🔵 BEFORE INSERT - Creating medication: \(medication.name)")
        
        modelContext.insert(medication)
        
        print("🟡 AFTER INSERT - About to save...")
        
        do {
            try modelContext.save()
            if dosage < 2 {
                print("✅ SAVE SUCCESS: \(medication.name) - \(medication.amount)\(medication.unit.displayName) - \(medication.dosage) pill - \(medication.timeOfDay?.rawValue ?? "No time")")
            } else {
                let timesStr = medication.dosageTimes.map { $0.rawValue }.joined(separator: ", ")
                print("✅ SAVE SUCCESS: \(medication.name) - \(medication.amount)\(medication.unit.displayName) - \(medication.dosage) pills - Times: \(timesStr)")
            }
            
            let descriptor = FetchDescriptor<Medication>()
            let allMeds = try modelContext.fetch(descriptor)
            print("📊 Total medications in context: \(allMeds.count)")
            for med in allMeds {
                if med.dosage < 2 {
                    print("   - \(med.name) \(med.amount)\(med.unit.displayName) (\(med.timeOfDay?.rawValue ?? "nil"))")
                } else {
                    let times = med.dosageTimes.map { $0.rawValue }.joined(separator: ", ")
                    print("   - \(med.name) \(med.amount)\(med.unit.displayName) (Times: \(times))")
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
        while selectedTimes.count <= index {
            selectedTimes.append(nil)
        }
        selectedTimes[index] = time
    }
    
    func resetForm() {
        medicineName = ""
        dosage = 1
        amount = ""
        selectedUnit = .mg
        selectedTime = nil
        selectedTimes = []
    }
}
