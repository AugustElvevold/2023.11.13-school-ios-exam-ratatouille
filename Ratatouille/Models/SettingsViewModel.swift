//
//  SettingsViewModel.swift
//  Ratatouille
//
//  Created by Kandidatnr: 2003 on 28/11/2023.
//

import Foundation
import SwiftData

class SettingsViewModel: ObservableObject {
	@Published var apiIngredients: [IngredientModel] = []
	@Published var apiCategories: [CategoryModel] = []
	@Published var apiAreas: [AreaModel] = []
	@Published var queryRequest: Bool = false
	@Published var betterCategorySearch: Bool = true
	
	func fetchIngredients() async {
		if !apiIngredients.isEmpty{
			return
		}
		DispatchQueue.main.async {
			self.queryRequest = true
		}
		let fetchedIngredients = await APISerciveFetchIngredients()
		DispatchQueue.main.async {
			self.apiIngredients = fetchedIngredients
			self.queryRequest = false
		}
	}
	
	func fetchCategories() async {
		if !apiCategories.isEmpty {
			return
		}
		DispatchQueue.main.async {
			self.queryRequest = true
		}
		let fetchedCategories = await APIServiceFetchCategories()
		DispatchQueue.main.async {
			self.apiCategories = fetchedCategories
			self.queryRequest = false
		}
	}
	
	func fetchAreas() async {
		if !apiAreas.isEmpty {
			return
		}
		DispatchQueue.main.async {
			self.queryRequest = true
		}
		let fetchedAreas = await APIServiceFetchAreas()
		DispatchQueue.main.async {
			self.apiAreas = fetchedAreas
			self.queryRequest = false
		}
	}
}
