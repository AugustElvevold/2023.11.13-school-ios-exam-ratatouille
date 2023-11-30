//
//  RatatouilleApp.swift
//  Ratatouille
//
//  Created by Kandidatnr: 2003 on 18/11/2023.
//

import SwiftUI
import SwiftData

@main
struct RatatouilleApp: App {
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        } 
//    }()
	@StateObject var searchViewModel = SearchViewModel()
	@StateObject var settingViewModel = SettingsViewModel()
	@StateObject var csManager = ColorSchemeManager()
	@StateObject var tabSelection = TabSelection()

    var body: some Scene {
        WindowGroup {
            ContentView()
						.environmentObject(csManager)
						.environmentObject(tabSelection)
						.environmentObject(searchViewModel)
						.environmentObject(settingViewModel)
						.onAppear(){
							csManager.applyColorScheme()
						}
        }
				.modelContainer(for: [Meal.self, IngredientModel.self, CategoryModel.self, AreaModel.self])
    }
}
