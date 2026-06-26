import SwiftUI

struct CategoryManagerView: View {
    @ObservedObject var store: CategoryStore
    @State private var showAdd = false

    var body: some View {
        List {
            ForEach(store.categories) { category in
                HStack(spacing: 12) {
                    Image(systemName: category.symbol)
                        .foregroundStyle(category.color)
                        .frame(width: 24)
                    Text(category.name)
                }
            }
            .onDelete { offsets in
                offsets.map { store.categories[$0] }.forEach(store.delete)
            }
        }
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAdd = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .overlay {
            if store.categories.isEmpty {
                ContentUnavailableView(
                    "No categories",
                    systemImage: "tag",
                    description: Text("Add categories to organize your tasks.")
                )
            }
        }
        .sheet(isPresented: $showAdd) {
            CategoryEditorView(store: store)
        }
    }
}

struct CategoryEditorView: View {
    @ObservedObject var store: CategoryStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var colorHex = "#0A84FF"
    @State private var symbol = "tag.fill"

    private let palette = [
        "#0A84FF", "#5E5CE6", "#BF5AF2", "#FF375F",
        "#FF9F0A", "#FFD60A", "#30D158", "#40C8E0"
    ]
    private let symbols = [
        "tag.fill", "briefcase.fill", "person.fill", "heart.fill", "book.fill",
        "house.fill", "cart.fill", "dumbbell.fill", "cup.and.saucer.fill", "leaf.fill"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Category name", text: $name)
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 10) {
                        ForEach(palette, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex) ?? .blue)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle().stroke(Color.primary, lineWidth: colorHex == hex ? 3 : 0)
                                )
                                .onTapGesture { colorHex = hex }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 14) {
                        ForEach(symbols, id: \.self) { sym in
                            Image(systemName: sym)
                                .font(.title3)
                                .frame(width: 44, height: 44)
                                .background(
                                    (symbol == sym ? (Color(hex: colorHex) ?? .blue).opacity(0.2) : Color.clear),
                                    in: RoundedRectangle(cornerRadius: 10)
                                )
                                .foregroundStyle(symbol == sym ? (Color(hex: colorHex) ?? .blue) : .primary)
                                .onTapGesture { symbol = sym }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        store.add(name: name, colorHex: colorHex, symbol: symbol)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
