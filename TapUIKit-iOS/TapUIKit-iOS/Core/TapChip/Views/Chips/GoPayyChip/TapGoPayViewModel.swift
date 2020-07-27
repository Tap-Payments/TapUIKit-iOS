//
//  TapGoPayCollectionViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/16/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import class UIKit.UICollectionViewCell

/// The view model that controlls the GoPay cell
@objc public class TapGoPayViewModel: GenericTapChipViewModel {
    
    // MARK:- Variables
    
    /// The delegate that the associated cell needs to subscribe to know the events and actions it should do
    internal var cellDelegate:GenericCellChipViewModelDelegate?
    
    // MARK:- Public methods
    public override func identefier() -> String {
        return "TapGoPayChipCollectionViewCell"
    }
    
    
    public override func didSelectItem() {
        cellDelegate?.changeSelection(with: true)
        viewModelDelegate?.goPay(for: self)
    }
    
    public override func didDeselectItem() {
        cellDelegate?.changeSelection(with: false)
    }
    
    public override func changedEditMode(to: Bool) {
        // When the view model get notified about the new editing mode status
        cellDelegate?.changedEditMode(to: to)
    }
    
    // MARK:- Internal methods
    internal override  func correctCellType(for cell:GenericTapChip) -> GenericTapChip {
        return cell as! TapGoPayChipCollectionViewCell
    }
}
