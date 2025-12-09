//
//  MedicationCard.swift
//  Minder
//
//  Created by Areeg Altaiyah on 01/12/2025.
//
import SwiftUI

struct MedicationCard: View {
    let medicationName: String
    let timeOfDay: TimeOfDay
    @State private var isSelected: Bool = false
    var onDelete: (() -> Void)? = nil
    
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
                        // Directly delegate to parent to present a single confirmation
                        onDelete?()
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
            }
        }
    }
}

// For use with SwiftData model - with explicit time context
extension MedicationCard {
    init(medication: Medication, displayTime: TimeOfDay, isSelected: Bool = false, onDelete: (() -> Void)? = nil) {
        self.medicationName = medication.name
        self.timeOfDay = displayTime
        self._isSelected = State(initialValue: isSelected)
        self.onDelete = onDelete
    }
}

#Preview {
    VStack(spacing: 20) {
        MedicationCard(medicationName: "Aspirin", timeOfDay: .morning, onDelete: {
            print("Delete tapped")
        })
        MedicationCard(medicationName: "Vitamin D", timeOfDay: .night, onDelete: {
            print("Delete tapped")
        })
    }
    .padding()
}
