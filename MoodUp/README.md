

# MoodUp 🌿

MoodUp is a modern iOS app designed to help you track your mood, understand patterns, and improve your well-being through simple daily check-ins and smart insights.

---

## ✨ Features

### 😊 Mood Tracking
- Log your mood throughout the day
- Clean and intuitive UI
- Emoji-based interaction for fast input

### 📊 Statistics
- Weekly mood overview
- Most frequent mood detection
- Daily activity tracking
- Quick summary cards

### 💡 Insights & Recommendations
- Personalized recommendations based on:
  - Sleep quality
  - Energy level
- Daily contextual feedback

### 💤 Apple Health Integration
- Import sleep data from Apple Health (HealthKit)
- Automatic sleep duration detection
- Smart mapping to sleep quality (Great / Okay / Bad)
- Optional — user can also enter data manually

### 🔔 Notifications
- Reminders to log mood
- Customizable frequency

### 👤 Profile
- Editable user profile
- Profile photo support
- App settings (dark mode, notifications)

---

## 🧠 Architecture

- SwiftUI
- MVVM-like approach
- ObservableObject + EnvironmentObject
- Local persistence via UserDefaults
- Modular structure:
  - Views
  - Models
  - Services

---

## 🛠 Tech Stack

- Swift
- SwiftUI
- HealthKit
- Combine
- UserDefaults

---

## 📱 Screens

- Mood (main screen)
- Stats (analytics)
- Insights (recommendations + sleep)
- Notifications
- Profile

---

## 🚀 Getting Started

```bash
git clone https://github.com/andreyboyarko/MoodUP.git
cd MoodUP
open MoodUp.xcodeproj
