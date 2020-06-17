//
//  SavedCardCollectionViewCellModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/17/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import class UIKit.UICollectionViewCell

/// The view model that controlls the SavedCard cell
public class SavedCardCollectionViewCellModel: GenericTapChipViewModel {
    
    // MARK:- Variables
    
    /// The delegate that the associated cell needs to subscribe to know the events and actions it should do
    internal var cellDelegate:GenericChipViewModelDelegate?
    
    // MARK:- Public methods
    public override func identefier() -> String {
        return "SavedCardCollectionViewCell"
    }
    
    
    public override func didSelectItem() {
       cellDelegate?.changeSelection(with: true)
    }
    
    public override func didDeselectItem() {
       cellDelegate?.changeSelection(with: false)
    }
    
    // MARK:- Internal methods
    internal override  func correctCellType(for cell:GenericTapChip) -> GenericTapChip {
        return cell as! SavedCardCollectionViewCell
    }
}
