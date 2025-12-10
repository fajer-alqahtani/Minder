import SwiftUI

// MARK: - Model
enum AmountEaten: String, CaseIterable, Identifiable {
    case ateAll = "Ate All"
    case ateHalf = "Ate Half"
    case didNotEat = "Did Not Eat"

    var id: String { rawValue }
}

// MARK: - MEALS CARD (small + clean + fits like the screenshot)

struct MealsCard: View {
    @State private var amount: AmountEaten? = .ateAll   // default selected

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Header row
            HStack(spacing: 10) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 20))
                    .foregroundColor(.ourDarkGrey)

                Text("Meals")
                    .font(.headline)
                    .foregroundColor(.ourDarkGrey)

                Spacer()
            }

            // Subtitle
            Text("How much did they eat?")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Choice chips
            HStack(spacing: 10) {
                ForEach(AmountEaten.allCases) { option in
                    amountChip(option)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(.systemGray6))
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Chip Button
    private func amountChip(_ option: AmountEaten) -> some View {
        let isSelected = amount == option

        return Button {
            amount = option
        } label: {
            Text(option.rawValue)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(
                    isSelected ? .ourDarkGrey : .ourDarkGrey.opacity(0.7)
                )
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.yellow.opacity(0.15) : Color(.systemBackground))
                        .overlay(
                            Capsule()
                                .stroke(
                                    isSelected ? Color.yellow.opacity(0.8) : Color.gray.opacity(0.15),
                                    lineWidth: 2
                                )
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MealsCard()
        .padding()
        .background(Color(.systemGroupedBackground))
}

