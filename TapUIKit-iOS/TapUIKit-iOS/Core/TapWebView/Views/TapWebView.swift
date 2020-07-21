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

@objc public class TapWebView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var loader: UIImageView!
    @IBOutlet weak var webView: WKWebView!
   
    var viewModel:TapWebViewModel? {
        didSet {
            viewModel?.viewDelegate = self
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
    
        let loadingBudle:Bundle = Bundle.init(for: TapActionButton.self)
        let imageData = try? Data(contentsOf: loadingBudle.url(forResource: "3sec-white-loader-2", withExtension: "gif")!)
        let gif = try! UIImage(gifData: imageData!)
        
        loader.delegate = nil
        loader.setGifImage(gif, loopCount: -1)
        loader.isHidden = true
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
    
    func loaderVisibility(changed to: Bool) {
        if to {
            loader.fadeIn()
        }else {
            loader.fadeIn()
        }
        
        webView.isUserInteractionEnabled = !to
    }
    
    
}
