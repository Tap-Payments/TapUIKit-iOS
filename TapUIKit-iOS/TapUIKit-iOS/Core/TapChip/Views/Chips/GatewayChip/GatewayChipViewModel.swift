//
//  GatewayChipViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/14/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//
/// The view model that controlls the GatewayChip cell
@objc public class GatewayChipViewModel: GenericTapChipViewModel {
    
    // MARK:- Variables
    
    /// The delegate that the associated cell needs to subscribe to know the events and actions it should do
    internal var cellDelegate:GenericCellChipViewModelDelegate?
    
    // MARK:- Public methods
    
    public override func identefier() -> String {
        return "GatewayImageCollectionViewCell"
    }
    
    
    public override func didSelectItem() {
        // When the view model get notified it's selected, the view model needs to inform the attached view so it re displays itself
        cellDelegate?.changeSelection(with: true)
        viewModelDelegate?.gateway(for: self)
    }
    
    public override func didDeselectItem() {
        // When the view model get notified it's deselected, the view model needs to inform the attached view so it re displays itself
        cellDelegate?.changeSelection(with: false)
        
    }
    
    public override func changedEditMode(to: Bool) {
        // When the view model get notified about the new editing mode status
        cellDelegate?.changedEditMode(to: to)
    }
    
    // MARK:- Internal methods
    
    internal override  func correctCellType(for cell:GenericTapChip) -> GenericTapChip {
        return cell as! GatewayImageCollectionViewCell
    }
    
}
