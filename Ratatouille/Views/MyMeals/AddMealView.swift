//
//  AddMealView.swift
//  Ratatouille
//
//  Created by Kandidatnr: 2003 on 25/11/2023.
//

import SwiftUI
import SwiftData

struct AddMealView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@State private var name: String = ""
	@State private var category: String = ""
	@State private var area: String = ""
	@State private var instructions: String = ""
	@State private var thumbNailURL: String = ""
	@State private var youtubeLink: String = ""
	@State private var recipeSourceURL: String = ""
	@State private var ingredientEntries: [( ingredient: String, measure: String)] = []
	
	private var isFormEdited: Bool {
		!name.isEmpty || !category.isEmpty || !area.isEmpty ||
		!instructions.isEmpty || !thumbNailURL.isEmpty ||
		!youtubeLink.isEmpty || !recipeSourceURL.isEmpty ||
		!ingredientEntries.allSatisfy { $0.ingredient.isEmpty && $0.measure.isEmpty }
	}
	
	var body: some View {
		Form {
			Section(header: Text("Måltid")) {
				TextField("Navn", text: $name)
				TextField("Kategori", text: $category)
				TextField("Land", text: $area)
				TextField("Instrukser", text: $instructions)
				TextField("Bilde URL", text: $thumbNailURL)
				TextField("YouTube URL", text: $youtubeLink)
				TextField("Kilde URL", text: $recipeSourceURL)
			}
			
			Section(header: Text("Ingredienser")) {
				ForEach(0..<ingredientEntries.count, id: \.self) { index in
					HStack {
						TextField("Ingrediens", text: self.$ingredientEntries[index].ingredient)
						TextField("Mål", text: self.$ingredientEntries[index].measure)
					}
				}
				.onDelete(perform: removeIngredients)
				
				Button(action: addIngredient) {
					Text("Legg til ingrediens")
				}
			}
		}
		.navigationBarItems(trailing: Button("Lagre") {
			saveMeal()
		}.disabled(!isFormEdited))
	}
	
	private func addIngredient() {
		if ingredientEntries.count < 20 {
			ingredientEntries.append(("", ""))
		}
	}
	
	private func removeIngredients(at offsets: IndexSet) {
		ingredientEntries.remove(atOffsets: offsets)
	}
	
	private func saveMeal() {
		let meal = Meal()
		
		// Only set attributes if they have been provided, otherwise the default value in Meal init will be used
		if !name.isEmpty {
			meal.name = name
		}
		if !category.isEmpty {
			meal.strCategory = category
		}
		if !area.isEmpty {
			meal.strArea = area
		}
		if !instructions.isEmpty {
			meal.strInstructions = instructions
		}
		if !thumbNailURL.isEmpty {
			meal.strMealThumb = thumbNailURL
		}
		if !youtubeLink.isEmpty {
			meal.strYoutube = youtubeLink
		}
		if !recipeSourceURL.isEmpty {
			meal.strSource = recipeSourceURL
		}
		
		// Convert ingredientEntries to the required format
		meal.ingredients = ingredientEntries.filter { !$0.ingredient.isEmpty && !$0.measure.isEmpty }
			.map { [$0.ingredient, $0.measure] }
		meal.saved = true
		// Add meal to database
		modelContext.insert(meal)
		dismiss()
	}
}

#Preview {
    AddMealView()
		.modelContainer(for: Meal.self)
}
