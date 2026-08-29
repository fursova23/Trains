import SwiftUI

struct CarrierLogoView: View {
    let url: URL?
    let fallbackText: String

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .padding(4)
            default:
                Text(fallbackText)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("BrandBlue"))
            }
        }
        .frame(width: 38, height: 38)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
