//
//  TapGoPayCollectionViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/16/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import class UIKit.UICollectionViewCell

public class TapGoPayViewModel: GenericTapChipViewModel {
    
    internal var cellDelegate:GenericChipViewModelDelegate?
    
    public override func identefier() -> String {
        return "TapGoPayChipCollectionViewCell"
    }
    
    
    public override func didSelectItem() {
        cellDelegate?.changeSelection(with: true)
    }
    
    public override func didDeselectItem() {
        cellDelegate?.changeSelection(with: false)
    }
    
    
    public override  func correctCellType(for cell:GenericTapChip) -> GenericTapChip {
        return cell as! TapGoPayChipCollectionViewCell
    }
}
