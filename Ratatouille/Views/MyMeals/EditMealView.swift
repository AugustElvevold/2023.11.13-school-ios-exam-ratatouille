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
	
	var meal: Meal
	@State private var updatedMeal: Meal = Meal()
	@State private var stringUrl: String = ""
	@State private var ingredientEntries: [( ingredient: String, measure: String)] = []

	var body: some View {
		Form {
			Section{
				TextField("Navn", text: $updatedMeal.name)
				TextField("Kategori", text: $updatedMeal.strCategory)
				//				TextField("Land", text: $updatedMeal.strArea.name)
				TextField("Land", text: $updatedMeal.strArea)
			} header: {
				Text("Måltid")
			}
				Section{
					ZStack(alignment: .topLeading) {
						if updatedMeal.instructions.isEmpty {
							Text("Skriv inn instrukser her...")
								.foregroundColor(.gray.opacity(0.5))
								.padding(.top, 8)
								.padding(.leading, 4)
						}
						TextEditor(text: $updatedMeal.instructions)
							.frame(minHeight: 60)
					}
				} header: {
					Text("Instrukser")
				}
			Section{
				TextField("Bilde URL", text: $stringUrl)
				TextField("YouTube URL", text: $updatedMeal.linkYoutube)
				TextField("Kilde URL", text: $updatedMeal.linkSource)
			} header: {
				Text("Lenker")
			}
			
			Section(header: Text("Ingredienser")) {
				ForEach($ingredientEntries.indices, id: \.self) { index in
					HStack {
						TextField("Ingrediens", text: $ingredientEntries[index].ingredient)
						TextField("Mål", text: $ingredientEntries[index].measure)
					}
				}
				.onDelete(perform: removeIngredients)
				
				Button("Legg til ingrediens", action: addIngredient)
			}
		}
		.onAppear(){
			updatedMeal.name = meal.name
			updatedMeal.strCategory = meal.strCategory
			updatedMeal.strArea = meal.strArea
			updatedMeal.instructions = meal.instructions
			updatedMeal.linkYoutube = meal.linkYoutube
			updatedMeal.linkSource = meal.linkSource
			ingredientEntries = meal.ingredients.map { (ingredient: $0[0], measure: $0[1]) }
		}
		.toolbar(content: {
			ToolbarItem(placement: .cancellationAction){
				Button("Avbryt", role: .cancel){
					dismiss()
				}
			}
			ToolbarItem(placement: .confirmationAction){
				Button(action: {
					updateMeal()
					dismiss()
				}, label: {
					Text("Lagre")
				})
				.disabled(updatedMeal.name.isEmpty || (updatedMeal.name == meal.name && updatedMeal.instructions == meal.instructions && updatedMeal.strCategory == meal.strCategory && updatedMeal.strArea == meal.strArea && updatedMeal.linkYoutube == meal.linkYoutube && updatedMeal.linkSource == meal.linkSource && updatedMeal.ingredients == meal.ingredients && URL(string: stringUrl) == meal.image))
			}
		})
		.navigationBarBackButtonHidden()
	}
	
	private func addIngredient() {
		updatedMeal.ingredients.append(["", ""])
	}
	
	private func removeIngredients(at offsets: IndexSet) {
		updatedMeal.ingredients.remove(atOffsets: offsets)
	}
	
	private func updateMeal() {
		meal.name = updatedMeal.name
		meal.strCategory = updatedMeal.strCategory
//		meal.strArea.name = updatedMeal.strArea.name
		meal.strArea = updatedMeal.strArea
		meal.instructions = updatedMeal.instructions
		meal.image = URL(string: stringUrl) ?? Missing.imageUrl
		meal.linkYoutube = updatedMeal.linkYoutube
		meal.linkSource = updatedMeal.linkSource
		meal.ingredients = ingredientEntries.filter { !$0.ingredient.isEmpty && !$0.measure.isEmpty }
			.map { [$0.ingredient, $0.measure] }
		meal.updatedDate = .now
		dismiss()
	}
}

//#Preview {
//    EditMealView()
//}
