//
//  ShiftCardView.swift
//  VolunteerLogbook
//

import SwiftUI

/// Reusable card displaying summary details for a volunteer shift.
struct ShiftCardView: View {
    let title: String
    let category: ShiftCategory
    let location: String
    let date: Date
    let status: ShiftStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: category.iconName)
                    .font(.headline)
                    .foregroundStyle(category.tintColor)
                    .frame(width: 38, height: 38)
                    .background(
                        category.tintColor.opacity(0.14),
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    Text(category.rawValue)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(category.tintColor)
                }

                Spacer(minLength: 8)

                StatusBadgeView(status: status)
            }

            Divider()

            HStack(spacing: 16) {
                Label(location, systemImage: "mappin.and.ellipse")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer(minLength: 8)

                Label(date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(
            Color(uiColor: .secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}

#Preview {
    let sample = Shift.makeSampleShifts()[0]
    ShiftCardView(
        title: sample.title,
        category: sample.category,
        location: sample.location,
        date: sample.shiftDate,
        status: sample.status
    )
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
