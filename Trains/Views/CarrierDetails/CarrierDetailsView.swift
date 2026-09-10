import SwiftUI
import UIKit

struct CarrierDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CarrierDetailsViewModel

    init(trip: CarrierTrip) {
        _viewModel = StateObject(wrappedValue: CarrierDetailsViewModel(trip: trip))
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Информация о перевозчике")
                    .font(.system(size: 17, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 48)
                HStack {
                    AppBackButton { dismiss() }
                    Spacer()
                }
            }
            .frame(height: 44)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    logo
                        .frame(height: 104)
                        .frame(maxWidth: .infinity)
                        .background(.white, in: RoundedRectangle(cornerRadius: 24))
                        .padding(.top, 16)

                    Text(viewModel.details.name)
                        .font(.system(size: 24, weight: .bold))

                    switch viewModel.state {
                    case .idle, .loading:
                        ProgressView().frame(maxWidth: .infinity).padding(.top, 24)
                    case .failed(let error):
                        Text(error.title).foregroundStyle(.secondary)
                        Button("Повторить") { Task { await viewModel.load() } }
                    case .loaded:
                        contact(title: "E-mail", value: viewModel.details.email, url: viewModel.details.emailURL)
                        contact(title: "Телефон", value: viewModel.details.phone, url: viewModel.details.phoneURL)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            }
        }
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .task { await viewModel.load() }
    }

    private var logo: some View {
        AsyncImage(url: viewModel.details.logoURL) { phase in
            if case .success(let image) = phase {
                image.resizable().scaledToFit().padding(16)
            } else if viewModel.details.name.localizedCaseInsensitiveContains("РЖД"),
                      let image = UIImage(named: "carrier_logo") {
                Image(uiImage: image).resizable().scaledToFit().padding(16)
            } else {
                Text(viewModel.details.name)
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color("BrandBlue"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(16)
            }
        }
        .accessibilityLabel("Логотип перевозчика")
    }

    private func contact(title: String, value: String?, url: URL?) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title).font(.system(size: 17))
            if let value, let url {
                Link(value, destination: url)
                    .font(.system(size: 12))
                    .foregroundStyle(Color("BrandBlue"))
            } else {
                Text(value ?? "Не указан")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(minHeight: 44, alignment: .leading)
    }
}
