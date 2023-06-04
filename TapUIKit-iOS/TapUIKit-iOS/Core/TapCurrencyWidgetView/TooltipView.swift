//
//  TooltipView.swift
//  TapUIKit-iOS
//
//  Created by MahmoudShaabanAllam on 31/05/2023.
//  Copyright © 2023 Tap Payments. All rights reserved.
//

import UIKit
import TapThemeManager2020
import LocalisationManagerKit_iOS
/// A view contain the Tooltip
internal class TooltipView: UIView {
    /// Top arrow view
    @IBOutlet weak var topIndicatorView: UIView!
    /// Bottom arrow view
    @IBOutlet weak var bottomIndicatorView: UIView!
    /// Left arrow view
    @IBOutlet weak var leftIndicatorView: UIView!
    /// Right arrow view
    @IBOutlet weak var rightIndicatorView: UIView!
    /// View will contain the view to be shown
    @IBOutlet weak var contentView: UIView!
    /// View background blurred view
    @IBOutlet weak var cardBlurView: CardVisualEffectView!
    /// View contain every thing
    @IBOutlet weak var container: UIView!
    
    
    var removeCallback: (() -> Void)?
    internal let themePath: String = "CurrencyWidget.currencyDropDown"
    
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.container = setupXIB()
        applyTheme()
        
        isHidden = true
        translatesAutoresizingMaskIntoConstraints = false
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
    
    
    // MARK: - Animations
    func show() {
        fadeIn()
    }
    
    func hide() {
        removeCallback?()
        fadeOut {
            self.removeFromSuperview()
        }
    }
    
}

// Mark:- Theme methods
extension TooltipView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        
        cardBlurView.scale = 1
        cardBlurView.blurRadius = 6
        cardBlurView.colorTint = TapThemeManager.colorValue(for: "\(themePath).backgroundColor")
        cardBlurView.layer.tap_theme_cornerRadious = ThemeCGFloatSelector.init(keyPath: "\(themePath).cornerRadius")
        cardBlurView.layer.masksToBounds = true
        cardBlurView.clipsToBounds = false
        cardBlurView.colorTintAlpha = 0.75
        
        contentView.backgroundColor = .clear
        contentView.layer.tap_theme_cornerRadious = ThemeCGFloatSelector.init(keyPath: "\(themePath).cornerRadius")
        contentView.layer.tap_theme_borderColor = .init(keyPath: "\(themePath).borderColor")
//        contentView.layer.masksToBounds = true
//        contentView.clipsToBounds = false
//        contentView.layer.shadowOpacity = 1
        contentView.layer.tap_theme_shadowRadius = .init(keyPath: "\(themePath).shadowBlur")
        contentView.layer.tap_theme_shadowColor = .init(keyPath: "\(themePath).shadowColor")
        
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}



extension UIView {
    internal func fadeIn(completion: (() -> Void)? = nil) {
        alpha = 0
        isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1
        }) { (_) in
            completion?()
        }
    }
    
    internal func fadeOut(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { (_) in
            self.isHidden = true
            completion?()
        }
    }
}



class SnapshotView: UIImageView {
    
}







