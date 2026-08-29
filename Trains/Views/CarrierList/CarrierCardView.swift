import SwiftUI

struct CarrierCardView: View {
    let trip: CarrierTrip

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                CarrierLogoView(
                    url: trip.logoURL,
                    fallbackText: String(trip.carrierName.prefix(2)).uppercased()
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(trip.carrierName)
                        .font(.system(size: 17))
                        .foregroundStyle(.black)
                        .lineLimit(2)

                    if let transferDescription = trip.transferDescription {
                        Text(transferDescription)
                            .font(.system(size: 12))
                            .foregroundStyle(Color("TransferColor"))
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 8)

                Text(trip.dateText)
                    .font(.system(size: 12))
                    .foregroundStyle(.black)
            }

            HStack(spacing: 8) {
                Text(trip.departureText)
                    .font(.system(size: 17))

                Rectangle()
                    .fill(Color.black.opacity(0.2))
                    .frame(height: 1)

                Text(trip.durationText)
                    .font(.system(size: 12))
                    .fixedSize()

                Rectangle()
                    .fill(Color.black.opacity(0.2))
                    .frame(height: 1)

                Text(trip.arrivalText)
                    .font(.system(size: 17))
            }
            .foregroundStyle(.black)
        }
        .padding(14)
        .frame(height: 104)
        .background(Color("ScheduleCardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
