//
//  TapAmountSectionView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/11/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapThemeManager2020
// import SimpleAnimation

@objc public class TapAmountSectionView: UIView {
    
    /// The container view that holds everything from the XIB
    @IBOutlet var containerView: UIView!
    /// The label that will display the total amount of the transaction
    @IBOutlet weak var amountLabel: UILabel!
    /// The label that will display the total converted amount of the transaction
    @IBOutlet weak var convertedAmountLabel: UILabel!
    /// Holds the button and the label that shows the number of items
    @IBOutlet weak var itemsHolderView: UIView!
    /// Shows the title of the button of number of titles or CLOSE the items view
    @IBOutlet weak var itemsNumberLabel: UILabel!
    /// Shows a drop down arrow to indicate the button is clickable
    @IBOutlet weak var downArrowImageView: UIImageView!
    /// The vertical containter for the amount + the converted amount of any to make sure they are always correctly aligned and centered
    @IBOutlet weak var amountsStackView: UIStackView!
    
    @objc public var viewModel:TapAmountSectionViewModel? {
        didSet{
            createObservables()
        }
    }
    
    /// The path to look for theme entry in
    private let themePath = "amountSectionView"
    
    // Mark:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.containerView = setupXIB()
        translatesAutoresizingMaskIntoConstraints = false
        applyTheme()
    }
    
    
    
    private func createObservables() {
        bindLabels()
        bindVisibilities()
    }
    
    ///Updates all the labels with the corresponding values in the view modelt
    private func bindLabels() {
        guard let viewModel = viewModel else { return }
        
        // Bind the amount, converted and items count
        
        viewModel.originalAmountLabelObserver = { [weak self] originalAmount in
            guard let originalAmount:String = originalAmount else { return }
            let convertedAmount:String = viewModel.convertedTransactionAmountFormated
            if convertedAmount == "" {
                self?.amountLabel.text = originalAmount
                self?.showHide(for: self!.convertedAmountLabel, show: false, at: 1)
            }else{
                self?.convertedAmountLabel.text = originalAmount
                self?.amountLabel.text = convertedAmount
                self?.showHide(for: self!.convertedAmountLabel, show: true, at: 1)
            }
        }
        
        viewModel.itemsLabelObserver = { itemsCount in
            self.itemsNumberLabel.text = itemsCount
            self.updateItemsButtonUI()
        }
    }
    
    /// Handles showing/hiding the dropdown icon.
    /// It will be visibile in case of shoowing item count only
    internal func updateItemsButtonUI() {
        var dropDownArrowFinalWidth:Double = 0
        if viewModel?.currentStateView == .DefaultView {
            dropDownArrowFinalWidth = 16
        }
        // Update the visibility and the size of the icon view accordingly
        downArrowImageView.isHidden = !(viewModel?.currentStateView == .DefaultView)
        downArrowImageView.snp.remakeConstraints { make in
            make.width.equalTo(dropDownArrowFinalWidth)
        }
        downArrowImageView.layoutIfNeeded()
        itemsNumberLabel.layoutIfNeeded()
    }
    
    @objc override func shouldShowTapView() -> Bool {
        return viewModel?.shouldShow ?? true
    }
    
    ///Updates all the views that can be shown or hidden based on change of observables
    private func bindVisibilities() {
        guard let viewModel = viewModel else { return }
        // hide the amounts view if the view model says so
        viewModel.showAmount = { shouldShowAmount in
            self.amountsStackView.isHidden = !shouldShowAmount
        }
        
        // hide the items count view if the view model says so
        viewModel.showItemsObserver = { shouldShowItems in
            self.itemsHolderView.isHidden = !shouldShowItems
        }
    }
    
    private func showHide(for label:UILabel, show:Bool, at position:Int) {
        if show {
            // Then we need to show this label inside the stack view, first we need to check if it is not already added
            if !amountsStackView.arrangedSubviews.contains(label) {
                amountsStackView.insertArrangedSubview(label, at: position)
                label.fadeIn()
            }
        }else {
            // Then we need to remove this label from the stack view
            label.fadeOut { [weak self] _ in
                self?.amountsStackView.removeArrangedSubview(label)
            }
        }
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.frame = bounds
    }
    
    @objc public func changeViewModel(with viewModel:TapAmountSectionViewModel) {
        self.viewModel = viewModel
    }
    
    /// Tell the view model when the amount section view in the view is clixked by the user
    
    @IBAction func amountSectionClicked(_ sender: Any) {
        viewModel?.amountSectionClicked()
    }
    ///Tell the view model when the items in the view is clicked by the user
    @IBAction func itemsClicked(_ sender: Any) {
        viewModel?.itemsClicked()
    }
}


// Mark:- Theme methods
extension TapAmountSectionView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        amountLabel.tap_theme_font = .init(stringLiteral: "\(themePath).originalAmountLabelFont",shouldLocalise:false)
        amountLabel.tap_theme_textColor = .init(keyPath: "\(themePath).originalAmountLabelColor")
        
        convertedAmountLabel.tap_theme_font = .init(stringLiteral: "\(themePath).convertedAmountLabelFont",shouldLocalise:false)
        convertedAmountLabel.tap_theme_textColor = .init(keyPath: "\(themePath).convertedAmountLabelColor")
        
        itemsNumberLabel.tap_theme_font = .init(stringLiteral: "\(themePath).itemsLabelFont")
        itemsNumberLabel.tap_theme_textColor = .init(keyPath: "\(themePath).itemsLabelColor")
        
        itemsHolderView.tap_theme_backgroundColor = .init(keyPath: "\(themePath).itemsNumberButtonBackgroundColor")
        itemsHolderView.layer.tap_theme_cornerRadious = .init(keyPath: "\(themePath).itemsNumberButtonCorner")
        itemsHolderView.layer.tap_theme_borderWidth = .init(keyPath: "\(themePath).itemsNumberButtonBorder.width")
        itemsHolderView.layer.tap_theme_borderColor = .init(keyPath: "\(themePath).itemsNumberButtonBorder.color")
        
        
        downArrowImageView.tap_theme_image = .init(keyPath: "\(themePath).itemsButtonArrowIcon")
        
        tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}

