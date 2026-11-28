//
//  StatusBadgeView.swift
//  VolunteerLogbook
//

import SwiftUI

/// Reusable visual status pill for Completed, Upcoming, and Cancelled shifts.
struct StatusBadgeView: View {
    let status: ShiftStatus

    var body: some View {
        Label(status.rawValue, systemImage: status.iconName)
            .font(.caption.weight(.semibold))
            .foregroundStyle(status.tintColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                status.tintColor.opacity(0.14),
                in: Capsule()
            )
            .accessibilityLabel("Status: \(status.rawValue)")
    }
}

#Preview {
    HStack {
        ForEach(ShiftStatus.allCases) { status in
            StatusBadgeView(status: status)
        }
    }
    .padding()
}
