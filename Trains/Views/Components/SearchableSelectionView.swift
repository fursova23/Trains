import SwiftUI

struct SearchableSelectionView<Item: Identifiable>: View where Item.ID: Hashable {
    let title: String
    let items: [Item]
    let itemTitle: (Item) -> String
    let emptyMessage: String
    let onBack: () -> Void
    let onSelect: (Item) -> Void

    @State private var query = ""

    private var filteredItems: [Item] {
        guard !query.isEmpty else { return items }

        return items.filter {
            itemTitle($0).localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            SearchField(text: $query)
                .padding(.horizontal, 16)

            if filteredItems.isEmpty {
                Spacer()

                Text(emptyMessage)
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
                                    Text(itemTitle(item))
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
            Text(title)
                .font(.system(size: 17, weight: .bold))

            HStack {
                AppBackButton(action: onBack)
                Spacer()
            }
        }
        .frame(height: 50)
        .padding(.horizontal, 8)
    }
}
