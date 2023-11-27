//
//  MealDetailView.swift
//  Ratatouille
//
//  Created by Kandidatnr: 2003 on 26/11/2023.
//

import SwiftUI
import SwiftData

struct MealDetailView: View {
	@Bindable var meal: Meal
	
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 0) {
				// Image without padding to take full width
				if !meal.strMealThumb.isEmpty {
					AsyncImage(url: URL(string: meal.strMealThumb)) { image in
						image.resizable()
					} placeholder: {
						ProgressView()
					}
					.aspectRatio(contentMode: .fit)
					.frame(maxWidth: .infinity)
//					.cornerRadius(8)
				}
				
				// Content with padding
				VStack(alignment: .leading, spacing: 10) {
					Text(meal.name)
						.font(.title)
						.fontWeight(.bold)
					
					Text("Kategori: \(meal.strCategory)")
					Text("Land: \(meal.strArea)")
					Text("Instruksjoner:")
						.fontWeight(.bold)
						.font(.headline)
					Text(meal.strInstructions)
					
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
						if !meal.strSource.isEmpty {
							Link(destination: URL(string: meal.strSource)!) {
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
						
						if !meal.strYoutube.isEmpty {
							Link(destination: URL(string: meal.strYoutube)!) {
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
				if (meal.saved) {
					NavigationLink(destination: EditMealView(meal: meal)) {
						Text("Rediger")
					}
				}
			}
		}
	}
}


//#Preview {
//	let json = """
// {
// "idMeal": "52771",
// "strMeal": "Spicy Arrabiata Penne",
// "strCategory": "Vegetarian",
// "strArea": "Italian",
// "strInstructions": "Bring a large pot of water to a boil...",
// "strMealThumb": "https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg",
// "strYoutube": "https://www.youtube.com/watch?v=1IszT_guI08",
// "strIngredient1": "penne rigate",
// "strMeasure1": "1 pound",
// "strIngredient2": "olive oil",
// "strMeasure2": "1/4 cup",
// "strIngredient3": "garlic",
// "strMeasure3": "3 cloves",
// "strIngredient4": "chopped tomatoes",
// "strMeasure4": "1 tin",
// "strIngredient5": "red chile flakes",
// "strMeasure5": "1/2 teaspoon",
// "strIngredient6": "italian seasoning",
// "strMeasure6": "1/2 teaspoon",
// "strIngredient7": "basil",
// "strMeasure7": "6 leaves",
// "strIngredient8": "Parmigiano-Reggiano",
// "strMeasure8": "sprinkling",
// "strIngredient9": "",
// "strMeasure9": "",
// "strIngredient10": "",
// "strMeasure10": "",
// "strIngredient11": "",
// "strMeasure11": "",
// "strIngredient12": "",
// "strMeasure12": "",
// "strIngredient13": "",
// "strMeasure13": "",
// "strIngredient14": "",
// "strMeasure14": "",
// "strIngredient15": "",
// "strMeasure15": "",
// "strIngredient16": "",
// "strMeasure16": "",
// "strIngredient17": "",
// "strMeasure17": "",
// "strIngredient18": "",
// "strMeasure18": "",
// "strIngredient19": "",
// "strMeasure19": "",
// "strIngredient20": "",
// "strMeasure20": ""
// }
// """
//	let dummyMeal: Meal
//	if let jsonData = json.data(using: .utf8) {
//		dummyMeal = try! JSONDecoder().decode(Meal.self, from: jsonData)
//	} else {
//		fatalError("Invalid JSON")
//	}
//	return MealDetailView(meal: dummyMeal)
//}
