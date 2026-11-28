//
//  ShiftDetailView.swift
//  VolunteerLogbook
//

import SwiftUI

/// Detail screen displaying complete information for a selected volunteer shift.
struct ShiftDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ShiftStorageService.self) private var storageService

    let shift: Shift
    @State private var isShowingEditSheet = false
    @State private var isShowingDeleteConfirmation = false
    @State private var deleteErrorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let deleteErrorMessage {
                    Label(deleteErrorMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            Color.red.opacity(0.1),
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                        )
                }

                titleCard

                metadataCard

                notesCard

                deleteButton
            }
            .padding(16)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Shift Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    isShowingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            EditShiftView(shift: shift)
        }
        .confirmationDialog(
            "Delete Shift?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Shift", role: .destructive) {
                deleteShift()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \"\(shift.title)\"? This action cannot be undone.")
        }
    }

    private func deleteShift() {
        do {
            try storageService.deleteShift(shift)
            dismiss()
        } catch {
            deleteErrorMessage = error.localizedDescription
        }
    }

    private var titleCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(shift.category.rawValue, systemImage: shift.category.iconName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(shift.category.tintColor)

                Spacer()

                StatusBadgeView(status: shift.status)
            }

            Text(shift.title)
                .font(.title2.bold())
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color(uiColor: .secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
    }

    private var metadataCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            detailRow(
                label: "Site / Location",
                value: shift.location,
                iconName: "mappin.and.ellipse"
            )

            Divider()

            detailRow(
                label: "Date & Time",
                value: shift.shiftDate.formatted(date: .complete, time: .shortened),
                iconName: "calendar.badge.clock"
            )

            Divider()

            detailRow(
                label: "Last Updated",
                value: shift.updatedAt.formatted(date: .abbreviated, time: .shortened),
                iconName: "clock.arrow.circlepath"
            )
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color(uiColor: .secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Volunteer Notes", systemImage: "note.text")
                .font(.headline)

            Text(shift.notes.isEmpty ? "No notes recorded for this shift." : shift.notes)
                .font(.body)
                .foregroundStyle(shift.notes.isEmpty ? .secondary : .primary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color(uiColor: .secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            isShowingDeleteConfirmation = true
        } label: {
            Label("Delete Shift", systemImage: "trash")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.bordered)
        .tint(.red)
        .padding(.top, 8)
    }

    private func detailRow(label: String, value: String, iconName: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .font(.body)
                .foregroundStyle(.tint)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ShiftDetailView(shift: Shift.makeSampleShifts()[0])
            .environment(ShiftStorageService.preview())
    }
}
