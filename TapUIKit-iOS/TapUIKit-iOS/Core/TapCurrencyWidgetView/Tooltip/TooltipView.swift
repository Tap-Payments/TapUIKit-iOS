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
    
    @IBOutlet weak var mainView: UIView!
    
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
        
        mainView.layer.tap_theme_cornerRadious = ThemeCGFloatSelector.init(keyPath: "\(themePath).cornerRadius")
        mainView.layer.tap_theme_borderColor = .init(keyPath: "\(themePath).borderColor")
        mainView.layer.masksToBounds = true
        mainView.clipsToBounds = true
        mainView.layer.borderWidth = 1
        mainView.layer.tap_theme_borderColor = .init(keyPath: "\(themePath).borderColor")
        
        mainView.backgroundColor = .clear
        
        container.layer.shadowOpacity = 1
        container.layer.shadowOffset = CGSize(width: CGFloat(TapThemeManager.numberValue(for: "\(themePath).shadowOffsetWidth")?.floatValue ?? 0), height: CGFloat(TapThemeManager.numberValue(for: "\(themePath).shadowOffsetHeight")?.floatValue ?? 0))
        container.layer.tap_theme_shadowRadius = .init(keyPath: "\(themePath).shadowBlur")
        container.layer.shadowRadius = 16
        container.layer.tap_theme_shadowColor = .init(keyPath: "\(themePath).shadowColor")
        
        
        
        container.layer.shadowColor = UIColor(red: 0.294, green: 0.282, blue: 0.278, alpha: 0.5).cgColor
        container.layer.shadowOpacity = 1
        container.layer.shadowRadius = 64
        container.layer.shadowOffset = CGSize(width: 0, height: 24)
        
        
        cardBlurView.scale = 1
        cardBlurView.blurRadius = 6
        cardBlurView.colorTint = TapThemeManager.colorValue(for: "\(themePath).backgroundColor")
        cardBlurView.colorTintAlpha = 0.75
        
        contentView.backgroundColor = .clear
        
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
    
    internal func updatePositionRegardingScreenSize(_ pointView: UIView?, _ height: CGFloat, _ tooltipDirection: TooltipDirection) -> TooltipDirection {
        let frameRelativeToScreen = pointView?.globalFrame
        
        /*if (frameRelativeToScreen?.origin.y ?? 0) + height + 20 > UIScreen.main.bounds.height, tooltipDirection == .up {
            return .down
        }
        
        if (frameRelativeToScreen?.origin.y ?? 0) - height - 20 < 0, tooltipDirection == .down {
            return .up
        }*/
        return tooltipDirection
    }
    
    internal func setupArrowView(tooltipDirection: TooltipDirection) {
        self.rightIndicatorView.isHidden = tooltipDirection != .right
        self.leftIndicatorView.isHidden = tooltipDirection != .left
        self.topIndicatorView.isHidden = tooltipDirection != .up
        self.bottomIndicatorView.isHidden = tooltipDirection != .down
    }
    
    internal func applySizeConstraint(height: CGFloat, width: CGFloat) {
        NSLayoutConstraint.activate([self.widthAnchor.constraint(equalToConstant: width)])
        NSLayoutConstraint.activate([self.heightAnchor.constraint(equalToConstant: height)])
    }
    
    internal func setupViewToShow(viewToShow: UIView) {
        self.addSubview(viewToShow)
        self.bringSubviewToFront(viewToShow)
        let horizontalConstraint = viewToShow.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        let verticalConstraint = viewToShow.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        let widthConstraint = viewToShow.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8)
        let heightConstraint = viewToShow.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.8)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        viewToShow.translatesAutoresizingMaskIntoConstraints = false
    }
    
    internal func setupTooltipDirection(pointView: UIView, mainView: UIView, tooltipDirection: TooltipDirection) {
        setupArrowDirection(tooltipDirection: tooltipDirection, pointView: pointView)
        setupArrowPosition(pointView: pointView, mainView: mainView, tooltipDirection: tooltipDirection)
    }
    
    private func setupArrowPosition(pointView: UIView, mainView: UIView, tooltipDirection: TooltipDirection) {
        if tooltipDirection.isVertical {
            let leadingConstraintConstant: CGFloat = 8
            let triangleConstraintConstant: CGFloat = pointView.frame.origin.x + (3 * leadingConstraintConstant) + 2
            if TapLocalisationManager.shared.localisationLocale == "ar" {
                NSLayoutConstraint.activate([
                    self.topIndicatorView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: triangleConstraintConstant - 8),
                    self.bottomIndicatorView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: triangleConstraintConstant),
                    self.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -1 * leadingConstraintConstant),
                ])
            } else {
                NSLayoutConstraint.activate([
                    self.topIndicatorView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: triangleConstraintConstant - 8),
                    self.bottomIndicatorView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: triangleConstraintConstant),
                    self.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: leadingConstraintConstant),
                ])
            }
            
        } else if tooltipDirection.isHorizontal {
            let centerAnchor = self.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0)
            centerAnchor.priority = .defaultHigh
            NSLayoutConstraint.activate([centerAnchor])
        }
    }
    
    private func setupArrowDirection(tooltipDirection: TooltipDirection, pointView: UIView) {
        switch tooltipDirection {
        case .up:
            NSLayoutConstraint.activate([self.topAnchor.constraint(equalTo: pointView.bottomAnchor, constant: -12)])
        case .down:
            NSLayoutConstraint.activate([self.bottomAnchor.constraint(equalTo: pointView.topAnchor, constant: 12)])
        case .right:
            NSLayoutConstraint.activate([self.rightAnchor.constraint(equalTo: pointView.leftAnchor, constant: 0)])
        case .left:
            NSLayoutConstraint.activate([self.leftAnchor.constraint(equalTo: pointView.rightAnchor, constant: 0)])
        case .center:
            NSLayoutConstraint.activate([
                self.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
                self.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
                self.leadingAnchor.constraint(greaterThanOrEqualTo: mainView.leadingAnchor, constant: 0),
                self.trailingAnchor.constraint(greaterThanOrEqualTo: mainView.trailingAnchor, constant: 0)
            ])
        }
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
    
    fileprivate var globalFrame: CGRect? {
        let rootView = UIApplication.shared.keyWindow?.rootViewController?.view
        return self.convert(self.frame, to: rootView)
    }
    
}



class SnapshotView: UIImageView {
    
}







