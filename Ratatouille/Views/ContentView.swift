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
	@EnvironmentObject var splashScreenManager: SplashScreenManager
	@EnvironmentObject var searchViewModel: SearchViewModel
	@EnvironmentObject var settingViewModel: SettingsViewModel
	@EnvironmentObject var tabSelection: TabSelection
	@EnvironmentObject var csManager: ColorSchemeManager
	
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
				.environmentObject(settingViewModel)
				.tag(TabSelection.Tab.search)
			SettingView()
				.tabItem {
					Label("Innstillinger", systemImage: "gearshape.fill")
				}
				.tag(TabSelection.Tab.settings)
				.environmentObject(csManager)
				.environmentObject(settingViewModel)
		}
		.onAppear() {
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
				withAnimation(.easeOut(duration: 1)) {
					splashScreenManager.dismiss()
				}
			}
		}
	}
}

#Preview {
	ContentView()
		.environmentObject(SplashScreenManager())
		.environmentObject(SearchViewModel())
		.environmentObject(TabSelection())
		.environmentObject(ColorSchemeManager())
		.environmentObject(SettingsViewModel())
		.modelContainer(for: [MealModel.self, IngredientModel.self, CategoryModel.self, AreaModel.self])
}

class TabSelection: ObservableObject {
	enum Tab {
		case recipes, search, settings
	}
	
	@Published var selectedTab: Tab = .recipes
}
