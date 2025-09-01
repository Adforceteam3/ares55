import SwiftUI
import WebKit
import Combine

struct DuckView: View {
    @StateObject private var viewModel = WebModel()
    @State private var flower: WKWebView? = nil
    @State private var canGoBack = false
    @State private var showPopup = false
    
    var method = StartFlow.shared

    var body: some View {
        ZStack {
            if let url = URL(string: method.currentLink ?? "") {
                StoneView(
                    url: url,
                    agent: StartFlow.agent,
                    treeView: $flower,
                    canGoBack: $canGoBack,
                    popupWebView: $viewModel.popupWebView,
                    showPopup: $showPopup
                )
            }
        }
        .background(.black)
        .sheet(isPresented: $showPopup) {
            if let popupWebView = viewModel.popupWebView {
                VStack {
                    HStack {
                        Spacer()
                        Button{
                            self.showPopup.toggle()
                        }label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    PopupView(view: popupWebView)
                }
            }
        }
    }
}

struct PopupView: UIViewRepresentable {
    let view: WKWebView
    func makeUIView(context: Context) -> UIView {
        view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

class WebModel: ObservableObject {
    var cancellables = Set<AnyCancellable>()
    @Published var popupWebView: WKWebView?
}

struct StoneView: UIViewRepresentable {
    let url: URL
    let agent: String
    @StateObject var webModel = WebModel()
    @Binding var treeView: WKWebView?
    
    @Binding var canGoBack: Bool
    @Binding var popupWebView: WKWebView?
    @Binding var showPopup: Bool

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: StoneView
        
        init(_ parent: StoneView) {
            self.parent = parent
            
        }
        
        @objc func handleRefresh(_ sender: UIRefreshControl) {
            parent.treeView?.reload()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                sender.endRefreshing()
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                let cookieData = cookies.compactMap {
                    try? NSKeyedArchiver.archivedData(withRootObject: $0, requiringSecureCoding: false)
                }
                UserDefaults.standard.set(cookieData, forKey: "SavedCookies")
            }
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.treeView = webView
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                let scheme = url.scheme?.lowercased()
                let urlString = url.absoluteString.lowercased()
                
                if let scheme = scheme,
                   scheme != "http", scheme != "https", scheme != "about" {
                    if scheme == "itms-apps" || urlString.contains("apps.apple.com") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        decisionHandler(.cancel)
                        return
                    }
                    
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    decisionHandler(.cancel)
                    return
                }
            }
            
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {

            let isNewWindowRequest = navigationAction.targetFrame == nil

            if isNewWindowRequest {
                let popup = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
                popup.navigationDelegate = self
                popup.uiDelegate = self

                DispatchQueue.main.async {
                    self.parent.popupWebView = popup
                    self.parent.showPopup = true
                }

                return popup
            }
            return nil
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsAirPlayForMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true
        config.websiteDataStore = WKWebsiteDataStore.default()
        
        let sea = WKWebView(frame: .zero, configuration: config)

        sea.scrollView.backgroundColor = .black
        sea.allowsBackForwardNavigationGestures = true
        sea.navigationDelegate = context.coordinator
        sea.uiDelegate = context.coordinator
        sea.customUserAgent = agent
        
        sea.publisher(for: \.canGoBack, options: [.new])
            .receive(on: DispatchQueue.main)
            .assign(to: \.canGoBack, on: self)
            .store(in: &webModel.cancellables)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.handleRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = .white
        sea.scrollView.refreshControl = refreshControl
        
        if let cookieData = UserDefaults.standard.array(forKey: "SavedCookies") as? [Data] {
            for data in cookieData {
                if let cookie = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? HTTPCookie {
                    config.websiteDataStore.httpCookieStore.setCookie(cookie)
                }
            }
        }

        sea.load(URLRequest(url: url))
        return sea
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
