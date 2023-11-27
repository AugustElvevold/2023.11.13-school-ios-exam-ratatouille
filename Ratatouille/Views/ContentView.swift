//
//  ContentView.swift
//  Ratatouille
//
//  Created by Kandidatnr: 2003 on 18/11/2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@EnvironmentObject var searchViewModel: SearchViewModel
	@EnvironmentObject var tabSelection: TabSelection
	@EnvironmentObject var csManager: ColorSchemeManager
//	@Query private var items: [Item]
	
	var body: some View {
		TabView(selection: $tabSelection.selectedTab) {
			MyMealsView()
				.tabItem {
					Label("Oppskrifter", systemImage: "list.bullet")
				}
				.tag(TabSelection.Tab.recipes)
			SearchView()
				.tabItem {
					Label("Søk", systemImage: "magnifyingglass")
				}
				.environmentObject(searchViewModel)
				.tag(TabSelection.Tab.search)
			SettingView()
				.tabItem {
					Label("Innstillinger", systemImage: "gearshape.fill")
				}
				.tag(TabSelection.Tab.settings)
				.environmentObject(csManager)
		}
	}
}

#Preview {
	ContentView()
		.environmentObject(SearchViewModel())
		.modelContainer(for: Meal.self)
		.environmentObject(TabSelection())
		.environmentObject(ColorSchemeManager())
//	Removes all data from the database after stopping the preview
//		.modelContainer(for: Meal.self, inMemory: true)
}

class TabSelection: ObservableObject {
	enum Tab {
		case recipes, search, settings
	}
	
	@Published var selectedTab: Tab = .recipes
}
