//
//  TapWebViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/21/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import WebKit


internal protocol TapWebViewDelegate {
    
    func reloadWebView()
    func load(with url:URL)
    func stopLoading()
    func loaderVisibility(changed to:Bool)
}

@objc public protocol TapWebViewModelDelegate {
    
    @objc func willLoad(request:URLRequest) -> WKNavigationActionPolicy
    @objc func didLoad(url:URL?)
    @objc func didFail(with error:Error,for url:URL?)

}

@objc public class TapWebViewModel:NSObject {
    @objc public var delegate:TapWebViewModelDelegate?
    var viewDelegate:TapWebViewDelegate?
    
    @objc public func load(with url:URL) {
        viewDelegate?.load(with: url)
    }
    
    @objc public func reloadWebView() {
        viewDelegate?.reloadWebView()
    }
    @objc public func stopLoading() {
        viewDelegate?.stopLoading()
    }
    
}


extension TapWebViewModel:WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let decision = delegate?.willLoad(request: navigationAction.request) ?? .allow
        
        viewDelegate?.loaderVisibility(changed: decision == .allow)
        
        decisionHandler(decision)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        delegate?.didLoad(url: webView.url)
        viewDelegate?.loaderVisibility(changed: false)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        delegate?.didFail(with: error, for: webView.url)
    }
}
