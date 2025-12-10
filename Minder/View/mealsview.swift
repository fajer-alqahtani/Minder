
// Make it smaller

import SwiftUI

// MARK: - Brand Colors used in the card
extension Color {
    // minderDark already exists in EmotionalStatusView.swift. Do not redeclare it here.
    static let cardGray = Color(red: 0.95, green: 0.96, blue: 0.98)
    static let selectedYellow = Color(red: 1.00, green: 0.97, blue: 0.85)
    static let yellowBorder = Color(red: 0.95, green: 0.82, blue: 0.20)
}

// MARK: - Model
enum AmountEaten: String, CaseIterable, Identifiable {
    case ateAll = "Ate All"
    case ateHalf = "Ate Half"
    case didNotEat = "Did Not Eat"

    var id: String { rawValue }
}

// MARK: - Reusable Section
struct HowMuchTheyAteSection: View {
    @State private var amount: AmountEaten? = .ateAll   // default like your screenshot

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header row
            HStack(spacing: 12) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.minderDark)
                Text("Meals")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.minderDark)
                Spacer()
            }

            // Section title
            Text("How much they ate")
                .font(.system(size: 34, weight: .semibold))   // big title like the screenshot
                .foregroundColor(.primary)

            // Choice chips
            HStack(spacing: 20) {
                ForEach(AmountEaten.allCases) { option in
                    amountChip(option)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(Color.minderDark.opacity(0.06))
        )
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }

    // MARK: - Chip Button
    private func amountChip(_ option: AmountEaten) -> some View {
        let isSelected = amount == option

        return Button {
            amount = option
        } label: {
            Text(option.rawValue)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isSelected ? .minderDark : .minderDark.opacity(0.75))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.yellow.opacity(0.15) : Color(.systemGray6))
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? Color.yellow.opacity(0.85) : Color.clear, lineWidth: 2)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Page container
struct MealsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HowMuchTheyAteSection()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    MealsView()
}
