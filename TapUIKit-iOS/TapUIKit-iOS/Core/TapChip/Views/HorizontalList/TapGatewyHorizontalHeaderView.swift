//
//  TapHorizontalHeaderView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/17/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020
import class LocalisationManagerKit_iOS.TapLocalisationManager
import class CommonDataModelsKit_iOS.TapCommonConstants

/// The protocol to listen to events fired from the header left and right accessories
protocol TapHorizontalHeaderDelegate {
    /**
     Will be fired once the right accessory is clicked
     - Parameter type: The header view which fired the event
     */
    func rightAccessoryClicked(with type:TapHorizontalHeaderView)
    
    /**
     Will be fired once the left accessory is clicked
     - Parameter type: The header view which fired the event
     */
    func leftAccessoryClicked(with type:TapHorizontalHeaderView)
}

/// Represents a generic header view to be attached to the genetic horizontal chips list
class TapHorizontalHeaderView: UIView {
    
    /// Reference to the left accessory view
    @IBOutlet weak var leftButton: UIButton!
    /// Reference to the right accessory view
    @IBOutlet weak var rightButton: UIButton!
    /// Reference to the main XIB view
    @IBOutlet var contentView: UIView!
    /// Subscribe to this to get notified upon fired events
    var delegate:TapHorizontalHeaderDelegate?
    
    /// Defines which header view should be loaded
    var headerType:TapHorizontalHeaderType? = nil {
        didSet{
            commonInit()
        }
    }
    /// Keeps track of the last applied theme value
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    
    
    @IBAction func leftButtonClicked(_ sender: Any) {
        delegate?.leftAccessoryClicked(with: self)
    }
    
    @IBAction func rightButtonClicked(_ sender: Any) {
        delegate?.rightAccessoryClicked(with: self)
    }
    
    
    /// The path to look for theme entry in
    private var themePath:String {
        get{
            headerType?.themePath() ?? ""
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
    
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.contentView = setupXIB()
        applyTheme()
        localize()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = bounds
    }
    
    /// Handles all required localisations for the different views insude the header
    private func localize() {
        let (leftTitle,rightTitle) = headerType?.localizedTitles() ?? ("","")
        leftButton.setTitle(leftTitle, for: .normal)
        rightButton.setTitle(rightTitle, for: .normal)
    }
    
    
    /**
     Handles updating the theme and the localisations based ont the new header type
     - Parameter headerViewType: The new header type to be used
     */
    func showHeader(with headerViewType:TapHorizontalHeaderType) {
        guard headerViewType != .NoHeader else {
            return
        }
        
        self.headerType = headerViewType
    }
    
    
}

/// Represents the enum of different implemented horizontal chip list header views
@objc public enum TapHorizontalHeaderType:Int {
    /// The SELECT - EDIT header view for the list of payment gatewas and saved cards
    case GatewayListHeader
    case NoHeader
    /// Defines the theme entry based on the type
    func themePath() -> String {
        switch self {
            case .GatewayListHeader:
                return "horizontalList.headers.gatewayHeader"
        case .NoHeader:
            return ""
        }
    }
    
    /**
     Defines the localizations of left and tight accessoty based on the type
     - Returns: (Localized Left title, Localized Right title)
     */
    func localizedTitles() -> (String,String) {
        
        let sharedLocalisationManager = TapLocalisationManager.shared
        
        var (leftTitleKey,rightTitleKey) = ("","")
        
        switch self {
        case .GatewayListHeader:
            (leftTitleKey,rightTitleKey) = ("HorizontalHeaders.GatewayHeader.leftTitle","HorizontalHeaders.GatewayHeader.rightTitle")
        case .NoHeader:
            (leftTitleKey,rightTitleKey) = ("","")
        }
        
        return (sharedLocalisationManager.localisedValue(for: leftTitleKey, with: TapCommonConstants.pathForDefaultLocalisation()),sharedLocalisationManager.localisedValue(for: rightTitleKey, with: TapCommonConstants.pathForDefaultLocalisation()))
        
    }
}



// Mark:- Theme methods
extension TapHorizontalHeaderView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        guard themePath != "" else { return }
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        leftButton.titleLabel?.tap_theme_font = .init(stringLiteral: "\(themePath).leftButton.labelTextFont")
        leftButton.tap_theme_setTitleColor(selector: .init(keyPath: "\(themePath).leftButton.labelTextColor"), forState: .normal)
        
        rightButton.titleLabel?.tap_theme_font = .init(stringLiteral: "\(themePath).rightButton.labelTextFont")
        rightButton.tap_theme_setTitleColor(selector: .init(keyPath: "\(themePath).rightButton.labelTextColor"), forState: .normal)
        
        contentView.tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        
        guard lastUserInterfaceStyle != self.traitCollection.userInterfaceStyle else {
            return
        }
        lastUserInterfaceStyle = self.traitCollection.userInterfaceStyle
        applyTheme()
    }
}


