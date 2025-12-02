//
//  Rectangle.swift
//  Minder
//
//  Created by Areeg Altaiyah on 01/12/2025.
//
import SwiftUI

struct MedicationCard: View {
    let medicationName: String
    let timeOfDay: TimeOfDay
    @State private var isSelected: Bool = false
    
    var body: some View {
        ZStack {
            // The rounded rectangle
            Rectangle()
                .cornerRadius(50)
                .foregroundStyle(timeOfDay == .morning ? Color.ourYellow.opacity(0.2): Color.ourGrey.opacity(0.2))
            
            HStack(spacing: 1) {
                // The circle with checkmark
                ZStack {
                    Circle()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(isSelected ? Color.ourGrey : (timeOfDay == .morning) ? Color.ourYellow.opacity(0.6) : Color.ourGrey.opacity(0.2))
                    
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
                    .foregroundStyle(timeOfDay == .morning ? Color.ourYellow : .secondary)
                
                // Medication name
                Text(medicationName)
                    .font(.system(.footnote, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
               
                Spacer()

                
            }
            .padding(.horizontal, 8)
        }
        .frame(width: 133, height: 40)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isSelected.toggle()
            }
        }
    }
}

// For use with SwiftData model
extension MedicationCard {
    init(medication: Medication, isSelected: Bool = false) {
        self.medicationName = medication.name
        self.timeOfDay = medication.timeOfDay ?? .morning
        self._isSelected = State(initialValue: isSelected)
    }
}

#Preview {
    VStack(spacing: 20) {
        MedicationCard(medicationName: "Aspirin", timeOfDay: .morning)
        MedicationCard(medicationName: "Vitamin D", timeOfDay: .night)
    }
}
