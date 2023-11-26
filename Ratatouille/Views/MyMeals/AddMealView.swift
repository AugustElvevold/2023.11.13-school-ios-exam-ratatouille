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
//	@State private var meal: Meal = Meal(id: "", name: "", strCategory: "", strArea: "", strInstructions: "", strMealThumb: "", strYoutube: "", ingredients: [], strSource: "")
	@State private var name: String = ""
//	@State private var ingredientEntries: [(
//		ingredient: String,
//		measure: String)
//	] = []
	
	var body: some View {
		Form {
			Section(header: Text("Meal Details")) {
				TextField("Navn", text: $name)
//				TextField("Name", text: $meal.name)
//				TextField("Category", text: $meal.strCategory)
//				TextField("Area", text: $meal.strArea)
//				TextField("Instructions", text: $meal.strInstructions)
//				TextField("Image URL", text: $meal.strMealThumb)
//				TextField("YouTube URL", text: $meal.strYoutube)
//				TextField("Source URL", text: $meal.strSource)
			}
			
			Section(header: Text("Ingredients")) {
				Text("FUCK INGREDIENTS")
//				ForEach(0..<ingredientEntries.count, id: \.self) { index in
//					HStack {
//						TextField("Ingredient", text: self.$ingredientEntries[index].ingredient)
//						TextField("Measure", text: self.$ingredientEntries[index].measure)
//					}
//				}
//				.onDelete(perform: removeIngredients)
				
//				Button(action: addIngredient) {
//					Text("Add Ingredient")
//				}
			}
		}
		.navigationBarItems(trailing: Button("Save") {
			// Code to save the meal
			saveMeal()
		})
	}
	
//	private func addIngredient() {
//		if ingredientEntries.count < 20 {
//			ingredientEntries.append(("", ""))
//		}
//	}
//	
//	private func removeIngredients(at offsets: IndexSet) {
//		ingredientEntries.remove(atOffsets: offsets)
//	}
//	
	private func saveMeal() {
		// Convert ingredientEntries to the required format and save the meal
//		meal.ingredients = ingredientEntries.map { [$0.ingredient, $0.measure] }
		let meal = Meal(id: "", name: "", strCategory: "", strArea: "", strInstructions: "", strMealThumb: "", strYoutube: "", ingredients: [], strSource: "")
		meal.name = name;
		modelContext.insert(meal)
		// Save the meal here...
	}
}

#Preview {
    AddMealView()
		.modelContainer(for: Meal.self)
}
