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
                                .foregroundColor(.black.opacity(0.9))
                        }
                        
                        Spacer()
                        
                        // Top-right icon button
                        Button {
                            print("Header icon tapped")
                        } label: {
                            NavigationLink(destination: SummaryView()) {
                                Image(systemName: "text.line.3.summary")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.ourDarkGrey)
                                    )
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
                    
                    // MARK: - MEALS CARD (layout only for now)
                    MealsCard()
                    
                    // MARK: - EMOTIONAL STATUS CARD (layout only for now)
                    EmotionalStatusCard()
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)   // this makes card width ≈ 354 on most iPhones
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
            
            // Header row (pills icon + title + add + toggle)
            HStack(spacing: 12) {
                // Left icon (like in mock)
                Image(systemName: "pills")
                    .font(.system(size: 22))
                
                Text("Medications")
                    .font(.headline)
                    .foregroundColor(.ourDarkGrey)
                
                Spacer()
                
                // Add button (can be NavigationLink later)
                NavigationLink(destination: MedicationView()) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.ourDarkGrey)
                }
                
//                // Collapse/expand chevron (optional)
//                Button {
//                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
//                        showMedications.toggle()
//                    }
//                } label: {
//                    Image(systemName: showMedications ? "chevron.up" : "chevron.down")
//                        .font(.system(size: 14))
//                        .foregroundColor(.secondary)
//                        .padding(.leading, 4)
//                }
            }
            
            if showMedications {
                // Content
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
        // This makes the card "≈354 x 211" when content is small,
        // and lets it grow naturally when there are many items.
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
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 22))
                
                Text("Emotional Status")
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




#Preview {
    MainPage()
        .modelContainer(for: Medication.self, inMemory: true)
}
