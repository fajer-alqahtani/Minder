//
//  SummaryView.swift
//  Minder
//

import SwiftUI
import UIKit

struct SummaryView: View {
    @StateObject var viewModel = SummaryViewModel()
    @State private var showSaveAlert = false
    @Environment(\.displayScale) private var displayScale

    // MARK: - Shared content (used in body + snapshot)
    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                headerSection
                tabsSection
                emotionalStatusSection
                mealsSection
                medicationSection
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
        .background(Color("Color"))
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            content
                .navigationBarHidden(true)
        }
        .alert("Saved to Photos", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your care overview has been saved as an image.")
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Button { } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("ourGrey"))
                }
                Spacer()
                Button {
                    saveSnapshot()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .foregroundColor(Color("ourGrey"))
                }
            }

            Text(viewModel.title)
                .font(.title2)
                .bold()
                .foregroundColor(Color("ourGrey"))
            
            Text(viewModel.dateRangeText)
                .font(.subheadline)
                .foregroundColor(Color("AccentColor"))
        }
    }
    
    // MARK: - Tabs
    private var tabsSection: some View {
        HStack(spacing: 8) {
            ForEach(SummaryPeriod.allCases) { period in
                Button {
                    viewModel.changePeriod(period)
                } label: {
                    Text(period.rawValue)
                        .font(.subheadline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            viewModel.selectedPeriod == period
                            ? Color("ourGrey")
                            : Color.clear
                        )
                        .foregroundColor(
                            viewModel.selectedPeriod == period
                            ? Color("Color") // white text
                            : Color("ourGrey").opacity(0.7)
                        )
                        .clipShape(Capsule())
                }
            }
            Spacer()
        }
    }
    
    // MARK: - Emotional Status
    private var emotionalStatusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack(spacing: 8) {
                Image(systemName: "heart.text.square.fill")
                    .foregroundColor(Color("ourGrey"))
                Text("Emotional status")
                    .font(.headline)
                    .foregroundColor(Color("ourGrey"))
            }
            
            HStack(spacing: 16) {
                ForEach(viewModel.emotionalStatus.categories) { category in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(category.color)
                            .frame(width: 9, height: 9)
                        Text(category.name)
                            .font(.caption)
                            .foregroundColor(Color("ourGrey").opacity(0.7))
                    }
                }
            }
            
            HStack {
                Spacer()
                DonutChart(emotionalStatus: viewModel.emotionalStatus)
                Spacer()
            }
            
        }
        .padding(16)
        .background(Color("Color"))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Meals Summary
    private var mealsSection: some View {
        let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

        return VStack(alignment: .leading, spacing: 12) {
            
            HStack(spacing: 8) {
                Image(systemName: "fork.knife")
                    .foregroundColor(Color("ourGrey"))
                Text("Meals Summary")
                    .font(.headline)
                    .foregroundColor(Color("ourGrey"))
            }

            HStack {
                ForEach(viewModel.mealsWeek.indices, id: \.self) { index in
                    VStack(spacing: 6) {

                        // اسم اليوم
                        Text(weekDays[index])
                            .font(.caption2)
                            .foregroundColor(Color("ourGrey").opacity(0.7))

                        // الدائرة
                        ZStack {
                            if viewModel.mealsWeek[index].isCompleted {
                                Circle()
                                    .fill(Color("AccentColor"))
                                    .frame(width: 28, height: 28)
                                Image(systemName: "checkmark")
                                    .font(.caption)
                                    .foregroundColor(Color("Color"))
                            } else {
                                Circle()
                                    .stroke(Color("AccentColor").opacity(0.25), lineWidth: 2)
                                    .background(Circle().fill(Color("Color")))
                                    .frame(width: 28, height: 28)
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(Color("Color"))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }

    
    // MARK: - Medication Overview
    private var medicationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack(spacing: 8) {
                Image(systemName: "pills.fill")
                    .foregroundColor(Color("ourGrey"))
                Text("Medication Overview")
                    .font(.headline)
                    .foregroundColor(Color("ourGrey"))
            }
            
            HStack(spacing: 8) {
                ForEach(viewModel.medications) { section in
                    VStack(alignment: .leading, spacing: 16) {
                        
                        HStack(spacing: 8) {
                            Image(systemName: section.iconName)
                                .foregroundColor(
                                    section.period == .morning
                                    ? Color("ourYellow")   // ☀️ yellow
                                    : Color("ourGrey")     // 🌙 grey
                                )
                            
                            Text(section.period.rawValue)
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(Color("ourGrey"))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(section.items) { item in
                                HStack(spacing: 6) {
                                    Image(systemName: "pills.fill")
                                        .font(.caption2)
                                        .foregroundColor(Color("ourGrey"))
                                    
                                    Text("\(item.count) \(item.name)")
                                        .font(.body)
                                        .foregroundColor(Color("ourGrey"))
                                }
                            }
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(section.backgroundColor)
                    .cornerRadius(20)
                }
            }
        }
        .padding(8)
        .background(Color("Color"))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }

    // MARK: - Save as Image
    @MainActor
    private func saveSnapshot() {
        // نجيب الويندو اللي عليها الاب شغال
        guard
            let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
            let window = scene.windows.first(where: { $0.isKeyWindow })
        else {
            print("No active window found")
            return
        }

        let bounds = window.bounds

        // نرندر الويندو كاملة كصورة
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let image = renderer.image { _ in
            window.drawHierarchy(in: bounds, afterScreenUpdates: true)
        }

        // نحفظ الصورة في الألبوم
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showSaveAlert = true
    }

    }


// MARK: - DonutChart
struct DonutChart: View {
    let emotionalStatus: EmotionalStatusSummary   // value + label + categories

    // Relative weight for each emotion (Joyful, Saddness, Angry)
    private let rawValues: [Double] = [0.4, 0.30, 0.25]

    // How big the gap is between each arc (0.02 = 2% of the circle)
    private let gap: Double = 0.02

    var body: some View {
        ZStack {
            // Draw one arc per emotion
            ForEach(emotionalStatus.categories.indices, id: \.self) { index in
                let range = trimRange(for: index)

                Circle()
                    .trim(from: range.start, to: range.end)
                    .stroke(
                        emotionalStatus.categories[index].color,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))  // start at the top
            }

            // Center label
            VStack(spacing: 4) {
                Text("\(Int(emotionalStatus.value * 100))%")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color("ourGrey"))

                Text(emotionalStatus.label)
                    .font(.title3)
                    .foregroundColor(Color("ourGrey").opacity(0.7))
            }
        }
        .frame(width: 170, height: 200)
    }

    // MARK: - Helpers to add SPACE between arcs

    private var scaledSegments: [Double] {
        let total = rawValues.reduce(0, +)
        let totalGap = gap * Double(rawValues.count)
        let scale = (1.0 - totalGap) / total

        return rawValues.map { $0 * scale }
    }

    private func trimRange(for index: Int) -> (start: CGFloat, end: CGFloat) {
        let before = scaledSegments.prefix(index).reduce(0, +)
        let start = before + gap * Double(index)
        let end = start + scaledSegments[index]
        return (CGFloat(start), CGFloat(end))
    }
}

// MARK: - Preview
struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}
