//
//  TapChip.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/14/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import class UIKit.UICollectionViewCell

/// This is a superclass for all the chips views created, this will make sure all have the same interface/output and ease the parametery type in methods
@objc public class GenericTapChip:UICollectionViewCell {
    
    
    // MARK:- Internal methods
    /**
     All created chips views should have an interface to know about their selection status
     - Parameter state: True if it was just selected and false otherwise
     */
    internal func selectStatusChaned(with state:Bool) {
        return
    }
    
    /**
     Each cell generated must have an interface to tell its type
     - Returns: The corresponding cell type
     */
    internal func tapChipType() -> TapChipType {
        return .GatewayChip
    }
    
    /**
     All created chips views should have an integhtrface to cnfigure itself with a given view model
     - Parameter viewModel: The view model the cell will attach itself to
     */
    internal func configureCell(with viewModel:GenericTapChipViewModel) {
        return
    }
    
    public override var isSelected: Bool {
        didSet{
            selectStatusChaned(with: isSelected)
        }
    }
}

/// An enum to identify all the created chips tupes, to be used to pvoide a singleton place to knwo all about each type
@objc public enum TapChipType:Int,CaseIterable {
    /// Gateway chip which has only centered payment gateway logo
    case GatewayChip = 1
    /// Apple pay chip which has Pay with Apple pay logo
    case ApplePayChip = 2
    /// Gopay chip which has the TAP logo and goPay title
    case GoPayChip = 3
    /// Currency chip which has the flag and teh ISO code of the currency
    case CurrencyChip = 4
    /// Saved card chip has the card icon and the crypted card number
    case SavedCardChip = 5
    /// Logout chip has the logout icon
    case LogoutChip = 6
    
    
    /**
     Defines what is the theme path to look for to customise a cell based on its type
     - Returns: The theme entry location inside the Theme json file
     */
    func themePath() -> String {
        switch self {
        case .GatewayChip,.LogoutChip:
            return "horizontalList.chips.gatewayChip"
        case .ApplePayChip:
            return "horizontalList.chips.applePayChip"
        case .GoPayChip:
            return "horizontalList.chips.goPayChip"
        case .CurrencyChip:
            return "horizontalList.chips.currencyChip"
        case .SavedCardChip:
            return "horizontalList.chips.savedCardChip"
        }
    }
    
    /**
     Defines The XIB name should be loaded into the view basde on the cell type
     - Returns: The XIB name of the file inside the bundle that has the view needed to be rendered
     */
    func nibName() -> String {
        switch self {
        case .GatewayChip:
            return "GatewayImageCollectionViewCell"
        case .ApplePayChip:
            return "ApplePayChipCollectionViewCell"
        case .GoPayChip:
            return "TapGoPayChipCollectionViewCell"
        case .CurrencyChip:
            return "CurrencyChipCollectionViewCell"
        case .SavedCardChip:
            return "SavedCardCollectionViewCell"
        case .LogoutChip:
            return "TapLogoutChipCollectionViewCell"
        }
    }
}
