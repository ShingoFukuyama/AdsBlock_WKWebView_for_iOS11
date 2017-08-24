//
//  ViewController.swift
//  AdsBlockWKWebView
//
//  Created by Shingo Fukuyama on 2017/08/19.
//  Copyright © 2017 Shingo Fukuyama. All rights reserved.
//

import UIKit
import WebKit

fileprivate let ruleId1 = "MyRuleID 001"
fileprivate let ruleId2 = "MyRuleID 002"
fileprivate let keyDidCompileRuleList = "DidCompileRuleList"

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    var webview: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .yellow
        
        UserDefaults.standard.register(defaults: [
            keyDidCompileRuleList : false
            ])
        UserDefaults.standard.synchronize()
        
        webview = WKWebView(frame: CGRect.zero)
        webview.navigationDelegate = self
        webview.uiDelegate = self
        webview.allowsBackForwardNavigationGestures = true
        view.addSubview(webview)
        webview.frame = view.bounds
        
        if #available(iOS 11, *) {
            if !UserDefaults.standard.bool(forKey: keyDidCompileRuleList) {
                setupContentBlock { [weak self] in
                    self?.startLoading()
                }
            }
            else {
                registerRuleLists({ [weak self] in
                    self?.startLoading()
                })
            }
        } else {
            alertToUseIOS11()
            startLoading()
        }
    }
    
    private func startLoading() {
        let url = URL(string: "https://www.google.com")!
        let request = URLRequest(url: url)
        webview.load(request)
    }
    
    @available(iOS 11.0, *)
    private func registerRuleLists(_ completion: (() -> Void)?) {
        let config = webview.configuration
        let group = DispatchGroup()
        group.enter()
        WKContentRuleListStore.default().lookUpContentRuleList(forIdentifier: ruleId1) { (contentRuleList, error) in
            if let error = error {
                print("\(type(of: self)) \(#function) \(ruleId1) :\(error)")
                return
            }
            if let list = contentRuleList {
                config.userContentController.add(list)
                group.leave()
            }
        }
        
        group.enter()
        WKContentRuleListStore.default().lookUpContentRuleList(forIdentifier: ruleId2) { (contentRuleList, error) in
            if let error = error {
                print("\(type(of: self)) \(#function) \(ruleId2) :\(error)")
                return
            }
            if let list = contentRuleList {
                config.userContentController.add(list)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion?()
        }
        
    }
    
    @available(iOS 11.0, *)
    private func setupContentBlock(_ completion: (() -> Void)?) {
        /*
         [Creating Safari Content-Blocking Rules](https://developer.apple.com/library/content/documentation/Extensions/Conceptual/ContentBlockingRules/CreatingRules/CreatingRules.htmle)
         
         When you provide your rule list to WebKit, WebKit compiles into
         an efficient byte code format. This is kind of an implementation
         detail that's not directly relevant to you. I'm bringing it up
         because I want to assure you that a content rule list even a
         large set of thousands of rules we've been spending a lot of time
         working on making that as efficient as possible. And no matter
         how big your rule set is, if it compiles successfully you should
         not see degradation in loading performance. You supply your rules
         in a simple JSON format.
         
         When we compile a rule list from JSON to the efficient byte code
         format, you can name it.
         
         And then later you can look up by the same identifier so you
         don't have to compile it again.
         
         WebKit stores it on the storage of the device and can look it up
         much quicker later.
         */
        
        let group = DispatchGroup()
        
        // Compile from a string leteral
        // Swift 4  Multi-line string literals
        let jsonString = """
[{
  "trigger": {
    "url-filter": "dgoogleads\\\\.g\\\\.doubleclick\\\\.net"
  },
  "action": {
    "type": "block"
  }
}]
"""
        group.enter()
        WKContentRuleListStore.default().compileContentRuleList(forIdentifier: ruleId1, encodedContentRuleList: jsonString) { [weak self] (contentRuleList: WKContentRuleList?, error: Error?) in
            if let error = error {
                print("\(type(of: self)) \(#function) string literal :\(error)")
                return
            }
            group.leave()
        }
        
        // Compile from a json file
        group.enter()
        if let jsonFilePath = Bundle.main.path(forResource: "adaway.json", ofType: nil),
            let jsonFileContent = try? String(contentsOfFile: jsonFilePath, encoding: String.Encoding.utf8) {
            WKContentRuleListStore.default().compileContentRuleList(forIdentifier: ruleId2, encodedContentRuleList: jsonFileContent) { [weak self] (contentRuleList, error) in
                if let error = error {
                    print("\(type(of: self)) \(#function) from file :\(error)")
                    return
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            UserDefaults.standard.set(true, forKey: keyDidCompileRuleList)
            UserDefaults.standard.synchronize()
            self?.registerRuleLists(completion)
        }
    }
    
    @available(iOS 11.0, *)
    private func resetContentRuleList() {
        let config = webview.configuration
        config.userContentController.removeAllContentRuleLists()
    }
    
    private func alertToUseIOS11() {
        let title: String? = "Use iOS 11 and above for ads-blocking."
        let message: String? = nil
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: { (action) in
            
        }))
        DispatchQueue.main.async { [unowned self] in
            self.view.window?.rootViewController?.present(alertController, animated: true, completion: {
                
            })
        }
    }
    
    // Just for invalidating target="_blank"
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else {
            return nil
        }
        guard let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame else {
            webView.load(URLRequest(url: url))
            return nil
        }
        return nil
    }
    

}

