//
//  StatCardView.swift
//  VolunteerLogbook
//

import SwiftUI

/// Reusable dashboard metric card displaying a key volunteer summary figure.
struct StatCardView: View {
    let title: String
    let value: String
    let iconName: String
    let tintColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconName)
                    .font(.headline)
                    .foregroundStyle(tintColor)
                    .frame(width: 34, height: 34)
                    .background(tintColor.opacity(0.14), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title.bold())
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())

                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
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
    HStack(spacing: 12) {
        StatCardView(
            title: "Total Shifts",
            value: "12",
            iconName: "calendar.badge.clock",
            tintColor: .blue
        )
        StatCardView(
            title: "Completed",
            value: "8",
            iconName: "checkmark.seal.fill",
            tintColor: .green
        )
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
