import SwiftUI

struct CarrierDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CarrierDetailsViewModel
    private let trip: CarrierTrip

    // MARK: - Initialization

    init(
        trip: CarrierTrip,
        viewModel: @autoclosure @escaping () -> CarrierDetailsViewModel
    ) {
        self.trip = trip
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            navigationBar
            content
        }
        .background(
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
        )
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .task { await viewModel.load() }
    }

    // MARK: - Subviews

    private var navigationBar: some View {
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
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                logo
                    .frame(height: 104)
                    .frame(maxWidth: .infinity)
                    .background(
                        .white,
                        in: RoundedRectangle(cornerRadius: 24)
                    )
                    .padding(.top, 16)

                Text(viewModel.details?.name ?? trip.carrierName)
                    .font(.system(size: 24, weight: .bold))

                stateContent
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private var stateContent: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, 24)

        case .failed(let error):
            Text(error.title)
                .foregroundStyle(.secondary)

            Button("Повторить", action: retryLoading)

        case .loaded:
            contact(
                title: "E-mail",
                value: viewModel.details?.email,
                url: viewModel.details?.emailURL
            )

            contact(
                title: "Телефон",
                value: viewModel.details?.phone,
                url: viewModel.details?.phoneURL
            )
        }
    }

    private var logo: some View {
        let name = viewModel.details?.name ?? trip.carrierName
        let logoURL = viewModel.details?.logoURL ?? trip.logoURL

        return AsyncImage(url: logoURL) { phase in
            if case .success(let image) = phase {
                image.resizable().scaledToFit().padding(16)
            } else {
                Text(name)
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
        VStack(alignment: .leading, spacing: .zero) {
            Text(title)
                .font(.system(size: 17))

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

    // MARK: - Actions

    private func retryLoading() {
        Task {
            await viewModel.load()
        }
    }
}

// MARK: - Previews

#Preview("Загрузка") {
    NavigationStack {
        CarrierDetailsView(
            trip: CarrierDetailsPreviewData.trip,
            viewModel: CarrierDetailsViewModel(
                carrierCode: CarrierDetailsPreviewData.carrierCode,
                repository: CarrierDetailsPreviewRepository(result: nil)
            )
        )
    }
}

#Preview("Загружено") {
    NavigationStack {
        CarrierDetailsView(
            trip: CarrierDetailsPreviewData.trip,
            viewModel: CarrierDetailsViewModel(
                carrierCode: CarrierDetailsPreviewData.carrierCode,
                repository: CarrierDetailsPreviewRepository(
                    result: .success(CarrierDetailsPreviewData.details)
                )
            )
        )
    }
}

#Preview("Ошибка") {
    NavigationStack {
        CarrierDetailsView(
            trip: CarrierDetailsPreviewData.trip,
            viewModel: CarrierDetailsViewModel(
                carrierCode: CarrierDetailsPreviewData.carrierCode,
                repository: CarrierDetailsPreviewRepository(
                    result: .failure(URLError(.badServerResponse))
                )
            )
        )
    }
}

private enum CarrierDetailsPreviewData {
    static let carrierCode = 112

    static let trip = CarrierTrip(
        id: "preview",
        carrierCode: carrierCode,
        carrierName: "ОАО «РЖД»",
        logoURL: nil,
        departure: .now,
        arrival: .now,
        duration: 0,
        hasTransfer: false
    )

    static let details = CarrierDetails(
        name: "ОАО «РЖД»",
        logoURL: nil,
        email: "info@rzd.ru",
        phone: "+7 (800) 775-00-00"
    )
}

private struct CarrierDetailsPreviewRepository: CarrierDetailsRepositoryProtocol {
    let result: Result<CarrierDetails, Error>?

    func fetchCarrier(code: Int) async throws -> CarrierDetails {
        guard let result else {
            try await Task.sleep(nanoseconds: 3_600_000_000_000)
            throw CancellationError()
        }

        return try result.get()
    }
}
