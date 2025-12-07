///
//  MedicationView.swift
//  Minder
//
//  Created by Areeg Altaiyah on 24/11/2025.


import SwiftUI
import SwiftData

struct MedicationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: MedicationViewModel?
    @State private var showConfirmAlert = false

    var body: some View {
        NavigationStack {
            
            Group {
                if let viewModel {
                    VStack {
                        ScrollView {
                            VStack {
                                MedicineNameField(name: Binding(
                                    get: { viewModel.medicineName },
                                    set: { viewModel.medicineName = $0 }
                                ))
                                
                                MedicineDosageControl(dosage: Binding(
                                    get: { viewModel.dosage },
                                    set: { viewModel.dosage = $0 }
                                ))
                                
                                MedicineTimeSelector(
                                    selectedTime: Binding(
                                        get: { viewModel.selectedTime },
                                        set: { viewModel.selectedTime = $0 }
                                    ),
                                    selectedTimes: Binding(
                                        get: { viewModel.selectedTimes },
                                        set: { viewModel.selectedTimes = $0 }
                                    ),
                                    dosage: Binding(
                                        get: { viewModel.dosage },
                                        set: { viewModel.dosage = $0 }
                                    ),
                                    onSelect: viewModel.selectTime,
                                    onSelectForDosage: viewModel.selectTimeForDosage
                                )
                            }
                            .padding(.bottom, 20)
                        }
                        
                        ConfirmButton(
                            isEnabled: viewModel.isConfirmEnabled,
                            action: {
                                showConfirmAlert = true
                            }
                        )
                        .padding(.bottom, 10)
                    }
                    .padding(25)
                    
                    .alert("Medication Added", isPresented: $showConfirmAlert) {
                        Button("OK") {
                            viewModel.confirmMedication()
                            dismiss()
                        }
                    } message: {
                        Text("\(viewModel.medicineName) added successfully!\nDosage: \(viewModel.dosage) pill(s)")
                    }
                } else {
                    // Show loading indicator while the viewModel is loading
                    ProgressView()
                }
            }
            .toolbar {
                // Title
                ToolbarItem(placement: .principal) {
                    Text("Add Medication").font(.title2.bold())
                        .foregroundColor(.minderDark)
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = MedicationViewModel(modelContext: modelContext)
            }
        }
    }
}





// MARK: - Subviews
struct MedicineNameField: View {
    @Binding var name: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Medicine Name").font(.title3).bold()
            TextField("", text: $name)
                .padding()
                .background(Color.accentColor.opacity(0.10))
                .cornerRadius(12)
        }
        .padding(.bottom, 20)
    }
}

struct MedicineDosageControl: View {
    @Binding var dosage: Int
    
    var body: some View {
        HStack {
            Text("Dosage").font(.title3).bold()
            LabeledStepper("", description: "", value: $dosage)
                .font(.title3).bold()
        }
        .padding(.bottom, 20)
    }
}

struct MedicineTimeSelector: View {
    @Binding var selectedTime: TimeOfDay?
    @Binding var selectedTimes: [TimeOfDay?]
    @Binding var dosage: Int
    let onSelect: (TimeOfDay) -> Void
    let onSelectForDosage: (Int, TimeOfDay) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Only show "Time" title when dosage is 1
            if dosage < 2 {
                Text("Time").font(.title3).bold()
            }
            
            if dosage >= 2 {
                // Show multiple time selectors for each dose
                ForEach(0..<dosage, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(ordinalText(for: index + 1)) Dosage Time")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        HStack {
                            TimeButton(
                                title: TimeOfDay.morning.localizedTitle,
                                icon: "sun.max.fill",
                                iconColor: .yellow,
                                isSelected: index < selectedTimes.count && selectedTimes[index] == .morning
                            ) {
                                onSelectForDosage(index, .morning)
                            }
                            
                            Spacer()
                            
                            TimeButton(
                                title: TimeOfDay.night.localizedTitle,
                                icon: "moon.fill",
                                iconColor: .accentColor,
                                isSelected: index < selectedTimes.count && selectedTimes[index] == .night
                            ) {
                                onSelectForDosage(index, .night)
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                    .padding(.bottom, 10)
                }
            } else {
                // Show original single time selector for dosage = 1
                HStack {
                    TimeButton(
                        title: TimeOfDay.morning.localizedTitle,
                        icon: "sun.max.fill",
                        iconColor: .yellow,
                        isSelected: selectedTime == .morning
                    ) {
                        onSelect(.morning)
                    }
                    
                    Spacer()
                    
                    TimeButton(
                        title: TimeOfDay.night.localizedTitle,
                        icon: "moon.fill",
                        iconColor: .accentColor,
                        isSelected: selectedTime == .night
                    ) {
                        onSelect(.night)
                    }
                }
                .padding(.horizontal, 25)
            }
        }
        .onChange(of: dosage) { oldValue, newValue in
            // Initialize selectedTimes array when dosage changes
            if newValue >= 2 {
                selectedTimes = Array(repeating: nil, count: newValue)
            } else {
                selectedTimes = []
            }
        }
    }
    
    // Helper function to convert numbers to ordinal text
    private func ordinalText(for number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}


struct TimeButton: View {
    let title: LocalizedStringKey
    let icon: String
    let iconColor: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label {
                Text(title)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(Color.primary)
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
                    .font(.title3).bold()
            }
        }
        .frame(width: 148, height: 56)
        .background(isSelected ? iconColor.opacity(0.2) : Color.accentColor.opacity(0.1))
        .cornerRadius(65)
        .overlay(
            RoundedRectangle(cornerRadius: 65)
                .stroke(isSelected ? iconColor : Color.clear, lineWidth: 3)
        )
    }
}

struct ConfirmButton: View {
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("CONFIRM")
                .font(.title2)
                .bold()
                .foregroundStyle(Color.white)
        }
        .frame(width: 354, height: 56)
        .background(isEnabled ? Color.ourGrey : Color.gray.opacity(0.3))
        .cornerRadius(43)
        .shadow(radius: isEnabled ? 5 : 0)
        .disabled(!isEnabled)
    }
}

#Preview {
    MedicationView()
        .modelContainer(for: Medication.self, inMemory: true)
}
