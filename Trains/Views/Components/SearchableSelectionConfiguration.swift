struct SearchableSelectionConfiguration<Item> {
    let title: String
    let items: [Item]
    let itemTitle: KeyPath<Item, String>
    let emptyMessage: String
}
