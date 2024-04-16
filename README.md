# Ratatouille
This is a an ios app for browsing, creating and storing food recipes. The app uses `themealdb` api to fetch meals the user serarches for and lists it in a view for the user to check out details and download it if desired. The UI is Norwegian even though the code and api is english as required in the exam task.

## Preview
![ratatouille-app](https://github.com/AugustElvevold/2023.11.13-school-ios-exam-ratatouille/assets/89490288/173c2bff-562d-4b7c-87ed-d64fee5d3c78)

## Getting started
1. Clone repo
2. Open in xcode
3. Run on simulator or iPhone

## Features

* **Splash screen:**
  The app includes a launch screen that transitions into a splash screen view that is animated on launch.

* **"Oppskrifter":**
  Main view that the user loads into when opening the app. It will list all the recipes saved and stored locally on the device. You can create a new, edit existing ones, or swipe left to archive recipes.

* **"Søk":**
  Search view is where you can find all recipes online. You can search for keyword and get results or you can do searches by category, area, or ingredient in "Filtrert søk". When you get the results you can swipe left to save or click on meals to view details. Some meals have links to youtube video or website where the recipe is originaly from. When you save recipes the app will automaticly highlight already saved meals with a green icon on the meal.

* **"Innstillinger":**
  In settings you can look at all the areas, categories, and ingredients. They are empty untill you either create one or download from the api. The area items also use flagsapi with country code to load in flag images.
  There is also an option to switch between dark, light and automatic theme for the app.
  I added a toggle to switch between a, in my opinion, better search method and the exam required method in the "Filtrert søk".
  Last there is archive where all the archive-swipted items go. In archive view the different categories are sorted to their own lists, inside each one you can go to un-archive or delete them fully. You can also click in the top right to get a menu for un-archiving or deleting all at once.

