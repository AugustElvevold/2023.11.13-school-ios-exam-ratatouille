//
//  SearchViewModel.swift
//  Ratatouille
//
//  Created by August Elvevold on 20/11/2023.
//

import Foundation

class SearchViewModel: ObservableObject {
	@Published var meals: [Meal] = []
	@Published var searchText: String = ""
	@Published var lastSearchText: String = ""
	@Published var queryRequest: Bool = false
	@Published var noResults: Bool = false
	
	func searchMeals() async {
		DispatchQueue.main.async {
			self.queryRequest = true
		}
		let fetchedMeals = await fetchMealsByItem(from: APIString.search + searchText)
		DispatchQueue.main.async {
			self.meals = fetchedMeals
			self.lastSearchText = self.searchText
//			self.applyFilters()
			self.queryRequest = false
			self.noResults = fetchedMeals.isEmpty
		}
	}
}
