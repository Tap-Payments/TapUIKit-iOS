//
//  TapWebViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/21/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import WebKit

/// An internal protocol to communicate between the view model and the web view itself
internal protocol TapWebViewDelegate {
    /// Will be fired when the view model wants to tell the webview to do a refresh
    func reloadWebView()
    /**
     Will be fired when the viewmodel wants to tell the web view to start loading a certain URL
     - Parameter url: The url to be loaded
     */
    func load(with url:URL)
    /// Will be fired when the view model wants to tell the webview to stop loading
    func stopLoading()
    /// Will be fired when the view model wants to hide/show the header view
    func updateHeaderView(with visibility:Bool)
    /// Will be fires when the viewmode wants to change the size of the webview with respect to the superview
    func updateSize(with shouldBeFullScreen: Bool)
}

/// Protocol to communicate between the view model and the parent view
@objc public protocol TapWebViewModelDelegate {
    
    /**
     Will be fired when the web will start loading a certain url and needs a decision from the parent to decide what to do with the request
     - Parameter request: The request the web view is about to load
     - Returns: A valid web policy to tell the web view whether it should proceed with the request or not
     */
    @objc func willLoad(request:URLRequest) -> WKNavigationActionPolicy
    /**
     Will be fired when the web view actually finishes loading the current url
     - Parameter url: The url the web view just finished loading
     */
    @objc func didLoad(url:URL?)
    /**
     Will be fired when the web view fails at loading a certain url
     - Parameter url: The url the web view had a problem with
     - Parameter error: The error that occured while loading this url
     */
    @objc func didFail(with error:Error,for url:URL?)
    
    /// Will be fired when the user cancels the authentication web view
    @objc func webViewCanceled(showingFullScreen:Bool)
    
}


/// A view model that controlls TapWebView
@objc public class TapWebViewModel:NSObject {
    
    /// Reference to the web view itself as UI that will be rendered
    public var webView:TapWebView = .init()
    /// The timer used to check if no redirection is being called for the last 3 seconds
    internal var timer: Timer?
    /// The delay that we should wait for to decide if it is idle in  seonds
    internal var delayTime:CGFloat = 0.500
    
    /// Public Reference to the table view itself as UI that will be rendered
    @objc public var attachedView:TapWebView {
        return webView
    }
    
    /// A custom action block to execute when nothing else being loaded for a while
    @objc public var idleForWhile:()->() = {}
    
    /// Protocol to communicate between the view model and the parent view
    @objc public var delegate:TapWebViewModelDelegate?
    /// An internal protocol to communicate between the view model and the web view itself
    var viewDelegate:TapWebViewDelegate?
    /// Indicates whetehr or not to show a header view above the web view
    @objc public var shouldShowHeaderView:Bool = true {
        didSet{
            viewDelegate?.updateHeaderView(with: shouldShowHeaderView)
        }
    }
    
    /// Indicates whetehr or not the web view should take the whole screen
    @objc public var shouldBeFullScreen:Bool = false {
        didSet{
            viewDelegate?.updateSize(with: shouldBeFullScreen)
        }
    }
    /**
     Will be fired when the viewmodel wants to tell the web view to start loading a certain URL
     - Parameter url: The url to be loaded
     */
    @objc public func load(with url:URL) {
        viewDelegate?.load(with: url)
    }
    
    /// Will be fired when the view model wants to tell the webview to do a refresh
    @objc public func reloadWebView() {
        viewDelegate?.reloadWebView()
    }
    
    /// Will be fired when the view model wants to tell the webview to stop loading
    @objc public func stopLoading() {
        viewDelegate?.stopLoading()
    }
    
    @objc override public init() {
        super.init()
        webView = .init()
        webView.setup(with: self)
    }
}


extension TapWebViewModel:WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Fetch the decision to do from the delegate
        let decision = delegate?.willLoad(request: navigationAction.request) ?? .allow
        decisionHandler(decision)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Inform teh delegate about this url we finished loading
        delegate?.didLoad(url: webView.url)
        
        if let timer = timer {
            timer.invalidate()
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: delayTime, repeats: false, block: { (timer) in
            timer.invalidate()
            self.idleForWhile()
        })
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // Inform teh delegate about this url we failed at
        delegate?.didFail(with: error, for: webView.url)
    }
}
