//
//  TapDragHandlerView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/9/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020
import LocalisationManagerKit_iOS
import CommonDataModelsKit_iOS

/// Represents a standalone configurable view to show a drag handler at the top of the bottom sheet
@objc public class TapDragHandlerView: UIView {
    
    /// The container view that holds everything from the XIB
    @IBOutlet var containerView: UIView!
    /// The image view to show the drag handler
    @IBOutlet var handlerImageView: UIImageView!
    /// The width constraint of the separation line, to be used in animating the width of the handler
    @IBOutlet weak var handlerImageViewWidthConstraint: NSLayoutConstraint!
    /// The height constraint of the separation line, to be used in animating the height of the handler
    @IBOutlet weak var handlerImageViewHeightConstraint: NSLayoutConstraint!
    /// The path to look for theme entry in
    private let themePath = "tapDragHandler"
    
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
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.layoutIfNeeded()
        handlerImageView.translatesAutoresizingMaskIntoConstraints = false
        applyTheme()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.frame = bounds
    }
    
    /**
     Will animate the handler image view to the provided width and height
     - Parameter width: The new width to be applied
     - Parameter height: The new height to be applied
     - Parameter animated : Indicates whether the width change should be animated or not, default is true
     */
    @objc public func changeHandlerSize(with width:CGFloat, and height:CGFloat, animated:Bool = true) {
        handlerImageViewWidthConstraint.constant = width
        handlerImageViewHeightConstraint.constant = height
        
        if animated {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut], animations: { [weak self] in
                self?.layoutIfNeeded()
            }, completion: nil)
        }else{
            layoutIfNeeded()
        }
    }
}

// Mark:- Theme methods
extension TapDragHandlerView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /**
     Update the visibility of the tap handler dragger with the given status
     - Parameter visiblity: If set, the handler will be shown. Will be hidden otherwise.
     */
    @objc public func updateHandler(visiblity to:Bool) {
        handlerImageView.isHidden = !to
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
       
        handlerImageView.tap_theme_image = .init(keyPath: "\(themePath).image")
        handlerImageView.layer.tap_theme_cornerRadious = .init(keyPath: "\(themePath).corner")
        changeHandlerSize(with: CGFloat(TapThemeManager.numberValue(for: "\(themePath).width")?.floatValue ?? 75),
                          and: CGFloat(TapThemeManager.numberValue(for: "\(themePath).height")?.floatValue ?? 2))
        tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
