//
//  TapWebViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/21/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import WebKit

@objc public protocol TapWebViewModelDelegate {
    
    @objc func willLoad(request:URLRequest) -> WKNavigationActionPolicy
    @objc func didLoad(url:URL?)
    @objc func didFail(with error:NSError,for url:URL?)
    
}

@objc public class TapWebViewModel:NSObject {
 
    var delegate:TapWebViewModelDelegate?
    
}


extension TapWebViewModel:WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(delegate?.willLoad(request: navigationAction.request) ?? .allow)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        delegate?.didLoad(url: webView.url)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        delegate?.didFail(with: error, for: webView.url)
    }
}
