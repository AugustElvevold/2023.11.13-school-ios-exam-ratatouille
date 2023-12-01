//
//  SearchViewModel.swift
//  Ratatouille
//
//  Created by Kandidatnr: 2003 on 20/11/2023.
//

import Foundation

class SearchViewModel: ObservableObject {
	@Published var meals: [MealModel] = []
	@Published var searchText: String = ""
	@Published var searchTextPrev: String = ""
	@Published var searchTitleString: String = ""
	@Published var loadingData: Bool = false
	@Published var noResults: Bool = false
	
	@Published var allApiAreas: [String] = []
	@Published var allApiCategories: [String] = []
	@Published var allApiIngredients: [String] = []
	
	private var isCategoryFilterDataFetched = false
	
	func ensureCategoryFilterDataIsFetched() {
		guard !isCategoryFilterDataFetched else { return }
		Task {
			await fetchAllData()
			isCategoryFilterDataFetched = true
		}
	}
	
	func searchMeals() async {
		DispatchQueue.main.async {
			self.loadingData = true
		}
		let fetchedMeals = await fetchMealsByItem(from: APIString.search + searchText)
		DispatchQueue.main.async {
			self.meals = fetchedMeals
			self.searchTitleString = "Søkeresultater for \"\(self.searchText)\" ga \(self.meals.isEmpty ? "0" : "\(self.meals.count)") treff"
			self.searchTextPrev = self.searchText
//			self.applyFilters()
			self.loadingData = false
			self.noResults = fetchedMeals.isEmpty
		}
	}
	
	func fetchAllData() async {
		//		if (!allCountries.isEmpty && !allCategories.isEmpty && !allIngredients.isEmpty) {
		//			return
		//		}
		let categories = await fetchFilterOptions(urlString: APIString.categoryList)
		let areas = await fetchFilterOptions(urlString: APIString.areaList)
		let ingredients = await fetchFilterOptions(urlString: APIString.ingredientList)
		
		DispatchQueue.main.async {
			self.allApiCategories = categories
			self.allApiAreas = areas
			self.allApiIngredients = ingredients
		}
	}
	
	func fetchMealsBy(_ item: String, _ apiTypeString: String) async {
		DispatchQueue.main.async {
			self.loadingData = true
		}
//		print(apiTypeString + item)
		let fetchedMeals = await fetchMealsByItem(from: apiTypeString + item)
		DispatchQueue.main.async {
			self.meals = fetchedMeals
			self.searchTitleString = "Alle \"\(item)\" matoppskrifter"
			self.searchText = ""
//			self.applyFilters()
			self.loadingData = false
		}
	}
	
}
