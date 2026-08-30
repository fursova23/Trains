import SwiftUI

struct SearchableSelectionView<Item: Identifiable>: View where Item.ID: Hashable {
    let configuration: SearchableSelectionConfiguration<Item>
    let onBack: () -> Void
    let onSelect: (Item) -> Void

    @State private var query = ""

    private var filteredItems: [Item] {
        guard !query.isEmpty else { return configuration.items }

        return configuration.items.filter {
            title(for: $0).localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            SearchField(text: $query)
                .padding(.horizontal, 16)

            if filteredItems.isEmpty {
                Spacer()

                Text(configuration.emptyMessage)
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)

                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredItems) { item in
                            Button {
                                onSelect(item)
                            } label: {
                                HStack(spacing: 12) {
                                    Text(title(for: item))
                                        .font(.system(size: 17))
                                        .foregroundStyle(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(.primary)
                                }
                                .frame(height: 60)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .background(Color(uiColor: .systemBackground))
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        ZStack {
            Text(configuration.title)
                .font(.system(size: 17, weight: .bold))

            HStack {
                AppBackButton(action: onBack)
                Spacer()
            }
        }
        .frame(height: 50)
        .padding(.horizontal, 8)
    }

    private func title(for item: Item) -> String {
        item[keyPath: configuration.itemTitle]
    }
}
