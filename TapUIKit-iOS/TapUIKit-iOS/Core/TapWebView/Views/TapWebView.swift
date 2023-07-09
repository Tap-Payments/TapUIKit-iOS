//
//  TapWebView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/21/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import WebKit
import TapThemeManager2020

var myContext = 0

/// Represents the cutom TapWebView
@objc public class TapWebView: UIView {
    /// Represents the main holding view
    @IBOutlet var contentView: UIView!
    /// The view holding the webview used for theming like radius and shadows
    @IBOutlet public weak var webViewHolder: UIView!
    /// Represents the actual backbone web view
    @IBOutlet public weak var webView: WKWebView!
    /// The progress bar to show a web view is being loaded
    @IBOutlet weak var progressView: UIProgressView!
    /// Displays a loading activity indicator for the user
    @IBOutlet weak var loadingGif: UIImageView!
    @IBOutlet weak var loaderView: UIView!
    /// Displays tap section header view before the web view
    @IBOutlet weak var webViewHeaderView: TapHorizontalHeaderView!
    /// Represents the view model controlling this web view
    var viewModel:TapWebViewModel? {
        didSet {
            // once assigned, we declare our self as the delegate
            viewModel?.viewDelegate = self
            reload()
        }
    }
    
    @IBOutlet weak var webViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var webViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var webViewLeadingConstraint: NSLayoutConstraint!
    
    /// The button that will dismiss the whole TAP sheet
    @IBOutlet weak var cancelButton: UIButton!
    
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
        
        webViewHeaderView.headerType = .WebViewTitle
        let loadingBudle:Bundle = Bundle.init(for: TapActionButton.self)
        let imageData = try? Data(contentsOf: loadingBudle.url(forResource: "Black-loader", withExtension: "gif")!)
        let gif = try! UIImage(gifData: imageData!)
        loadingGif.setGifImage(gif, loopCount: 100) // Will loop forever
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: &myContext)
        
        webViewHolder.clipsToBounds = false
        webView.clipsToBounds = true
       /* webView.layer.cornerRadius = 8
        webViewHolder.layer.shadowColor = UIColor(white: 0, alpha: 0.15).cgColor
        webViewHolder.layer.shadowOpacity = 1
        webViewHolder.layer.shadowRadius = 4*/
        
        applyTheme()
    }
    
    /// Will be called when the close button is clicked
    @IBAction func cancelButtonClicked(_ sender: Any) {
        viewModel?.delegate?.webViewCanceled(showingFullScreen:viewModel?.shouldBeFullScreen ?? false)
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
                progressView.isHidden = true //progress >= 0.9
                loaderView.isHidden   = progress >= 0.9
                progressView.progress = progress;
            }
            return
        }
    }
    
    internal func reload() {
        guard let viewModel = viewModel else { return }
        webView.navigationDelegate = viewModel
        webViewHeaderView.isHidden = !viewModel.shouldShowHeaderView
        //cancelButton.isHidden = !webViewHeaderView.isHidden
    }
}


extension TapWebView: TapWebViewDelegate {
    func updateHeaderView(with visibility: Bool) {
        webViewHeaderView.isHidden = !visibility
        //cancelButton.isHidden = !webViewHeaderView.isHidden
    }
    
    func reloadWebView() {
        webView.reload()
    }
    
    func load(with url: URL) {
        webView.load(.init(url: url))
    }
    func stopLoading() {
        webView.stopLoading()
    }
    
    func updateSize(with shouldBeFullScreen: Bool) {
        webViewHolder.translatesAutoresizingMaskIntoConstraints = false
        webViewLeadingConstraint.constant = 0
        webViewTrailingConstraint.constant = 0
        webViewTopConstraint.constant = -30
        webView.layer.cornerRadius = 0
        
        DispatchQueue.main.async{
            self.webView.layoutIfNeeded()
            self.webView.updateConstraints()
        }
    }
}



// Mark:- Theme methods
extension TapWebView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        let themePath:String = "merchantHeaderView"
        cancelButton.tap_theme_setTitleColor(selector: .init(keyPath: "\(themePath).cancelButton.titleLabelColor"), forState: .normal)
        cancelButton.tap_theme_tintColor = .init(keyPath: "\(themePath).cancelButton.titleLabelColor")
        cancelButton.titleLabel?.tap_theme_font = .init(stringLiteral: "\(themePath).cancelButton.titleLabelFont")
        cancelButton.layer.cornerRadius = 16
        cancelButton.tap_theme_backgroundColor = .init(keyPath: "\(themePath).cancelButton.backgroundColor")
        
        cancelButton.setTitle("", for: .normal)
        cancelButton.setImage(TapThemeManager.imageValue(for: "merchantHeaderView.closeCheckoutIcon"), for: .normal)
        
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
