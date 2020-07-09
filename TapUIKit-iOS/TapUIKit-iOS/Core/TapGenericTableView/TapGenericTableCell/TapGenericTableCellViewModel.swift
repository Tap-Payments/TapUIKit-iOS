//
//  TapGenericTableCellViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/21/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation

/// A protocl of methods to be applied to all table cells viewmodel to infom the view model with needed events
internal protocol TapGenericCellViewModelDelegate {
    
    /**
     The event will be fired when the user cliks on an Item cell
     - Parameter viewModel: Represents The attached view model
     */
    func itemClicked(for viewModel:ItemCellViewModel)
    func reloadRows(at indexPaths:[IndexPath])
}


/// A protocl of methods to be applied to all generated  cells to infom the view model with needed events
internal protocol TapCellViewModelDelegate {
    /**
     Each view model should have an interface to know his cell is selected or nt. Fired from the cell itself
     - parameter status: tTrue if it was just selected and false otherwise
     */
    func changeSelection(with status:Bool)
    /**
     Instruc the cell to reload itself
     */
    func reloadData()
}


/// This is a superclass for all the table cells view models created, this will make sure all have the same interface/output and ease the parametery type in methods
@objc public class TapGenericTableCellViewModel:NSObject {
    
    // MARK:- Internal methods
    
    /**
     All created table cells should have an interface to know about their selection status
     - Parameter state: True if it was just selected and false otherwise
     */
    internal func selectStatusChaned(with state:Bool) {
        return
    }
    
    /**
     Each cell generated must have an interface to tell its type
     - Returns: The corresponding cell type
     */
    internal func tapCellType() -> TapGenericCellType {
        return .ItemTableCell
    }
    
    /**
     All created tabe cells should have an integhtrface to cnfigure itself with a given view model
     - Parameter viewModel: The view model the cell will attach itself to
     */
    internal func configureCell(with viewModel:TapGenericTableCellViewModel) {
        return
    }
    
    
    /// A protocl of methods to be applied to all table cells viewmodel to infom the view model with needed events
    internal var viewModelDelegate:TapGenericCellViewModelDelegate?
    
    /**
     Each Cell ViewModel will be responsible to create a unique identifir for himself and for the collectionviewcell attached to it
     - Returns: The identefier to be used in declaring the type and to dequeue the cells from the table vew
     */
    func identefier() -> String {
        return ""
    }
    
    ///Each Cell View Model must have an interface to know that his assocated cell is selected to do the needed logic
    func didSelectItem() {
        return
    }
    
    ///Each Cell View Model must have an interface to know that his assocated cell is deselected to do the needed logic
    func didDeselectItem() {
        return
    }
    
    /**
     To consolidate the code as much as possible, each view model is reponsible for casting in a generic uitableviewcell into his associated type. This will keep the view unaware of the inner classes
     - Returns: The correctly typed cell based on the type of the view model
     */
    func correctCellType(for cell:TapGenericTableCell) -> TapGenericTableCell {
        return cell
    }
}


/// An enum to identify all the created cells types, to be used to pvoide a singleton place to know all about each type
@objc public enum TapGenericCellType:Int,CaseIterable {
    /// The cell that represents the items inside order/transaction
    case ItemTableCell = 0
    
    /**
     Defines what is the theme path to look for to customise a cell based on its type
     - Returns: The theme entry location inside the Theme json file
     */
    func themePath() -> String {
        switch self {
        case .ItemTableCell:
            return "itemsList.item"
        }
    }
    
    /**
     Defines The XIB name should be loaded into the view basde on the cell type
     - Returns: The XIB name of the file inside the bundle that has the view needed to be rendered
     */
    func nibName() -> String {
        switch self {
        case .ItemTableCell:
            return "ItemTableViewCell"
        }
    }
}

