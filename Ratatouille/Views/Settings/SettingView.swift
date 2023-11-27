//
//  SettingsView.swift
//  Ratatouille
//
//  Created by August Elvevold on 18/11/2023.
//

import SwiftUI
import SwiftData

struct SettingView: View {
	@Environment(\.colorScheme) private var current
	@Environment(\.modelContext) private var modelContext
	@EnvironmentObject var csManager: ColorSchemeManager
	@Query (
		filter: #Predicate<Meal> { $0.archived == true },
		sort: \Meal.createdDate, order: .forward, animation: .default
	) private var archivedMeals: [Meal] = [Meal]()
	
	var body: some View {
		NavigationStack {
			List {
				NavigationLink(destination: Text("Rediger landområder")) {
					HStack {
						Image(systemName: "globe")
						Text("Rediger landområder")
					}
				}
				
				NavigationLink(destination: Text("Rediger kategorier")) {
					HStack {
						Image(systemName: "folder")
						Text("Rediger kategorier")
					}
				}
				
				NavigationLink(destination: Text("Rediger ingredienser")) {
					HStack {
						Image(systemName: "leaf")
						Text("Rediger ingredienser")
					}
				}
				
				Section(header: Text("Tema")) {
					Text("Theme is: \(String(describing: current))")
					Picker("Tema", selection: $csManager.colorScheme) {
						Text("Mørkt").tag(ColorScheme.dark)
						Text("Lyst").tag(ColorScheme.light)
						Text("Automatisk").tag(ColorScheme.unspecified)
					}
					.pickerStyle(SegmentedPickerStyle())
				}
				.padding(.horizontal, -14)
				
				NavigationLink(destination:
												NavigationStack{
					List(archivedMeals, id: \.self) { meal in
						HStack {
							Text(meal.name)
							Spacer()
						}
						.swipeActions(edge: .trailing){
							Button(role: .destructive) {
								delete(meal)
							} label: {
								Label("Slett", systemImage: "trash.fill")
							}
							Button(role: .destructive) {
								unArchiveMeal(meal)
							} label: {
								Label("Flytt til mine oppskrifter", systemImage: "tray.and.arrow.up.fill")
							}
							.tint(.green)
						}
					}
					Button("Slett alle oppskrifter") {
						archivedMeals.forEach { meal in
							delete(meal)
						}
					}
					.foregroundColor(.red)
					.navigationTitle("Arkiv")
				}) {
					HStack {
						Image(systemName: "archivebox.fill")
						Text("Arkiv")
					}.foregroundColor(.red)
				}
			}
			.navigationTitle("Innstillinger")
		}
	}
	private func unArchiveMeal(_ meal: Meal) {
		meal.archived = false
	}
	private func delete(_ meal: Meal) {
		modelContext.delete(meal)
	}
}

#Preview {
	SettingView()
		.environmentObject(ColorSchemeManager())
}


