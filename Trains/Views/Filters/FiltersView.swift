import SwiftUI

struct FiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding private var filter: CarrierFilter
    @State private var draft: CarrierFilter

    init(filter: Binding<CarrierFilter>) {
        _filter = filter
        _draft = State(initialValue: filter.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                AppBackButton { dismiss() }
                Spacer()
            }
            .padding(.horizontal, 4)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Время отправления")
                        .font(.system(size: 24, weight: .bold))
                        .padding(.bottom, 20)

                    ForEach(DeparturePeriod.allCases) { period in
                        Button {
                            toggle(period)
                        } label: {
                            HStack {
                                Text(period.title)
                                    .font(.system(size: 17))
                                    .foregroundStyle(.primary)

                                Spacer()

                                Checkbox(isSelected: draft.periods.contains(period))
                            }
                            .frame(height: 60)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }

                    Text("Показывать варианты с пересадками")
                        .font(.system(size: 24, weight: .bold))
                        .padding(.top, 20)
                        .padding(.bottom, 14)

                    ForEach(TransferOption.allCases) { option in
                        Button {
                            draft.transferOption = option
                        } label: {
                            HStack {
                                Text(option.title)
                                    .font(.system(size: 17))
                                    .foregroundStyle(.primary)

                                Spacer()

                                RadioButton(isSelected: draft.transferOption == option)
                            }
                            .frame(height: 60)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color(uiColor: .systemBackground))
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if draft.hasSelection {
                Button {
                    filter = draft
                    dismiss()
                } label: {
                    Text("Применить")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color("BrandBlue"))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(Color(uiColor: .systemBackground))
            }
        }
    }

    private func toggle(_ period: DeparturePeriod) {
        if draft.periods.contains(period) {
            draft.periods.remove(period)
        } else {
            draft.periods.insert(period)
        }
    }
}

private struct Checkbox: View {
    let isSelected: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(isSelected ? Color.primary : Color.clear)

            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(Color.primary, lineWidth: 2)

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(uiColor: .systemBackground))
            }
        }
        .frame(width: 24, height: 24)
    }
}

private struct RadioButton: View {
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.primary, lineWidth: 2)

            if isSelected {
                Circle()
                    .fill(Color.primary)
                    .padding(5)
            }
        }
        .frame(width: 24, height: 24)
    }
}

#Preview("Фильтры") {
    NavigationStack {
        FiltersView(filter: .constant(CarrierFilter()))
    }
}
