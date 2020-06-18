//
//  GenericTapChipViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/14/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import class UIKit.UICollectionViewCell
import class TapApplePayKit_iOS.TapApplePayToken

/// A protocl of methods to be applied to all chips viewmodel to infom the view model with needed events
internal protocol GenericChipViewModelDelegate {
    
    /**
     The event will be fired when a successful apple pay authorization happened
     - Parameter viewModel: Represents The attached view model
     - Parameter token: Represents Tap wrapper for the generated token
     */
    func applePayAuthoized(for viewModel:ApplePayChipViewCellModel, with token:TapApplePayToken)
    /**
     The event will be fired when the user cliks on a saved card chip
     - Parameter viewModel: Represents The attached view model
     */
    func savedCard(for viewModel:SavedCardCollectionViewCellModel)
    /**
     The event will be fired when the user cliks on a gateway chip
     - Parameter viewModel: Represents The attached view model
     */
    func gateway(for viewModel:GatewayChipViewModel)
    /**
     The event will be fired when the user cliks on a goPay chip
     - Parameter viewModel: Represents The attached view model
     */
    func goPay(for viewModel:TapGoPayViewModel)
    /**
     The event will be fired when the user cliks on a currency chip
     - Parameter viewModel: Represents The attached view model
     */
    func currencyChip(for viewModel:CurrencyChipViewModel)
}


/// A protocl of methods to be applied to all generated chip cells to infom the view model with needed events
internal protocol GenericCellChipViewModelDelegate {
    /**
        Each view model should have an interface to know his cell is selected or nt. Fired from the cell itself
     - parameter status: tTrue if it was just selected and false otherwise
     */
    func changeSelection(with status:Bool)
}

/// This is a superclass for all the chips view models created, this will make sure all have the same interface/output and ease the parametery type in methods
@objc public class GenericTapChipViewModel:NSObject {
    
    /// The title to be displayed if any in the Chip cell
    public var title:String?
    /// The icon if any to be displayed in the Chip cell
    public var icon:String?
    
    /// A protocl of methods to be applied to all chips viewmodel to infom the view model with needed events
    internal var viewModelDelegate:GenericChipViewModelDelegate?
    
    /**
     Creates a view model with the provided data
      - Parameter title: The title to be displayed if any in the Chip cell default is nil
     - Parameter icon:The icon if any to be displayed in the Chip cell default is nil
     */
    public init(title:String? = nil, icon:String? = nil) {
        self.title = title
        self.icon = icon
    }
    
    /**
     Each Chip View Model will be responsible to create a unique identifir for himself and for the collectionviewcell attached to it
     - Returns: The identefier to be used in declaring the type and to dequeue the cells from the collectionview
     */
    func identefier() -> String {
        return ""
    }
    
    ///Each Chip View Model must have an interface to know that his assocated cell is selected to do the needed logic
    func didSelectItem() {
        return
    }
    
    ///Each Chip View Model must have an interface to know that his assocated cell is deselected to do the needed logic
    func didDeselectItem() {
        return
    }
    
    /**
     To consolidate the code as much as possible, each view model is reponsible for casting in a generic uicollectionviewcell into his associated type. This will keep the view unaware of the inner classes
     - Returns: The correctly typed cell based on the type of the view model
     */
    func correctCellType(for cell:GenericTapChip) -> GenericTapChip {
        return cell
    }
    
}