//
//  EditShiftView.swift
//  VolunteerLogbook
//

import SwiftUI

/// Modal form screen for updating an existing volunteer shift.
struct EditShiftView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ShiftStorageService.self) private var storageService

    @State private var viewModel: ShiftFormViewModel

    init(shift: Shift) {
        _viewModel = State(initialValue: ShiftFormViewModel(shift: shift))
    }

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
            .navigationTitle("Edit Shift")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Update") {
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
    EditShiftView(shift: Shift.makeSampleShifts()[0])
        .environment(ShiftStorageService.preview())
}
