//
//  ShiftFormFieldsView.swift
//  VolunteerLogbook
//

import SwiftUI

/// Shared form fields used by both AddShiftView and EditShiftView to avoid UI duplication.
struct ShiftFormFieldsView: View {
    @Binding var title: String
    @Binding var category: ShiftCategory
    @Binding var location: String
    @Binding var shiftDate: Date
    @Binding var status: ShiftStatus
    @Binding var notes: String
    var validationMessage: String?

    var body: some View {
        Form {
            if let validationMessage, !validationMessage.isEmpty {
                Section {
                    Label(validationMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }
            }

            Section("Shift Details") {
                TextField("Shift Title (e.g., Food Pantry Prep)", text: $title)
                    .textInputAutocapitalization(.words)

                Picker("Category", selection: $category) {
                    ForEach(ShiftCategory.allCases) { item in
                        Label(item.rawValue, systemImage: item.iconName)
                            .tag(item)
                    }
                }

                TextField("Site / Location", text: $location)
                    .textInputAutocapitalization(.words)

                DatePicker(
                    "Shift Date",
                    selection: $shiftDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }

            Section("Status Tracking") {
                Picker("Status", selection: $status) {
                    ForEach(ShiftStatus.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Notes") {
                TextField(
                    "Optional shift notes, tasks, or supervisor info...",
                    text: $notes,
                    axis: .vertical
                )
                .lineLimit(4...8)
            }
        }
    }
}
