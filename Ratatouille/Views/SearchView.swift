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
	@Bindable var viewModel: SearchViewModel
	@EnvironmentObject var settingsViewModel: SettingsViewModel
	
	@Query private var savedMeals: [MealModel] = [MealModel]()
	
	@FocusState private var isEditing: Bool
	@State private var debounceTask: DispatchWorkItem?
	@State private var showCategorySearchSheet: Bool = false
	
	var body: some View {
		NavigationStack {
			VStack {
				HStack {
					HStack{
						Image(systemName: "magnifyingglass")
							.foregroundColor(.gray)
							.padding(.horizontal, 8)
						TextField("Søk etter oppskrifter", text: $viewModel.searchText, onEditingChanged: { editing in
							self.isEditing = editing
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
				CategorySearchView(searchViewModel: viewModel)
			}
			.background(Color(UIColor.systemBackground))
			.toolbar{
				ToolbarItem(placement: .topBarTrailing) {
					Button(action: {
						showCategorySearchSheet = true
					}, label: {
						HStack{
							Text("Filtrert søk")
							Image(systemName: "text.magnifyingglass")
						}
					})
				}
			}
		}
		.onAppear {
			viewModel.ensureCategoryFilterDataIsFetched()
		}
	}
	func isMealSaved(mealID: String) -> Bool {
		return savedMeals.contains { $0.id == mealID && $0.updatedDate == $0.createdDate }
	}
	func isMealArchived(mealID: String) -> Bool {
		guard let matchedMeal = savedMeals.first(where: { $0.id == mealID }) else {
			return false
		}
		return matchedMeal.archived
	}
	private func debounceSearch(immediate: Bool) {
		if viewModel.searchText == viewModel.searchTextPrev {
			return
		}
		debounceTask?.cancel()
		
		if immediate {
			performSearch()
		} else {
			let task = DispatchWorkItem {
				performSearch()
			}
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: task)
			
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
	SearchView(viewModel: SearchViewModel())
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
			
			VStack(alignment: .leading, spacing: 4) {
				Text(meal.name)
					.font(.headline)
					.lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
				Text(meal.strCategory)
					.font(.subheadline)
					.foregroundColor(.secondary)
					.lineLimit(1)
				Text(meal.strArea)
					.font(.subheadline)
					.foregroundColor(.secondary)
					.lineLimit(1)
			}
			
			Spacer()
			if self.meal.saved {
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
		self.meal.saved = true
		let meal = MealModel(
			id: meal.id,
			name: meal.name,
			strCategory: meal.strCategory,
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
	var searchViewModel: SearchViewModel
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
				NavigationLink(destination: CategorySearchListView(searchViewModel: searchViewModel, dismissParent: dismiss, categories: areas, title: "Landområder", apiString: APIString.searchByArea), label: {
					HStack {
						Image(systemName: "globe.europe.africa.fill")
							.foregroundColor(.blue)
							.font(.title)
							.frame(width: 44, alignment: .center)
						Text("Landområder")
							.font(.headline)
					}
					.frame(height: 50)
				})
				
				NavigationLink(destination: CategorySearchListView(searchViewModel: searchViewModel, dismissParent: dismiss, categories: categories, title: "Kategorier", apiString: APIString.searchByCategory), label: {
					HStack {
						Image(systemName: "square.grid.2x2.fill")
							.foregroundColor(.green)
							.font(.title)
							.frame(width: 44, alignment: .center)
						Text("Kategorier")
							.font(.headline)
					}
					.frame(height: 50)
				})
				
				NavigationLink(destination: CategorySearchListView(searchViewModel: searchViewModel, dismissParent: dismiss, categories: ingredients, title: "Ingredienser", apiString: APIString.searchByIngredient), label: {
					HStack {
						Image(systemName: "carrot.fill")
							.foregroundColor(.orange)
							.font(.title)
							.frame(width: 44, alignment: .center)
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
	var searchViewModel: SearchViewModel
	@EnvironmentObject var settingsViewModel: SettingsViewModel
	@Environment(\.dismiss) var dismiss
	var dismissParent: DismissAction
	var categories: [String]
	var title: String
	var apiString: String
	
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
		await searchViewModel.fetchMealsBy(category, apiString)
	}
}
