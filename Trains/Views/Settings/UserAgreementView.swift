import SwiftUI
import WebKit

struct UserAgreementView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var loadError: AppErrorKind?
    @State private var reloadID = UUID()

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Пользовательское соглашение")
                    .font(.system(size: 17, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 36)
                HStack {
                    AppBackButton { dismiss() }
                    Spacer()
                }
            }
            .frame(height: 42)

            ZStack {
                AgreementWebView(url: AppSettings.agreementURL, isLoading: $isLoading, loadError: $loadError)
                    .id(reloadID)
                    .opacity(loadError == nil ? 1 : 0)

                if let loadError {
                    VStack(spacing: 16) {
                        ErrorStateView(kind: loadError)
                        Button("Повторить") {
                            self.loadError = nil
                            isLoading = true
                            reloadID = UUID()
                        }
                        .padding(.bottom, 24)
                    }
                } else if isLoading {
                    ProgressView()
                }
            }
        }
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
        .accessibilityIdentifier("agreementScreen")
    }
}

private struct AgreementWebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var loadError: AppErrorKind?

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        view.isOpaque = false
        view.backgroundColor = .clear
        view.load(URLRequest(url: url))
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.parent = self
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.navigationDelegate = nil
        uiView.stopLoading()
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var parent: AgreementWebView

        init(parent: AgreementWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            handle(error)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            handle(error)
        }

        private func handle(_ error: Error) {
            guard (error as NSError).code != NSURLErrorCancelled else { return }
            parent.isLoading = false
            parent.loadError = AppErrorKind.from(error)
        }
    }
}
