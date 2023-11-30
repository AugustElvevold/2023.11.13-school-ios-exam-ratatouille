//
//  APISercive.swift
//  Ratatouille
//
//  Created by August Elvevold on 20/11/2023.
//

import Foundation
import SwiftData

struct APIString {
	static let baseURL = "https://www.themealdb.com/api/json/v1/1/"
//	static let categoryList = "\(baseURL)list.php?c=list" // For some reason is missing a few categories
	static let categoryList = "\(baseURL)categories.php"
	static let areaList = "\(baseURL)list.php?a=list"
	static let ingredientList = "\(baseURL)list.php?i=list"
	static let search = "\(baseURL)search.php?s="
	static let searchByCategory = "\(baseURL)filter.php?c="
	static let searchByArea = "\(baseURL)filter.php?a="
	static let searchByIngredient = "\(baseURL)filter.php?i="
	static let staticMeal = "\(search)Arrabiata"
}

func fetchData<T: Decodable>(from urlString: String) async -> T? {
	guard let url = URL(string: urlString) else {
		print("Invalid URL: \(urlString)")
		return nil
	}
	
	do {
		let (data, _) = try await URLSession.shared.data(from: url)
//		print("Fetched data from: \(urlString)")
		let decodedResponse = try JSONDecoder().decode(T.self, from: data)
		return decodedResponse
	} catch {
		print("Fetch failed: \(error.localizedDescription)")
		return nil
	}
}

func fetchMeals(query: String) async -> [Meal] {
	let urlString = APIString.search + (query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
	let response: APIMealResponse? = await fetchData(from: urlString)
	return response?.meals ?? []
}

func fetchMealsByItem(from urlString: String) async -> [Meal] {
	let response: APIMealResponse? = await fetchData(from: urlString)
	// Uses response meals names to fetch the full meals one by one and then add them to meals before returning. The API does not return a full meal when searching by category, area or ingredient...
	var meals: [Meal] = []
	print("fetchMealsByItem response: \(response?.meals ?? [])")
	for response in response?.meals ?? [] {
		print("Fetching \(response.name)")
		let meal = await fetchMeals(query: response.name)
		meals.append(contentsOf: meal)
	}
	return meals
}

func APISerciveFetchIngredients() async -> [IngredientModel] {
	let urlString = APIString.ingredientList
	let response: IngredientsResponse? = await fetchData(from: urlString)
	return response?.meals ?? []
}

func APIServiceFetchCategories() async -> [CategoryModel] {
	let urlString = APIString.categoryList
	let response: CategoriesResponse? = await fetchData(from: urlString)
	return response?.categories ?? []
}

func APIServiceFetchAreas() async -> [AreaModel] {
	let urlString = APIString.areaList
	let response: AreasResponse? = await fetchData(from: urlString)
	return response?.meals ?? []
}
