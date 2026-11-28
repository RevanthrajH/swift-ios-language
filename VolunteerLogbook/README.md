# Community Volunteer & Shift Logbook (`VolunteerLogbook`)

**Wipro iOS Project #38** — An offline-first iPhone application built with **Swift**, **SwiftUI**, **MVVM**, **SwiftData**, and **LocalAuthentication** to log, track, search, and manage community volunteering shifts.

---

## Key Features

1. **Biometric Authentication & Manual Fallback**
   - Authenticates users at launch using Apple's `LocalAuthentication` framework (**Face ID** / **Touch ID**) without storing any biometric data.
   - Automatically displays a validated manual login fallback (Volunteer ID + passcode) when biometrics are unavailable or cancelled.
2. **Live Statistics Dashboard**
   - Displays summary cards for **Total Shifts**, **Categories**, **Completed**, and **Upcoming** shifts, plus **Recently Added Shifts**.
   - Updates immediately whenever shifts are added, edited, or deleted.
3. **Scrollable Shift List**
   - Shows every logged shift with title, category, site/location, formatted date, and status badge.
4. **Add Shift Entry (with Validation)**
   - Modal form supporting title, category (`Food Drive`, `Teaching`, `Cleanup`, `Relief`), site/location, date & time, status, and notes.
   - Validates required fields (`title` and `location`) before saving persistently.
5. **Shift Details**
   - Displays complete shift metadata, notes, last-updated timestamp, and actions to edit or delete.
6. **Edit Shift**
   - Modifies any existing shift field and persists updates immediately across all screens.
7. **Delete Shift (with Confirmation)**
   - Supports swipe-to-delete in the shift list and deletion from the detail screen, always guarded by a confirmation dialog.
8. **Combined Search & Filtering**
   - Searches by shift title or site/location while simultaneously filtering by category and status, with one-tap filter reset.
9. **Shift Status Tracking**
   - Tracks `Completed`, `Upcoming`, and `Cancelled` shifts with distinct visual status badges.

---

## Technical Stack & Constraints

- **Platform:** iPhone only (`TARGETED_DEVICE_FAMILY = 1`), Portrait orientation locked
- **Language & UI:** Swift, SwiftUI (Light & Dark Mode support)
- **Architecture:** MVVM (Models, Views, ViewModels, Services, Reusable Components)
- **Persistence:** SwiftData (offline local SQLite storage)
- **Security:** Apple `LocalAuthentication` (`LAContext`)
- **Testing:** Swift Testing (`VolunteerLogbookTests`)

---

## Project Structure

```text
VolunteerLogbook/
├── VolunteerLogbook/
│   ├── App/
│   │   ├── VolunteerLogbookApp.swift
│   │   └── AppState.swift
│   ├── Models/
│   │   └── Shift.swift
│   ├── Services/
│   │   ├── BiometricAuthService.swift
│   │   └── ShiftStorageService.swift
│   ├── ViewModels/
│   │   ├── AuthenticationViewModel.swift
│   │   ├── DashboardViewModel.swift
│   │   ├── ShiftFormViewModel.swift
│   │   └── ShiftListViewModel.swift
│   ├── Views/
│   │   ├── MainTabView.swift
│   │   ├── Authentication/
│   │   │   └── LoginView.swift
│   │   ├── Dashboard/
│   │   │   └── DashboardView.swift
│   │   ├── Shifts/
│   │   │   ├── ShiftListView.swift
│   │   │   ├── AddShiftView.swift
│   │   │   ├── ShiftDetailView.swift
│   │   │   └── EditShiftView.swift
│   │   └── Components/
│   │       ├── ShiftCardView.swift
│   │       ├── ShiftFormFieldsView.swift
│   │       ├── StatCardView.swift
│   │       └── StatusBadgeView.swift
│   └── Resources/
│       └── Assets.xcassets/
├── VolunteerLogbookTests/
│   └── VolunteerLogbookTests.swift
└── VolunteerLogbookUITests/
    └── VolunteerLogbookUITests.swift
```

---

## Running & Testing in Xcode

1. Open **`VolunteerLogbook.xcodeproj`** in Xcode on macOS.
2. Select an **iPhone Simulator** (for example, iPhone 17) and press **Cmd + R** to build and run.
3. **Testing Biometrics in Simulator:**
   - **Manual Fallback (default):** When Face ID is not enrolled, the app automatically expands the manual login form.
   - **Face ID Simulation:** In Simulator's menu bar, select **Features → Face ID → Enrolled**, relaunch the app, and trigger **Features → Face ID → Matching Face** or **Non-matching Face**.
4. **Running Unit Tests:** Press **Cmd + U** in Xcode (or run `VolunteerLogbookTests`) to execute all 6 unit tests covering SwiftData persistence, form validation, search & filtering, deletion confirmation, dashboard statistics, and authentication logic.
