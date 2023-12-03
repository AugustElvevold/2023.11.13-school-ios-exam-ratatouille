//
//  APISercive.swift
//  Ratatouille
//
//  Created by Kandidatnr: 2003 on 20/11/2023.
//

import Foundation
import SwiftData

struct APIString {
	static let baseURL = "https://www.themealdb.com/api/json/v1/1/"
	static let categoryListFull = "\(baseURL)categories.php"
	static let categoryList = "\(baseURL)list.php?c=list"
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
		let decodedResponse = try JSONDecoder().decode(T.self, from: data)
		return decodedResponse
	} catch {
		print("Fetch failed: \(error.localizedDescription)")
		return nil
	}
}

func fetchMeals(query: String) async -> [MealModel] {
	let urlString = APIString.search + (query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
	let response: APIMealResponse? = await fetchData(from: urlString)
	return response?.meals ?? []
}

func fetchMealsByItem(from urlString: String) async -> [MealModel] {
	let response: APIMealResponse? = await fetchData(from: urlString)
	var meals: [MealModel] = []
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
	let urlString = APIString.categoryListFull
	let response: CategoriesResponse? = await fetchData(from: urlString)
	return response?.categories ?? []
}

func APIServiceFetchAreas() async -> [AreaModel] {
	let urlString = APIString.areaList
	let response: AreasResponse? = await fetchData(from: urlString)
	return response?.meals ?? []
}

struct FilterListResponse: Decodable {
	var filters: [Filter]?
	
	enum CodingKeys: String, CodingKey {
		case filters = "meals"
	}
}

struct Filter: Identifiable, Decodable {
	var id = UUID()
	var name: String?
	
	private enum CodingKeys: String, CodingKey {
		case category = "strCategory"
		case country = "strArea"
		case ingredient = "strIngredient"
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		if let category = try container.decodeIfPresent(String.self, forKey: .category) {
			self.name = category
		} else if let country = try container.decodeIfPresent(String.self, forKey: .country) {
			self.name = country
		} else if let ingredient = try container.decodeIfPresent(String.self, forKey: .ingredient) {
			self.name = ingredient
		} else {
			self.name = nil
		}
	}
}

func fetchFilterOptions(urlString: String) async -> [String] {
	let response: FilterListResponse? = await fetchData(from: urlString)
	return response?.filters?.compactMap { $0.name?.capitalized } ?? []
}
