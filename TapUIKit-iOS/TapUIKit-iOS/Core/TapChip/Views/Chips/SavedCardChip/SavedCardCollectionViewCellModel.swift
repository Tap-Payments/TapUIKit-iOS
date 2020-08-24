//
//  SavedCardCollectionViewCellModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/17/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import class UIKit.UICollectionViewCell

/// The view model that controlls the SavedCard cell
@objc public class SavedCardCollectionViewCellModel: GenericTapChipViewModel {
    
    // MARK:- Variables
    
    /// The delegate that the associated cell needs to subscribe to know the events and actions it should do
    internal var cellDelegate:GenericCellChipViewModelDelegate?
    
    @objc public var listSource:TapHorizontalHeaderType = .GatewayListHeader
    
    @objc public init(title: String? = nil, icon: String? = nil, listSource:TapHorizontalHeaderType = .GatewayListHeader) {
        super.init(title: title, icon: icon)
        self.listSource = listSource
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    // MARK:- Public methods
    public override func identefier() -> String {
        return "SavedCardCollectionViewCell"
    }
    
    
    public override func didSelectItem() {
        cellDelegate?.changeSelection(with: true)
        viewModelDelegate?.savedCard(for: self)
    }
    
    public override func didDeselectItem() {
        cellDelegate?.changeSelection(with: false)
    }
    
    public override func changedEditMode(to: Bool) {
        // When the view model get notified about the new editing mode status
        cellDelegate?.changedEditMode(to: to)
    }
    
    func deleteChip() {
        viewModelDelegate?.deleteChip(for: self)
    }
    
    // MARK:- Internal methods
    internal override  func correctCellType(for cell:GenericTapChip) -> GenericTapChip {
        return cell as! SavedCardCollectionViewCell
    }
}
