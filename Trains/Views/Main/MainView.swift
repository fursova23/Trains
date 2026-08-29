import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: TravelScheduleViewModel
    @Binding var origin: RoutePoint?
    @Binding var destination: RoutePoint?

    let onSelectOrigin: () -> Void
    let onSelectDestination: () -> Void

    @State private var showsCarriers = false

    private var isRouteComplete: Bool {
        origin != nil && destination != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            routeSelector
                .padding(.horizontal, 16)
                .padding(.top, 24)

            if isRouteComplete {
                Button {
                    showsCarriers = true
                } label: {
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
        .navigationDestination(isPresented: $showsCarriers) {
            if let origin, let destination {
                CarrierListView(
                    viewModel: viewModel,
                    origin: origin,
                    destination: destination
                )
            }
        }
    }

    private var routeSelector: some View {
        HStack(spacing: 16) {
            VStack(spacing: 0) {
                routeButton(
                    title: origin?.title ?? "Откуда",
                    isPlaceholder: origin == nil,
                    action: onSelectOrigin
                )

                routeButton(
                    title: destination?.title ?? "Куда",
                    isPlaceholder: destination == nil,
                    action: onSelectDestination
                )
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            Button {
                swap(&origin, &destination)
            } label: {
                Image("swap_button")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color("BrandBlue"))
                    .frame(width: 44, height: 44)
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
                .frame(height: 56)
                .padding(.horizontal, 16)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .tint(titleColor)
    }
}

#Preview("Главная с маршрутом") {
    NavigationStack {
        MainView(
            viewModel: TravelScheduleViewModel(),
            origin: .constant(RoutePoint(
                city: "Москва",
                station: "Курский вокзал",
                stationCode: "s2000001"
            )),
            destination: .constant(RoutePoint(
                city: "Санкт Петербург",
                station: "Балтийский вокзал",
                stationCode: "s9602494"
            )),
            onSelectOrigin: {},
            onSelectDestination: {}
        )
    }
}
