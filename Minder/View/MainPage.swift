import SwiftUI
import SwiftData

struct MainPage: View {
    @StateObject private var viewModel = MainPageViewModel()
    @State private var showMedications = true      // open by default
    @Query private var medications: [Medication]
    @Query private var emotionLogs: [EmotionLog]
    
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
                    
                    // MARK: - EMOTIONAL STATUS CARD  ✅ updated
                    EmotionalStatusCard()
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
                .padding(.bottom, 24)
            }
            .onAppear {
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
                
                
                // ⭐ ADD THIS TO CHECK IF EMOTION LOGS ARE BEING SAVED
                print("🧠 Emotion logs stored:", emotionLogs.count)
                for log in emotionLogs {
                    print("  • emotions:", log.emotions.map { $0.localizedTitle })
                    print("    intensity:", log.intensity.rawValue)
                    print("    timestamp:", log.timestamp)
                }
            }

        }
    }
}

// MARK: - MEDICATIONS CARD VIEW

struct MedicationsCard: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var showMedications: Bool
    let medications: [Medication]
    let morningMeds: [Medication]
    let nightMeds: [Medication]
    @State private var showDeleteAlert = false
    @State private var medicationToDelete: Medication?
    @State private var timeToDelete: TimeOfDay?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Header row
            HStack(spacing: 12) {
                Image(systemName: "pills")
                    .font(.system(size: 22))
                    .foregroundColor(.ourDarkGrey)

                // "Medications" → localizable key
                Text(String(localized: "medications.card.title"))
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

                    // Morning section
                    if !morningMeds.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {

                            // "Morning" → use TimeOfDay.morning.titleKey
                            Text(TimeOfDay.morning.titleKey)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.secondary)

                            VStack(spacing: 8) {
                                ForEach(morningMeds) { medication in
                                    MedicationCard(
                                        medication: medication,
                                        displayTime: .morning,
                                        onDelete: {
                                            medicationToDelete = medication
                                            timeToDelete = .morning
                                            showDeleteAlert = true
                                        }
                                    )
                                }
                            }
                        }
                    }

                    // Night section
                    if !nightMeds.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {

                            // "Night" → use TimeOfDay.night.titleKey
                            Text(TimeOfDay.night.titleKey)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.secondary)

                            VStack(spacing: 8) {
                                ForEach(nightMeds) { medication in
                                    MedicationCard(
                                        medication: medication,
                                        displayTime: .night,
                                        onDelete: {
                                            medicationToDelete = medication
                                            timeToDelete = .night
                                            showDeleteAlert = true
                                        }
                                    )
                                }
                            }
                        }
                    }

                    // Empty state
                    if medications.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "pills.circle")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)

                            // "No medications added yet" → localizable key
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
                if let med = medicationToDelete, let time = timeToDelete {
                    deleteMedicationFromTime(med, timeToRemove: time)
                }
            }
        } message: {
            Text(String(localized: "medications.delete.message"))
        }



    }

    // Smart delete function - handles single time removal or full deletion
    private func deleteMedicationFromTime(_ medication: Medication, timeToRemove: TimeOfDay) {
        withAnimation {
            if medication.dosage < 2 {
                modelContext.delete(medication)
            } else {
                medication.dosageTimes.removeAll { $0 == timeToRemove }

                if medication.dosageTimes.count == 1 {
                    medication.dosage = 1
                    medication.timeOfDay = medication.dosageTimes.first
                    medication.dosageTimes = []
                } else if medication.dosageTimes.isEmpty {
                    modelContext.delete(medication)
                } else {
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

// MARK: - EMOTIONAL STATUS CARD  ✅ uses Emotion + ViewModel + Color Scheme Fix

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
        .modelContainer(for: Medication.self, inMemory: true)
}
