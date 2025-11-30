//
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

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    VStack {
                        Spacer()
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
                            onSelect: viewModel.selectTime
                        )
                        Spacer()
                        ConfirmButton(
                            isEnabled: viewModel.isConfirmEnabled,
                            action: {
                                viewModel.confirmMedication()
                                dismiss()
                            }
                        )
                    }
                    .padding(25)
                } else {
                    // Show loading indicator while the viewModel is loading
                    ProgressView()
                }
            }
            .toolbar {
                //Back button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                    }
                }
                // Title
                ToolbarItem(placement: .principal) {
                    Text("Add Medication").font(.title.bold())
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
    let onSelect: (TimeOfDay) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Time").font(.title3).bold()
            HStack {
                TimeButton(
                    title: "Morning",
                    icon: "sun.max.fill",
                    iconColor: .yellow,
                    isSelected: selectedTime == .morning
                ) {
                    onSelect(.morning)
                }
                
                Spacer()
                
                TimeButton(
                    title: "Night",
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
}

struct TimeButton: View {
    let title: String
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
        .shadow(radius: isEnabled ? 5 : 0)        .disabled(!isEnabled)
    }
}

#Preview {
    MedicationView()
        .modelContainer(for: Medication.self)
}
