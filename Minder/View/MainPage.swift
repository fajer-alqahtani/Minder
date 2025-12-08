import SwiftUI
import SwiftData

struct MainPage: View {
    @StateObject private var viewModel = MainPageViewModel()
    @State private var showMedications = true      // open by default (like the mock)
    @Query private var medications: [Medication]
    
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
                        
                        // Top-right icon button
                        Button {
                            print("Header icon tapped")
                        } label: {
                            NavigationLink(destination: SummaryView()) {
                                Image(systemName: "text.line.3.summary")
                                    .foregroundColor(.ourDarkGrey)
                                    .padding(10)
                            }
                            .buttonStyle(.plain)

                        }
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
            }
        }
    }
}

// MARK: - MEDICATIONS CARD VIEW

struct MedicationsCard: View {
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
                                    MedicationCard(medication: medication, displayTime: .morning)
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
                                    MedicationCard(medication: medication, displayTime: .night)
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

// MARK: - EMOTIONAL STATUS CARD  ✅ uses Emotion + ViewModel

struct EmotionalStatusCard: View {
    // Local view model so the chips behave like in EmotionalStatusView
    @State private var viewModel = EmotionalStatusViewModel()
    
    // 2-column layout similar to your full emotional screen
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
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
            
            // Emotion chips – same logic as in EmotionalStatusView
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Emotion.allCases, id: \.self) { emotion in
                    let isSelected = viewModel.selectedEmotions.contains(emotion)
                    
                    Button {
                        viewModel.toggleEmotion(emotion)
                    } label: {
                        HStack {
                            Text(emotion.icon)
                                .font(.title3)
                            Text(emotion.localizedTitle)
                                .font(.subheadline.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(isSelected ? Color.ourDarkGrey : Color.white)
                        .foregroundColor(isSelected ? .white : .ourDarkGrey)
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
}

#Preview {
    MainPage()
        .modelContainer(for: Medication.self, inMemory: true)
}
