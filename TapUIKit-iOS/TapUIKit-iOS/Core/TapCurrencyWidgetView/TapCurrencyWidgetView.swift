//
//  TapCurrencyWidgetView.swift
//  TapUIKit-iOS
//
//  Created by MahmoudShaabanAllam on 24/05/2023.
//  Copyright © 2023 Tap Payments. All rights reserved.
//

import UIKit
import Nuke
import LocalisationManagerKit_iOS
import TapThemeManager2020

public class TapCurrencyWidgetView: UIView {
    /// We will use the width constraint, to update the look of the payment option logo image view at run time to match the width of the payment logo we are displaying
    @IBOutlet weak var paymentOptionLogoImageViewWidthConstrain: NSLayoutConstraint!
    ///  A collection of direction based views
    @IBOutlet var toBeLocalizedViews: [UIView]!
    /// The view that holds the content elements
    @IBOutlet weak var contentHolderView: UIView!
    /// The container view that holds everything from the XIB
    @IBOutlet var containerView: UIView!
    /// The confirm button to change the currency to be accepted by this provider
    @IBOutlet weak var confirmButton: UIButton!
    /// The amount label which displays amount after conversion to be used with this provider
    @IBOutlet weak var amountLabel: UILabel!
    /// The currency View image view which displays currency to be used with this provider
    @IBOutlet weak var currencyImageView: UIImageView!
    /// The message label  which displays the CurrencyWidget message
    @IBOutlet weak var messageLabel: UILabel!
    /// The provider image view which displays the provider logo
    @IBOutlet weak var providerImageView: UIImageView!
    /// The  image view which displays the chevron icon
    @IBOutlet weak var chevronImageView: UIImageView!
    /// The  button to show the currency drop down
    @IBOutlet weak var currencyDropDownButton: UIButton!
    
    /// The view model controlling this view
    @objc private var viewModel:TapCurrencyWidgetViewModel?
    /// The path to look for theme entry in
    private let themePath = "CurrencyWidget"
    
    /// The path to look for localised entry in
    private let localisationPath = "CurrencyWidget"
    
    private let tooltipManager: TooltipManager = TooltipManager()
    
    
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
     Will redo the whole setup for the view with the new passed data from the new view model
     - Parameter with viewModel: The new view model to setup the view with
     */
    @objc public func changeViewModel(with viewModel:TapCurrencyWidgetViewModel) {
        self.viewModel = viewModel
        self.viewModel?.tapCurrencyWidgetView = self
        reload()
    }
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.containerView = setupXIB()
        applyTheme()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// When user click on confirm button
    @IBAction func confirmClicked(_ sender: Any) {
        viewModel?.confirmClicked()
    }
    
    /// When the user clicks on the drop down to show the supported currencies list
    @IBAction func currencyClicked(_ sender: Any) {
        setupTooltips()
        tooltipManager.showToolTip()
        viewModel?.currencyClicked()
    }
    /// Will localize the views by checking their class. If they are views we will set the semantic attributes, if text based views we will change the alignments as well
    private func localizeViews() {
        // Let us compute the correct semantic and text alignment
        let semantic:UISemanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight
        let aligment:NSTextAlignment = TapLocalisationManager.shared.localisationLocale == "ar" ? .right : .left
        toBeLocalizedViews.forEach { view in
            view.semanticContentAttribute = semantic
            if let label:UILabel = view as? UILabel {
                label.textAlignment = aligment
            }
        }
    }
    
    /// Will adjust the UI and the data source for the popup that shows a drop down selector to choose one of the supported of the currencies if the current currency widgets supports 2+ currencies.
    private func setupTooltips() {
        // Assign the delgates
        tooltipManager.delegate = self
        // let us create the selection table and fetch its correct data source
        let currencyTableView = CurrencyTableView()
        guard let viewModel = viewModel else {
            return
        }
        
        currencyTableView.changeViewModel(tapCurrencyWidgetViewModel: viewModel)
        tooltipManager.setup(tooltipToShow: TooltipController(view: chevronImageView, direction: .up, viewToShow: currencyTableView, height: viewModel.drowDownListHeight , width: 224), mainView: self.findViewController()?.view ?? self)
    }
    
}


// Mark:- view model delegate methods
extension TapCurrencyWidgetView:TapCurrencyWidgetViewDelegate {
    /// Remove tooltips
    func removeTooltip() {
        tooltipManager.removeTooltips()
    }
    
    /// Consolidated one point to reload view
    func reload() {
        assignLabels()
        loadImages()
        localizeViews()
        setupCurrencyDropDown()
    }
    
    /// Responsible for showing or hide currency drop down
    private func setupCurrencyDropDown() {
        setCurrencyDropDownButtonState(show: viewModel?.showMultipleCurrencyOption ?? false)
        showChevronCorrectPosition(isExpanded: viewModel?.isCurrencyDropDownExpanded ?? false)
    }
    
    /// Responsible show correct arrow position
    private func showChevronCorrectPosition(isExpanded: Bool) {
        let dropDownThemePath = "\(themePath).currencyDropDown"
        
        if isExpanded {
            chevronImageView.tap_theme_image = .init(keyPath: "\(dropDownThemePath).arrowUpImageName")
        } else {
            chevronImageView.tap_theme_image = .init(keyPath: "\(dropDownThemePath).arrowDownImageName")
        }
        
        chevronImageView.image = chevronImageView.image?.withRenderingMode(.alwaysTemplate)
        chevronImageView.tap_theme_tintColor = .init(keyPath: "\(dropDownThemePath).arrowDownTint")
    }
    
    /// Responsible show or hide currency drop down button
    private func setCurrencyDropDownButtonState(show: Bool) {
        chevronImageView.isHidden = !show
        currencyDropDownButton.isEnabled = show
    }
    
    /// Responsible for all logic needed to assign the textual info into the corresponding labels
    private func assignLabels() {
        messageLabel.text = viewModel?.messageLabel
        confirmButton.setTitle(viewModel?.confirmButtonText, for: .normal)
        amountLabel.text = viewModel?.amountLabel
    }
    
    /// Responsible for all logic needed to load images
    private func loadImages() {
        
        let options = ImageLoadingOptions(
            transition: .fadeIn(duration: 0.2)
        )
        
        // load currencyFlag
        // Make sure we have a valid URL
        guard let currencyFlag:URL = URL(string: viewModel?.amountFlag ?? "") else { return }
        // load the image from the URL
        currencyImageView.downloadImage(with: currencyFlag, nukeOptions: options)
        
        // load paymentOptionLogo
        // Make sure we have a valid URL
        guard let paymentOptionLogo:URL = viewModel?.paymentOptionLogo else { return }
        // load the image from the URL
        Nuke.loadImage(with: paymentOptionLogo, into: providerImageView) { result in
            if let image:UIImage = self.providerImageView.image {
                // Let us compute the needed width
                let correctWidth:CGFloat = (image.size.width * image.scale) / 4
                // Let us update our image view width
                DispatchQueue.main.async {
                    self.paymentOptionLogoImageViewWidthConstrain.constant = correctWidth
                    self.providerImageView.updateConstraints()
                    self.providerImageView.layoutIfNeeded()
                }
            }
        }
    }
    
}

// Mark:- Theme methods
extension TapCurrencyWidgetView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        let amountLabelThemePath = "\(themePath).amountLabel"
        // Here we will not need to localise this label, as it is always with English letters. hence, we will always our English fonts.
        amountLabel.tap_theme_font = .init(stringLiteral: "\(amountLabelThemePath).font",shouldLocalise: false)
        amountLabel.tap_theme_textColor = .init(keyPath: "\(amountLabelThemePath).color")
        
        let messageLabelThemePath = "\(themePath).messageLabel"
        messageLabel.tap_theme_font = .init(stringLiteral: "\(messageLabelThemePath).font")
        messageLabel.tap_theme_textColor = .init(keyPath: "\(messageLabelThemePath).color")
        
        let backgroundThemePath = "\(themePath).background"
        contentHolderView.tap_theme_backgroundColor = .init(keyPath: "\(backgroundThemePath).color")
        contentHolderView.layer.tap_theme_cornerRadious = ThemeCGFloatSelector.init(keyPath: "\(backgroundThemePath).cornerRadius")
        contentHolderView.layer.masksToBounds = true
        contentHolderView.clipsToBounds = false
        contentHolderView.layer.shadowOpacity = 1
        contentHolderView.layer.tap_theme_shadowRadius = .init(keyPath: "\(backgroundThemePath).shadow.blurRadius")
        contentHolderView.layer.tap_theme_shadowColor = .init(keyPath: "\(backgroundThemePath).shadow.color")
        
        let confirmButtonThemePath = "\(themePath).confirmButton"
        
        confirmButton.tap_theme_setTitleColor(selector: .init(keyPath: "\(confirmButtonThemePath).titleFontColor"), forState: .normal)
        confirmButton.tap_theme_tintColor = .init(keyPath: "\(confirmButtonThemePath).titleFontColor")
        confirmButton.titleLabel?.tap_theme_font = .init(stringLiteral: "\(confirmButtonThemePath).titleFont")
        confirmButton.layer.cornerRadius = confirmButton.frame.height / 2
        confirmButton.tap_theme_backgroundColor = .init(keyPath: "\(confirmButtonThemePath).backgroundColor")
        confirmButton.titleEdgeInsets = .init(top: TapLocalisationManager.shared.localisationLocale == "ar" ? 4 : 0, left: 0, bottom: 0, right: 0)
        
        let dropDownThemePath = "\(themePath).currencyDropDown"
        
        chevronImageView.tap_theme_image = .init(keyPath: "\(dropDownThemePath).arrowDownImageName")
        chevronImageView.image = chevronImageView.image?.withRenderingMode(.alwaysTemplate)
        chevronImageView.tap_theme_tintColor = .init(keyPath: "\(dropDownThemePath).arrowDownTint")
        
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}

internal extension UIView {
    /**
     An extension method to detect the viewcontroller which the current view is embedded in
     - Returns: UIViewcontroller that holds the current view or nil if not found for any case
     **/
    fileprivate func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}

extension TapCurrencyWidgetView: ToolTipDelegate {
    func toolTipDidComplete() {
        viewModel?.currencyClicked()
    }
}
