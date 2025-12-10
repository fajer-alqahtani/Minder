import SwiftUI
import SwiftData

struct MainPage: View {
    @StateObject private var viewModel = MainPageViewModel()
    @State private var showMedications = true
    @Query private var medications: [Medication]
    @Query private var emotionLogs: [EmotionLog]
    @Query private var medicationLogs: [MedicationLog]  // ⬅️ ADDED
    @Environment(\.modelContext) private var modelContext  // ⬅️ ADDED
    @AppStorage("lastCheckedDate") private var lastCheckedDateString = ""  // ⬅️ ADDED
    
    // Group medications by time of day
    private var morningMeds: [Medication] {
        medications.filter { medication in
            if medication.dosage < 2 {
                return medication.timeOfDay == .morning
            } else {
                return medication.dosageTimes.contains(.morning)
            }
        }
    }

    private var nightMeds: [Medication] {
        medications.filter { medication in
            if medication.dosage < 2 {
                return medication.timeOfDay == .night
            } else {
                return medication.dosageTimes.contains(.night)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - HEADER
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Today's Record")
                                .font(.largeTitle.bold())
                                .foregroundColor(.ourDarkGrey)
                            
                            Text(viewModel.formattedDate)
                                .font(.title3)
                                .foregroundColor(.ourDarkGrey)
                        }
                        
                        Spacer()
                        
                        // Top-right navigation icon button
                        NavigationLink(destination: SummaryView()) {
                            Image(systemName: "text.line.3.summary")
                                .font(.title)
                                .foregroundColor(.ourDarkGrey)
                                .padding(10)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 1)
                    
                    // MARK: - MEDICATIONS CARD
                    MedicationsCard(
                        showMedications: $showMedications,
                        medications: medications,
                        morningMeds: morningMeds,
                        nightMeds: nightMeds
                    )
                    
                    // MARK: - MEALS CARD
                    MealsCard()
                    
                    // MARK: - EMOTIONAL STATUS CARD
                    EmotionalStatusCard()
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
                .padding(.bottom, 24)
            }
            .onAppear {
                checkAndSaveYesterdayMedications()  // ⬅️ NEW: Auto-save yesterday's unchecked
                
                print("📱 MainPage appeared - Total medications: \(medications.count)")
                
                // Medication debugging…
                for med in medications {
                    if med.dosage < 2 {
                        print("   - \(med.name): \(med.dosage) pill, time: \(med.timeOfDay?.rawValue ?? "nil")")
                    } else {
                        let times = med.dosageTimes.map { $0.rawValue }.joined(separator: ", ")
                        print("   - \(med.name): \(med.dosage) pills, times: [\(times)]")
                    }
                }
                
                print("🌅 Morning meds: \(morningMeds.count)")
                print("🌙 Night meds: \(nightMeds.count)")
                
                print("🧠 Emotion logs stored:", emotionLogs.count)
                for log in emotionLogs {
                    print("  • emotions:", log.emotions.map { $0.localizedTitle })
                    print("    intensity:", log.intensity.rawValue)
                    print("    timestamp:", log.timestamp)
                }
            }
        }
    }
    
    // ⬅️ NEW: Check if it's a new day and save yesterday's unchecked medications
    private func checkAndSaveYesterdayMedications() {
        let today = Calendar.current.startOfDay(for: Date())
        let todayString = ISO8601DateFormatter().string(from: today)
        
        // Check if we've already processed today
        if lastCheckedDateString == todayString {
            return  // Already processed today
        }
        
        // It's a new day! Check yesterday's medications
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) else { return }
        
        print("🌅 NEW DAY DETECTED - Processing yesterday's medications...")
        
        // Get all medication entries for yesterday
        for medication in medications {
            var timesToCheck: [TimeOfDay] = []
            
            if medication.dosage < 2 {
                if let time = medication.timeOfDay {
                    timesToCheck.append(time)
                }
            } else {
                timesToCheck = medication.dosageTimes
            }
            
            // Check each time slot
            for time in timesToCheck {
                let hasLog = medicationLogs.contains { log in
                    log.medicationId == medication.id &&
                    log.timeOfDay == time &&
                    Calendar.current.isDate(log.date, inSameDayAs: yesterday)
                }
                
                if !hasLog {
                    // No log exists - create one with wasTaken = false
                    let missedLog = MedicationLog(
                        medicationName: medication.name,
                        medicationId: medication.id,
                        timeOfDay: time,
                        wasTaken: false,
                        date: yesterday
                    )
                    modelContext.insert(missedLog)
                    print("❌ Created 'not taken' log: \(medication.name) - \(time.rawValue) for yesterday")
                }
            }
        }
        
        // Save all the "not taken" logs
        try? modelContext.save()
        
        // Update last checked date
        lastCheckedDateString = todayString
        print("✅ Finished processing yesterday's medications")
    }
}

// MARK: - MEDICATIONS CARD VIEW

struct MedicationsCard: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var showMedications: Bool
    let medications: [Medication]
    let morningMeds: [Medication]
    let nightMeds: [Medication]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Header row
            HStack(spacing: 12) {
                Image(systemName: "pills")
                    .font(.system(size: 22))
                    .foregroundColor(.ourDarkGrey)
                
                Text("Medications")
                    .font(.headline)
                    .foregroundColor(.ourDarkGrey)
                
                Spacer()
                
                // Add button (NavigationLink)
                NavigationLink(destination: MedicationView()) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.ourDarkGrey)
                }
            }
            
            if showMedications {
                VStack(alignment: .leading, spacing: 16) {
                    
                    if !morningMeds.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Morning")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 8) {
                                ForEach(morningMeds) { medication in
                                    MedicationCard(
                                        medication: medication,
                                        displayTime: .morning,
                                        onDelete: {
                                            deleteMedicationFromTime(medication, timeToRemove: .morning)
                                        }
                                    )
                                }
                            }
                        }
                    }
                    
                    if !nightMeds.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Night")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 8) {
                                ForEach(nightMeds) { medication in
                                    MedicationCard(
                                        medication: medication,
                                        displayTime: .night,
                                        onDelete: {
                                            deleteMedicationFromTime(medication, timeToRemove: .night)
                                        }
                                    )
                                }
                            }
                        }
                    }
                    
                    if medications.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "pills.circle")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            
                            Text("No medications added yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 24)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(.systemGray6))
        )
        .frame(maxWidth: .infinity, minHeight: 211, alignment: .topLeading)
    }
    
    // Smart delete function - handles single time removal or full deletion
    private func deleteMedicationFromTime(_ medication: Medication, timeToRemove: TimeOfDay) {
        withAnimation {
            // If it's a single-dose medication (only one time), delete the whole medication
            if medication.dosage < 2 {
                modelContext.delete(medication)
            } else {
                // Multi-dose medication - remove only the specific time
                medication.dosageTimes.removeAll { $0 == timeToRemove }
                
                // If only one time remains, update dosage to 1 and set timeOfDay
                if medication.dosageTimes.count == 1 {
                    medication.dosage = 1
                    medication.timeOfDay = medication.dosageTimes.first
                    medication.dosageTimes = []
                } else if medication.dosageTimes.isEmpty {
                    // If no times remain (shouldn't happen but safety check), delete medication
                    modelContext.delete(medication)
                } else {
                    // Update dosage to match remaining times
                    medication.dosage = medication.dosageTimes.count
                }
            }
            
            try? modelContext.save()
        }
    }
}

// MARK: - MEALS CARD

struct MealsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 22))
                    .foregroundColor(.ourDarkGrey)
                
                Text("Meals")
                    .font(.headline)
                    .foregroundColor(.ourDarkGrey)
                
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(.systemGray6))
        )
        .frame(maxWidth: .infinity, minHeight: 90, alignment: .center)
    }
}

// MARK: - EMOTIONAL STATUS CARD

struct EmotionalStatusCard: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @State private var viewModel = EmotionalStatusViewModel()
    @Query private var emotionLogs: [EmotionLog]
    
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.ourDarkGrey)
                
                Text("Emotional Status")
                    .font(.headline)
                    .foregroundColor(.ourDarkGrey)
                
                Spacer()
            }
            
            Text("How is the patient feeling today?")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // ⬇️ Emotion chips
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Emotion.allCases, id: \.self) { emotion in
                    let isSelected = viewModel.selectedEmotions.contains(emotion)
                    
                    Button {
                        viewModel.toggleEmotion(emotion)
                        
                        if viewModel.isFormComplete {
                            viewModel.saveEntry(context: modelContext)
                        }
                        
                    } label: {
                        HStack {
                            Text(emotion.icon)
                                .font(.title3)
                            Text(emotion.localizedTitle)
                                .font(.subheadline.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(isSelected ? Color.ourDarkGrey : Color(.systemBackground))
                        .foregroundColor(textColor(isSelected: isSelected))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    isSelected ? Color.clear : Color.gray.opacity(0.2),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 3, y: 1)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(.systemGray6))
        )
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private func textColor(isSelected: Bool) -> Color {
        if isSelected {
            return colorScheme == .dark ? .black : .white
        } else {
            return .primary
        }
    }
}


#Preview {
    MainPage()
        .modelContainer(for: [Medication.self, MedicationLog.self], inMemory: true)
}
