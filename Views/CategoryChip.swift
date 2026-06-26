import SwiftUI

struct CategoryChip: View {
    let category: Category

    var body: some View {
        Label(category.name, systemImage: category.symbol)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(category.color.opacity(0.18), in: Capsule())
            .foregroundStyle(category.color)
    }
}
