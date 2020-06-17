//
//  TapChipHorizontalListViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/15/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//


import class UIKit.UICollectionView
import class UIKit.UINib

/// This is the public protocol for outer components to listen to events and data fired from this view model and its attached view
public protocol TapChipHorizontalListViewModelDelegate {
    /**
        The event will be fired when a cell is selected in the attacjed uicollection voew
     - Parameter viewModel: Represents the attached view model of the selectec cell view
     */
    func didSelect(item viewModel:GenericTapChipViewModel)
    func headerLeftButtonClicked(in headerType:TapHorizontalHeaderType)
    func headerRightButtonClicked(in headerType:TapHorizontalHeaderType)
    
}

/// This is the internal protocol for communication between the view model and its attached UIView
internal protocol TapChipHorizontalViewModelDelegate {
    /**
     The event will be fired when the data source of the view model had been changed hence the UIVIew needds to start updating itself
     - Parameter dataSource: Represents the new datasource if needed
     */
    func reload(new dataSource:[GenericTapChipViewModel])
    func showHeader(with type:TapHorizontalHeaderType?)
}

/// This is the view model that adjusts and adapts the info shown in any GenericTapHorizontal list. It accepts and arranges different chips view models through one place
public class TapChipHorizontalListViewModel {
    
    // Mark:- Variables
    
    /// The data source which represents the list of view models to be displayed inside the uicollectionview
    public var dataSource:[GenericTapChipViewModel] = [] {
        didSet{
            // When it is changed, we need to inform the attached view that he needs to reload itself now
            cellDelegate?.reload(new: dataSource)
        }
    }
    
    public var headerType:TapHorizontalHeaderType? {
        didSet{
            cellDelegate?.showHeader(with: headerType)
        }
    }
    
    /// Attach yourself to this delegate to start getting events fired from this view model and its attached uicollectionview
    public var delegate:TapChipHorizontalListViewModelDelegate?
    
    /// Attach yourself to this delegare if you are the associated view so you can be instructed by actions you have to do
    internal var cellDelegate:TapChipHorizontalViewModelDelegate? {
        didSet{
            cellDelegate?.showHeader(with: headerType)
        }
    }
    
    // Mark:- Public methods
    /**
     Creates the ViewModel and makes it ready for work
     - Parameter dataSource: The list of viewmodels that will be rendered as list of UIViews in the collectionview
     */
    public init(dataSource:[GenericTapChipViewModel], headerType:TapHorizontalHeaderType? = nil) {
        defer {
            self.dataSource = dataSource
            self.headerType = headerType
        }
    }
    
    /// Creates empty view model, added for convience
    public init() {}
    
    // Mark:- Internal methods
    
    /**
     Logic to attach and register all created custom XIB files and classes to a provided collection view. Helps in automating the process and no need to do a custom code for each created XIB custom cell.
     - Parameter collectionView: The UICollectionView you want to register all created custom Tap Chip Cells to it
     */
    internal func registerAllXibs(for collectionView:UICollectionView) {
        // Fetch all availble chip cells views
        let chipCellsNames:[String] = TapChipType.allCases.map{ $0.nibName() }
        // For each one of them, register its XIB and class to the provided collection view
        chipCellsNames.forEach { chipName in
            // We need to load teh XIB from the correct bundle which  is this bundle
            let bundle = Bundle(for: TapChipHorizontalListViewModel.self)
            collectionView.register(UINib(nibName: chipName, bundle: bundle), forCellWithReuseIdentifier: chipName)
        }
    }
    
    /**
     Calclates teh number of sections to be displayed inside the attached collecionvoew
      - Returns: The number of sections (ROWS) to be displayed
     */
    internal func numberOfSections() -> Int {
        1
    }
    
    /**
     Calclates teh number of items to be displayed for a given row
     - Parameter section: The section you want to know the number of items in, default is 0
     - Returns: The number of items (COLUMNS) to be displayed in the provided row
     */
    internal func numberOfRows(for section:Int = 0) -> Int {
        switch section {
            case 0:
                return dataSource.count
            default:
                return 0
        }
    }
    
    internal func leftButtonClicked(for header:TapHorizontalHeaderView) {
        delegate?.headerLeftButtonClicked(in: header.headerType)
    }
    
    internal func rightButtonClicked(for header:TapHorizontalHeaderView) {
        delegate?.headerRightButtonClicked(in: header.headerType)
    }
    
    /**
     Fetches the correct view model associated to a certain cell
     - Parameter index: The position of the cell you want the view model of it
     - Returns: The view model that is associated to the given cell index
     */
    internal func viewModel(at index:Int) -> GenericTapChipViewModel {
        return dataSource[index]
    }
    
    /**
     Fire the event and handle the logic of selecting a certain cell
     - Parameter index: The position of the cell the user selected
     */
    internal func didSelectItem(at index:Int) {
        let selectedViewModel = viewModel(at: index)
        // Inform the view model of the selected cell that he is selected, hence, he will pass this value to his attached UIView
        selectedViewModel.didSelectItem()
        // Inform the main (outer) delegate, that an item had been selected
        delegate?.didSelect(item: selectedViewModel)
    }
    
    /**
     Fire the event and handle the logic of deselecting a certain cell
     - Parameter index: The position of the cell the user deselected
     */
    internal func didDeselectItem(at index:Int) {
        // Inform the view model of the deselected cell that he is selected, hence, he will pass this value to his attached UIView
        viewModel(at: index).didDeselectItem()
    }
    
    /**
     To isolate the view totally about any logic, this method gives back the cell that needds to be displayed inside the list at a certain position
     - Parameter collectionView: Which collection view we need to display the cell in
     - Parameter indexPath: The posotion of the required cell to be loaded
     - Returns: A subclass of the GenericTapChip based on the type of its view model
     */
    internal func dequeuCell(in collectionView:UICollectionView, at indexPath:IndexPath) -> GenericTapChip {
        
        // Get the associated view model at the given index
        let currentViewModel = viewModel(at: indexPath.row)
        // Generically fetch the cell at the provided position
        let cell:GenericTapChip = collectionView.dequeueReusableCell(withReuseIdentifier: currentViewModel.identefier(), for: indexPath) as! GenericTapChip
        
        // Based on the type of the viewmodel we define which subclass the cell will be
        return currentViewModel.correctCellType(for: cell)
    }
    
}
