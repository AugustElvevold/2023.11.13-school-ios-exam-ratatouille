//
//  MealDetailView.swift
//  Ratatouille
//
//  Created by Kandidatnr: 2003 on 26/11/2023.
//

import SwiftUI
import SwiftData

struct MealDetailView: View {
	@Environment(\.modelContext) private var modelContext
	@Bindable var meal: Meal
	var isSearchResult: Bool = false
	@State var alreadySavedMeal = false
	
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 0) {
					AsyncImage(url: meal.image) { image in
						image.resizable()
					} placeholder: {
						ProgressView()
					}
					.aspectRatio(contentMode: .fit)
					.frame(maxWidth: .infinity)
//					.cornerRadius(8)
				
				// Content with padding
				VStack(alignment: .leading, spacing: 10) {
					Text(meal.name)
						.font(.title)
						.fontWeight(.bold)
					
					Text("Kategori: \(meal.category)")
//					Text("Land: \(meal.area.name)")
					Text("Land: \(meal.area)")
					Text("Instruksjoner:")
						.fontWeight(.bold)
						.font(.headline)
					Text(meal.instructions)
					
					if !meal.ingredients.isEmpty {
						VStack(alignment: .leading) {
							Text("Ingredienser:")
								.fontWeight(.bold)
								.font(.headline)
							ForEach(meal.ingredients, id: \.self) { ingredient in
								HStack {
									Text(ingredient[0])
										.fontWeight(.bold)
										.frame(maxWidth: .infinity, alignment: .leading)
									Spacer()
									Text(ingredient[1])
										.frame(maxWidth: 100, alignment: .leading)
								}
							}
						}
					}
					
					VStack {
						if !meal.linkSource.isEmpty {
							Link(destination: URL(string: meal.linkSource)!) {
								HStack {
									Image(systemName: "globe")
										.foregroundColor(.white)
									Text("Gå til oppskrift")
										.foregroundColor(.white)
										.fontWeight(.semibold)
								}
								.padding()
								.background(Color.blue)
								.cornerRadius(8)
							}
						}
						
						if !meal.linkYoutube.isEmpty {
							Link(destination: URL(string: meal.linkYoutube)!) {
								HStack {
									Image(systemName: "play.circle")
										.foregroundColor(.white)
									Text("Se på YouTube")
										.foregroundColor(.white)
										.fontWeight(.semibold)
								}
								.padding()
								.background(Color.red)
								.cornerRadius(8)
							}
						}
					}
					.buttonStyle(.plain)
					
					Spacer()
				}
				.padding(32)
			}
		}
		.navigationTitle(meal.name)
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				if (meal.saved && !isSearchResult) {
					NavigationLink(destination: EditMealView(meal: meal)) {
						Text("Rediger")
					}
				} else {
					Button() {
						saveMeal(meal: meal)
					} label: {
						Text("Lagre")
					}
					.disabled(meal.saved || alreadySavedMeal)
				}
			}
		}
	}
	func saveMeal(meal: Meal) {
		let meal = Meal(
			id: meal.id,
			name: meal.name,
			strCategory: meal.category,
			//			strArea: meal.area.name,
			strArea: meal.area,
			strInstructions: meal.instructions,
			strMealThumb: meal.image,
			strYoutube: meal.linkYoutube,
			ingredients: meal.ingredients,
			strSource: meal.linkSource
		)
		let time = Date.now
		meal.createdDate = time
		meal.updatedDate = time
		meal.saved = true
		modelContext.insert(meal)
		try? modelContext.save()
		alreadySavedMeal = true
	}
}
