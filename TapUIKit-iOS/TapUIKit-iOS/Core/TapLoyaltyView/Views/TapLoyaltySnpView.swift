//
//  TapLoyaltySnpView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 14/09/2022.
//  Copyright © 2022 Tap Payments. All rights reserved.
//

import UIKit
import SnapKit
import LocalisationManagerKit_iOS
import CommonDataModelsKit_iOS
import TapThemeManager2020

/// A view represents the loyalty points view used while paying
@objc public class TapLoyaltyView: UIView {
    
    /// The container view that holds everything from the XIB
    internal lazy var containterView:UIView = UIView()
    /// An empty padding at the bottom to allow space for expansion in case we want to show the hint warning view
    internal lazy var bottomPaddingView:UIView = UIView()
    /// The path to look for theme entry in
    private let themePath = "loyaltyView"
    /// The header view part in the loyalty widget
    internal lazy var headerView:TapLoyaltyHeaderView = TapLoyaltyHeaderView()
    /// The amount view part in the loyalty widget
    internal lazy var amountView:TapLoyaltyAmountView = TapLoyaltyAmountView()
    /// The footer view part in the loyalty widget
    internal lazy var footerView:TapLoyaltyFooterView = TapLoyaltyFooterView()
    /// The warning hint view to be displayed whenever a warning is needed
    internal lazy var warningHintView:TapHintView = TapHintView()
    /// Holds all views that will be removed/added based on changing the enablement of the loyalty widget
    internal lazy var enablementEffectedViews:[UIView] = []
    
    // Mark:- Init methods
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder:coder)
        self.backgroundColor = .clear
        commonInit()
    }
    
    internal func commonInit() {
        
        rtlSupport()
        
        addSubViews()
        applyTheme()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in
            self?.setupConstraints()
        }
    }
    
    // MARK: Private
    
    /// Used to refresh the data rendered inside the header view of the loyalty widget
    internal func reloadHeaderView() {
        // Set the UI data
        headerView.setup(with: viewModel?.loyaltyIcon, headerText: viewModel?.headerTitleText, subtitleText: viewModel?.headerSubTitleText, isEnabled: viewModel?.isEnabled ?? false, termsAndConditionsEnabled: viewModel?.shouldShowTermsButton ?? false)
        // Set the delegate
        headerView.delegate = viewModel
    }
    
    
    /// Used to refresh the data rendered inside the header view of the loyalty widget
    internal func reloadAmountView() {
        // Set the UI data
        guard let nonNullViewModel = self.viewModel else { return }
        amountView.setup(with: nonNullViewModel, initialAmount: nonNullViewModel.amount)
        // Set the delegate
        amountView.delegate = viewModel
    }
    
    
    // Used to refresh the data rendered inside the header view of the loyalty widget
    internal func reloadFooterView() {
        // Set the UI data
        guard let nonNullViewModel = self.viewModel else { return }
        footerView.setup(with: nonNullViewModel)
    }
    
    
    /// Handles the logic to get the amount section back to its original data
    internal func resetData(forSubViews:[LoyaltySubViewsID] = [.All]) {
        // hide the keyboard if any
        amountView.amountTextField.resignFirstResponder()
        // Decide which sub view should be reloaded based on the caller decision
        forSubViews.forEach { loyaltySubViewsID in
            switch loyaltySubViewsID {
            case .Header:
                reloadHeaderView()
                break
            case .Footer:
                reloadFooterView()
                break
            case .Amount:
                reloadAmountView()
                break
            default:
                // Reset the amount section data
                reloadAmountView()
                // Reset the header value
                reloadHeaderView()
                // Reset the footer value
                reloadFooterView()
            }
        }
    }
    
    /// Will change the UI state enable/disable based on the provided valye
    /// - Parameter to enabled: If true then it is enabled and clickable and expanded. Otehrwise, will be shrunk and disbaled
    internal func changeState(to enabled:Bool) {
        // In all cases we will need to reset the data
        viewModel?.calculateInitialAmount()
        resetData(forSubViews: [.Amount,.Footer])
        if enabled {
            // let us show all the sub views again
            enablementEffectedViews.forEach{ view in
                view.isHidden = false
                view.isUserInteractionEnabled = true
            }
        }else{
            // let us remove all sub views except the header
            enablementEffectedViews.forEach{ view in
                view.isHidden = true
                view.isUserInteractionEnabled = false
            }
        }
        
        DispatchQueue.main.async  { [weak self] in
            self?.bottomPaddingView.snp.updateConstraints({ make in
                make.height.equalTo(enabled ? 44 : 0)
            })
            self?.bottomPaddingView.layoutIfNeeded()
        }
        
        // In all cases, we will need to re adjust our stack's height
        adjustHeight()
    }
    
    /// Used to compute the required height for the loyalty widget, deoends on ;
    /// enabled or not
    /// there is a warning hint or not
    internal func adjustHeight() {
        DispatchQueue.main.async  { [weak self] in
            self?.snp.updateConstraints({ make in
                make.height.equalTo(self?.viewModel?.widgetHeight ?? 44)
            })
            self?.layoutIfNeeded()
        }
    }
    
    /// Used to add the sub views originally to the non Xib view
    internal func addSubViews() {
        addSubview(containterView)
        addSubview(bottomPaddingView)
        
        containterView.addSubview(headerView)
        containterView.addSubview(amountView)
        containterView.addSubview(warningHintView)
        containterView.addSubview(footerView)
        // Mark the views that will change its visibility based in the enabelement of the loyalty widget
        enablementEffectedViews.append(bottomPaddingView)
        enablementEffectedViews.append(amountView)
        enablementEffectedViews.append(warningHintView)
        enablementEffectedViews.append(footerView)
    }
    
    /// creates the needed constraints to make sure the views are correctly laid out
    internal func setupConstraints() {
        
        translatesAutoresizingMaskIntoConstraints = false
        containterView.translatesAutoresizingMaskIntoConstraints = false
        
        // The view height
        snp.remakeConstraints { make in
            make.height.equalTo(viewModel?.widgetHeight ?? 44)
        }
        
        // The bottom margin view
        bottomPaddingView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(44)
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        // The containter view itself
        containterView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.bottom.equalTo(bottomPaddingView.snp.top)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        // The header view
        headerView.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        // The amount view
        amountView.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
        }
        
        // The warning view
        warningHintView.snp.makeConstraints { make in
            make.height.equalTo(viewModel?.shouldShowHint ?? false ? 44 : 0)
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.top.equalTo(amountView.snp.bottom)
        }
        
        
        // The footer view
        footerView.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.top.equalTo(warningHintView.snp.bottom)
        }
        
        layoutIfNeeded()
        
    }
    
    /// Handles the logic needed to set the height/visibility of the warning hint view
    internal func adjustHintViewConstraints() {
        // The warning view
        // Check if we should show it or not
        let shouldShowIt:Bool = viewModel?.shouldShowHint ?? false
        // check if we need to do anything
        //guard !shouldShowIt && warningHintView.frame.height == 44 || shouldShowIt && warningHintView.frame.height == 0 else { return }
        
        // Set the correct displayable title in the warning
        warningHintView.viewModel.overrideTitle = viewModel?.hintWarningTitle
        
        DispatchQueue.main.async  { [weak self] in
            self?.warningHintView.snp.updateConstraints({ make in
                make.height.equalTo(shouldShowIt ? 44 : 0)
            })
            self?.bottomPaddingView.snp.updateConstraints({ make in
                make.height.equalTo(shouldShowIt ? 0 : 44)
            })
            if shouldShowIt && self?.warningHintView.alpha != 1 {
                self?.warningHintView.fadeIn()
                self?.bottomPaddingView.fadeOut()
            }
            else if !shouldShowIt && self?.warningHintView.alpha != 0 {
                self?.warningHintView.fadeOut()
                self?.bottomPaddingView.fadeIn()
            }
            self?.warningHintView.layoutIfNeeded()
            self?.bottomPaddingView.layoutIfNeeded()
        }
    }
    
    
    // MARK: Public
    /// The view model that controls this UIView
    @objc public var viewModel:TapLoyaltyViewModel? {
        didSet{
            refresh()
        }
    }
    
    /// Updates the view with the new view model
    public func changeViewModel(with viewModel:TapLoyaltyViewModel) {
        self.warningHintView.setup(with: viewModel.hintViewModel)
        self.viewModel = viewModel
        self.viewModel?.tapLoyaltyView = self
    }
    
    /// Call to refresh the UI if any data changed
    @objc public func refresh() {
        reloadHeaderView()
        reloadAmountView()
        reloadFooterView()
    }
    
}



// Mark:- Theme methods
extension TapLoyaltyView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        backgroundColor = .clear
        bottomPaddingView.backgroundColor = .clear
        
        containterView.layer.tap_theme_cornerRadious  = .init(keyPath: "\(themePath).cardView.radius")
        containterView.layer.tap_theme_shadowColor = .init(keyPath: "\(themePath).cardView.shadowColor")
        containterView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        containterView.layer.tap_theme_shadowRadius = .init(keyPath: "\(themePath).cardView.shadowRadius")
        
        containterView.layer.shadowOpacity =
        TapThemeManager.numberValue(for: "\(themePath).cardView.shadowRadius")?.floatValue ?? 0
        containterView.tap_theme_backgroundColor = .init(keyPath: "\(themePath).cardView.backgroundColor")
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}



/// An enum to identify which sub view will need to be refreshed based on the context
internal enum LoyaltySubViewsID {
    /// Refresh all the subviews
    case All
    /// Refresh the header view
    case Header
    /// Refresh the footer view
    case Footer
    /// Refresh the amount view
    case Amount
}
