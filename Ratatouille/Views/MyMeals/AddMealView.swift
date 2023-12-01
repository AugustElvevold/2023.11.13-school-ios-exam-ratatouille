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
	@State private var newMeal: MealModel = MealModel()
	@State private var thumbNailURL: String = ""
	@State private var ingredientEntries: [( ingredient: String, measure: String)] = []
	@State private var showAlert: Bool = false
	
	private var isRequiredFieldsAdded: Bool {
		!newMeal.name.isEmpty || !newMeal.instructions.isEmpty || !ingredientEntries.allSatisfy { $0.ingredient.isEmpty && $0.measure.isEmpty } 
	}
	
	var body: some View {
		NavigationStack{
			Form {
				Section {
					TextField("Navn", text: $newMeal.name)
					TextField("Kategori", text: $newMeal.strCategory)
					//					TextField("Land", text: $newMeal.strArea.name)
					TextField("Land", text: $newMeal.strArea)
				} header: {
					Text("Måltid")
				}
					Section{
						ZStack(alignment: .topLeading) {
							if newMeal.instructions.isEmpty {
								Text("Skriv inn instrukser her...")
									.foregroundColor(.gray.opacity(0.5))
									.padding(.top, 8)
									.padding(.leading, 4)
							}
							TextEditor(text: $newMeal.instructions)
								.frame(minHeight: 60)
						}
					} header: {
						Text("Instrukser")
					}
				Section{
					TextField("Bilde URL", text: $thumbNailURL)
					TextField("YouTube URL", text: $newMeal.linkYoutube)
					TextField("Kilde URL", text: $newMeal.linkSource)
				} header: {
					Text("Måltid")
				}
				
				Section {
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
				} header: {
					Text("Ingredienser")
				}
			}
		}
		.toolbar(content: {
			ToolbarItem(placement: .cancellationAction){
				Button("Avbryt", role: .cancel){
					dismiss()
				}
			}
			ToolbarItem(placement: .confirmationAction){
				Button(action: {
					saveMeal()
					dismiss()
				}, label: {
					Text("Lagre")
				})
				.disabled(!isRequiredFieldsAdded)
			}
		})
		.navigationBarBackButtonHidden()
		.alert(isPresented: $showAlert) {
			Alert(
				title: Text("Feil"),
				message: Text(missingFieldsMessage()),
				dismissButton: .default(Text("OK")))
		}
	}
	private func missingFieldsMessage() -> String {
		var missingFields = [String]()
		
		if newMeal.name.isEmpty {
			missingFields.append("navn")
		}
		if newMeal.instructions.isEmpty {
			missingFields.append("instruksjoner")
		}
		if ingredientEntries.allSatisfy({ $0.ingredient.isEmpty && $0.measure.isEmpty }) {
			missingFields.append("ingredienser")
		}
		
		return missingFields.isEmpty ? "" : "Mangler påkrevde felter: " + missingFields.joined(separator: ", ")
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
		newMeal.image = URL(string: thumbNailURL) ?? Missing.imageUrl
		newMeal.saved = true
		newMeal.ingredients  = ingredientEntries.filter { !$0.ingredient.isEmpty && !$0.measure.isEmpty }
			.map { [$0.ingredient, $0.measure] }

		modelContext.insert(newMeal)
		dismiss()
	}
}
