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
	@StateObject var splashScreenManager = SplashScreenManager()
	@StateObject var settingViewModel = SettingsViewModel()
	var searchViewModel = SearchViewModel()
	@StateObject var tabSelection = TabSelection()
	@StateObject var csManager = ColorSchemeManager()

    var body: some Scene {
        WindowGroup {
					ZStack {
						ContentView(searchViewModel: SearchViewModel())
							.environmentObject(splashScreenManager)
							.environmentObject(settingViewModel)
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
