//
//  MainTabView.swift
//  VolunteerLogbook
//

import SwiftUI

/// Root tab container connecting the Dashboard and Shift List navigation stacks.
struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var bindableState = appState

        TabView(selection: $bindableState.selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2.fill")
                }
                .tag(AppTab.dashboard)

            ShiftListView()
                .tabItem {
                    Label("Shifts", systemImage: "list.bullet.clipboard.fill")
                }
                .tag(AppTab.shifts)
        }
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
        .environment(ShiftStorageService.preview())
}
