//
//  AreaModel.swift
//  Ratatouille
//
//  Created by August Elvevold on 29/11/2023.
//

import Foundation
import SwiftData

@Model
final class AreaModel: Decodable, Identifiable {
	static let defaultFlagUrl = URL(string: "https://upload.wikimedia.org/wikipedia/commons/2/2f/Missing_flag.png")!
	
	@Attribute(.unique) var uuid: UUID
	var name: String
	var countryCode: String
	var flagUrl: URL
	var archived: Bool
	
	@Relationship(deleteRule: .nullify, inverse: \Meal.category)
	var meals: [Meal]?
	
	init(
		_ name: String = "",
		_ countryCode: String = ""
	){
		self.uuid = UUID()
		self.name = name
		self.countryCode = countryCode
		self.flagUrl = AreaModel.defaultFlagUrl
		self.archived = false
		addCountryCode()
		updateFlagUrl()
	}
	
	@Relationship(deleteRule: .nullify, inverse: \Meal.area)
	var meals: [Meal]?
	
	func updateFlagUrl() {
		if (countryCode.count == 2 ){
			self.flagUrl = URL(string: "https://flagsapi.com/\(countryCode.uppercased())/flat/64.png")!
		} else {
			self.flagUrl = AreaModel.defaultFlagUrl
		}
	}
	
	func updateCountryCode() {
		if countryCode.isEmpty {
			addCountryCode()
		}
	}
	
	func addCountryCode() {
		self.countryCode = AreaManager.shared.countryCode(forArea: name)
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
		self.flagUrl = try container.decodeIfPresent(URL.self, forKey: .flagUrl) ?? AreaModel.defaultFlagUrl
		self.uuid = UUID()
		self.archived = false
		self.countryCode = ""
		addCountryCode()
		updateFlagUrl()
	}
	
	private enum CodingKeys: String, CodingKey {
		case name = "strArea"
		case flagUrl
	}
}

struct AreasResponse: Decodable {
	var meals: [AreaModel]
}

class AreaManager {
	static let shared = AreaManager()
	
	private var areas: [String: AreaModel] = [:]
	
	var areaToCountryCode: [String: String] = [
		"American": "US",
		"British": "GB",
		"Canadian": "CA",
		"Chinese": "CN",
		"Croatian": "HR",
		"Dutch": "NL",
		"Egyptian": "EG",
		"Filipino": "PH",
		"Greek": "GR",
		"French": "FR",
		"Indian": "IN",
		"Irish": "IR",
		"Italian": "IT",
		"Jamaican": "JM",
		"Japanese": "JP",
		"Kenyan": "KE",
		"Malaysian": "MY",
		"Mexican": "MX",
		"Moroccan": "MA",
		"Polish": "PL",
		"Portuguese": "PT",
		"Russian": "RU",
		"Spanish": "ES",
		"Thai": "TH",
		"Tunisian": "TN",
		"Turkish": "TR",
		"Vietnamese": "VN"
	]
	
	private init() {}
	
	func countryCode(forArea area: String) -> String {
		areaToCountryCode[area] ?? ""
	}
	
	func findOrCreateArea(named name: String) -> AreaModel {
		if let existingArea = areas[name] {
			return existingArea
		} else {
			let newArea = AreaModel(name)
			areas[name] = newArea
			return newArea
		}
	}
}
