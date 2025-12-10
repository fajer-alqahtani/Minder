//
//  MedicationCard.swift
//  Minder
//
//  Created by Areeg Altaiyah on 01/12/2025.
//
import SwiftUI
import SwiftData

struct MedicationCard: View {
    let medication: Medication
    let medicationName: String
    let timeOfDay: TimeOfDay
    @State private var isSelected: Bool = false
    var onDelete: (() -> Void)? = nil
    @State private var showDeleteAlert = false
    
    @Environment(\.modelContext) private var modelContext
    @Query private var medicationLogs: [MedicationLog]
    
    var body: some View {
        ZStack {
            // The rounded rectangle
            Rectangle()
                .cornerRadius(50)
                .foregroundStyle(timeOfDay == .morning ? Color.ourYellow.opacity(0.2): Color.accentColor.opacity(0.2))
            
            HStack(spacing: 1) {
                // The circle with checkmark
                ZStack {
                    Circle()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(isSelected ? Color.ourGrey : (timeOfDay == .morning) ? Color.ourYellow.opacity(0.6) : Color.accentColor.opacity(0.2))
                    
                    // Checkmark icon
                    if isSelected {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.white)
                            .font(.system(.title3))
                    }
                }
                // Time of day icon
                Image(systemName: timeOfDay == .morning ? "sun.max.fill" : "moon.fill")
                    .font(.system(.caption))
                    .foregroundStyle(timeOfDay == .morning ? Color.ourYellow : Color.accentColor)
                
                // Medication name
                Text(medicationName)
                    .font(.system(.footnote, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
               
                Spacer()
                
                // Delete button
                if onDelete != nil {
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.red.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 40)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isSelected.toggle()
                saveMedicationLog()  // ⬅️ SAVE STATE
            }
        }
        .onAppear {
            loadTodayStatus()  // ⬅️ LOAD TODAY'S STATUS
        }
        .alert("Remove Medication", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                onDelete?()
            }
        } message: {
            Text("Remove \(medicationName) from \(timeOfDay == .morning ? "morning" : "night")?")
        }
    }
    
    // ⬅️ NEW: Save medication log when checked/unchecked
    private func saveMedicationLog() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Check if log already exists for today
        let existingLog = medicationLogs.first { log in
            log.medicationId == medication.id &&
            log.timeOfDay == timeOfDay &&
            Calendar.current.isDate(log.date, inSameDayAs: today)
        }
        
        if let existingLog = existingLog {
            // Update existing log
            existingLog.wasTaken = isSelected
        } else {
            // Create new log
            let newLog = MedicationLog(
                medicationName: medicationName,
                medicationId: medication.id,
                timeOfDay: timeOfDay,
                wasTaken: isSelected,
                date: today
            )
            modelContext.insert(newLog)
        }
        
        try? modelContext.save()
        print("💾 Saved log: \(medicationName) - \(timeOfDay.rawValue) - Taken: \(isSelected)")
    }
    
    // ⬅️ NEW: Load today's status when card appears
    private func loadTodayStatus() {
        let today = Calendar.current.startOfDay(for: Date())
        
        let todayLog = medicationLogs.first { log in
            log.medicationId == medication.id &&
            log.timeOfDay == timeOfDay &&
            Calendar.current.isDate(log.date, inSameDayAs: today)
        }
        
        if let todayLog = todayLog {
            isSelected = todayLog.wasTaken
            print("📖 Loaded log: \(medicationName) - \(timeOfDay.rawValue) - Taken: \(isSelected)")
        }
    }
}

// For use with SwiftData model - with explicit time context
extension MedicationCard {
    init(medication: Medication, displayTime: TimeOfDay, isSelected: Bool = false, onDelete: (() -> Void)? = nil) {
        self.medication = medication
        self.medicationName = medication.name
        self.timeOfDay = displayTime
        self._isSelected = State(initialValue: isSelected)
        self.onDelete = onDelete
    }
}

#Preview {
    VStack(spacing: 20) {
        // Preview needs context now
    }
    .padding()
    .modelContainer(for: [Medication.self, MedicationLog.self], inMemory: true)
}
