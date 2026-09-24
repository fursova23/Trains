import SwiftUI
import WebKit

struct AgreementWebView: UIViewRepresentable {
    let request: WebPageRequest

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        view.isOpaque = false
        view.backgroundColor = .clear
        view.load(URLRequest(url: request.url))
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.parent = self
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.navigationDelegate = nil
        uiView.stopLoading()
        coordinator.parent.request.complete(.failure(CancellationError()))
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var parent: AgreementWebView

        init(parent: AgreementWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.request.complete(.success(()))
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            handle(error)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            handle(error)
        }

        private func handle(_ error: Error) {
            guard (error as NSError).domain != NSURLErrorDomain
                    || (error as NSError).code != NSURLErrorCancelled else { return }
            parent.request.complete(.failure(error))
        }
    }
}

#Preview("Agreement Web View") {
    AgreementWebView(request: WebPageRequest(url: AppSettings.agreementURL))
}
