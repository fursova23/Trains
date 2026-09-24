import SwiftUI

struct MainView: View {
    @ObservedObject private var viewModel: MainViewModel

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            StoriesCollectionView(stories: viewModel.stories)
                .padding(.top, 24)

            routeSelector
                .padding(.horizontal, 16)
                .padding(.top, 44)

            if viewModel.isRouteComplete {
                Button(action: viewModel.search) {
                    Text("Найти")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 150, height: 60)
                        .background(Color("BrandBlue"))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.top, 16)
            }

            Spacer()
        }
        .background(Color(uiColor: .systemBackground))
        .toolbar(.hidden, for: .navigationBar)
    }

    private var routeSelector: some View {
        HStack(spacing: 16) {
            VStack(spacing: 0) {
                routeButton(
                    title: viewModel.origin?.title ?? "Откуда",
                    isPlaceholder: viewModel.origin == nil,
                    action: { viewModel.beginSelection(.origin) }
                )
                .accessibilityIdentifier("originField")

                routeButton(
                    title: viewModel.destination?.title ?? "Куда",
                    isPlaceholder: viewModel.destination == nil,
                    action: { viewModel.beginSelection(.destination) }
                )
                .accessibilityIdentifier("destinationField")
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            Button(action: viewModel.swapRoute) {
                Image("swap_button")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color("BrandBlue"))
                    .frame(width: 36, height: 36)
                    .background(Color.white)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Поменять местами")
        }
        .padding(16)
        .background(Color("BrandBlue"))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func routeButton(
        title: String,
        isPlaceholder: Bool,
        action: @escaping () -> Void
    ) -> some View {
        let titleColor = isPlaceholder ? Color("PlaceholderGray") : Color.black

        return Button(action: action) {
            Text(title)
                .font(.system(size: 17))
                .foregroundStyle(titleColor)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 48)
                .padding(.horizontal, 16)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .tint(titleColor)
    }
}

#Preview("Главная без маршрута") {
    NavigationStack {
        MainView(viewModel: MainViewModel())
    }
}

#Preview("Главная с маршрутом") {
    NavigationStack {
        MainView(
            viewModel: MainViewModel(
                origin: RoutePoint(
                    city: "Москва",
                    station: "Курский вокзал",
                    stationCode: "s2000001"
                ),
                destination: RoutePoint(
                    city: "Санкт Петербург",
                    station: "Балтийский вокзал",
                    stationCode: "s9602494"
                )
            )
        )
    }
}
