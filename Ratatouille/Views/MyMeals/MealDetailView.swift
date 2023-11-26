//
//  MealDetailView.swift
//  Ratatouille
//
//  Created by August Elvevold on 26/11/2023.
//

import SwiftUI
import SwiftData

struct MealDetailView: View {
	let meal: Meal
	
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 10) {
				Text(meal.name)
					.font(.title)
					.fontWeight(.bold)
				
				if !meal.strMealThumb.isEmpty {
					AsyncImage(url: URL(string: meal.strMealThumb)) { image in
						image.resizable()
					} placeholder: {
						ProgressView()
					}
					.aspectRatio(contentMode: .fit)
					.cornerRadius(8)
				}
				
				Text("Category: \(meal.strCategory)")
				Text("Area: \(meal.strArea)")
				Text("Instructions:")
					.fontWeight(.semibold)
				Text(meal.strInstructions)
				
				if !meal.ingredients.isEmpty {
					VStack(alignment: .leading) {
						Text("Ingredients:")
							.fontWeight(.semibold)
						ForEach(meal.ingredients, id: \.self) { ingredient in
							Text(ingredient.joined(separator: ": "))
						}
					}
				}
				
				if !meal.strYoutube.isEmpty {
					Link("Watch on YouTube", destination: URL(string: meal.strYoutube)!)
				}
				
				Spacer()
			}
			.padding()
		}
		.navigationTitle(meal.name)
		.navigationBarTitleDisplayMode(.inline)
	}
}

#Preview {
	let meal = Meal(id: "01", name: "Spaghetti Bolognese", strCategory: "Pasta", strArea: "Italian", strInstructions: "Cook pasta. Prepare sauce. Mix and serve.", strMealThumb: "", strYoutube: "", ingredients: [["Pasta", "200g"], ["Tomato Sauce", "100g"]], strSource: "")
	return MealDetailView(meal: meal)
}
