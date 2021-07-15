//
//  TapWebView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/21/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import class WebKit.WKWebView
import class UIKit.UIImageView
import class UIKit.UIView
import class UIKit.UIImage
import struct UIKit.CGRect

var myContext = 0

/// Represents the cutom TapWebView
@objc public class TapWebView: UIView {
    /// Represents the main holding view
    @IBOutlet var contentView: UIView!
    /// Represents the actual backbone web view
    @IBOutlet weak var webView: WKWebView!
    /// The progress bar to show a web view is being loaded
    @IBOutlet weak var progressView: UIProgressView!
    
    /// Represents the view model controlling this web view
    var viewModel:TapWebViewModel? {
        didSet {
            // once assigned, we declare our self as the delegate
            viewModel?.viewDelegate = self
            reload()
        }
    }
    
    // Mark:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    //deinit
    deinit {
        //remove all observers
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    /**
     Connects this web view to the needed view model
     - Parameter viewModel: The tab web viewmodel that controls  this web view
     */
    @objc public func setup(with viewModel:TapWebViewModel) {
        self.viewModel = viewModel
    }
    
    
    // MARK:- Private methods
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.contentView = setupXIB()
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: &myContext)
    }
    
    
    //observer
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let change = change else { return }
        if context != &myContext {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == "estimatedProgress" {
            if let progress = (change[NSKeyValueChangeKey.newKey] as AnyObject).floatValue {
                progressView.isHidden = progress >= 0.9
                progressView.progress = progress;
            }
            return
        }
    }
    
    internal func reload() {
        guard let viewModel = viewModel else { return }
        webView.navigationDelegate = viewModel
    }
}


extension TapWebView: TapWebViewDelegate {
    func reloadWebView() {
        webView.reload()
    }
    
    func load(with url: URL) {
        webView.load(.init(url: url))
    }
    func stopLoading() {
        webView.stopLoading()
    }
}
