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
	
	@Query private var meals: [Meal] = [Meal]()
	
	var body: some View {
		NavigationStack {
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
					NavigationLink(destination: AddMealView()) {
						Text("Lag egen oppskrift")
					}
					.padding(.top, -8)
				}
			} else {
				List(meals, id: \.self) { meal in
					NavigationLink(destination: MealDetailView(meal: meal)){
						Text(meal.name)
					}
					.swipeActions(edge: .trailing){
						Button(role: .destructive) {
							print("Arkiver")
						} label: {
							Label("Arkiver", systemImage: "archivebox.fill")
						}
					}
				}
				.toolbar {
					NavigationLink(destination: AddMealView()) {
						Label("Legg til oppskrift", systemImage: "plus")
					}
				}
			}
		}
		.navigationTitle("Oppskrifter")
	}
}

#Preview {
	MyMealsView()
		.modelContainer(for: Meal.self)
}

