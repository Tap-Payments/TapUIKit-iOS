//
//  TapChip.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/14/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import RxSwift

public class GenericTapChip:UICollectionViewCell {
    
    
    let disposeBag:DisposeBag = .init()
    
    func identefier() -> String {
        return ""
    }
    func updateTheme(for state:Bool) {
        return
    }
    func tapChipType() -> TapChipType {
        return .GatewayChip
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.rx.isSelected.subscribe(onNext: { [weak self] (selected) in
            self?.updateTheme(for: selected)
        }).disposed(by: disposeBag)
    }
    
    
}


public enum TapChipType {
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
}


extension Reactive where Base: UICollectionViewCell {
    
    public var isSelected: Observable< Bool > {
        return self.observeWeakly(Bool.self, #keyPath(UICollectionViewCell.isSelected)).map { $0 ?? false }
    }
}
