import Foundation
import SwiftData

// Store one meal selection per day
@Model
final class MealLog {
    var id: UUID
    var date: Date   // normalized to start of day
    var amountRaw: String  // store enum raw value

    init(date: Date, amount: AmountEaten) {
        self.id = UUID()
        self.date = MealLog.startOfDay(for: date)
        self.amountRaw = amount.rawValue
    }

    var amount: AmountEaten? {
        AmountEaten(rawValue: amountRaw)
    }

    func updateAmount(_ newAmount: AmountEaten) {
        self.amountRaw = newAmount.rawValue
    }

    static func startOfDay(for date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
}
