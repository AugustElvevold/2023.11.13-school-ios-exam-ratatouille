//
//  EditMealView.swift
//  Ratatouille
//
//  Created by August Elvevold on 26/11/2023.
//

import SwiftUI
import SwiftData

struct EditMealView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@Bindable var meal: Meal
	
	@State private var name: String = ""
	@State private var strCategory: String = ""
	@State private var strArea: String = ""
	@State private var strInstructions: String = ""
	@State private var strMealThumb: String = ""
	@State private var strYoutube: String = ""
	@State private var strSource: String = ""
	@State private var ingredients: [( ingredient: String, measure: String)] = []
	
	private var isFormEdited: Bool {
		!name.isEmpty || !strCategory.isEmpty || !strArea.isEmpty ||
		!strInstructions.isEmpty || !strMealThumb.isEmpty ||
		!strYoutube.isEmpty || !strSource.isEmpty ||
		!ingredients.allSatisfy { $0.ingredient.isEmpty && $0.measure.isEmpty }
	}
	
	var body: some View {
		Form {
			Section(header: Text("Måltid")) {
				TextField("Navn", text: $name)
				TextField("Kategori", text: $strCategory)
				TextField("Land", text: $strArea)
				TextField("Instrukser", text: $strInstructions)
				TextField("Bilde URL", text: $strMealThumb)
				TextField("YouTube URL", text: $strYoutube)
				TextField("Kilde URL", text: $strSource)
			}
			
			Section(header: Text("Ingredienser")) {
				ForEach($ingredients.indices, id: \.self) { index in
					HStack {
						TextField("Ingrediens", text: $ingredients[index].ingredient)
						TextField("Mål", text: $ingredients[index].measure)
					}
				}
				.onDelete(perform: removeIngredients)
				
				Button("Legg til ingrediens", action: addIngredient)
			}
		}
		.navigationBarItems(trailing: Button("Lagre") {
			updateMeal()
		})
		.onAppear(){
			// Update the local state with the meal data
			name = meal.name
			strCategory = meal.strCategory
			strArea = meal.strArea
			strInstructions = meal.strInstructions
			strMealThumb = meal.strMealThumb
			strYoutube = meal.strYoutube
			strSource = meal.strSource
			ingredients = meal.ingredients.map { (ingredient: $0[0], measure: $0[1]) }
		}
	}
	
	private func addIngredient() {
		meal.ingredients.append(["", ""])
	}
	
	private func removeIngredients(at offsets: IndexSet) {
		meal.ingredients.remove(atOffsets: offsets)
	}
	
	private func updateMeal() {
//		meal.edited = true
		meal.updatedDate = .now
		meal.name = name
		meal.strCategory = strCategory
		meal.strArea = strArea
		meal.strInstructions = strInstructions
		meal.strMealThumb = strMealThumb
		meal.strYoutube = strYoutube
		meal.strSource = strSource
		meal.ingredients = ingredients.map { [$0.ingredient, $0.measure] }
		dismiss()
	}
}

//#Preview {
//    EditMealView()
//}
