import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.name) private var recipes: [Recipe]
    @State private var showingNewRecipe = false

    var body: some View {
        NavigationStack {
            ScrollView {
                if recipes.isEmpty {
                    emptyState
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(recipes) { recipe in
                            NavigationLink(value: recipe) {
                                RecipeCardView(recipe: recipe, onDelete: {
                                    withAnimation {
                                        modelContext.delete(recipe)
                                    }
                                })
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Recipes")
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewRecipe = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .sheet(isPresented: $showingNewRecipe) {
                NavigationStack {
                    RecipeDetailView(recipe: nil)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 56))
                .foregroundStyle(.tertiary)
            Text("No Recipes")
                .font(.title2.bold())
            Text("Tap + to create your first recipe.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 120)
    }
}

struct RecipeCardView: View {
    let recipe: Recipe
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name)
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(recipe.ratioString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(recipe.formattedTotalDuration)
                    .font(.subheadline.weight(.medium).monospacedDigit())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }

            Divider()

            HStack(spacing: 16) {
                RecipeStatView(
                    icon: "scalemass.fill",
                    value: String(format: "%.0fg", recipe.coffeeGrams),
                    color: .brown
                )
                RecipeStatView(
                    icon: "drop.fill",
                    value: String(format: "%.0fml", recipe.waterML),
                    color: .cyan
                )
                RecipeStatView(
                    icon: "list.number",
                    value: "\(recipe.steps.count) steps",
                    color: .orange
                )
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct RecipeStatView: View {
    let icon: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    RecipeListView()
        .modelContainer(previewContainer)
}
