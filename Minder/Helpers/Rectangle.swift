import SwiftUI

struct MedicationCard: View {
    let medicationName: String
    let medicationId: UUID
    let timeOfDay: TimeOfDay
    let doseIndex: Int
    let amount: Int
    let unit: MedicationUnit
    @Binding var isSelected: Bool
    var onToggle: ((Bool) -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            Rectangle()
                .cornerRadius(50)
                .foregroundStyle(timeOfDay.color.opacity(0.2))
            
            HStack(spacing: 1) {
                ZStack {
                    Circle()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(isSelected ? Color.ourGrey : timeOfDay.color.opacity(0.6))
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.white)
                            .font(.system(.title3))
                    }
                }
                
                Image(systemName: timeOfDay.icon)
                    .font(.system(.caption))
                    .foregroundStyle(timeOfDay.color)
                    .padding(.leading,5)
                
                Text(medicationName)
                    .font(.system(.footnote, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .padding(.horizontal,5)

                Text("\(amount)\(unit.displayName)")
                    .font(.system(.caption2, weight: .regular))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if onDelete != nil {
                    Button(action: {
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
                onToggle?(isSelected)
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        MedicationCard(
            medicationName: "Aspirin",
            medicationId: UUID(),
            timeOfDay: .morning,
            doseIndex: 0,
            amount: 500,
            unit: .mg,
            isSelected: .constant(false),
            onDelete: { print("Delete tapped") }
        )
        MedicationCard(
            medicationName: "Vitamin D",
            medicationId: UUID(),
            timeOfDay: .afternoon,
            doseIndex: 0,
            amount: 1000,
            unit: .mg,
            isSelected: .constant(true),
            onDelete: { print("Delete tapped") }
        )
        MedicationCard(
            medicationName: "Cough Syrup",
            medicationId: UUID(),
            timeOfDay: .evening,
            doseIndex: 0,
            amount: 10,
            unit: .ml,
            isSelected: .constant(false),
            onDelete: { print("Delete tapped") }
        )
        MedicationCard(
            medicationName: "Melatonin",
            medicationId: UUID(),
            timeOfDay: .night,
            doseIndex: 0,
            amount: 5,
            unit: .mg,
            isSelected: .constant(true),
            onDelete: { print("Delete tapped") }
        )
    }
    .padding()
}
