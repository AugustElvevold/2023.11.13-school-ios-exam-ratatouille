//
//  IngredientsModel.swift
//  Ratatouille
//
//  Created by Kandidatnr: 2003 on 28/11/2023.
//

import Foundation
import SwiftData

@Model
final class IngredientModel: Decodable, Identifiable {
	@Attribute(.unique) var uuid: UUID
	var id: String
	var name: String
	var ingredientDescription: String
	var type: String
	var archived: Bool
	
	init(
		_ id: String = "",
		_ name: String = "",
		_ ingredientDescription: String = "",
		_ type: String = ""
	){
		self.uuid = UUID()
		self.id = id
		self.name = name
		self.ingredientDescription = ingredientDescription
		self.type = type
		self.archived = false
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
		self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
		self.ingredientDescription = try container.decodeIfPresent(String.self, forKey: .ingredientDescription) ?? ""
		self.type = try container.decodeIfPresent(String.self, forKey: .type) ?? ""
		self.uuid = UUID()
		self.archived = false
	}
	
	private enum CodingKeys: String, CodingKey {
		case id = "idIngredient"
		case name = "strIngredient"
		case ingredientDescription = "strDescription"
		case type = "strType"
	}
}

struct IngredientsResponse: Decodable {
	var meals: [IngredientModel]
}

