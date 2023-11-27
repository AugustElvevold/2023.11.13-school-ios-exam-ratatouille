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
	
	@Query private var savedMeals: [Meal] = [Meal]()
	
	@FocusState private var isEditing: Bool
	@State private var debounceTask: DispatchWorkItem?
	
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
					.background(Color(UIColor.systemBackground))
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
						Text("Søkeresultater for \"\(viewModel.lastSearchText)\" ga \(viewModel.meals.isEmpty ? "0" : "\(viewModel.meals.count)") resultater ")
							.font(.caption)
							.foregroundColor(.secondary)
							.padding(.horizontal)
							.padding(.top, -4)
						Spacer()
					}
				}
				
				if(viewModel.queryRequest){
					ContentUnavailableView(){
						ProgressView()
						Text("Søker..")
							.font(.caption)
					}
				} else {
					// Results list
					if !viewModel.meals.isEmpty && !viewModel.noResults {
						List(viewModel.meals, id: \.uuid) { meal in
								NavigationLink(destination: MealDetailView(meal: meal)){
									MealRowView(meal: meal, savedMeals: savedMeals)
								}
							
						}
					} else {
						if viewModel.meals.isEmpty && viewModel.noResults{
							ContentUnavailableView("🤷🏼‍♂️Ingen resultater", systemImage: "magnifyingglass")
						}
						if (!viewModel.queryRequest && viewModel.meals.isEmpty && !viewModel.noResults){
							ContentUnavailableView("Søk etter matretter", systemImage: "fork.knife")
						}
					}
				}
			}
			.background(Color(UIColor.secondarySystemBackground))
			//.background(Color(UIColor.systemBackground))
		}
	}
	private func debounceSearch(immediate: Bool) {
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
		.modelContainer(for: Meal.self)
}

struct MealRowView: View {
	@Environment(\.modelContext) private var modelContext
//	@State private var animateIn = false
	@State var meal: Meal
	@State var savedMeals: [Meal]
	
	@State private var alreadySavedMeal = false
	@State private var savedMealArchived = false
	
	var body: some View {
		HStack {
			// Image
			if !meal.strMealThumb.isEmpty, let url = URL(string: meal.strMealThumb) {
				AsyncImage(url: url) { image in
					image.resizable()
				} placeholder: {
					Color.gray.frame(width: 80, height: 80)
				}
				.frame(width: 80, height: 80)
				.cornerRadius(10)
			} else {
				Color.gray.frame(width: 80, height: 80)
					.cornerRadius(10)
			}
			
			// Text Content
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
		.onAppear(){
			alreadySavedMeal = isMealSaved(mealID: meal.id)
			savedMealArchived = isMealArchived(mealID: meal.id)
		}
//		.offset(x: animateIn ? 0 : -UIScreen.main.bounds.width, y: 0)
//		.onAppear {
//			withAnimation(.easeOut(duration: 0.5)) {
//				animateIn = true
//			}
//		}
	}
	func saveMeal(meal: Meal) {
		let meal = Meal(
			id: meal.id,
			name: meal.name,
			strCategory: meal.strCategory,
			strArea: meal.strArea,
			strInstructions: meal.strInstructions,
			strMealThumb: meal.strMealThumb,
			strYoutube: meal.strYoutube,
			ingredients: meal.ingredients,
			strSource: meal.strSource
		)
		let time = Date.now
		meal.createdDate = time
		meal.updatedDate = time
		meal.saved = true
		modelContext.insert(meal)
		try? modelContext.save()
		alreadySavedMeal = true
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
}
