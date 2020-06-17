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

protocol TapHorizontalHeaderDelegate {
    func rightAccessoryClicked(with type:TapHorizontalHeaderView)
    func leftAccessoryClicked(with type:TapHorizontalHeaderView)
}

class TapHorizontalHeaderView: UIView {
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet var contentView: UIView!
    var delegate:TapHorizontalHeaderDelegate?
    var headerType:TapHorizontalHeaderType = .GatewayListHeader {
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
            headerType.themePath()
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
    
    private func localize() {
        let (leftTitle,rightTitle) = headerType.localizedTitles()
        leftButton.setTitle(leftTitle, for: .normal)
        rightButton.setTitle(rightTitle, for: .normal)
    }
    
    
    func showHeader(with headerViewType:TapHorizontalHeaderType?) {
        guard let nonNullHeader = headerViewType else {
            return
        }
        
        self.headerType = nonNullHeader
    }
    
    
}


public enum TapHorizontalHeaderType {
    case GatewayListHeader
    
    func themePath() -> String {
        switch self {
            case .GatewayListHeader:
                return "horizontalList.headers.gatewayHeader"
        }
    }
    
    func localizedTitles() -> (String,String) {
        
        let sharedLocalisationManager = TapLocalisationManager.shared
        
        var (leftTitleKey,rightTitleKey) = ("","")
        
        switch self {
        case .GatewayListHeader:
            (leftTitleKey,rightTitleKey) = ("HorizontalHeaders.GatewayHeader.leftTitle","HorizontalHeaders.GatewayHeader.rightTitle")
        }
        
        //sharedLocalisationManager.localisedValue(for: "\(localizationPath).paymentFor", with: TapCommonConstants.pathForDefaultLocalisation())
            
        return (sharedLocalisationManager.localisedValue(for: leftTitleKey, with: TapCommonConstants.pathForDefaultLocalisation()),sharedLocalisationManager.localisedValue(for: rightTitleKey, with: TapCommonConstants.pathForDefaultLocalisation()))
        
    }
}



// Mark:- Theme methods
extension TapHorizontalHeaderView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
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


