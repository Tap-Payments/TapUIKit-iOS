//
//  TapAsyncView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 19/01/2023.
//

import UIKit
import TapThemeManager2020

/// A class to show the result of the async payment in a native manner
@objc public class TapAsyncView: UIView {
    
    /// The content view holding all the views
    @IBOutlet var contentView: UIView!
    /// The top view that displays the merchant logo and name
    //@IBOutlet weak var merchantHeaderView: TapMerchantHeaderView!
    /// The blur view at the background
    @IBOutlet weak var backgroundBlurView: UIVisualEffectView!
    /// The title label
    @IBOutlet weak var paymentProgressLabel: UILabel!
    /// Contains all the labels the will have the same design (font and size)
    @IBOutlet var labels: [UILabel]!
    
    /// Displaying the method the reciept was sent with email or sms
    @IBOutlet weak var paymentRecieptLabel: UILabel!
    /// Displaying the value of the reciept actual email or phone
    @IBOutlet weak var paymentContactDetailsLabel: UILabel!
    /// Displaying a title to tell that the coming thing is the payment referene
    @IBOutlet weak var paymentReferenceTitleLabel: UILabel!
    /// The code title
    @IBOutlet weak var paymentCodeTitleLabel: UILabel!
    /// The payment code itself
    @IBOutlet weak var paymentCodeLabel: UILabel!
    /// The payment expiry title
    @IBOutlet weak var paymentExpiryTitleLabel: UILabel!
    /// The payment expiry date
    @IBOutlet weak var paymentExpiryLabel: UILabel!
    /// Visit the banches message
    @IBOutlet weak var paymentVisitBranchesLabel: UILabel!
    /// The button holding the URL to see the branches
    @IBOutlet weak var paymentStoresUrlButton: UIButton!
    
    /// The view model controling this view
    @objc public var viewModel:TapAsyncViewModel? {
        didSet{
            reloadData()
        }
    }
    
    /// The theme path
    private let themePath = "asyncView"
    
    // Mark:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    /// Will reload the data from the view model
    internal func reloadData() {
        localise()
        reloadMerchantView()
    }
    
    /**
     Will redo the whole setup for the view with the new passed data from the new view model
     - Parameter with viewModel: The new view model to setup the view with
     */
    @objc public func changeViewModel(with viewModel:TapAsyncViewModel) {
        self.viewModel = viewModel
    }
    
    /// Will be fired when the branches button clicked
    @IBAction func visitBranchesClicked(_ sender: Any) {
        viewModel?.visitStoresClicked()
    }
    
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.contentView = setupXIB()
        translatesAutoresizingMaskIntoConstraints = false
        //handlerImageView.translatesAutoresizingMaskIntoConstraints = false
        applyTheme()
        localise()
    }
    
    
    internal func localise() {
        paymentProgressLabel.text = viewModel?.paymentProgressLabel
        paymentRecieptLabel.text = viewModel?.paymentRecieptLabel
        paymentContactDetailsLabel.text = viewModel?.paymentContactDetailsLabel
        paymentReferenceTitleLabel.text = viewModel?.paymentReferenceTitleLabel
        paymentCodeTitleLabel.text = viewModel?.paymentCodeTitleLabel
        paymentCodeLabel.text = viewModel?.paymentCodeLabel
        paymentExpiryTitleLabel.text = viewModel?.paymentExpiryTitleLabel
        paymentExpiryLabel.text = viewModel?.paymentExpiryLabel
        paymentVisitBranchesLabel.text = viewModel?.paymentVisitBranchesLabel
        paymentStoresUrlButton.setTitle(viewModel?.storesURL?.absoluteString ?? "", for: .normal)
    }
    
    internal func reloadMerchantView() {
        if let merchantModel = viewModel?.merchantModel {
            //merchantHeaderView.changeViewModel(with: merchantModel)
        }
    }
}




// Mark:- Theme methods
extension TapAsyncView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        
        
        backgroundBlurView.effect = UIBlurEffect(style: traitCollection.userInterfaceStyle == .dark ? .dark : .light)
        
        labels.forEach { label in
            label.tap_theme_font = .init(stringLiteral: "\(themePath).labelsFont")
            label.tap_theme_textColor = .init(keyPath: "\(themePath).labelsColor")
        }
        
        paymentCodeLabel.tap_theme_font = .init(stringLiteral: "\(themePath).codeLabelFont")
        paymentCodeLabel.tap_theme_textColor = .init(keyPath: "\(themePath).codeLabelColor")
        
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
