//
//  SearchViewModel.swift
//  Ratatouille
//
//  Created by August Elvevold on 20/11/2023.
//

import Foundation

class SearchViewModel: ObservableObject {
	@Published var meals: [APIMeal] = []
	@Published var searchText: String = ""
	
	func searchMeals() async {
		DispatchQueue.main.async {
//			self.queryRequest = true
		}
		let fetchedMeals = await fetchMealsByItem(from: APIString.search + searchText)
		DispatchQueue.main.async {
			self.meals = fetchedMeals
//			self.applyFilters()
//			self.queryRequest = false
		}
	}
}
