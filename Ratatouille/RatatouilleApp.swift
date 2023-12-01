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
	@StateObject var splashScreenManager = SplashScreenManager()
	@StateObject var settingViewModel = SettingsViewModel()
	@StateObject var searchViewModel = SearchViewModel()
	@StateObject var tabSelection = TabSelection()
	@StateObject var csManager = ColorSchemeManager()

    var body: some Scene {
        WindowGroup {
					ZStack {
						ContentView()
							.environmentObject(splashScreenManager)
							.environmentObject(settingViewModel)
							.environmentObject(searchViewModel)
							.environmentObject(tabSelection)
							.environmentObject(csManager)
							.onAppear(){
								csManager.applyColorScheme()
							}
						
						if splashScreenManager.phase != .completed {
							SplashView()
								.environmentObject(splashScreenManager)
						}
					}
        }
				.modelContainer(for: [MealModel.self, IngredientModel.self, CategoryModel.self, AreaModel.self])
    }
}
