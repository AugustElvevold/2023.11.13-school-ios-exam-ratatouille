//
//  CategoryModel.swift
//  Ratatouille
//
//  Created by August Elvevold on 28/11/2023.
//

import Foundation
import SwiftData

@Model
final class CategoryModel: Decodable, Identifiable {
	@Attribute(.unique) var uuid: UUID
	var id: String
	var name: String
	var categoryDescription: String
	var categoryThumb: URL
	var archived: Bool
	
	@Relationship(deleteRule: .nullify, inverse: \Meal.category)
	var meals: [Meal]?
	
	init(
		_ id: String = "",
		_ name: String = "",
		_ categoryDescription: String = "",
		_ categoryThumb: URL = Missing.imageUrl
	){
		self.uuid = UUID()
		self.id = id
		self.name = name
		self.categoryDescription = categoryDescription
		self.categoryThumb = categoryThumb
		self.archived = false
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
		self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
		self.categoryDescription = try container.decodeIfPresent(String.self, forKey: .categoryDescription) ?? ""
		self.categoryThumb = try container.decodeIfPresent(URL.self, forKey: .categoryThumb) ?? Missing.imageUrl
		self.uuid = UUID()
		self.archived = false
	}
	
	private enum CodingKeys: String, CodingKey {
		case id = "idCategory"
		case name = "strCategory"
		case categoryDescription = "strCategoryDescription"
		case categoryThumb = "strCategoryThumb"
	}
}

struct CategoriesResponse: Decodable {
	var categories: [CategoryModel]
}
