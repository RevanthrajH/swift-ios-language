//
//  DashboardView.swift
//  VolunteerLogbook
//

import SwiftUI

/// Home screen displaying volunteer summary cards and recently added shifts.
struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(ShiftStorageService.self) private var storageService

    @State private var viewModel = DashboardViewModel()
    @State private var isShowingAddShift = false

    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var summary: DashboardSummary {
        viewModel.summary(for: storageService.shifts)
    }

    private var recentShifts: [Shift] {
        viewModel.recentShifts(from: storageService.shifts)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerBanner

                    summaryGrid

                    recentEntriesSection
                }
                .padding(16)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Dashboard")
            .navigationDestination(for: Shift.self) { shift in
                ShiftDetailView(shift: shift)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        appState.lockSession()
                    } label: {
                        Label("Lock", systemImage: "lock.fill")
                    }
                    .accessibilityLabel("Lock Logbook")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddShift = true
                    } label: {
                        Label("Add Shift", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddShift) {
                AddShiftView()
            }
            .animation(.easeInOut(duration: 0.2), value: summary)
        }
    }

    private var headerBanner: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Community Overview")
                    .font(.title2.bold())
                Text("Track your volunteer hours and upcoming shifts.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "hands.sparkles.fill")
                .font(.title2)
                .foregroundStyle(.tint)
                .padding(12)
                .background(.tint.opacity(0.14), in: Circle())
        }
        .padding(16)
        .background(
            Color(uiColor: .secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
    }

    private var summaryGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 12) {
            StatCardView(
                title: "Total Shifts",
                value: "\(summary.totalShifts)",
                iconName: "list.bullet.clipboard.fill",
                tintColor: .blue
            )

            StatCardView(
                title: "Categories",
                value: "\(summary.activeCategories)",
                iconName: "square.grid.2x2.fill",
                tintColor: .orange
            )

            StatCardView(
                title: "Completed",
                value: "\(summary.completedShifts)",
                iconName: "checkmark.seal.fill",
                tintColor: .green
            )

            StatCardView(
                title: "Upcoming",
                value: "\(summary.upcomingShifts)",
                iconName: "calendar.badge.clock",
                tintColor: .indigo
            )
        }
    }

    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recently Added Shifts")
                    .font(.headline)

                Spacer()

                Button("View All") {
                    appState.selectedTab = .shifts
                }
                .font(.subheadline.weight(.semibold))
            }

            if recentShifts.isEmpty {
                ContentUnavailableView(
                    "No Shifts Logged Yet",
                    systemImage: "calendar.badge.plus",
                    description: Text("Add your first community volunteer shift to see it here.")
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                VStack(spacing: 12) {
                    ForEach(recentShifts) { shift in
                        NavigationLink(value: shift) {
                            ShiftCardView(
                                title: shift.title,
                                category: shift.category,
                                location: shift.location,
                                date: shift.shiftDate,
                                status: shift.status
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

#Preview {
    DashboardView()
        .environment(AppState())
        .environment(ShiftStorageService.preview())
}
