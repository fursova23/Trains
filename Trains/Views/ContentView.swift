import SwiftUI

struct ContentView: View {
    @StateObject private var demo = NetworkServicesDemo()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Перед запуском добавьте YANDEX_RASP_API_KEY в Environment Variables схемы Trains")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button("Проверить основные сервисы") {
                    Task {
                        await demo.runBasicChecks()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(demo.isRunning)

                Button("Загрузить все станции") {
                    Task {
                        await demo.loadAllStations()
                    }
                }
                .buttonStyle(.bordered)
                .disabled(demo.isRunning)

                if demo.isRunning {
                    ProgressView()
                }

                List(demo.messages, id: \.self) { message in
                    Text(message)
                        .font(.callout.monospaced())
                }
                .listStyle(.plain)
            }
            .padding()
            .navigationTitle("Проверка API")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
