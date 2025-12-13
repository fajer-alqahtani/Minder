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
                    
                    .alert(
                        String(localized: "medication.alert.title"),
                        isPresented: $showConfirmAlert
                    ) {
                        Button(String(localized: "common.ok")) {
                            viewModel.confirmMedication()
                            dismiss()
                        }
                    } message: {
                        let format = String(localized: "medication.alert.message")
                        let message = String(format: format, locale: .current, viewModel.medicineName, viewModel.dosage)
                        Text(message)
                    }

                } else {
                    ProgressView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Add Medication").font(.title2.bold())
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
            if dosage < 2 {
                Text("Time").font(.title3).bold()
            }
            
            if dosage >= 2 {
                ForEach(Array(0..<max(0, dosage)), id: \.self) { index in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(ordinalText(for: index + 1)) Dosage Time")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        TimeButtonGrid(
                            selectedTime: index < selectedTimes.count ? selectedTimes[index] : nil
                        ) { time in
                            onSelectForDosage(index, time)
                        }
                    }
                    .padding(.bottom, 10)
                }
            } else {
                TimeButtonGrid(selectedTime: selectedTime) { time in
                    onSelect(time)
                }
            }
        }
        .onChange(of: dosage) { oldValue, newValue in
            if newValue >= 2 {
                selectedTimes = Array(repeating: nil, count: newValue)
            } else {
                selectedTimes = []
            }
        }
    }
    
    private func ordinalText(for number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}


// MARK: - Time Button Grid (2x2 layout)

struct TimeButtonGrid: View {
    let selectedTime: TimeOfDay?
    let onSelect: (TimeOfDay) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Top row: Morning & Afternoon
            HStack(spacing: 12) {
                TimeButton(
                    title: TimeOfDay.morning.titleKey,
                    icon: TimeOfDay.morning.icon,
                    iconColor: TimeOfDay.morning.color,
                    isSelected: selectedTime == .morning
                ) {
                    onSelect(.morning)
                }
                
                TimeButton(
                    title: TimeOfDay.afternoon.titleKey,
                    icon: TimeOfDay.afternoon.icon,
                    iconColor: TimeOfDay.afternoon.color,
                    isSelected: selectedTime == .afternoon
                ) {
                    onSelect(.afternoon)
                }
            }
            
            // Bottom row: Evening & Night
            HStack(spacing: 12) {
                TimeButton(
                    title: TimeOfDay.evening.titleKey,
                    icon: TimeOfDay.evening.icon,
                    iconColor: TimeOfDay.evening.color,
                    isSelected: selectedTime == .evening
                ) {
                    onSelect(.evening)
                }
                
                TimeButton(
                    title: TimeOfDay.night.titleKey,
                    icon: TimeOfDay.night.icon,
                    iconColor: TimeOfDay.night.color,
                    isSelected: selectedTime == .night
                ) {
                    onSelect(.night)
                }
            }
        }
    }
}


// MARK: - Time Button

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
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(Color.primary)
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
                    .font(.subheadline).bold()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(isSelected ? iconColor.opacity(0.2) : Color.accentColor.opacity(0.1))
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(isSelected ? iconColor : Color.clear, lineWidth: 3)
        )
    }
}


// MARK: - Confirm Button

struct ConfirmButton: View {
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(String(localized: "confirm.button.title"))
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
