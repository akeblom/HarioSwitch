import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.name) private var recipes: [Recipe]
    @State private var showingNewRecipe = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(recipes) { recipe in
                    NavigationLink(value: recipe) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(recipe.name)
                                .font(.headline)
                            HStack(spacing: 12) {
                                Label("\(recipe.coffeeGrams, specifier: "%.0f")g", systemImage: "scalemass")
                                Label("\(recipe.waterML, specifier: "%.0f")ml", systemImage: "drop")
                                Text(recipe.ratioString)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(recipe.formattedTotalDuration)
                                    .foregroundStyle(.secondary)
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .onDelete(perform: deleteRecipes)
            }
            .navigationTitle("Hario Switch recipies")
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewRecipe = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewRecipe) {
                NavigationStack {
                    RecipeDetailView(recipe: nil)
                }
            }
            .overlay {
                if recipes.isEmpty {
                    ContentUnavailableView(
                        "No Recipes",
                        systemImage: "cup.and.saucer",
                        description: Text("Tap + to create your first recipe.")
                    )
                }
            }
        }
    }

    private func deleteRecipes(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(recipes[index])
        }
    }
}
