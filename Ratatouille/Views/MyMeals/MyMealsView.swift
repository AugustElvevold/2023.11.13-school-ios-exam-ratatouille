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
		filter: #Predicate<Meal> { $0.archived == false }
	) private var meals: [Meal] = [Meal]()
	
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
		.modelContainer(for: Meal.self)
}

struct MyMealRowView: View {
	@State var meal: Meal
	
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
				Text(meal.category)
					.font(.subheadline)
					.foregroundColor(.secondary)
					.lineLimit(1)
				Text(meal.area.name)
//				Text(meal.area)
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
	private func toggleFavoriteMeal(_ meal: Meal) {
		meal.favorite = !meal.favorite
	}
	private func archiveMeal(_ meal: Meal) {
		meal.archived = true
	}
}
