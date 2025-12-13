import SwiftUI
import SwiftData

// Helper struct to represent individual doses
struct DoseEntry: Identifiable {
    let id = UUID()
    let medication: Medication
    let timeOfDay: TimeOfDay
    let doseIndex: Int
}

struct MainPage: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = MainPageViewModel()
    @State private var showMedications = true
    @AppStorage("lastCheckedDateString") private var lastCheckedDateString: String = ""
    @Query private var medications: [Medication]
    @Query private var emotionLogs: [EmotionLog]
    @Query private var medicationLogs: [MedicationLog]
    
    private var morningDoses: [DoseEntry] {
        getDoses(for: .morning)
    }
    
    private var afternoonDoses: [DoseEntry] {
        getDoses(for: .afternoon)
    }
    
    private var eveningDoses: [DoseEntry] {
        getDoses(for: .evening)
    }
    
    private var nightDoses: [DoseEntry] {
        getDoses(for: .night)
    }
    
    private func getDoses(for time: TimeOfDay) -> [DoseEntry] {
        var doses: [DoseEntry] = []
        
        for medication in medications {
            if medication.dosage < 2 {
                if medication.timeOfDay == time {
                    doses.append(DoseEntry(
                        medication: medication,
                        timeOfDay: time,
                        doseIndex: 0
                    ))
                }
            } else {
                for (index, medTime) in medication.dosageTimes.enumerated() {
                    if medTime == time {
                        doses.append(DoseEntry(
                            medication: medication,
                            timeOfDay: time,
                            doseIndex: index
                        ))
                    }
                }
            }
        }
        
        return doses
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
                        
                        NavigationLink(destination: SummaryView()) {
                            Image(systemName: "heart.text.square.fill")
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
                        morningDoses: morningDoses,
                        afternoonDoses: afternoonDoses,
                        eveningDoses: eveningDoses,
                        nightDoses: nightDoses,
                        medicationLogs: medicationLogs
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
                checkAndSaveYesterdayMedications()
                
                print("📱 MainPage appeared - Total medications: \(medications.count)")
                
                for med in medications {
                    if med.dosage < 2 {
                        print("   - \(med.name): \(med.amount)\(med.unit.displayName), \(med.dosage) pill, time: \(med.timeOfDay?.rawValue ?? "nil")")
                    } else {
                        let times = med.dosageTimes.map { $0.rawValue }.joined(separator: ", ")
                        print("   - \(med.name): \(med.amount)\(med.unit.displayName), \(med.dosage) pills, times: [\(times)]")
                    }
                }
                
                print("🌅 Morning doses: \(morningDoses.count)")
                print("☀️ Afternoon doses: \(afternoonDoses.count)")
                print("🌆 Evening doses: \(eveningDoses.count)")
                print("🌙 Night doses: \(nightDoses.count)")
                
                print("🧠 Emotion logs stored:", emotionLogs.count)
                for log in emotionLogs {
                    print("  • emotions:", log.emotions.map { $0.localizedTitle })
                    print("    intensity:", log.intensity.rawValue)
                    print("    timestamp:", log.timestamp)
                }
            }
        }
    }
    
    private func checkAndSaveYesterdayMedications() {
        let today = Calendar.current.startOfDay(for: Date())
        let todayString = ISO8601DateFormatter().string(from: today)
        
        if lastCheckedDateString == todayString {
            return
        }
        
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) else { return }
        
        print("🌅 NEW DAY DETECTED - Processing yesterday's medications...")
        
        for medication in medications {
            var timesToCheck: [(TimeOfDay, Int)] = []
            
            if medication.dosage < 2 {
                if let time = medication.timeOfDay {
                    timesToCheck.append((time, 0))
                }
            } else {
                for (index, time) in medication.dosageTimes.enumerated() {
                    timesToCheck.append((time, index))
                }
            }
            
            for (time, doseIndex) in timesToCheck {
                let hasLog = medicationLogs.contains { log in
                    log.medicationId == medication.id &&
                    log.timeOfDay == time &&
                    log.doseIndex == doseIndex &&
                    Calendar.current.isDate(log.date, inSameDayAs: yesterday)
                }
                
                if !hasLog {
                    let missedLog = MedicationLog(
                        medicationName: medication.name,
                        medicationId: medication.id,
                        timeOfDay: time,
                        doseIndex: doseIndex,
                        amount: medication.amount,
                        unit: medication.unit,
                        wasTaken: false,
                        date: yesterday
                    )
                    modelContext.insert(missedLog)
                    print("❌ Created 'not taken' log: \(medication.name) \(medication.amount)\(medication.unit.displayName) - \(time.rawValue) dose #\(doseIndex + 1) for yesterday")
                }
            }
        }
        
        try? modelContext.save()
        lastCheckedDateString = todayString
        print("✅ Finished processing yesterday's medications")
    }
}

// MARK: - MEDICATIONS CARD VIEW

struct MedicationsCard: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var showMedications: Bool
    let medications: [Medication]
    let morningDoses: [DoseEntry]
    let afternoonDoses: [DoseEntry]
    let eveningDoses: [DoseEntry]
    let nightDoses: [DoseEntry]
    let medicationLogs: [MedicationLog]
    @State private var showDeleteAlert = false
    @State private var medicationToDelete: Medication?
    @State private var doseIndexToDelete: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack(spacing: 12) {
                Image(systemName: "pills.fill")
                    .font(.title2)
                    .foregroundColor(.ourDarkGrey)

                Text(String(localized: "medications.card.title"))
                    .font(.headline)
                    .foregroundColor(.ourDarkGrey)

                Spacer()

                NavigationLink(destination: MedicationView()) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.ourDarkGrey)
                }
            }

            if showMedications {
                VStack(alignment: .leading, spacing: 16) {

                    if !morningDoses.isEmpty {
                        DoseTimeSection(
                            timeOfDay: .morning,
                            doses: morningDoses,
                            medicationLogs: medicationLogs,
                            modelContext: modelContext,
                            onDelete: { dose in
                                medicationToDelete = dose.medication
                                doseIndexToDelete = dose.doseIndex
                                showDeleteAlert = true
                            }
                        )
                    }
                    
                    if !afternoonDoses.isEmpty {
                        DoseTimeSection(
                            timeOfDay: .afternoon,
                            doses: afternoonDoses,
                            medicationLogs: medicationLogs,
                            modelContext: modelContext,
                            onDelete: { dose in
                                medicationToDelete = dose.medication
                                doseIndexToDelete = dose.doseIndex
                                showDeleteAlert = true
                            }
                        )
                    }
                    
                    if !eveningDoses.isEmpty {
                        DoseTimeSection(
                            timeOfDay: .evening,
                            doses: eveningDoses,
                            medicationLogs: medicationLogs,
                            modelContext: modelContext,
                            onDelete: { dose in
                                medicationToDelete = dose.medication
                                doseIndexToDelete = dose.doseIndex
                                showDeleteAlert = true
                            }
                        )
                    }

                    if !nightDoses.isEmpty {
                        DoseTimeSection(
                            timeOfDay: .night,
                            doses: nightDoses,
                            medicationLogs: medicationLogs,
                            modelContext: modelContext,
                            onDelete: { dose in
                                medicationToDelete = dose.medication
                                doseIndexToDelete = dose.doseIndex
                                showDeleteAlert = true
                            }
                        )
                    }

                    if medications.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "pills.circle")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)

                            Text(String(localized: "medications.card.empty"))
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
        .alert(
            String(localized: "medication.delete.title"),
            isPresented: $showDeleteAlert
        ) {
            Button(String(localized: "common.cancel"), role: .cancel) { }

            Button(String(localized: "medication.delete.confirm"), role: .destructive) {
                if let med = medicationToDelete, let doseIndex = doseIndexToDelete {
                    deleteDose(med, doseIndex: doseIndex)
                }
            }
        } message: {
            Text(String(localized: "medications.delete.message"))
        }
    }

    private func deleteDose(_ medication: Medication, doseIndex: Int) {
        withAnimation {
            if medication.dosage < 2 {
                modelContext.delete(medication)
            } else {
                medication.dosageTimes.remove(at: doseIndex)
                medication.dosage = medication.dosageTimes.count
                
                if medication.dosageTimes.count == 1 {
                    medication.timeOfDay = medication.dosageTimes.first
                    medication.dosageTimes = []
                    medication.dosage = 1
                } else if medication.dosageTimes.isEmpty {
                    modelContext.delete(medication)
                }
            }

            try? modelContext.save()
        }
    }
}

// MARK: - Dose Time Section

struct DoseTimeSection: View {
    let timeOfDay: TimeOfDay
    let doses: [DoseEntry]
    let medicationLogs: [MedicationLog]
    let modelContext: ModelContext
    let onDelete: (DoseEntry) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: timeOfDay.icon)
                    .foregroundColor(timeOfDay.color)
                    .font(.subheadline)
                
                Text(timeOfDay.titleKey)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 8) {
                ForEach(doses) { dose in
                    MedicationCardWrapper(
                        dose: dose,
                        medicationLogs: medicationLogs,
                        modelContext: modelContext,
                        onDelete: {
                            onDelete(dose)
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Medication Card Wrapper

struct MedicationCardWrapper: View {
    let dose: DoseEntry
    let medicationLogs: [MedicationLog]
    let modelContext: ModelContext
    let onDelete: () -> Void
    
    @State private var isSelected: Bool = false
    
    var body: some View {
        MedicationCard(
            medicationName: displayName,
            medicationId: dose.medication.id,
            timeOfDay: dose.timeOfDay,
            doseIndex: dose.doseIndex,
            amount: dose.medication.amount,
            unit: dose.medication.unit,
            isSelected: $isSelected,
            onToggle: { newValue in
                handleToggle(newValue)
            },
            onDelete: onDelete
        )
        .onAppear {
            loadLogState()
        }
    }
    
    private var displayName: String {
        if dose.medication.dosage >= 2 {
            let sameTimeBefore = dose.medication.dosageTimes.prefix(dose.doseIndex + 1)
                .filter { $0 == dose.timeOfDay }
                .count
            return "\(dose.medication.name) (\(ordinal(sameTimeBefore)))"
        }
        return dose.medication.name
    }
    
    private func ordinal(_ n: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: n)) ?? "\(n)"
    }
    
    private func loadLogState() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let log = medicationLogs.first(where: { log in
            log.medicationId == dose.medication.id &&
            log.timeOfDay == dose.timeOfDay &&
            log.doseIndex == dose.doseIndex &&
            Calendar.current.isDate(log.date, inSameDayAs: today)
        }) {
            isSelected = log.wasTaken
        } else {
            isSelected = false
        }
    }
    
    private func handleToggle(_ newValue: Bool) {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let existingLog = medicationLogs.first(where: { log in
            log.medicationId == dose.medication.id &&
            log.timeOfDay == dose.timeOfDay &&
            log.doseIndex == dose.doseIndex &&
            Calendar.current.isDate(log.date, inSameDayAs: today)
        }) {
            existingLog.wasTaken = newValue
            print("📝 Updated log: \(dose.medication.name) \(dose.medication.amount)\(dose.medication.unit.displayName) dose #\(dose.doseIndex + 1) - \(newValue ? "taken" : "not taken")")
        } else {
            let newLog = MedicationLog(
                medicationName: dose.medication.name,
                medicationId: dose.medication.id,
                timeOfDay: dose.timeOfDay,
                doseIndex: dose.doseIndex,
                amount: dose.medication.amount,
                unit: dose.medication.unit,
                wasTaken: newValue,
                date: today
            )
            modelContext.insert(newLog)
            print("✅ Created log: \(dose.medication.name) \(dose.medication.amount)\(dose.medication.unit.displayName) dose #\(dose.doseIndex + 1) - \(newValue ? "taken" : "not taken")")
        }
        
        try? modelContext.save()
    }
}

// MARK: - MEALS CARD

struct MealsCardPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "fork.knife")
                    .font(.title2)
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
                Image(systemName: "apple.meditate")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.ourDarkGrey)
                
                Text("Emotional Status")
                    .font(.headline)
                    .foregroundColor(.ourDarkGrey)
                
                Spacer()
            }
            
            Text("How is the patient feeling today?")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
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
