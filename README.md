🧠 Minder – Caregiver Daily Support App

Minder is an iOS application designed to help caregivers easily track and review a patient’s daily care activities, including medications, meals, and emotional status. The app provides a clear daily record and a summarized overview to support better caregiving decisions and communication.

✨ Features

Daily Record

Add and review medications (morning & evening).

Log meals completion for each day.

Quickly record the patient’s emotional status using predefined emotions.

Emotional Tracking

Emotions are saved using SwiftData.

Supports multiple emotion entries per day.

Designed for fast, low-effort logging.

Summary View

Daily / Weekly / Monthly tabs.

Emotional status visualized using a donut chart.

Meal completion overview by day.

Medication overview grouped by time of day.

Summary data updates automatically based on saved records.

Usability-Focused Design

Simple, clear UI for caregivers.

Minimal steps to complete daily tasks.

Localized text support using String Catalogs.

🏗 Architecture

Framework: SwiftUI

Data Persistence: SwiftData

Architecture Pattern: MVVM

Charts: Custom SwiftUI Donut Chart

Localization: Localizable.xcstrings

🧩 Data Models

EmotionLog

Stores emotions selected by the user.

Includes timestamp and optional metadata.

Emotions are aggregated in the Summary view to calculate emotional trends.

🧪 Usability Testing Scenario

Task:
Complete today’s caregiving routine by adding a medication, recording meals, logging the patient’s emotional status, and reviewing the summary overview.

Expected Outcome:
All entries are saved successfully and reflected in the Summary page, allowing the caregiver to clearly understand the patient’s condition.

🚀 Getting Started

Clone the repository:

git clone https://github.com/your-username/minder.git


Open the project in Xcode (latest version recommended).

Run the app on an iOS simulator or physical device.

Make sure SwiftData models are correctly loaded via .modelContainer.

📸 Screens

Splash Screen with animated branding

Today’s Record (Medications, Meals, Emotional Status)

Care Overview Summary with charts

👩‍💻 Team

Developed as part of the Apple Developer Academy program.

📌 Notes

All data is stored locally using SwiftData.

Designed as a prototype focused on usability and clarity.

Future improvements may include reminders, data export, and caregiver sharing.

If you want, I can:

Shorten it

Make it more academic

Add screenshots section

Or rewrite it specifically for Apple Developer Academy submission

يمكن أن تصدر عن ChatGPT بعض الأخطاء. لذلك يجب التحقق من المعلومات المهمة.
