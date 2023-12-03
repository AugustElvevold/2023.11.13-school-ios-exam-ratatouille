//
//  SettingsView.swift
//  Ratatouille
//
//  Created by Kandidatnr: 2003 on 18/11/2023.
//

import SwiftUI
import SwiftData

struct SettingView: View {
	@Environment(\.colorScheme) private var current
	@Environment(\.modelContext) private var modelContext
	@EnvironmentObject var csManager: ColorSchemeManager
	@EnvironmentObject var viewModel: SettingsViewModel
	
	@Query(
		filter: #Predicate<IngredientModel> { $0.archived == true }
	) private var archivedIngredients: [IngredientModel] = [IngredientModel]()
	
	@Query(
		filter: #Predicate<CategoryModel> { $0.archived == true }
	) private var archivedCategories: [CategoryModel] = [CategoryModel]()
	
	@Query(
		filter: #Predicate<AreaModel> { $0.archived == true }
	) private var archivedAreas: [AreaModel] = [AreaModel]()
	
	@Query (
		filter: #Predicate<MealModel> { $0.archived == true },
		sort: \MealModel.createdDate, order: .forward, animation: .default
	) private var archivedMeals: [MealModel] = [MealModel]()
	
	var body: some View {
		NavigationStack {
			List {
				Section{
					NavigationLink(destination: AreaView()) {
						HStack {
							Image(systemName: "globe.europe.africa.fill")
								.foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
							Text("Landområder")
						}
					}
					
					NavigationLink(destination: CategoriesView()) {
						HStack {
							Image(systemName: "square.grid.2x2.fill")
								.foregroundColor(.green)
							Text("Kategorier")
						}
					}
					
					NavigationLink(destination: IngredientsView()) {
						HStack {
							Image(systemName: "carrot.fill")
								.foregroundColor(.orange)
							Text("Ingredienser")
						}
					}
				} header: {
					Text("Rediger")
				}
				
				Section{
					Picker("Tema", selection: $csManager.colorScheme) {
						Text("Mørkt").tag(ColorScheme.dark)
						Text("Lyst").tag(ColorScheme.light)
						Text("Automatisk").tag(ColorScheme.unspecified)
					}
					.pickerStyle(SegmentedPickerStyle())
					.listRowInsets(EdgeInsets())
				} header: {
					Text("Tema")
				}
				.padding(.horizontal, 6)
				
				Section{
					Toggle(isOn: $viewModel.betterCategorySearch, label: {
						Text("Søk med kategorier fra api")
					})
				} header: {
					Text("Kategori søkemetode")
				} footer: {
					if viewModel.betterCategorySearch {
						Text("Bruker API sine kategorier til å søke")
					} else {
						Text("Bruker lokale kategorier til å søke, siden oppgaven sier det...")
					}
				}
				
				Section{
					NavigationLink(destination: NavigationStack{
									List{
										Section{
											NavigationLink(destination: MealArchiveView(archivedMeals: archivedMeals)){
												HStack{
													Image(systemName: "fork.knife")
													Text("Arkiverte oppskrifter")
												}
												.foregroundColor(archivedMeals.isEmpty ? .gray : .purple)
											}
											.disabled(archivedMeals.isEmpty)
										} footer: {
											if archivedMeals.isEmpty{
												Text("Ingen arkiverte oppskrifter")
											} else {
												Text("Antall: \(archivedMeals.count)")
											}
										}
										Section{
											NavigationLink(destination: IngredientArchiveView(archivedIngredients: archivedIngredients)){
												HStack{
													Image(systemName: "carrot.fill")
													Text("Arkiverte ingredienser")
												}
												.foregroundColor(archivedIngredients.isEmpty ? .gray : .purple)
											}
											.disabled(archivedIngredients.isEmpty)
										} footer: {
											if archivedIngredients.isEmpty{
												Text("Ingen arkiverte ingredienser")
											} else {
												Text("Antall: \(archivedIngredients.count)")
											}
										}
										Section{
											NavigationLink(destination: CategoryArchiveView(archivedCategories: archivedCategories)){
												HStack{
													Image(systemName: "square.grid.2x2.fill")
													Text("Arkiverte kategorier")
												}
												.foregroundColor(archivedCategories.isEmpty ? .gray : .purple)
											}
											.disabled(archivedCategories.isEmpty)
										} footer: {
											if archivedCategories.isEmpty{
												Text("Ingen arkiverte kategorier")
											} else {
												Text("Antall: \(archivedCategories.count)")
											}
										}
										Section{
											NavigationLink(destination: AreaArchiveView(archivedAreas: archivedAreas)){
												HStack{
													Image(systemName: "globe.europe.africa.fill")
													Text("Arkiverte landområder")
												}
												.foregroundColor(archivedAreas.isEmpty ? .gray : .purple)
											}
											.disabled(archivedAreas.isEmpty)
										} footer: {
											if archivedAreas.isEmpty{
												Text("Ingen arkiverte landområder")
											} else {
												Text("Antall: \(archivedAreas.count)")
											}
										}
									}
					}
						.navigationTitle("Arkiv")
					) { HStack {
								Image(systemName: "archivebox.fill")
								Text("Arkiv")
							}
							.foregroundColor(.purple)
						}
				} header: {
					Text("Arkiv")
				}
			}
			.navigationTitle("Innstillinger")
		}
	}
}

struct IngredientsView: View {
	@Environment(\.modelContext) private var modelContext
	@EnvironmentObject var viewModel: SettingsViewModel
	
	@Query private var ingredients: [IngredientModel] = [IngredientModel]()
	
	@State private var ingredientsUpToDate = true
	
	@State private var loading = false
	@State private var loadingSaveIngredients = false
	@State private var showDeleteAlert: Bool = false
	
	var body: some View {
		NavigationStack{
			ZStack{
				if !ingredients.isEmpty {
					List(ingredients, id: \.uuid) { ingredient in
						if !ingredient.archived{
							NavigationLink(destination: IngredientDetailView(ingredient: ingredient)) {
								Text(ingredient.name)
									.swipeActions(edge: .trailing){
										Button(role: .destructive) {
											archiveIngredient(ingredient)
										} label: {
											Label("Arkiver", systemImage: "archivebox.fill")
										}
										.tint(.purple)
									}
							}
						}
					}
				}
				else {
					Button(action: {
						Task{
							loadingSaveIngredients = true
							await viewModel.fetchIngredients()
							for ingredient in viewModel.apiIngredients {
								saveIngredient(ingredient)
							}
							ingredientsUpToDate = await isApiIngredientsUpdated()
							loadingSaveIngredients = false
						}
					}, label: {
						Label("Last ned ingredienser fra api", systemImage: "arrow.down.to.line.compact")
					})}
				if loadingSaveIngredients {
					ContentUnavailableView{
						ProgressView()
						Text("Henter ingrediense fra API..")
							.font(.caption)
					}
					.background(Color.gray.opacity(0.4))
				}
				if loading {
					ContentUnavailableView{
						ProgressView()
						Text("Legger til manglende ingredienser fra API..")
							.font(.caption)
					}
					.background(Color.gray.opacity(0.4))
				}
			}
		}
		.navigationTitle("Ingredienser")
		.toolbar(content: {
			Menu{
				NavigationLink(destination: IngredientAddView(ingredients: ingredients)) {
					Label("Legg til ingrediens", systemImage: "plus")
				}
				if !ingredientsUpToDate && !ingredients.isEmpty{
					Button(action: {
						Task{
							loading = true
							print("Loading: \(loading)")
							await viewModel.fetchIngredients()
							for ingredient in viewModel.apiIngredients {
								saveOrUnarchiveIngredient(ingredient)
							}
							ingredientsUpToDate = await isApiIngredientsUpdated()
							
							loading = false
							print("Loading: \(loading)")
						}
					}, label: {
						Label("Legg til manglene ingredienser fra api", systemImage: "arrow.down.to.line.compact")
					})
				}
				Button(role: .destructive) {
					showDeleteAlert = true
				} label: {
					Label("Slett alle ingredienser", systemImage: "trash.fill")
						.foregroundColor(.red)
				}
				.buttonStyle(.bordered)
			} label: {
				Image(systemName: "ellipsis.circle")
			}
		})
		.task{
			ingredientsUpToDate = await isApiIngredientsUpdated()
			print(ingredientsUpToDate ? "Ingredients up to date" : "Ingredients not up to date")
		}
		.alert(isPresented: $showDeleteAlert)  {
			Alert(
				title: Text("Advarsel"),
				message: Text("Vil du slette alle ingrediensene?"),
				primaryButton: .destructive(Text("Slett")) {
					deleteAllIngredients()
				},
				secondaryButton: .default(Text("Avbryt")))
		}
	}
	
	func saveIngredient(_ ingredient: IngredientModel) {
		if !ingredients.contains(where: { $0.id == ingredient.id }) {
			let newIngredient = IngredientModel(
				ingredient.id,
				ingredient.name,
				ingredient.ingredientDescription,
				ingredient.type
			)
			modelContext.insert(newIngredient)
			try? modelContext.save()
		}
	}
	private func saveOrUnarchiveIngredient(_ ingredient: IngredientModel) {
		if let existingIngredientIndex = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
			ingredients[existingIngredientIndex].archived = false
		} else {
			let newIngredient = IngredientModel(
				ingredient.id,
				ingredient.name,
				ingredient.ingredientDescription,
				ingredient.type
			)
			modelContext.insert(newIngredient)
		}
		try? modelContext.save()
	}
	private func archiveIngredient(_ ingredient: IngredientModel) {
		ingredient.archived = true
		Task{
			ingredientsUpToDate = await isApiIngredientsUpdated()
		}
	}
	private func isApiIngredientsUpdated() async -> Bool {
		print("Check if ingredient list is up to date")
		await viewModel.fetchIngredients()
		
		let ingredientsDict = Dictionary(uniqueKeysWithValues: ingredients.map { ($0.id, !$0.archived) })
		
		return viewModel.apiIngredients.allSatisfy { apiIngredient in
			return ingredientsDict[apiIngredient.id] ?? false
		}
	}
	private func deleteAllIngredients() {
		for ingredient in ingredients {
			modelContext.delete(ingredient)
		}
		try? modelContext.save()
	}
}
struct IngredientDetailView: View {
	var ingredient: IngredientModel
	
	var body: some View {
		NavigationStack{
			ScrollView {
				VStack(alignment: .leading, spacing: 20) {
					
					VStack(alignment: .leading) {
						Text("Beskrivelse")
							.font(.headline)
							.padding(.bottom, 5)

						Text(ingredient.ingredientDescription)
					}
					.padding(.horizontal)
					
					VStack(alignment: .leading) {
						Text("Type")
							.font(.headline)
							.padding(.bottom, 5)
						
						Text(ingredient.type)
					}
					.padding(.horizontal)
				}
				.frame(maxWidth: .infinity, alignment: .leading)
			}
			.navigationTitle(ingredient.name)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					NavigationLink(destination: IngredientEditView(ingredient: ingredient)) {
						Text("Rediger")
					}
				}
			}
		}
	}
}
struct IngredientAddView: View {
	@Environment(\.modelContext) private var modelContext
	var ingredients: [IngredientModel]
	@State private var showAlert: Bool = false
	@State private var newIngredient: IngredientModel = IngredientModel()
	
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		NavigationStack {
			Form {
				Section{
					TextField("Navn", text: $newIngredient.name)
				} header: {
					Text("Ingrediens")
				}
				Section{
					ZStack(alignment: .topLeading) {
					if newIngredient.ingredientDescription.isEmpty {
						Text("Skriv inn beskrivelse her...")
							.foregroundColor(.gray.opacity(0.5))
							.padding(.top, 8)
							.padding(.leading, 4)
					}
					TextEditor(text: $newIngredient.ingredientDescription)
						.frame(minHeight: 60)
				}
				} header: {
					Text("Beskrivelse")
				}
				
				Section{
					TextField("Type", text: $newIngredient.type)
				} header: {
					Text("Type")
				}
			}
			.navigationBarTitle("Legg til ingrediens").navigationBarTitleDisplayMode(.inline)
			.submitLabel(.done)
			.onSubmit {
				saveIngredient()
			}
			Spacer()
		}
		.toolbar(content: {
			ToolbarItem(placement: .cancellationAction){
				Button("Avbryt", role: .cancel){
					dismiss()
				}
			}
			ToolbarItem(placement: .confirmationAction){
				Button(action: {
					saveIngredient()
				}, label: {
					Text("Lagre")
				})
				.disabled(newIngredient.name.isEmpty)
			}
		})
		.navigationBarBackButtonHidden()
		.alert(isPresented: $showAlert) {
			Alert(
				title: Text("Ingrediensen finnes allerede"),
				dismissButton: .default(Text("OK")))
		}
	}
	
	private func saveIngredient() {
		if ingredients.contains(where: {$0.name == newIngredient.name}) {
			showAlert = true
			return
		}
		modelContext.insert(newIngredient)
		try? modelContext.save()
		
		dismiss()
	}
}
struct IngredientEditView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) var dismiss
	var ingredient: IngredientModel
	@State private var updatedIngredient: IngredientModel = IngredientModel()
	
	var body: some View {
		Form {
			Section(header: Text("Ingrediens")) {
				TextField("Navn", text: $updatedIngredient.name)
			}
			
			Section(header: Text("Beskrivelse")) {
				ZStack(alignment: .topLeading) {
					if updatedIngredient.ingredientDescription.isEmpty {
						Text("Skriv inn beskrivelse her...")
							.foregroundColor(.gray.opacity(0.5))
							.padding(.top, 8)
							.padding(.leading, 4)
					}
					TextEditor(text: $updatedIngredient.ingredientDescription)
						.frame(minHeight: 60)
				}
			}
			
			Section(header: Text("Type")) {
				TextField("Type", text: $updatedIngredient.type)
			}
		}
		.onAppear() {
			updatedIngredient.name = ingredient.name
			updatedIngredient.ingredientDescription = ingredient.ingredientDescription
			updatedIngredient.type = ingredient.type
		}
		.navigationTitle("Rediger ingrediens").navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("Avbryt", role: .cancel) {
					dismiss()
				}
			}
			ToolbarItem(placement: .confirmationAction) {
				Button(action: {
					saveUpdatedIngredient()
					dismiss()
				}, label: {
					Text("Lagre")
				})
				.disabled(updatedIngredient.name.isEmpty ||
									(updatedIngredient.name == ingredient.name &&
									 updatedIngredient.ingredientDescription == ingredient.ingredientDescription &&
									 updatedIngredient.type == ingredient.type))
			}
		}
		.navigationBarBackButtonHidden()
	}
	
	private func saveUpdatedIngredient() {
		ingredient.name = updatedIngredient.name
		ingredient.ingredientDescription = updatedIngredient.ingredientDescription
		ingredient.type = updatedIngredient.type
		try? modelContext.save()
	}
}


struct CategoriesView: View {
	@Environment(\.modelContext) private var modelContext
	@EnvironmentObject var viewModel: SettingsViewModel
	
	@Query private var categories: [CategoryModel] = [CategoryModel]()
	
	@State private var categoriesUpToDate = true
	@State private var loading = false
	@State private var loadingSaveCategories = false
	@State private var showDeleteAlert: Bool = false
	
	var body: some View {
		NavigationStack {
			ZStack {
				if !categories.isEmpty {
					List(categories, id: \.uuid) { category in
						if !category.archived {
							NavigationLink(destination: CategoryDetailView(category: category, categories: categories)) {
								HStack{
									AsyncImage(url: category.categoryThumb) { image in
										image.resizable()
									} placeholder: {
										Color.gray.frame(width: 50, height: 50)
									}
									.frame(width: 50, height: 50)
									.cornerRadius(4)
									Text(category.name)
								}
								.padding(.vertical, -0)
								.padding(.horizontal, -8)
								.swipeActions(edge: .trailing) {
									Button(role: .destructive) {
										archiveCategory(category)
									} label: {
										Label("Arkiver", systemImage: "archivebox.fill")
									}
									.tint(.purple)
								}
							}
						}
					}
				}
				else {
					Button(action: {
						Task {
							loadingSaveCategories = true
							await viewModel.fetchCategories()
							for category in viewModel.apiCategories {
								saveCategory(category)
							}
							categoriesUpToDate = await isApiCategoriesUpdated()
							loadingSaveCategories = false
						}
					}, label: {
						Label("Last ned kategorier fra API", systemImage: "arrow.down.to.line.compact")
					})
				}
				if loadingSaveCategories {
					ContentUnavailableView {
						ProgressView()
						Text("Henter kategorier fra API...")
							.font(.caption)
					}
					.background(Color.gray.opacity(0.4))
				}
				if loading {
					ContentUnavailableView {
						ProgressView()
						Text("Oppdaterer kategorier fra API...")
							.font(.caption)
					}
					.background(Color.gray.opacity(0.4))
				}
			}
		}
		.navigationTitle("Kategorier")
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Menu {
					NavigationLink(destination: CategoryAddView(categories: categories)) {
						Label("Legg til kategori", systemImage: "plus")
							.foregroundColor(.blue)
					}
					if !categoriesUpToDate && !categories.isEmpty {
						Button(action: {
							Task {
								loading = true
								await viewModel.fetchAreas()
								for area in viewModel.apiCategories {
									saveOrUnarchiveCategory(area)
								}
								categoriesUpToDate = await isApiCategoriesUpdated()
								loading = false
							}
						}, label: {
							Label("Legg til manglene kategorier fra api", systemImage: "arrow.down.to.line.compact")
						})
					}
					if !categories.isEmpty {
						Button(role: .destructive){
							showDeleteAlert = true
						} label: {
							Label("Slett alle kategorier", systemImage: "trash")
						}
					}
				} label: {
					Image(systemName: "ellipsis.circle")
				}
			}
		}
		.task {
			categoriesUpToDate = await isApiCategoriesUpdated()
		}
		.alert(isPresented: $showDeleteAlert)  {
			Alert(
				title: Text("Advarsel"),
				message: Text("Vil du slette alle kategoriene?"),
				primaryButton: .destructive(Text("Slett")) {
					deleteAllCategories()
				},
				secondaryButton: .default(Text("Avbryt")))
		}
	}
	
	func saveCategory(_ category: CategoryModel) {
		if !categories.contains(where: { $0.id == category.id }) {
			let newCategory = CategoryModel(
				category.id,
				category.name,
				category.categoryDescription,
				category.categoryThumb
			)
			modelContext.insert(newCategory)
			try? modelContext.save()
		}
	}
	
	private func saveOrUnarchiveCategory(_ category: CategoryModel) {
		if let existingCategoryIndex = categories.firstIndex(where: { $0.id == category.id }) {
			categories[existingCategoryIndex].archived = false
		} else {
			let newCategory = CategoryModel(
				category.id,
				category.name,
				category.categoryDescription,
				category.categoryThumb
			)
			modelContext.insert(newCategory)
		}
		try? modelContext.save()
	}
	
	private func archiveCategory(_ category: CategoryModel) {
		category.archived = true
		Task {
			categoriesUpToDate = await isApiCategoriesUpdated()
		}
	}

	private func isApiCategoriesUpdated() async -> Bool {
		await viewModel.fetchCategories()
		
		let categoriesDict = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, !$0.archived) })
		
		return viewModel.apiCategories.allSatisfy { apiCategory in
			categoriesDict[apiCategory.id] ?? false
		}
	}

	private func deleteAllCategories() {
		for category in categories {
			modelContext.delete(category)
		}
		try? modelContext.save()
	}

}
struct CategoryDetailView: View {
	@State var category: CategoryModel
	var categories: [CategoryModel]
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading, spacing: 20) {
					AsyncImage(url: category.categoryThumb) { image in
						image
							.resizable()
							.scaledToFit()
					} placeholder: {
						ProgressView()
					}
					.frame(maxWidth: .infinity)
					.cornerRadius(12)
					.padding()
					
					VStack(alignment: .leading) {
						Text("Beskrivelse")
							.font(.headline)
							.padding(.bottom, 5)
						
						Text(category.categoryDescription)
					}
					.padding(.horizontal)
				}
			}
			.navigationTitle(category.name)
			.toolbar {
				NavigationLink(destination: CategoryEditView(category: category, categories: categories)) {
					Text("Rediger")
				}
			}
		}
	}
}
struct CategoryAddView: View {
	@Environment(\.modelContext) private var modelContext
	var categories: [CategoryModel]
	@State private var newCategory: CategoryModel = CategoryModel()
	@State private var showAlert: Bool = false
	@State private var urlString: String = ""
	
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		NavigationStack {
			Form {
				Section{
					TextField("Navn", text: $newCategory.name)
				} header: {
					Text("Kategori")
				}
				Section{
					ZStack(alignment: .topLeading) {
						if newCategory.categoryDescription.isEmpty {
							Text("Skriv inn beskrivelse her...")
								.foregroundColor(.gray.opacity(0.5))
								.padding(.top, 8)
								.padding(.leading, 4)
						}
						TextEditor(text: $newCategory.categoryDescription)
							.frame(minHeight: 60)
					}
				} header: {
					Text("Beskrivelse")
				}
				Section {
					TextField("Bilde url", text: $urlString)
				} header: {
					Text("Bilde")
				}
			}
			.navigationBarTitle("Legg til kategori")
			.submitLabel(.done)
			.onSubmit {
				saveCategory()
			}
			Spacer()
		}
		.toolbar(content: {
			ToolbarItem(placement: .cancellationAction){
				Button("Avbryt", role: .cancel){
					dismiss()
				}
			}
			ToolbarItem(placement: .confirmationAction){
				Button(action: {
					saveCategory()
				}, label: {
					Text("Lagre")
				})
				.disabled(newCategory.name.isEmpty)
			}
		})
		.navigationBarBackButtonHidden()
		.alert(isPresented: $showAlert) {
			Alert(
				title: Text("Kategorien finnes allerede"),
				dismissButton: .default(Text("OK")))
		}
	}
	
	private func saveCategory() {
		if categories.contains(where: { $0.name == newCategory.name }) {
			showAlert = true
			return
		}
		newCategory.categoryThumb = URL(string: urlString) ?? Missing.imageUrl
		modelContext.insert(newCategory)
		try? modelContext.save()
		
		dismiss()
	}
}
struct CategoryEditView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) var dismiss
	var category: CategoryModel
	var categories: [CategoryModel]
	@State private var updatedCategory: CategoryModel = CategoryModel()
	@State private var urlString: String = ""
	
	var body: some View {
		Form {
			Section {
				TextField("Navn", text: $updatedCategory.name)
			} header: {
				Text("Kategori")
			}
			Section{
				ZStack(alignment: .topLeading) {
					if updatedCategory.categoryDescription.isEmpty {
						Text("Skriv inn beskrivelse her...")
							.foregroundColor(.gray.opacity(0.5))
							.padding(.top, 8)
							.padding(.leading, 4)
					}
					TextEditor(text: $updatedCategory.categoryDescription)
						.frame(minHeight: 60)
				}
			} header: {
				Text("Beskrivelse")
			}
			Section {
				TextField("Bilde url", text: $urlString)
			} header: {
				Text("Bilde")
			}
		}
		.onAppear() {
			updatedCategory.name = category.name
			updatedCategory.categoryDescription = category.categoryDescription
			updatedCategory.categoryThumb = category.categoryThumb
			urlString = category.categoryThumb.absoluteString
		}
		.navigationTitle("Rediger kategori").navigationBarTitleDisplayMode(.inline)
		.toolbar(content: {
			ToolbarItem(placement: .cancellationAction) {
				Button("Avbryt", role: .cancel) {
					dismiss()
				}
			}
			ToolbarItem(placement: .confirmationAction) {
				Button(action: {
					saveUpdatedCategory()
					dismiss()
				}, label: {
					Text("Lagre")
				})
				.disabled(updatedCategory.name.isEmpty || (updatedCategory.name == category.name && updatedCategory.categoryDescription == category.categoryDescription && updatedCategory.categoryThumb == category.categoryThumb))
			}
		})
		.navigationBarBackButtonHidden()
	}
	
	private func saveUpdatedCategory() {
		category.name = updatedCategory.name
		category.categoryDescription = updatedCategory.categoryDescription
		category.categoryThumb = URL(string: urlString) ?? Missing.imageUrl
		try? modelContext.save()
	}
}

struct AreaView: View {
	@Environment(\.modelContext) private var modelContext
	@EnvironmentObject var viewModel: SettingsViewModel
	
	@Query private var areas: [AreaModel] = [AreaModel]()
	
	@State private var areasUpToDate = true
	@State private var loading = false
	@State private var isSavingAreas = false
	@State private var showDeleteAlert: Bool = false
	
	var body: some View {
		NavigationStack{
			ZStack{
				VStack{
					if !areas.isEmpty {
						List(areas, id: \.uuid) { area in
							if !area.archived {
								NavigationLink(destination: AreaEditView(area: area, areas: areas)) {
									HStack {
										AsyncImage(url: area.flagUrl) { image in
											image.resizable()
												.aspectRatio(contentMode: .fit)
										} placeholder: {
											Color.white
										}
										.frame(width: 45, height: area.countryCode.isEmpty ? 22 : 35)
										.background(Color.clear)
										.clipped()
										.cornerRadius(4)
										
										Text(area.name)
									}
									.frame(height: 25)
									.padding(.vertical, 4)
									.padding(.horizontal, -8)
										.swipeActions(edge: .trailing){
											Button(role: .destructive) {
												archiveArea(area)
											} label: {
												Label("Arkiver", systemImage: "archivebox.fill")
											}
											.tint(.purple)
										}
								}
							}
						}
					}
					if areas.isEmpty && !viewModel.queryRequest {
						Button(action: {
							Task {
								isSavingAreas = true
								await viewModel.fetchAreas()
								for area in viewModel.apiAreas {
									saveArea(area)
								}
								areasUpToDate = await isApiAreasUpdated()
								isSavingAreas = false
							}
						}, label: {
							Label("Last ned land fra api", systemImage: "arrow.down.to.line.compact")
						})
					}
				}
				if isSavingAreas {
					ContentUnavailableView {
						ProgressView()
						Text("Henter landområder fra API..")
							.font(.caption)
					}
					.background(Color.gray.opacity(0.4))
				}
				if loading {
					ContentUnavailableView {
						ProgressView()
						Text("Legger til manglende landområder fra API..")
							.font(.caption)
					}
					.background(Color.gray.opacity(0.4))
				}
			}
		}
		.navigationTitle("Landområder")
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Menu {
					NavigationLink(destination: AreaAddView(areas: areas)) {
						Label("Legg til landområder", systemImage: "plus")
							.foregroundColor(.blue)
					}
					if !areasUpToDate && !areas.isEmpty {
						Button(action: {
							Task {
								loading = true
								await viewModel.fetchAreas()
								for area in viewModel.apiAreas {
									saveOrUnarchiveArea(area)
								}
								areasUpToDate = await isApiAreasUpdated()
								loading = false
							}
						}, label: {
							Label("Legg til manglene landområder fra api", systemImage: "arrow.down.to.line.compact")
						})
					}
					if !areas.isEmpty {
						Button(role: .destructive){
							showDeleteAlert = true
						} label: {
							Label("Slett alle landområder", systemImage: "trash")
						}
					}
				} label: {
					Image(systemName: "ellipsis.circle")
				}
			}
		}
		.task {
			areasUpToDate = await isApiAreasUpdated()
		}
		.alert(isPresented: $showDeleteAlert)  {
			Alert(
				title: Text("Advarsel"),
				message: Text("Vil du slette alle landområdene?"),
				primaryButton: .destructive(Text("Slett")) {
					deleteAllAreas()
				},
				secondaryButton: .default(Text("Avbryt")))
		}
	}
	
	func saveArea(_ area: AreaModel) {
		if !areas.contains(where: { $0.name == area.name }) {
			let newArea = AreaModel(area.name)
			modelContext.insert(newArea)
			try? modelContext.save()
		}
	}
	
	private func saveOrUnarchiveArea(_ area: AreaModel) {
		if let existingAreaIndex = areas.firstIndex(where: { $0.name == area.name }) {
			areas[existingAreaIndex].archived = false
		} else {
			let newArea = AreaModel(area.name)
			modelContext.insert(newArea)
		}
		try? modelContext.save()
	}
	
	private func archiveArea(_ area: AreaModel) {
		area.archived = true
		Task {
			areasUpToDate = await isApiAreasUpdated()
		}
	}
	
	private func isApiAreasUpdated() async -> Bool {
		await viewModel.fetchAreas()
		let areasDict = Dictionary(uniqueKeysWithValues: areas.map { ($0.name, !$0.archived) })
		return viewModel.apiAreas.allSatisfy { apiArea in
			return areasDict[apiArea.name] ?? false
		}
	}
	
	private func deleteAllAreas() {
		for area in areas {
			modelContext.delete(area)
		}
		try? modelContext.save()
	}
}
struct AreaAddView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) var dismiss
	var areas: [AreaModel]
	let noFlag = AreaModel.defaultFlagUrl
	@State private var newArea: AreaModel = AreaModel()
	@State private var showAlert: Bool = false
	
	var body: some View {
		NavigationStack {
			Form {
				Section{
					TextField("Områdenavn (f.eks., Norsk)", text: $newArea.name)
						.disableAutocorrection(true)
						.onChange(of: newArea.name){ updateFlag()}
				} header: {
					Text("Landområde")
				}
				
				Section{
					HStack {
						TextField("Landskode (f.eks., NO)", text: $newArea.countryCode)
							.disableAutocorrection(true)
							.textInputAutocapitalization(.characters)
							.onChange(of: newArea.countryCode) {
								newArea.countryCode = String(newArea.countryCode.prefix(2))
								if newArea.countryCode.count == 2 {
									updateFlag()
								}
								if newArea.countryCode.count == 1 {
									newArea.flagUrl = noFlag
								}
							}
						
						AsyncImage(url: newArea.flagUrl) { image in
							image.resizable()
								.aspectRatio(contentMode: .fit)
						} placeholder: {
							Color.white
						}
						.frame(width: 70, height: 35)
						.background(Color.clear)
						.clipped()
						.cornerRadius(4)
					}
				} header: {
					Text("Landskode med flagg")
				} footer: {
					Text("\(newArea.flagUrl)")
				}
			}
			.navigationBarTitle("Legg til område")
			.toolbar(content: {
				ToolbarItem(placement: .cancellationAction){
					Button("Avbryt", role: .cancel){
						dismiss()
					}
				}
				ToolbarItem(placement: .confirmationAction){
					Button(action: {
						saveArea()
					}, label: {
						Text("Lagre")
					})
					.disabled(newArea.name.isEmpty)
				}
			})
			.navigationBarBackButtonHidden()
			.alert(isPresented: $showAlert) {
				Alert(
					title: Text("Området finnes allerede"),
					dismissButton: .default(Text("OK")))
			}
		}
	}
	
	private func updateFlag(){
		newArea.updateCountryCode()
		newArea.updateFlagUrl()
	}
	
	private func saveArea() {
		if areas.contains(where: {$0.name == newArea.name}) {
			showAlert = true
			return
		}
		if newArea.name.isEmpty { return }
		modelContext.insert(newArea)
		try? modelContext.save()
		
		dismiss()
	}
}
struct AreaEditView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) var dismiss
	var area: AreaModel
	var areas: [AreaModel]
	@State private var updatedArea: AreaModel = AreaModel()
	
	var body: some View {
		Form {
			
			Section{
				TextField("Områdenavn (f.eks., Norsk)", text: $updatedArea.name)
				.disableAutocorrection(true)
				.onChange(of: updatedArea.name){
					updatedArea.updateCountryCode()
					updatedArea.updateFlagUrl()
				}
			} header: {
				Text("Landområde")
			}
			
			Section{
				HStack{
					TextField("Landskode (f.eks., NO)", text: $updatedArea.countryCode)
						.disableAutocorrection(true)
						.textInputAutocapitalization(.characters)
						.onChange(of: updatedArea.countryCode){
							updatedArea.countryCode = String(updatedArea.countryCode.prefix(2))
							if updatedArea.countryCode.count == 2 {
								updatedArea.updateFlagUrl()
							}
							if updatedArea.countryCode.count == 1 {
								updatedArea.updateFlagUrl()
							}
						}
					
					AsyncImage(url: updatedArea.flagUrl) { image in
						image.resizable()
							.aspectRatio(contentMode: .fit)
					} placeholder: {
						Color.white
					}
					.frame(width: 70, height: 35)
					.background(Color.clear)
					.clipped()
					.cornerRadius(4)
				}
			} header: {
				Text("Landskode med flagg")
			} footer: {
				Text("\(updatedArea.flagUrl)")
			}
		}
		.onAppear(){
			updatedArea.name = area.name
			updatedArea.countryCode = area.countryCode
		}
		.navigationTitle("Rediger landområde").navigationBarTitleDisplayMode(.inline)
		.toolbar(content: {
			ToolbarItem(placement: .cancellationAction){
				Button("Avbryt", role: .cancel){
					dismiss()
				}
			}
			ToolbarItem(placement: .confirmationAction){
				Button(action: {
					saveUpdatedArea()
					dismiss()
				}, label: {
					Text("Lagre")
				})
				.disabled(updatedArea.name.isEmpty || (updatedArea.name == area.name && updatedArea.countryCode == area.countryCode))
			}
		})
		.navigationBarBackButtonHidden()
	}
	
	private func saveUpdatedArea() {
		area.name = updatedArea.name
		area.countryCode = updatedArea.countryCode
		area.updateFlagUrl()
		try? modelContext.save()
	}
}

struct MealArchiveView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) var dismiss
	var archivedMeals: [MealModel]
	@State private var showDeleteAlert = false
	
	var body: some View {
		NavigationStack{
			if !archivedMeals.isEmpty {
				List{
					Section(header: Text("Arkiverte oppskrifter")){
						
						ForEach(archivedMeals, id: \.self) { meal in
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
									unArchive(meal)
								} label: {
									Label("Flytt til mine oppskrifter", systemImage: "tray.and.arrow.up.fill")
								}
								.tint(.gray)
							}
						}
					}
				}
			} else {
				ContentUnavailableView("Ingen arkiverte oppskrifter", systemImage: "archivebox")
					.onAppear(){
						dismiss()
					}
			}
		}
		.navigationTitle("\(archivedMeals.count) arkiverte oppskrifter")
		.toolbar {
			Menu {
				Button(role: .cancel) {
					archivedMeals.forEach { meal in
						unArchive(meal)
					}
				}label:{
					Label("Gjennopprett alle oppskrifter", systemImage: "tray.and.arrow.up.fill")
				}
				Button(role: .destructive) {
					showDeleteAlert = true
				}label:{
					Label("Slett alle oppskrifter", systemImage: "trash.fill")
				}
			} label: {
				Image(systemName: "ellipsis.circle")
			}
		}
		.alert(isPresented: $showDeleteAlert)  {
			Alert(
				title: Text("Advarsel"),
				message: Text("Vil du slette alle oppskriftene?"),
				primaryButton: .destructive(Text("Slett")) {
					deleteAllAreas()
				},
				secondaryButton: .default(Text("Avbryt")))
		}
	}
	private func deleteAllAreas() {
		archivedMeals.forEach { meal in
			delete(meal)
		}
	}
	private func unArchive(_ meal: MealModel) {
		meal.archived = false
	}
	private func delete(_ meal: MealModel) {
		modelContext.delete(meal)
		try? modelContext.save()
	}
}
struct IngredientArchiveView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) var dismiss
	var archivedIngredients: [IngredientModel]
	@State private var showDeleteAlert = false
	
	var body: some View {
		NavigationStack{
			if !archivedIngredients.isEmpty {
				List{
					Section(header: Text("Arkiverte ingredienser")){
						
						ForEach(archivedIngredients, id: \.self) { ingredient in
							HStack {
								Text(ingredient.name)
								Spacer()
							}
							.swipeActions(edge: .trailing){
								Button(role: .destructive) {
									delete(ingredient)
								} label: {
									Label("Slett", systemImage: "trash.fill")
								}
								Button(role: .destructive) {
									unArchive(ingredient)
								} label: {
									Label("Flytt til mine ingredienser", systemImage: "tray.and.arrow.up.fill")
								}
								.tint(.gray)
							}
						}
					}
				}
			} else {
				ContentUnavailableView("Ingen arkiverte ingredienser", systemImage: "archivebox")
					.onAppear(){
						dismiss()
					}
			}
		}
		.navigationTitle("\(archivedIngredients.count) arkiverte ingredienser")
		.toolbar {
			Menu {
				Button(role: .cancel) {
					archivedIngredients.forEach { ingredient in
						unArchive(ingredient)
					}
				}label:{
					Label("Gjennopprett alle ingredienser", systemImage: "tray.and.arrow.up.fill")
				}
				Button(role: .destructive) {
					showDeleteAlert = true
				}label:{
					Label("Slett alle ingredienser", systemImage: "trash.fill")
				}
			} label: {
				Image(systemName: "ellipsis.circle")
			}
		}
		.alert(isPresented: $showDeleteAlert) {
			Alert(
				title: Text("Advarsel"),
				message: Text("Vil du slette alle ingrediensene?"),
				primaryButton: .destructive(Text("Slett")) {
					deleteAllAreas()
				},
				secondaryButton: .default(Text("Avbryt")))
		}
	}
	private func deleteAllAreas() {
		archivedIngredients.forEach { ingredient in
			delete(ingredient)
		}
	}
	private func unArchive(_ ingredient: IngredientModel) {
		ingredient.archived = false
	}
	private func delete(_ ingredient: IngredientModel) {
		modelContext.delete(ingredient)
		try? modelContext.save()
	}
}
struct CategoryArchiveView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) var dismiss
	var archivedCategories: [CategoryModel]
	@State private var showDeleteAlert = false
	
	var body: some View {
		NavigationStack{
			if !archivedCategories.isEmpty {
				List{
					Section(header: Text("Arkiverte kategorier")){
						
						ForEach(archivedCategories, id: \.self) { category in
							HStack {
								Text(category.name)
								Spacer()
							}
							.swipeActions(edge: .trailing){
								Button(role: .destructive) {
									delete(category)
								} label: {
									Label("Slett", systemImage: "trash.fill")
								}
								Button(role: .destructive) {
									unArchive(category)
								} label: {
									Label("Flytt til mine kategorier", systemImage: "tray.and.arrow.up.fill")
								}
								.tint(.gray)
							}
						}
					}
				}
			} else {
				ContentUnavailableView("Ingen arkiverte kategorier", systemImage: "archivebox")
					.onAppear(){
						dismiss()
					}
			}
		}
		.navigationTitle("\(archivedCategories.count) arkiverte kategorier")
		.toolbar {
			Menu {
				Button(role: .cancel) {
					archivedCategories.forEach { category in
						unArchive(category)
					}
				}label:{
					Label("Gjennopprett alle kategorier", systemImage: "tray.and.arrow.up.fill")
				}
				Button(role: .destructive) {

					showDeleteAlert = true
				}label:{
					Label("Slett alle kategorier", systemImage: "trash.fill")
				}
			} label: {
				Image(systemName: "ellipsis.circle")
			}
		}
		.alert(isPresented: $showDeleteAlert) {
			Alert(
				title: Text("Slett alle kategorier"),
				message: Text("Er du sikker på at du vil slette alle kategorier?"),
				primaryButton: .destructive(Text("Slett")) {
					deleteAllAreas()
				},
				secondaryButton: .default(Text("Avbryt")))
		}
	}
	private func deleteAllAreas() {
		archivedCategories.forEach { category in
			delete(category)
		}
	}
	private func unArchive(_ category: CategoryModel) {
		category.archived = false
	}
	private func delete(_ category: CategoryModel) {
		modelContext.delete(category)
		try? modelContext.save()
	}
}
struct AreaArchiveView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) var dismiss
	var archivedAreas: [AreaModel]
	@State private var showDeleteAlert = false
	
	var body: some View {
		NavigationStack{
			if !archivedAreas.isEmpty {
				List{
					Section(header: Text("Arkiverte landområde")){
						
						ForEach(archivedAreas, id: \.self) { area in
							HStack {
								Text(area.name)
								Spacer()
							}
							.swipeActions(edge: .trailing){
								Button(role: .destructive) {
									delete(area)
								} label: {
									Label("Slett", systemImage: "trash.fill")
								}
								Button(role: .destructive) {
									unArchive(area)
								} label: {
									Label("Flytt til mine landområde", systemImage: "tray.and.arrow.up.fill")
								}
								.tint(.gray)
							}
						}
					}
				}
			} else {
				ContentUnavailableView("Ingen arkiverte landområde", systemImage: "archivebox")
					.onAppear(){
						dismiss()
					}
			}
		}
		.navigationTitle("\(archivedAreas.count) arkiverte landområder")
		.toolbar {
			Menu {
				Button(role: .cancel) {
					archivedAreas.forEach { area in
						unArchive(area)
					}
				}label:{
					Label("Gjennopprett alle landområde", systemImage: "tray.and.arrow.up.fill")
				}
				Button(role: .destructive) {
					showDeleteAlert = true
				}label:{
					Label("Slett alle landområde", systemImage: "trash.fill")
				}
			} label: {
				Image(systemName: "ellipsis.circle")
			}
		}
		.alert(isPresented: $showDeleteAlert){
			Alert(
				title: Text("Slette alle landområde?"),
				message: Text("Dette vil slette alle landområde permanent"),
				primaryButton: .destructive(Text("Slett")) {
					deleteAllAreas()
				}, secondaryButton: .cancel())
		}
	}
	private func deleteAllAreas() {
		archivedAreas.forEach { area in
			delete(area)
		}
	}
	private func unArchive(_ area: AreaModel) {
		area.archived = false
	}
	private func delete(_ area: AreaModel) {
		modelContext.delete(area)
		try? modelContext.save()
	}
}

#Preview {
	SettingView()
		.environmentObject(ColorSchemeManager())
		.environmentObject(SettingsViewModel())
		.modelContainer(for: [MealModel.self, IngredientModel.self, CategoryModel.self, AreaModel.self])
}
