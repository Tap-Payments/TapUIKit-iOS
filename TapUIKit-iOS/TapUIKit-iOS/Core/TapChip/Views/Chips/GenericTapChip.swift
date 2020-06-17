//
//  TapChip.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/14/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import class UIKit.UICollectionViewCell

public class GenericTapChip:UICollectionViewCell {
    
    func selectStatusChaned(with state:Bool) {
        return
    }
    func tapChipType() -> TapChipType {
        return .GatewayChip
    }
    
    
    func configureCell(with viewModel:GenericTapChipViewModel) {
        return
    }
    
    
}


public enum TapChipType:CaseIterable {
    case GatewayChip
    case ApplePayChip
    case GoPayChip
    case CurrencyChip
    case SavedCardChip
    
    func themePath() -> String {
        switch self {
        case .GatewayChip:
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
    
    func nibName() -> String {
        switch self {
        case .GatewayChip:
            return "GatewayImageCollectionViewCell"
        case .ApplePayChip:
            return "GatewayImageCollectionViewCell"
        case .GoPayChip:
            return "TapGoPayChipCollectionViewCell"
        case .CurrencyChip:
            return "GatewayImageCollectionViewCell"
        case .SavedCardChip:
            return "SavedCardCollectionViewCell"
        }
    }
}
