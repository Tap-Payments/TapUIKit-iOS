//
//  TapLoyaltySnpView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 14/09/2022.
//  Copyright © 2022 Tap Payments. All rights reserved.
//

import UIKit
import SnapKit

/// A view represents the loyalty points view used while paying
@objc public class TapLoyaltyView: UIView {

    /// The container view that holds everything from the XIB
    lazy var containterView:UIView = UIView()
    /// The path to look for theme entry in
    private let themePath = "loyaltyView"
    /// The header view part in the loyalty widget
    lazy var headerView:TapLoyaltyHeaderView = TapLoyaltyHeaderView()
    
    
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
        headerView.setup(with: viewModel?.loyaltyIcon, headerText: viewModel?.headerTitleText, subtitleText: viewModel?.headerSubTitleText, isEnabled: true, termsAndConditionsEnabled: viewModel?.shouldShowTermsButton ?? false)
        // Set the delegate
        headerView.delegate = viewModel
    }
    
    
    
    /// Will change the UI state enable/disable based on the provided valye
    /// - Parameter to enabled: If true then it is enabled and clickable and expanded. Otehrwise, will be shrunk and disbaled
    internal func changeState(to enabled:Bool) {
        if enabled {
            // let us add all the sub views again
            
        }else{
            // let us remove all sub views except the header
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
                make.height.equalTo(self?.viewModel?.isEnabled ?? false ? 132 : 44)
            })
            self?.layoutIfNeeded()
        }
    }
    
    /// Used to add the sub views originally to the non Xib view
    internal func addSubViews() {
        addSubview(containterView)
        containterView.addSubview(headerView)
    }
    
    /// creates the needed constraints to make sure the views are correctly laid out
    internal func setupConstraints() {
        
        translatesAutoresizingMaskIntoConstraints = false
        containterView.translatesAutoresizingMaskIntoConstraints = false
        
        // The view height
        snp.remakeConstraints { make in
            make.height.equalTo(viewModel?.isEnabled ?? false ? 132 : 44)
        }
        
        // The containter view itself
        containterView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
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

        layoutIfNeeded()
        
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
        self.viewModel = viewModel
        self.viewModel?.tapLoyaltyView = self
    }
    
    /// Call to refresh the UI if any data changed
    @objc public func refresh() {
        reloadHeaderView()
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
