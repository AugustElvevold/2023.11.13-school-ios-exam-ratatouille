//
//  ContentView.swift
//  Ratatouille
//
//  Created by Kandidatnr: 2003 on 18/11/2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@EnvironmentObject var searchViewModel: SearchViewModel
	@EnvironmentObject var tabSelection: TabSelection
//	@Query private var items: [Item]
	
	var body: some View {
		TabView(selection: $tabSelection.selectedTab) {
			MyMealsView()
				.tabItem {
					Label("Oppskrifter", systemImage: "list.bullet")
				}
				.tag(TabSelection.Tab.recipes)
			SearchView()
				.tabItem {
					Label("Søk", systemImage: "magnifyingglass")
				}
				.environmentObject(searchViewModel)
				.tag(TabSelection.Tab.search)
			SettingView()
				.tabItem {
					Label("Innstillinger", systemImage: "gearshape.fill")
				}
				.tag(TabSelection.Tab.settings)
		}
		//        NavigationSplitView {
		//            List {
		//                ForEach(items) { item in
		//                    NavigationLink {
		//                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
		//                    } label: {
		//                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
		//                    }
		//                }
		//                .onDelete(perform: deleteItems)
		//            }
		//            .toolbar {
		//                ToolbarItem(placement: .navigationBarTrailing) {
		//                    EditButton()
		//                }
		//                ToolbarItem {
		//                    Button(action: addItem) {
		//                        Label("Add Item", systemImage: "plus")
		//                    }
		//                }
		//            }
		//        } detail: {
		//            Text("Select an item")
		//        }
		//    }
		
		//		private func addItem() {
		//			withAnimation {
		//				let newItem = Item(timestamp: Date())
		//				modelContext.insert(newItem)
		//			}
		//		}
		//
		//		private func deleteItems(offsets: IndexSet) {
		//			withAnimation {
		//				for index in offsets {
		//					modelContext.delete(items[index])
		//				}
		//			}
	}
}

#Preview {
	ContentView()
		.environmentObject(SearchViewModel())
		.modelContainer(for: Meal.self)
		.environmentObject(TabSelection())
//	Removes all data from the database after stopping the preview
//		.modelContainer(for: Meal.self, inMemory: true)
}

class TabSelection: ObservableObject {
	enum Tab {
		case recipes, search, settings
	}
	
	@Published var selectedTab: Tab = .recipes
}
