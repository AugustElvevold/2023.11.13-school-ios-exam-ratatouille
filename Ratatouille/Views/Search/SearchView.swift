//
//  SearchView.swift
//  Ratatouille
//
//  Created by Kandidatnr: 2003 on 18/11/2023.
//

import SwiftUI

struct SearchView: View {
	@EnvironmentObject var viewModel: SearchViewModel
	
	var body: some View {
		VStack {
			// Search bar
			HStack {
				TextField("Søk etter oppskrifter", text: $viewModel.searchText)
					.padding(.horizontal)
					.padding(.vertical, 12)
					.background(Color(UIColor.systemBackground))
					.cornerRadius(8)
					.submitLabel(.search)
					.onSubmit {
						Task {
							if !viewModel.searchText.isEmpty {
								await viewModel.searchMeals()
								//							viewModel.applyFilters()
							}
						}
					}
				
				Button(action: {
					Task {
						if !viewModel.searchText.isEmpty {
							await viewModel.searchMeals()
							//							viewModel.applyFilters()
						}
					}
				}) {
					Label("Søk", systemImage: "magnifyingglass")
					//						.foregroundColor(.white)
						.padding(.trailing)
						.padding(.vertical, 10)
					//						.background(viewModel.searchText.isEmpty ? Color.gray : Color.blue) // Use your custom color
				}
			}
			.padding(.horizontal)
			
			// Results list
			List {
				ForEach(viewModel.meals, id: \.id) { meal in
					VStack(alignment: .leading) {
						Text(meal.name)
						Text(meal.strCategory)
						Text(meal.strArea)
						// Add more details as needed
					}
				}
			}
		}
		.background(Color(UIColor.secondarySystemBackground))
		//.background(Color(UIColor.systemBackground))
	}
}

#Preview {
    SearchView()
		.environmentObject(SearchViewModel())
}
