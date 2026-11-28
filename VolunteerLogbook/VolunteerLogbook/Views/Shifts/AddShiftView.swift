//
//  AddShiftView.swift
//  VolunteerLogbook
//

import SwiftUI

/// Modal form screen for logging a new volunteer shift.
struct AddShiftView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ShiftStorageService.self) private var storageService

    @State private var viewModel = ShiftFormViewModel()

    var body: some View {
        NavigationStack {
            ShiftFormFieldsView(
                title: $viewModel.title,
                category: $viewModel.category,
                location: $viewModel.location,
                shiftDate: $viewModel.shiftDate,
                status: $viewModel.status,
                notes: $viewModel.notes,
                validationMessage: viewModel.validationMessage
            )
            .navigationTitle("Add Shift")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.save(using: storageService) {
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    AddShiftView()
        .environment(ShiftStorageService.preview())
}
