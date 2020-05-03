//
//  TapCardsCollectionViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 30/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import class UIKit.UICollectionView
import class UIKit.UINib

/// This protocol will be responsible for sharing the events and callbacks from the recent cards collection view kit
@objc public protocol TapCardsCollectionProtocol {
    /**
     Will be fired once a user clicks on a certain recent card object
     - Parameter viewModel : The TapCardRecentCardCellViewModel holding the information about the clicked/selected recent card
     */
    @objc func recentCardClicked(with viewModel:TapCardRecentCardCellViewModel)
    /**
    Will be fired once a user clicks on GoPay cell from the recent cards view
    - Parameter viewModel : The TapGoPayCellViewModel holding the information about the clicked/selected GoPay
    */
    @objc func goPayClicked(with viewModel:TapGoPayCellViewModel)
}

/// Represents the View model responsible for managing the data and the events shown and reacted to inside the TapRecentCards view
@objc public class TapCardsCollectionViewModel:NSObject {
    
    /// This is the data source used to fill in the recent cards horizontal list, will contain all needed cell to be displayed like GoPay, Separator and RecentCards
    internal lazy var dataSource:[CellConfigurator] = []
    
    /// The delegate that wants to listen to the callbacks and the events fired from within this view
    @objc public var delegate:TapCardsCollectionProtocol?
    
    /**
     Calculates the needed number of cells to be displayed
     - Returns: Int represents the number of total cells we will need to display
     */
    internal func numberOfItems() -> Int {
        return dataSource.count
    }
    
    /**
     Generates the cell configurator object (which contains the generic cell) of a certain path
     - Parameter indexPath: The location/pposiion of the item you want to generate its cell configurator
     - Returns: The cell configurator (generic tap cell) that represents the item in the given indexpath
     */
    internal func cellConfigurator(at indexPath:IndexPath) -> CellConfigurator {
        return dataSource[indexPath.row]
    }
    
    /**
     The view will use this method to inform the view model that the user selected a certain cell
     - Parameter indexPath: The position of the cell the user selected
     */
    internal func didSelectItem(at indexPath:IndexPath) {
        // We need to inform any delegate that a certain cell had been selected
        handleItemSelection(cell: cellConfigurator(at: indexPath))
    }
    
    /**
    The view will use this method to inform the view model that the user deselected a certain cell
    - Parameter indexPath: The position of the cell the user deselected
    */
    internal func didDeSelectItem(at indexPath:IndexPath) {
        // We need to inform any delegate that a certain cell had been deselected
        handleItemDeSelection(cell: cellConfigurator(at: indexPath))
    }
    
    /**
     The view will use this method so the view model handles registering all needed ui custom cells
     - Parameter collectionView: The collection view the view wants the view model t oregister all the needed custom cells on
     */
    internal func registerCells(on collectionView:UICollectionView) {
        // Register the TapRecentCard cell
        collectionView.register(UINib(nibName:String(describing: TapRecentCardCollectionViewCell.self), bundle: Bundle(for: TapRecentCardCollectionViewCell.self)), forCellWithReuseIdentifier: String(describing: TapRecentCardCollectionViewCell.self))
        // Register the TapGoPay cell
        collectionView.register(UINib(nibName:String(describing: TapGoPayCollectionViewCell.self), bundle: Bundle(for: TapGoPayCollectionViewCell.self)), forCellWithReuseIdentifier: String(describing: TapGoPayCollectionViewCell.self))
        // Register the TapRSeparator cell
         collectionView.register(UINib(nibName:String(describing: TapSeparatorCollectionViewCell.self), bundle: Bundle(for: TapSeparatorCollectionViewCell.self)), forCellWithReuseIdentifier: String(describing: TapSeparatorCollectionViewCell.self))
    }
    
    /**
     A convenience init of the view model with a certain viewmodels
     - Parameter models: The Viewmodels that will be rendered as cells inside the colletion view afterwards
     */
    @objc public convenience init(with models:[TapCellViewModel]) {
        self.init()
        // Fill in the data source, by mapping the passed viewmodels into their respective generic UI cells
        dataSource = models.map{ $0.convertToCellConfigrator() }
    }
    
    /**
     The method is responsible for the logic to be done when the user selects a certain cell, by informing the view what it needs to do ad informing any delegate about the event
     - Parameter cell : The selected Cell by  the user
     */
    internal func handleItemSelection(cell: CellConfigurator) {
        
        // Defensice code to check first, if there is an actual cell passed and there is a delegate that wants to hear back from us
        if let clickedCell:TapGenericCollectionViewCell = cell.collectionViewCell {
            // We inform the cell to perform the ui related to being selected
            clickedCell.selectCell()
           if let nonNullDelegate = delegate {
                // All good
                // Based on the selected cell type, we determine which delegate method we will call
                switch clickedCell.cellViewModel().self {
                case is TapGoPayCellViewModel:
                    nonNullDelegate.goPayClicked(with: clickedCell.cellViewModel() as! TapGoPayCellViewModel)
                case is TapCardRecentCardCellViewModel:
                    nonNullDelegate.recentCardClicked(with: clickedCell.cellViewModel() as! TapCardRecentCardCellViewModel)
                default:
                    break
                }
            }
        }
    }
    
    /**
    The method is responsible for the logic to be done when the user deselects a certain cell, by informing the view what it needs to do ad informing any delegate about the event
    - Parameter cell : The deselected Cell by  the user
    */
    internal func handleItemDeSelection(cell: CellConfigurator) {
        // Defensice code to check first, if there is an actual cell passed
        if let clickedCell:TapGenericCollectionViewCell = cell.collectionViewCell {
            // All good
            
            // We inform the cell to perform the ui related to being deselected
            clickedCell.deSelectCell()
        }
    }
    
    override internal init() {
        super.init()
    }
    
}
