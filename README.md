# 🧠 Minder  
### A Caregiver-Centered Daily Support iOS App

Minder is an iOS application designed to support caregivers in managing and monitoring a patient’s daily care with clarity and ease. It centralizes essential caregiving tasks—medications, meals, and emotional well-being—into a simple daily flow, while offering a clear summarized overview to support better decision-making and communication.

---

## 🌟 Purpose

Caregiving involves constant attention, emotional awareness, and accurate tracking. Minder was created to reduce cognitive load on caregivers by providing:

- A single place to record daily care activities  
- A fast, low-friction interface for emotional check-ins  
- A visual summary that highlights trends over time  

---

## ✨ Key Features

### 🗓 Daily Record
- Add and review medications, grouped by morning and evening
- Log daily meals with a clear completion indicator
- Record the patient’s emotional status using predefined emotions

### 💭 Emotional Tracking
- Emotions are persisted locally using **SwiftData**
- Supports multiple emotional entries per day
- Designed for quick, one-tap logging directly from the main screen

### 📊 Care Overview (Summary)
- Daily, Weekly, and Monthly views
- Emotional status visualized using a custom donut chart
- Meal completion overview by day
- Medication overview grouped by time of day
- Summary data updates automatically based on saved records

---

## 🏗 Technical Overview

- **Platform:** iOS  
- **Framework:** SwiftUI  
- **Architecture:** MVVM  
- **Data Persistence:** SwiftData  
- **Localization:** String Catalogs (`.xcstrings`)

---

## 🧪 Usability Testing Scenario

**Task:**  
Complete today’s caregiving routine by adding medication, recording meals, logging the patient’s emotional status, and reviewing the care summary.

**Expected Outcome:**  
All entries are saved successfully and reflected in the Summary view, allowing the caregiver to clearly understand the patient’s overall condition.

---

## 🚀 Getting Started

```bash
git clone https://github.com/your-username/minder.git
