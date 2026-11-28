//
//  ShiftListView.swift
//  VolunteerLogbook
//

import SwiftUI

/// Scrollable list of volunteer shifts with combined search and category/status filters.
struct ShiftListView: View {
    @Environment(ShiftStorageService.self) private var storageService
    @State private var viewModel = ShiftListViewModel()
    @State private var isShowingAddShift = false

    private var allShifts: [Shift] {
        storageService.shifts
    }

    private var displayedShifts: [Shift] {
        viewModel.filteredShifts(from: allShifts)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterHeader

                if allShifts.isEmpty {
                    ContentUnavailableView(
                        "No Volunteer Shifts",
                        systemImage: "tray",
                        description: Text("Tap + to log your first community shift.")
                    )
                } else if displayedShifts.isEmpty {
                    ContentUnavailableView {
                        Label("No Matching Shifts", systemImage: "magnifyingglass")
                    } description: {
                        Text("Try adjusting your search query or active filters.")
                    } actions: {
                        if viewModel.hasActiveFilters {
                            Button("Clear Filters") {
                                viewModel.clearFilters()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                } else {
                    List {
                        if viewModel.hasActiveFilters {
                            Text("Showing \(displayedShifts.count) of \(allShifts.count) shifts")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 2, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }

                        ForEach(displayedShifts) { shift in
                            ZStack {
                                NavigationLink(value: shift) {
                                    EmptyView()
                                }
                                .opacity(0)

                                ShiftCardView(
                                    title: shift.title,
                                    category: shift.category,
                                    location: shift.location,
                                    date: shift.shiftDate,
                                    status: shift.status
                                )
                            }
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    viewModel.requestDeletion(of: shift)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollDismissesKeyboard(.interactively)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Volunteer Shifts")
            .navigationDestination(for: Shift.self) { shift in
                ShiftDetailView(shift: shift)
            }
            .searchable(text: $viewModel.searchText, prompt: "Search title or location")
            .toolbar {
                if viewModel.hasActiveFilters {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Reset") {
                            viewModel.clearFilters()
                        }
                    }
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
            .confirmationDialog(
                "Delete Shift?",
                isPresented: $viewModel.isShowingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Shift", role: .destructive) {
                    viewModel.confirmDeletion(using: storageService)
                }
                Button("Cancel", role: .cancel) {
                    viewModel.cancelDeletion()
                }
            } message: {
                if let shift = viewModel.shiftPendingDeletion {
                    Text("Are you sure you want to delete \"\(shift.title)\"? This action cannot be undone.")
                }
            }
        }
    }

    private var filterHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip(title: "All Categories", isSelected: viewModel.selectedCategory == nil) {
                        viewModel.selectedCategory = nil
                    }

                    ForEach(ShiftCategory.allCases) { category in
                        filterChip(
                            title: category.rawValue,
                            isSelected: viewModel.selectedCategory == category
                        ) {
                            viewModel.selectedCategory = (viewModel.selectedCategory == category) ? nil : category
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip(title: "All Statuses", isSelected: viewModel.selectedStatus == nil) {
                        viewModel.selectedStatus = nil
                    }

                    ForEach(ShiftStatus.allCases) { status in
                        filterChip(
                            title: status.rawValue,
                            isSelected: viewModel.selectedStatus == status
                        ) {
                            viewModel.selectedStatus = (viewModel.selectedStatus == status) ? nil : status
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 10)
    }

    private func filterChip(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .foregroundStyle(isSelected ? .white : .primary)
                .background(
                    isSelected ? Color.accentColor : Color(uiColor: .secondarySystemGroupedBackground),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ShiftListView()
        .environment(ShiftStorageService.preview())
}
