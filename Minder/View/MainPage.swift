import SwiftUI
import SwiftData

struct MainPage: View {
    @StateObject private var viewModel = MainPageViewModel()
    @State private var showMedications = false
    @Query private var medications: [Medication]
    
    // Group medications by time of day
    private var morningMeds: [Medication] {
        medications.filter { $0.timeOfDay == .morning }
    }

    private var nightMeds: [Medication] {
        medications.filter { $0.timeOfDay == .night }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack {
                    // MAIN CONTENT
                    VStack {
                        ZStack(alignment: .topTrailing) {
                            // Background card + overlays
                            RoundedRectangle(cornerRadius: 50)
                                .fill(Color.accentColor)
                                .frame(width: 387, height: 340)
                            
                            // MinderM + Date under it
                                .overlay(alignment: .topLeading) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Image("MinderMark")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 50, height: 100)
                                        
                                        Text(viewModel.formattedDate)
                                            .font(.title3)
                                            .bold()
                                            .foregroundColor(.white.opacity(0.9))
                                        
                                        // greeting
                                        Text(viewModel.greeting)
                                            .font(.title)
                                            .foregroundColor(.ourDarkGrey)
                                            .padding(.top, 30)
                                        
                                        Text("Let's start today's record.")
                                            .font(.title)
                                            .bold()
                                            .foregroundColor(.ourDarkGrey)
                                    }
                                    .padding(.leading, 20)
                                    .padding(.top, 50)
                                }
                        }
                        .padding(.top, -70)
                        
                        Spacer()
                    }
                    .padding()
                    
                    VStack(spacing: 12) {
                        // MEDICATIONS SECTION - Unified expanding card
                        VStack(spacing: 0) {
                            // MEDICATIONS BUTTON (TOP PART)
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showMedications.toggle()
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "pills.fill")
                                        .font(.system(size: 20))

                                    Text("Medications")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.ourDarkGrey)

                                    Spacer()
                                    
                                    // Debug badge showing medication count
                                    Text("\(medications.count)")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue)
                                        .clipShape(Capsule())

                                    Image(systemName: showMedications ? "chevron.down" : "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 26)
                                .padding(.horizontal, 20)
                                .frame(width: 354)
                            }
                            .buttonStyle(.plain)
                            
                            // MEDICATIONS CONTENT (EXPANDING PART)
                            if showMedications {
                                VStack(alignment: .leading, spacing: 16) {
                                    // Morning Section
                                    if !morningMeds.isEmpty {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Morning")
                                                .font(.headline)
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal, 20)
                                            
                                            LazyVGrid(columns: [
                                                GridItem(.flexible(), spacing: 8),
                                                GridItem(.flexible(), spacing: 8)
                                            ], spacing: 8) {
                                                ForEach(morningMeds) { medication in
                                                    MedicationCard(medication: medication)
                                                }
                                            }
                                            .padding(.horizontal, 20)
                                        }
                                    }
                                    
                                    // Night Section
                                    if !nightMeds.isEmpty {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Night")
                                                .font(.headline)
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal, 20)
                                            
                                            LazyVGrid(columns: [
                                                GridItem(.flexible(), spacing: 8),
                                                GridItem(.flexible(), spacing: 8)
                                            ], spacing: 8) {
                                                ForEach(nightMeds) { medication in
                                                    MedicationCard(medication: medication)
                                                }
                                            }
                                            .padding(.horizontal, 20)
                                        }
                                    }
                                    
                                    // Empty state
                                    if medications.isEmpty {
                                        VStack(spacing: 12) {
                                            Image(systemName: "pills.circle")
                                                .font(.system(size: 40))
                                                .foregroundColor(.secondary)
                                            
                                            Text("No medications added yet")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 30)
                                    }
                                    
                                    // Add button
                                    HStack {
                                        Spacer()
                                        NavigationLink(destination: MedicationView()) {
                                            ZStack {
                                                Rectangle()
                                                    .fill(Color.ourDarkGrey)
                                                    .frame(width: 66, height: 31)
                                                    .cornerRadius(28)
                                                
                                                Image(systemName: "plus")
                                                    .foregroundColor(.white)
                                                    .font(.title3)
                                            }
                                        }
                                        .padding(.trailing, 20)
                                    }
                                }
                                .padding(.vertical, 16)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(.systemGray6))
                        )
                        .frame(width: 354)
                        .padding(.top, 240)

                        NavigationLink(
                            destination: Text("Meals Page")
                        ) {
                            HStack(spacing: 12) {
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 20))

                                Text("Meals")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.ourDarkGrey)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 26)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color(.systemGray6))
                            )
                            .frame(width: 354)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, showMedications ? -4 : 30)
                        
                        NavigationLink(
                            destination: EmotionalStatusView()
                        ) {
                            HStack(spacing: 12) {
                                Image(systemName: "heart.text.square.fill")
                                    .font(.system(size: 20))

                                Text("Emotional Status")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.ourDarkGrey)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 26)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color(.systemGray6))
                            )
                            .frame(width: 354)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 30)
                        
                        NavigationLink(
                            destination: Text("Summary Trial Page")
                        ) {
                            Text("Summary")
                                .font(Font.title)
                                .foregroundColor(.white)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 100)
                                .background(Color(.ourGrey))
                                .clipShape(Capsule())
                        }
                        .padding(.top, 80)
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 70)
                }
            }
            .onAppear {
                print("📱 MainPage appeared - Total medications: \(medications.count)")
                print("🌅 Morning meds: \(morningMeds.count)")
                print("🌙 Night meds: \(nightMeds.count)")
            }
        }
    }
}

#Preview {
    MainPage()
        .modelContainer(for: Medication.self, inMemory: true)
}
