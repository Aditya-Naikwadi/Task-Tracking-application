# ⚡ LvlUp - Elite Student Productivity

LvlUp is a premium, cross-platform productivity application built for students who want to master their time and stay accountable. Combining a sleek **Glassmorphic UI** with **Gamified Progress**, LvlUp transforms mundane task management into an engaging journey.

![App Header](https://via.placeholder.com/800x400/00E5FF/000000?text=TaskTrack+-+Master+Your+Time)

---

## ✨ Key Features

### 🎮 Gamified Productivity
- **XP & Levels**: Earn Experience Points for completing tasks. Level up every 500 XP!
- **Daily Streaks**: Keep the flame alive by maintaining consistency every day.
- **Priority Rewards**: Higher priority tasks yield greater XP rewards.

### 📊 Real-Time Insights
- **Task Distribution**: Visualize your focus across Academics, Work, and Personal life with interactive charts.
- **Productivity Trends**: Track your weekly performance and adjust your habits.

### 🤝 Seamless Collaboration
- **Unified Streams**: See your owned tasks and assigned tasks in one clean view.
- **Attachment Support**: Upload images and documents directly to specific tasks using Firebase Storage.
- **Threaded Comments**: Communicate with your team directly within each task.

### 🛠️ Smart Tools
- **Focus Timer**: Dedicated countdown timers for deep work sessions with background persistence.
- **Voice-to-Task**: Create tasks hands-free using advanced Speech-to-Text integration.
- **Smart Reminders**: Never miss a deadline with automated, scheduled local notifications.

---

## 🎨 Design Philosophy
TaskTrack utilizes a **Cyber-Dark Premium Theme**:
- **Primary Colors**: Electric Teal (`#00E5FF`) and Neon Orange (`#FF9100`).
- **Glassmorphism**: Translucent, blurred containers for a modern, depth-focused UI.
- **Animations**: Fluid transitions using `animate_do` and `Hero` animations.

---

## 🚀 Tech Stack
- **Frontend**: Flutter (3.x) - Material 3
- **Backend Services**: 
  - **Firebase Auth**: Secure Student Identity Management.
  - **Cloud Firestore**: Real-time NoSQL data synchronization.
  - **Firebase Storage**: For high-speed file attachments.
  - **Firebase Messaging**: Foundation for push notifications.
- **State Management**: Provider (ChangeNotifier)
- **Database Rules**: Custom Firestore Security Rules for data privacy.

---

## 📂 Project Structure
```bash
lib/
├── core/               # Shared constants, themes, and glass widgets
├── features/           # Feature-driven modules
│   ├── auth/           # Login, Registration, and UserModel
│   ├── tasks/          # Task CRUD, Priority, and Timer logic
│   ├── dashboard/      # Interactive charts and User Profile
├── services/           # Firebase and Hardware API wrappers
└── main.dart           # App entry and provider configuration
```

---

## 💻 Get Started

### Prerequisites
- Flutter SDK (Latest Stable)
- Firebase Account

### Installation
1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/task-track-app.git
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Configure Firebase**:
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).
   - Ensure Firestore, Auth (Email/Pass), and Storage are enabled in the Firebase Console.
4. **Run the App**:
   ```bash
   flutter run --release
   ```

---

## 🔐 Security
TaskTrack uses strictly defined **Firestore Security Rules** to ensure that:
- Users can only access tasks they own or are assigned to.
- Profile data is locked to the specific owner.
- Attachments are stored in task-specific directories.

---



---
*Stay Productive. Level Up. Conquer your Day.*
