//
//  MyMealsView.swift
//  Ratatouille
//
//  Created by Kandidatnr: 2003 on 18/11/2023.
//

import SwiftUI
import SwiftData

struct MyMealsView: View {
	@Environment(\.modelContext) private var modelContext
	@EnvironmentObject var tabSelection: TabSelection
	
	@Query(
		filter: #Predicate<MealModel> { $0.archived == false }
	) private var meals: [MealModel] = [MealModel]()
	
	var body: some View {
		NavigationStack {
			Group{
				if meals.isEmpty {
					ContentUnavailableView {
						Label("Ingen oppskrifter", systemImage: "tray.fill")
					} description: {
						Button{
							tabSelection.selectedTab = .search
						} label: {
							Text("Søk etter oppskrifter")
						}
						.padding(.top, 8)
					}
				} else {
					List(meals, id: \.self) { meal in
						NavigationLink(destination: MealDetailView(meal: meal)){
							MyMealRowView(meal: meal)
						}
						
					}
					.listStyle(.plain)
				}
			}
			.navigationTitle("Oppskrifter")
			.toolbar {
				NavigationLink(destination: AddMealView()) {
					Label("Legg til oppskrift", systemImage: "plus")
				}
			}
		}
	}
}

#Preview {
	MyMealsView()
		.modelContainer(for: MealModel.self)
}

struct MyMealRowView: View {
	@State var meal: MealModel
	
	var body: some View {
		HStack {
			AsyncImage(url: meal.image) { image in
				image.resizable()
			} placeholder: {
				Color.gray.frame(width: 80, height: 80)
			}
			.frame(width: 80, height: 80)
			.cornerRadius(10)
			
			VStack(alignment: .leading, spacing: 4) {
				Text(meal.name)
					.font(.headline)
					.lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
				Text(meal.strCategory)
					.font(.subheadline)
					.foregroundColor(.secondary)
					.lineLimit(1)
				//				Text(meal.strArea.name)
				Text(meal.strArea)
					.font(.subheadline)
					.foregroundColor(.secondary)
					.lineLimit(1)
			}
			
			Spacer()
			VStack{
				if meal.favorite{
					Image(systemName: "star.fill").foregroundColor(.yellow)
				}
				Spacer()
			}
		}
		.padding(.vertical, -0)
		.padding(.horizontal, -8)
		.swipeActions(edge: .trailing){
			Button(role: .destructive) {
				archiveMeal(meal)
			} label: {
				Label("Arkiver", systemImage: "archivebox.fill")
			}
		}
		.swipeActions(edge: .leading){
			Button() {
				toggleFavoriteMeal(meal)
			} label: {
				Label("Favoriser", systemImage: "star.fill")
			}
			.tint(meal.favorite ? .gray : .yellow)
		}
	}
	private func toggleFavoriteMeal(_ meal: MealModel) {
		meal.favorite = !meal.favorite
	}
	private func archiveMeal(_ meal: MealModel) {
		meal.archived = true
	}
}

struct MealDetailView: View {
	@Environment(\.modelContext) private var modelContext
	@Bindable var meal: MealModel
	var isSearchResult: Bool = false
	@State var alreadySavedMeal = false
	
	var body: some View {
		NavigationStack{
			List {
				Section {
					AsyncImage(url: meal.image) { image in
						image.resizable()
					} placeholder: {
						ProgressView()
					}
					.aspectRatio(contentMode: .fill)
					.frame(maxWidth: .infinity)
					
					.listRowInsets(EdgeInsets())
				}
				.frame(height: 300)
				
				Section(header: Text("Info")) {
					HStack{
						Text("Kategori: \(meal.strCategory)")
						Spacer()
						Text("Land: \(meal.strArea)")
					}
				}
				Section(header: Text("Instruksjoner")) {
					Text(meal.instructions)
				}
				
				if !meal.ingredients.isEmpty {
					Section(header: Text("Ingredienser")) {
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
				
				if !meal.linkSource.isEmpty || !meal.linkYoutube.isEmpty {
					Section(header: Text("Lenker")) {
						if !meal.linkSource.isEmpty {
							Link(destination: URL(string: meal.linkSource)!) {
								HStack {
									AsyncImage(url: URL(string: "https://icons.iconarchive.com/icons/johanchalibert/mac-osx-yosemite/256/safari-icon.png")) { image in
										image.resizable()
									} placeholder: {
										ProgressView()
									}
									.aspectRatio(contentMode: .fill)
									.frame(width: 20, height: 25)
									
									Text("Gå til oppskrift")
										.foregroundColor(.blue)
										.padding(.leading, 8)
								}
							}
						}
						
						if !meal.linkYoutube.isEmpty {
							Link(destination: URL(string: meal.linkYoutube)!) {
								HStack {
									AsyncImage(url: URL(string: "https://icons.iconarchive.com/icons/dakirby309/simply-styled/256/YouTube-icon.png")) { image in
										image.resizable()
									} placeholder: {
										ProgressView()
									}
									.aspectRatio(contentMode: .fill)
									.frame(width: 20, height: 25)
									Text("Se på YouTube")
										.foregroundColor(.red)
										.padding(.leading, 8)
								}
							}
						}
					}
					.buttonStyle(.plain)
				}
			}
//			.listStyle(GroupedListStyle())
			.navigationTitle(meal.name)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					if meal.saved && !isSearchResult {
						NavigationLink(destination: EditMealView(meal: meal)) {
							Text("Rediger")
						}
					} else {
						Button {
							saveMeal(meal: meal)
						} label: {
							Text("Lagre")
						}
						.disabled(meal.saved || alreadySavedMeal)
					}
				}
			}
		}
	}

	func saveMeal(meal: MealModel) {
		self.meal.saved = true
		let meal = MealModel(
			id: meal.id,
			name: meal.name,
			strCategory: meal.strCategory,
			//			strArea: meal.strArea.name,
			strArea: meal.strArea,
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

struct EditMealView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	var meal: MealModel
	@State private var updatedMeal: MealModel = MealModel()
	@State private var stringUrl: String = ""
	@State private var ingredientEntries: [( ingredient: String, measure: String)] = []
	
	var body: some View {
		NavigationStack{
			Form {
				Section {
					TextField("Navn", text: $updatedMeal.name)
				} header: {
					Text("Navn")
				}
				Section {
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
				Section {
					TextField("Kategori", text: $updatedMeal.strCategory)
				} header: {
					Text("Kategori")
				}
				
				Section {
					TextField("Landområde", text: $updatedMeal.strArea)
				} header: {
					Text("Landområde")
				}
				Section {
					TextField("Bilde URL", text: $stringUrl)
				} header: {
					Text("Bilde URL")
				}
				Section {
					TextField("YouTube URL", text: $updatedMeal.linkYoutube)
				} header: {
					Text("YouTube URL")
				}
				Section {
					TextField("Kilde URL", text: $updatedMeal.linkSource)
				} header: {
					Text("Kilde URL")
				}
			}
			.onAppear(){
				updatedMeal.name = meal.name
				updatedMeal.strCategory = meal.strCategory
				updatedMeal.strArea = meal.strArea
				updatedMeal.instructions = meal.instructions
				updatedMeal.linkYoutube = meal.linkYoutube
				updatedMeal.linkSource = meal.linkSource
				updatedMeal.ingredients = meal.ingredients
				stringUrl = meal.image.absoluteString
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
			.navigationBarBackButtonHidden()
			.navigationTitle("Rediger")
		}
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

struct AddMealView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	@State private var newMeal: MealModel = MealModel()
	@State private var thumbNailURL: String = ""
	@State private var ingredientEntries: [( ingredient: String, measure: String)] = []
	
	private var isRequiredFieldsAdded: Bool {
		!newMeal.name.isEmpty && !newMeal.instructions.isEmpty && !ingredientEntries.allSatisfy { $0.ingredient.isEmpty && $0.measure.isEmpty }
	}
	
	var body: some View {
		NavigationStack{
			Form {
				Section {
					TextField("Navn", text: $newMeal.name)
				} header: {
					Text("Navn")
				} footer: {
					Text("Obligatorisk felt")
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
				} footer: {
					Text("Obligatorisk felt")
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
				} footer: {
					Text("Obligatorisk felt")
				}
				Section {
					TextField("Kategori", text: $newMeal.strCategory)
				} header: {
					Text("Kategori")
				}
				Section {
					TextField("Landområde", text: $newMeal.strArea)
				} header: {
					Text("Landområde")
				}
				Section{
					TextField("Bilde URL", text: $thumbNailURL)
				} header: {
					Text("Bilde URL")
				}
				Section{
					TextField("YouTube URL", text: $newMeal.linkYoutube)
				} header: {
					Text("YouTube URL")
				}
				Section{
					TextField("Kilde URL", text: $newMeal.linkSource)
				} header: {
					Text("Kilde URL")
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
		.navigationTitle("Legg til").navigationBarTitleDisplayMode(.inline)
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
