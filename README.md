# Ratatouille
Welcome to my first iOS app! Ratatouille is designed for browsing, creating, and storing food recipes. It fetches recipe data from the [themealdb](https://www.themealdb.com) API, allowing users to search, view details, and download recipes. The user interface is in Norwegian, aligning with the requirements of my exam task, while the underlying code and API interactions are in English.


## Preview
![ratatouille-app](https://github.com/AugustElvevold/2023.11.13-school-ios-exam-ratatouille/assets/89490288/d86e9bf8-a54c-48fe-bae7-e6736c55460c)

## Getting started
To run Ratatouille locally, follow these steps:
1. Clone the repository.
2. Open the project in Xcode.
3. Run the project on an iOS simulator or a physical iPhone.

## Features

### Splash Screen
The app features an animated splash screen that smoothly transitions upon launch.

### Oppskrifter (Recipes)
This is the main view where users can:
- View all locally saved recipes.
- Create new recipes or edit existing ones.
- Swipe left on a recipe to archive it.

### Søk (Search)
In the search view, users can:
- Perform keyword searches or use the "Filtrert søk" for filtering by category, area, or ingredient.
- Swipe left to save recipes or tap to view detailed information.
- Access external links to recipes, such as YouTube videos or original websites.
- Recipes that are already saved are highlighted with a green icon.

### Innstillinger (Settings)
Settings allow users to:
- View and manage areas, categories, and ingredients (which are initially empty and can be populated from the API or manually).
- Use the [flagsapi](https://flagsapi.com) to display country flags based on codes.
- Switch between dark, light, and automatic themes.
- Toggle between a custom search method and the exam-required search method.
- Manage archived recipes, including un-archiving or deleting them individually or in bulk.


