import UIKit
import WebKit

public class DocCheckLogin: UIViewController {
    
    var webView: WKWebView? = nil
    
    let bundle = Bundle(url: Bundle(for: DocCheckLogin.classForCoder()).url(forResource: "DocCheckAppLoginSDK", withExtension: "bundle", subdirectory: nil)!)
    let toolbar: UIToolbar = UIToolbar()
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
    let cancelButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(cancelAction))
    let refreshButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshAction))
    var backButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(backAction))
    var forwardButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(forwardAction))
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    
    var language: String
    let loginId: String
    let templateName: String
    
    var loginFormUrl: URL? = nil
    var stopIntended: Bool = false
    
    let supportedLanguages = ["de", "com", "es", "fr", "nl", "it"]
    let DocCheckLoginUrl = "https://login.doccheck.com"
    let DocCheckLoginProtocol = "doccheck"
    let DocCheckLoginAction = "login"
    let DocCheckLoginErrorDomain = "dclogin"
    let DocCheckLoginErrorDescriptionMissingAppId = "No app id found"
    
    public var loginSuccesful: (() -> Void)? = nil
    public var loginFailed: ((DocCheckLoginError) -> Void)? = nil
    public var loginCanceled: (() -> Void)? = nil
    public var receivedUserInformations:(([AnyHashable : Any]?) -> Void)? = nil
    public var loginFormDidLoadInBackground: (() -> Void)? = nil
    public var loginFormDidFailInBackground: ((DocCheckLoginError) -> Void)? = nil
    public var enableDebugLog: Bool = false
    
    public init(with loginId: String, language: String = "de", templateName: String = "s_mobile") {
        self.loginId = loginId
        self.language = language
        self.templateName = templateName
        super.init(nibName: nil, bundle: nil)
        
        self.backButtonItem = UIBarButtonItem(image: UIImage(named: "arrow_left", in: bundle, with: nil), style: .plain, target: self, action: #selector(backAction))
        self.forwardButtonItem = UIBarButtonItem(image: UIImage(named: "arrow_right", in: bundle, with: nil), style: .plain, target: self, action: #selector(forwardAction))
    }
    
    public required init?(coder: NSCoder) {
        self.loginId = ""
        self.language = ""
        self.templateName = ""
        super.init(coder: coder)
        
        self.backButtonItem.image = UIImage(named: "arrow_left", in: bundle, with: nil)
        self.forwardButtonItem.image = UIImage(named: "arrow_right", in: bundle, with: nil)
    }
    
    public override func loadView() {
        let customView = UIView(frame: UIScreen.main.bounds)
        customView.autoresizesSubviews = true
        customView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view = customView
        
        spacer.width = 40
        toolbar.sizeToFit()
        toolbar.frame = CGRect(
            x: 0,
            y: customView.frame.size.height - toolbar.frame.size.height,
            width: customView.frame.size.width,
            height: toolbar.frame.size.height
        )
                
        toolbar.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        view.addSubview(toolbar)
        toolbar.items = [backButtonItem, spacer, forwardButtonItem, flexibleSpace, cancelButtonItem]
        toolbar.tintColor = .red
        
        
        if self.webView == nil {
            self.webView = WKWebView()
        }
        let webView: WKWebView = self.webView!
        
        
        webView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height - toolbar.frame.size.height)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.gray
        activityIndicator.frame = CGRect(x: CGFloat(round(Double(((webView.frame.size.width) - 25) / 2))), y: CGFloat(round(Double(((webView.frame.size.height) - 25) / 2))), width: 25, height: 25)
        webView.addSubview(activityIndicator)
        
        view.addSubview(webView)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let superframe = self.view.superview?.bounds else {
            return
        }
        self.view.frame = superframe
        self.requestRemoteLoginForm()
    }
    
    func requestRemoteLoginForm() {
        var error = false
        
        if loginId.isEmpty {
            debugPrint("DocCheckLogin - Missing login id.")
            error = true
        }
        
        if error == true {
            return
        }
        
        if webView == nil {
            self.loadView()
        }
        
        var validLanguage = false
        for i in 0..<supportedLanguages.count {
            let supportedLanguage = supportedLanguages[i]
            if supportedLanguage == language {
                validLanguage = true
            }
        }
        
        if !validLanguage {
            debugPrint("DocCheckLogin - Language \"\(self.language)\" is not supported, falling back to english")
            language = "com"
        }
        
        let urlString = "\(DocCheckLoginUrl)/code/\(language)/\(loginId)/\(templateName)/"
        loginFormUrl = URL(string: urlString)
        
        
        guard let webView = self.webView, let loginFormUrl = self.loginFormUrl else {
            debugPrint("DocCheckLogin - Contact support neither webview nor loginformurl was initiallised")
            return
        }
        
        
        if webView.isLoading || webView.url != loginFormUrl {
            //only reload if needed
            debugPrint("DocCheckLogin - Requesting login form from \(urlString)")
            let request = URLRequest(url: loginFormUrl)
            webView.load(request)
        } else {
            debugPrint("DocCheckLogin - No need to reload form from \(urlString)")
        }
    }
    
    @objc func cancelAction() {
        webView?.stopLoading()
        activityIndicator.stopAnimating()
        stopIntended = true
        updateToolbarItems(withCancelButton: false)
    }
    
    @objc func refreshAction() {
        webView?.reload()
    }
    
    @objc func backAction() {
        if let canGoBack = webView?.canGoBack, canGoBack {
            webView?.goBack()
        }
        else {
            // Notify delegate about canceled login attempt
            docCheckLoginCanceled()
            // If the user cancels the login he probably wants a new sessino next time = Dismiss the login
            dismissEntirely()
        }
    }
    
    @objc func forwardAction() {
        webView?.goForward()
    }
    
    func isDocCheckLoginRequest(_ urlObject: URL?) -> Bool {
        
        guard let url = urlObject else {
            debugPrint("DocCheckLogin - no url given")
            return false
        }

        // Check for colon
        guard let scheme = url.scheme else {
            debugPrint("DocCheckLogin - no scheme found")
            return false
        }
    
        guard let host = url.host else {
            debugPrint("DocCheckLogin - no host found")
            return false
        }
        
        if scheme == DocCheckLoginProtocol && host == DocCheckLoginAction {
            return true
        }
        
        return false
    }
    
    func handleLogin(forUrl url: URL?) {
        guard
            let url = url,
            let query = url.query
        else {
            debugPrint("DocCheckLogin - no query found")
            return
        }
        
        let parameters = query.components(separatedBy: "&")
        var parameterDictionary: [AnyHashable : Any] = [:]
        for parameter in parameters {
            let pair = parameter.components(separatedBy: "=")
            if pair.count != 2 {
                continue
            }
            let key = pair[0].lowercased()
            let value = pair[1]
            parameterDictionary[key] = value
        }
        
        guard let loginAppId = parameterDictionary["appid"] as? String else {
            debugPrint("DocCheckLogin - No app id found - please put it in the return url, e.g. doccheck://login?appid=your.app.id")
            self.loginFailed(with: .failedWithMissingAppId)
            return
        }
        
        guard let appId = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String else {
            debugPrint("DocCheckLogin - couldnt get the app id from bundle")
            self.loginFailed(with: .failedWithMissingAppIdInBundle)
            return
        }
        
        if appId.caseInsensitiveCompare(loginAppId) != .orderedSame && appId.caseInsensitiveCompare("de.antwerpes.doccheckloginkeyapp") != .orderedSame {
            debugPrint("DocCheckLogin - Login is not valid for app id \(appId)")
            return
        }
        
        guard let dcToken = parameterDictionary["dc_token"] as? String, !dcToken.isEmpty else {
            debugPrint("DocCheckLogin - Empty token received.")
            return
        }
        
        if !isValidToken(dcToken) {
            debugPrint("DocCheckLogin - Invalid token received.")
            return
        }
        
        persistSessionOnlyCookies()
        loginSuccessful()
        parameterDictionary.removeValue(forKey: "dc_timestamp")
        //[parameterDictionary removeObjectForKey:@"dc_token"];
        receivedUserInformations(parameterDictionary)
        dismissEntirely()
        
    }
    
    func isValidToken(_ token: String) -> Bool {
        var isValid = false

        debugPrint("DocCheckLogin - Checking login token \(token)")

        let urlString = "\(DocCheckLoginUrl)/soap/token/checkToken.php?json=1&strToken=\(token)"
        debugPrint("DocCheckLogin - Checking token against \(urlString)")
        guard let url = URL(string: urlString) else {
            return false
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        var responseData: Data? = nil
        do {
            responseData = URLSession.requestSynchronousData(request)
            guard
                let data = responseData,
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let boolValid = json["boolValid"] as? Bool,
                let intSeconds = json["intSeconds"] as? String,
                let intProfessionId = json["intProfessionId"] as? String,
                let strUniqueKey = json["strUniqueKey"] as? String
            else {
                return isValid
            }
            debugPrint("DocCheckLogin - Received token validation result - boolValid: \(boolValid), intSeconds: \(intSeconds), intProfessionId: \(intProfessionId), strUniqueKey: \(strUniqueKey)")
            
            if boolValid {
                debugPrint("DocCheckLogin - Token verification successful")
                isValid = true
            }
            
        } catch {
        }
        
        return isValid
    }
    
    func persistSessionOnlyCookies() {
        let cookieJar = HTTPCookieStorage.shared
        for cookie in cookieJar.cookies ?? [] {
            if cookie.expiresDate != nil {
                continue
            }

            var cookieProperties: [HTTPCookiePropertyKey : Any] = [:]
            cookieProperties[.name] = cookie.name
            cookieProperties[.domain] = cookie.domain
            cookieProperties[.originURL] = cookie.domain
            cookieProperties[.path] = cookie.path
            cookieProperties[.version] = NSNumber(value: Int32((Int(cookie.version))))
            cookieProperties[.expires] = Date().addingTimeInterval(60 * 60 * 24 * 3650) //10 years
            
            if let newCookie = HTTPCookie(properties: cookieProperties) {
                HTTPCookieStorage.shared.setCookie(newCookie)
            }
        }
        cookieJar.cookieAcceptPolicy = .always
    }
    
    
    func dismissEntirely() {
        view.removeFromSuperview()
        webView?.stopLoading()
        activityIndicator.stopAnimating()
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        }
        dismiss(animated: true)
    }
    
    func dismiss() {
        self.dismissEntirely()
        self.requestRemoteLoginForm()
    }
    
    func updateToolbarItems(withCancelButton showCancel: Bool) {
        if let canGoForward = webView?.canGoForward {
            forwardButtonItem.isEnabled = canGoForward
            toolbar.items = [backButtonItem, spacer, forwardButtonItem, flexibleSpace, (showCancel) ? cancelButtonItem : refreshButtonItem]
        }
    }
    
    // delegates
    func loginSuccessful() {
        self.loginSuccesful?()
        
    }
    func loginFailed(with error: DocCheckLoginError) {
        self.loginFailed?(error)
    }
    
    func docCheckLoginCanceled() {
        self.loginCanceled?()
    }
    
    func receivedUserInformations(_ userInfo: [AnyHashable : Any]?) {
        self.receivedUserInformations?(userInfo)
    }
    
    func docCheckLoginFormDidLoadInBackground() {
        self.loginFormDidLoadInBackground?()
    }
    
    func docCheckLoginFormDidFailInBackground(with error: DocCheckLoginError) {
        self.loginFormDidFailInBackground?(error)
    }
}

public enum DocCheckLoginError: Error {
    case failedWithMissingAppId
    case failedWithMissingAppIdInBundle
    case failedWithCanceledRequest
}

extension DocCheckLogin: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
        updateToolbarItems(withCancelButton: true)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        updateToolbarItems(withCancelButton: false)
        if view.superview == nil && (webView.url == loginFormUrl) {
            docCheckLoginFormDidLoadInBackground()
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        debugPrint("DocCheckLogin - decidePolicyForNavigationAction.")
        if navigationAction.navigationType == .formSubmitted && isDocCheckLoginRequest(navigationAction.request.url) == true {
            debugPrint("DocCheckLogin - Login redirect detected.")
            handleLogin(forUrl: navigationAction.request.url)
            decisionHandler(.cancel)
            return
        }
        
        if let urlToOpen = navigationAction.request.url?.absoluteString, urlToOpen.range(of: "doccheck") == nil {
            debugPrint("DocCheckLogin - URL does not contain doccheck, open external.")
            if let url = navigationAction.request.url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            decisionHandler(.cancel)
            return
        }
        debugPrint("DocCheckLogin - not login: \(navigationAction.request.url?.absoluteString)")
        decisionHandler(.allow)
        return
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if !stopIntended {
            activityIndicator.stopAnimating()

            /* NSURLErrorCancelled: Asynchronous Request cancelled (should be code -999)
                     *                        Occurs when the user taps X to cancel loading
                     *                        More Info: http://discussions.apple.com/thread.jspa?messageID=9210463&tstart=0
                     */
            if (error as NSError).code != 102 && (error as NSError).code != NSURLErrorCancelled {
                debugPrint("DocCheckLogin - Error: \(error)")
                
                if view.superview == nil {
                    self.docCheckLoginFormDidFailInBackground(with: .failedWithCanceledRequest)
                } else {
                    self.loginFailed(with: .failedWithCanceledRequest)
                }

                // If we got some unexpected error we want to start a new session the next time
                //[self dismiss];
            }
            if (error as NSError).code == NSURLErrorCancelled {
                updateToolbarItems(withCancelButton: false)
            }

            debugPrint("\(error)")

            dismissEntirely()
        } else {
            stopIntended = false
        }
    }
}

extension DocCheckLogin: WKUIDelegate {
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if !(navigationAction.targetFrame?.isMainFrame ?? false) {
            activityIndicator.startAnimating()
            webView.load(navigationAction.request)
        }
        return nil
    }
}

extension DocCheckLogin {
    
    func debugPrint(_ text: String) {
        if enableDebugLog {
            print(text)
        }
    }
}
