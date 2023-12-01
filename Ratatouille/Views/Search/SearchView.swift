//
//  SearchView.swift
//  Ratatouille
//
//  Created by Kandidatnr: 2003 on 18/11/2023.
//

import SwiftUI
import SwiftData

struct SearchView: View {
	@Environment(\.modelContext) private var modelContext
	@EnvironmentObject var viewModel: SearchViewModel
	@EnvironmentObject var settingsViewModel: SettingsViewModel
	
	@Query private var savedMeals: [MealModel] = [MealModel]()
	
	@FocusState private var isEditing: Bool
	@State private var debounceTask: DispatchWorkItem?
	@State private var showCategorySearchSheet: Bool = false
	
	@State private var showAlert: Bool = false
	
	var body: some View {
		NavigationStack {
			VStack {
				// Search bar
				HStack {
					HStack{
						Image(systemName: "magnifyingglass")
							.foregroundColor(.gray)
							.padding(.horizontal, 8)
						TextField("Søk etter oppskrifter", text: $viewModel.searchText, onEditingChanged: { editing in
							self.isEditing = editing // Update the state when editing starts or ends
						})
						.padding(.horizontal, -8)
						.padding(.vertical, 9)
						.focused($isEditing)
						.submitLabel(.search)
						.onSubmit {
							debounceSearch(immediate: true)
						}
						.onChange(of: viewModel.searchText){
							debounceSearch(immediate: false)
						}
						if !viewModel.searchText.isEmpty{
							Button(){
								viewModel.searchText = ""
							} label: {
								Image(systemName: "xmark.circle.fill")
									.foregroundColor(.gray)
									.padding(.horizontal, 8)
							}
						}
					}
					.background(Color(UIColor.secondarySystemBackground))
					.cornerRadius(14)
					.padding(.bottom, 4)
					
					if isEditing{
						Button(){
							$isEditing.wrappedValue = false
						} label: {
							Text("Avbryt")
						}
						.padding(.vertical, -10)
					}
				}
				.padding(.horizontal)
				
				if !viewModel.meals.isEmpty{
					HStack{
						Text("\(viewModel.searchTitleString)")
							.font(.caption)
							.foregroundColor(.secondary)
							.padding(.horizontal)
							.padding(.top, -4)
						Spacer()
					}
				}
				
				if(viewModel.loadingData){
					ContentUnavailableView(){
						ProgressView()
						Text("Søker..")
							.font(.caption)
					}
				} else {
					if !viewModel.meals.isEmpty && !viewModel.noResults {
						List(viewModel.meals, id: \.uuid) { meal in
							NavigationLink(destination: MealDetailView(meal: meal, isSearchResult: true, alreadySavedMeal: isMealSaved(mealID: meal.id))){
								MealRowView(meal: meal, alreadySavedMeal: isMealSaved(mealID: meal.id), savedMealArchived: isMealArchived(mealID: meal.id))
								}
						}
						.listStyle(.plain)
					} else {
						if viewModel.meals.isEmpty && viewModel.noResults{
							ContentUnavailableView("🤷🏼‍♂️Ingen resultater", systemImage: "magnifyingglass")
						}
						if (!viewModel.loadingData && viewModel.meals.isEmpty && !viewModel.noResults){
							ContentUnavailableView("Søk etter matretter", systemImage: "fork.knife")
						}
					}
				}
			}
			.sheet(isPresented: $showCategorySearchSheet) {
				CategorySearchView()
			}
//			.background(Color(UIColor.secondarySystemBackground))
			.background(Color(UIColor.systemBackground))
			.toolbar{
				ToolbarItem(placement: .topBarLeading) {
					Button(action: {
						showCategorySearchSheet = true
					}, label: {
						HStack{
							Image(systemName: "text.magnifyingglass")
							Text("Kategorier")
						}
					})
				}
				ToolbarItem(placement: .topBarTrailing) {
					Button(action: {
						// open filters
						showAlert = true
					}, label: {
						HStack{
							Text("Filter")
							Image(systemName: "slider.horizontal.3")
						}
					})
				}
			}
		}
		.onAppear {
			viewModel.ensureCategoryFilterDataIsFetched()
		}
		.alert(isPresented: $showAlert)  {
			Alert(
				title: Text("Not available yet"),
				message: Text("Dumb ass!"),
				dismissButton: .default(Text("Jeg er dum")))
		}
	}
	func isMealSaved(mealID: String) -> Bool {
		// Check if the meal exists and hasn't been updated since creation
		return savedMeals.contains { $0.id == mealID && $0.updatedDate == $0.createdDate }
	}
	func isMealArchived(mealID: String) -> Bool {
		// Check if the meal is saved and archived
		guard let matchedMeal = savedMeals.first(where: { $0.id == mealID }) else {
			return false
		}
		return matchedMeal.archived
	}
	private func debounceSearch(immediate: Bool) {
		if viewModel.searchText == viewModel.searchTextPrev {
			return
		}
		// Cancel the previous task if it exists
		debounceTask?.cancel()
		
		if immediate {
			// Perform search immediately
			performSearch()
		} else {
			// Create a new task for delayed execution
			let task = DispatchWorkItem {
				performSearch()
			}
			
			// Schedule the new task to run after 1 second
			DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: task)
			
			// Store the new task
			debounceTask = task
		}
	}
	private func performSearch() {
		Task {
			if !viewModel.searchText.isEmpty {
				await viewModel.searchMeals()
			}
		}
	}
}

#Preview {
	SearchView()
		.environmentObject(SearchViewModel())
		.environmentObject(SettingsViewModel())
		.modelContainer(for: [MealModel.self, AreaModel.self, IngredientModel.self, CategoryModel.self])
}

struct MealRowView: View {
	@Environment(\.modelContext) private var modelContext
	@State var meal: MealModel
	@State var alreadySavedMeal = false
	@State var savedMealArchived = false
	
	var body: some View {
		HStack {
				AsyncImage(url: meal.image) { image in
					image.resizable()
				} placeholder: {
					Color.gray.frame(width: 80, height: 80)
				}
				.frame(width: 80, height: 80)
				.cornerRadius(10)
			
			// Text Content
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
			if alreadySavedMeal {
				VStack{
						Image(systemName: savedMealArchived ? "archivebox.fill" : "tray.full.fill")
							.foregroundColor(savedMealArchived ? .red : .green)
							.padding(.top, 4)
					Spacer()
				}
			}
		}
		.padding(.vertical, -0)
		.padding(.horizontal, -8)
		.swipeActions(edge: .trailing) {
			if !alreadySavedMeal{
				Button() {
					saveMeal(meal: meal)
				} label: {
					Label("Lagre", systemImage: "tray.and.arrow.down.fill")
				}
				.tint(.blue)
			} else {
				Button() {} label: {
					Label("Lagret", systemImage: "tray.full.fill")
				}
				.tint(.gray)
			}
		}
	}
	func saveMeal(meal: MealModel) {
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

struct CategorySearchView: View {
	@Environment(\.modelContext) private var modelContext
	@EnvironmentObject var searchViewModel: SearchViewModel
	@EnvironmentObject var settingsViewModel: SettingsViewModel
	@Environment(\.dismiss) var dismiss
	
	@State private var areas: [String] = []
	@State private var categories: [String] = []
	@State private var ingredients: [String] = []
	
	@Query private var savedAreas: [AreaModel] = [AreaModel]()
	@Query private var savedCategories: [CategoryModel] = [CategoryModel]()
	@Query private var savedIngredients: [IngredientModel] = [IngredientModel]()
	
	var body: some View {
		NavigationStack{
			List{
				NavigationLink(destination: CategorySearchListView(dismissParent: dismiss, categories: areas, title: "Landområder"), label: {
					HStack {
						Image(systemName: "globe.europe.africa.fill")
							.foregroundColor(.blue)
							.font(.title)
							.frame(width: 44, alignment: .center) // Fixed width for the icon
						Text("Landområder")
							.font(.headline)
					}
					.frame(height: 50)
				})
				
				NavigationLink(destination: CategorySearchListView(dismissParent: dismiss, categories: areas, title: "Kategorier"), label: {
					HStack {
						Image(systemName: "square.grid.2x2.fill")
							.foregroundColor(.green)
							.font(.title)
							.frame(width: 44, alignment: .center) // Fixed width for the icon
						Text("Kategorier")
							.font(.headline)
					}
					.frame(height: 50)
				})
				
				NavigationLink(destination: CategorySearchListView(dismissParent: dismiss, categories: areas, title: "Ingredienser"), label: {
					HStack {
						Image(systemName: "carrot.fill")
							.foregroundColor(.orange)
							.font(.title)
							.frame(width: 44, alignment: .center) // Fixed width for the icon
						Text("Ingredienser")
							.font(.headline)
					}
					.frame(height: 50)
				})
			}
			.navigationTitle("Velg kategori")
		}
		.onAppear {
			setCategories()
		}
	}
	private func setCategories() {
		if settingsViewModel.betterCategorySearch {
			areas = searchViewModel.allApiAreas
			categories = searchViewModel.allApiCategories
			ingredients = searchViewModel.allApiIngredients
		} else {
			areas = savedAreas.map { $0.name }
			categories = savedCategories.map { $0.name }
			ingredients = savedIngredients.map { $0.name }
		}
	}
}

struct CategorySearchListView: View {
	@EnvironmentObject var searchViewModel: SearchViewModel
	@EnvironmentObject var settingsViewModel: SettingsViewModel
	@Environment(\.dismiss) var dismiss
	var dismissParent: DismissAction
	var categories: [String]
	var title: String
	
	var body: some View {
		NavigationStack{
			Group{
					if !searchViewModel.allApiAreas.isEmpty {
						List(categories, id: \.self) { category in
							Button {
								Task{
									await search(category: category)
								}
							} label: {
								Text("\(category)")
							}

						}
					} else {
						Text("Noe gikk galt ved innlasting av \(title.lowercased())")
					}
			}
			.navigationTitle("\(title)")
		}

	}
	private func search(category: String) async {
		dismiss()
		dismissParent()
		await searchViewModel.fetchMealsBy(category, APIString.searchByArea)
	}
}
