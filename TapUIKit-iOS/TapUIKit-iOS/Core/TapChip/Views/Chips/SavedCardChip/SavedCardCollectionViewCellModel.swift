//
//  SavedCardCollectionViewCellModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/17/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation

public class SavedCardCollectionViewCellModel: GenericTapChipViewModel {
    
    internal var cellDelegate:GenericChipViewModelDelegate?
    
    public override func identefier() -> String {
        return "SavedCardCollectionViewCell"
    }
    
    
    public override func didSelectItem() {
       cellDelegate?.changeSelection(with: true)
    }
    
    public override func didDeselectItem() {
       cellDelegate?.changeSelection(with: false)
    }
}
