//
//  Meal.swift
//  Ratatouille
//
//  Created by Kandidatnr: 2003 on 18/11/2023.
//

import Foundation
import SwiftData

@Model
final class Meal: Decodable, Identifiable {
	@Attribute(.unique) var uuid: UUID
	var id: String
	var name: String
	var strCategory: String
	var strArea: String
	var strInstructions: String
	var strMealThumb: String
	var strYoutube: String
	var ingredients: [[String]]
	var strSource: String
	var saved: Bool
	var updatedDate: Date
	var createdDate: Date
	var archived: Bool
	var favorite: Bool
	
	init(
		id: String = "",
		name: String = "",
		strCategory: String = "",
		strArea: String = "",
		strInstructions: String = "",
		strMealThumb: String = "https://static.vecteezy.com/system/resources/previews/005/337/799/non_2x/icon-image-not-found-free-vector.jpg",
		strYoutube: String = "",
		ingredients: [[String]] = [],
		strSource: String = ""
	) {
		self.uuid = UUID()
		self.id = id
		self.name = name
		self.strCategory = strCategory
		self.strArea = strArea
		self.strInstructions = strInstructions
		self.strMealThumb = strMealThumb
		self.strYoutube = strYoutube
		self.ingredients = ingredients
		self.strSource = strSource
		self.saved = false
		self.updatedDate = .now
		self.createdDate = .now
		self.archived = false
		self.favorite = false
	}
	
	enum CodingKeys: String, CodingKey {
		case id = "idMeal"
		case name = "strMeal"
		case strCategory, strArea, strInstructions, strMealThumb, strYoutube, strSource
		case strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5, strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10, strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15, strIngredient16, strIngredient17, strIngredient18, strIngredient19, strIngredient20
		case strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5, strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10, strMeasure11, strMeasure12, strMeasure13, strMeasure14, strMeasure15, strMeasure16, strMeasure17, strMeasure18, strMeasure19, strMeasure20
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		id = try container.decode(String.self, forKey: .id)
		name = try container.decode(String.self, forKey: .name)
		strCategory = try container.decodeIfPresent(String.self, forKey: .strCategory) ?? "Unknown Category"
		strArea = try container.decodeIfPresent(String.self, forKey: .strArea) ?? "Unknown Area"
		strInstructions = try container.decodeIfPresent(String.self, forKey: .strInstructions) ?? "No Instructions"
		strMealThumb = try container.decodeIfPresent(String.self, forKey: .strMealThumb) ?? "https://static.vecteezy.com/system/resources/previews/005/337/799/non_2x/icon-image-not-found-free-vector.jpg"
		strYoutube = try container.decodeIfPresent(String.self, forKey: .strYoutube) ?? ""
		strSource = try container.decodeIfPresent(String.self, forKey: .strSource) ?? ""
		
		var tempIngredients: [[String]] = []
		for i in 1...20 {
			let ingredientKey = CodingKeys(rawValue: "strIngredient\(i)")!
			let measureKey = CodingKeys(rawValue: "strMeasure\(i)")!
			
			if let ingredient = try container.decodeIfPresent(String.self, forKey: ingredientKey),
				 let measure = try container.decodeIfPresent(String.self, forKey: measureKey),
				 !ingredient.isEmpty, !measure.isEmpty {
				tempIngredients.append([ingredient, measure])
			}
		}
		self.ingredients = tempIngredients
		
		// Set default values for properties not present in the API response
		uuid = UUID()
		saved = false
		updatedDate = .now
		createdDate = .now
		archived = false
		favorite = false
	}
}

struct APIMealResponse: Decodable {
	var meals: [Meal]?
}
