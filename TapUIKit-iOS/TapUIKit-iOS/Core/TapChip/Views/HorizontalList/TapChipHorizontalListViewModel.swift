//
//  TapChipHorizontalListViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/15/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//


import class UIKit.UICollectionView
import class UIKit.UINib
import class UIKit.UIApplication
import class TapApplePayKit_iOS.TapApplePayToken

/// This is the public protocol for outer components to listen to events and data fired from this view model and its attached view
@objc public protocol TapChipHorizontalListViewModelDelegate {
    /**
     The event will be fired when a cell is selected in the attacjed uicollection voew
     - Parameter viewModel: Represents the attached view model of the selectec cell view
     */
    @objc func didSelect(item viewModel:GenericTapChipViewModel)
    /**
     The event will be fired when left button in the header if any is clicked
     - Parameter headerType: Represents which header was clicked
     */
    @objc func headerLeftButtonClicked(in headerType:TapHorizontalHeaderType)
    /**
     The event will be fired when right button in the header if any is clicked
     - Parameter headerType: Represents which header was clicked
     */
    @objc func headerRightButtonClicked(in headerType:TapHorizontalHeaderType)
    /**
     The event will be fired when end editing button in the header if any is clicked
     - Parameter headerType: Represents which header was clicked
     */
    @objc func headerEndEditingButtonClicked(in headerType:TapHorizontalHeaderType)
    /**
     The event will be fired when a successful apple pay authorization happened
     - Parameter viewModel: Represents The attached view model
     - Parameter token: Represents Tap wrapper for the generated token
     */
    @objc func applePayAuthoized(for viewModel:ApplePayChipViewCellModel, with token:TapApplePayToken)
    /**
     The event will be fired when the user cliks on a saved card chip
     - Parameter viewModel: Represents The attached view model
     */
    @objc func savedCard(for viewModel:SavedCardCollectionViewCellModel)
    /**
     The event will be fired when the user cliks on a gateway chip
     - Parameter viewModel: Represents The attached view model
     */
    @objc func gateway(for viewModel:GatewayChipViewModel)
    /**
     The event will be fired when the user cliks on a goPay chip
     - Parameter viewModel: Represents The attached view model
     */
    @objc func goPay(for viewModel:TapGoPayViewModel)
    
    /**
     The event will be fired when the user cliks on a currency chip
     - Parameter viewModel: Represents The attached view model
     */
    @objc func currencyChip(for viewModel:CurrencyChipViewModel)
    
    /**
     The event will be fired when the user cliks on delete icon in the chip
     - Parameter viewModel: Represents The attached view model
     */
    @objc func deleteChip(for viewModel:SavedCardCollectionViewCellModel)
    
    /**
     The event will be fired when the user cliks on logout icon in the chip
     - Parameter viewModel: Represents The attached view model
     */
    @objc func logoutChip(for viewModel:TapLogoutChipViewModel)
}

/// This is the internal protocol for communication between the view model and its attached UIView
internal protocol TapChipHorizontalViewModelDelegate {
    /**
     The event will be fired when the data source of the view model had been changed hence the UIVIew needds to start updating itself
     - Parameter dataSource: Represents the new datasource if needed
     */
    func reload(new dataSource:[GenericTapChipViewModel])
    /**
     The event will be fired when the data source of the view model had been changed hence the UIVIew needs to show or hide the header view
     - Parameter dataSource: Represents the new datasource if needed
     */
    func showHeader(with type:TapHorizontalHeaderType)
    /// Will be fired when teh view model thinks the attached view needs to update its  flow layout to properly render the scrolling direction
    func refreshLayout()
    
    /// Call this method when you want to deselct all selected items inside the horizontal list
    func deselectAll()
    /**
     Call this method when you want to change the diting state of the current shown header
     - Parameter to: The new editing satus
     */
    func changeHeaderEditingStatus(to:Bool)
    /**
     Call this method when you want to delete a cell
     - Parameter at index: The index of the cell to be deleted
     */
    func deleteCell(at index:Int)
    
    /**
     Will be fired you want to hide or show the right button accessory
     - Parameter show: Indicate whether to show the button or hide it
     */
    func shouldShowRightButton(show:Bool)
}

/// This is the view model that adjusts and adapts the info shown in any GenericTapHorizontal list. It accepts and arranges different chips view models through one place
@objc public class TapChipHorizontalListViewModel:NSObject {
    
    // Mark:- Variables
    /// Reference to the selected chip protocol to inform th cells upon selection of a cell
    @objc public var selectedChip:GenericTapChipViewModel?
    /// Reference to the list view itself as UI that will be rendered
    internal var listView:TapChipHorizontalList?
    /// Public reference to the list view itself as UI that will be rendered
    @objc public var attachedView:TapChipHorizontalList {
        return listView ?? .init()
    }
    
    /// Represents if the attached view should be visible or not, based on the existence of items inside the list
    @objc public var shouldShow:Bool = false
    
    /// The data source which represents the list of view models to be displayed inside the uicollectionview
    @objc public var dataSource:[GenericTapChipViewModel] = [] {
        didSet{
            if listView == nil {
                listView = .init()
                // Assign the cell delegate
                self.cellDelegate = listView
            }
            // Instruct the list view that ME is the viewmodel of it
            listView?.changeViewMode(with: self)
            // When it is changed, we need to inform the attached view that he needs to reload itself now
            cellDelegate?.reload(new: dataSource)
            assignModelsDelegate()
            shouldShow = dataSource.count > 0
        }
    }
    
    /**
     Deletes a certain cell
     - Parameter viewModel:The view model we want to remove its cell
     - Parameter shouldHideRightButton: If true, the edit button on the right will be invisible after deleting the mentioned chip
     */
    @objc public func deleteCell(with viewModel:GenericTapChipViewModel, shouldShowRightButton:Bool) {
        // make sure the passed view model is part of the data source
        guard dataSource.contains(viewModel),
              let index = dataSource.index(of: viewModel) else { return }
        // Inform the view to perform UI deletion
        //cellDelegate?.deleteCell(at: index)
        // Inform the view to perform UI visibility logic for the right button accessory (e.g. the edit button we may remove it if there is nothing else to remove.)
        cellDelegate?.shouldShowRightButton(show: shouldShowRightButton)
        
        // Delete it from the data source
        dataSource.remove(at: index)
    }
    
    /// Defines what type of header shall we show in the list if any
    @objc public var headerType:TapHorizontalHeaderType = .GatewayListHeader {
        didSet{
            cellDelegate?.showHeader(with: headerType)
        }
    }
    
    /// Attach yourself to this delegate to start getting events fired from this view model and its attached uicollectionview
    @objc public var delegate:TapChipHorizontalListViewModelDelegate?
    
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
    @objc public init(dataSource:[GenericTapChipViewModel], headerType:TapHorizontalHeaderType = .GatewayListHeader, selectedChip:GenericTapChipViewModel? = nil ) {
        super.init()
        defer {
            self.dataSource = dataSource
            self.headerType = headerType
            self.selectedChip = selectedChip
        }
    }
    
    /// Call this method when you want to deselct all selected items inside the horizontal list
    @objc public func deselectAll() {
        cellDelegate?.deselectAll()
    }
    
    
    /**
     Will be fired you want to hide or show the right button accessory
     - Parameter show: Indicate whether to show the button or hide it
     */
    @objc public func shouldShowRightButton(show:Bool) {
        cellDelegate?.shouldShowRightButton(show: show)
    }
    
    /**
     Call this method when the editing mode status had changed and you want to reflect this on all rendered chips
     - Parameter to: If set, then editing mode will
     */
    @objc public func editMode(changed to:Bool) {
        dataSource.forEach{ $0.editMode = to }
        cellDelegate?.changeHeaderEditingStatus(to: to)
    }
    
    /// Creates empty view model, added for convience
    public override init() {}
    
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
    
    /**
     The event will be fired when left button in the header if any is clicked
     - Parameter header: Represents which header was clicked
     */
    internal func leftButtonClicked(for header:TapHorizontalHeaderView) {
        delegate?.headerLeftButtonClicked(in: header.headerType!)
    }
    
    /**
     The event will be fired when right button in the header if any is clicked
     - Parameter header: Represents which header was clicked
     */
    internal func rightButtonClicked(for header:TapHorizontalHeaderView) {
        delegate?.headerRightButtonClicked(in: header.headerType!)
    }
    
    /**
     The event will be fired when end editing button is clicked
     - Parameter header: Represents which header was clicked
     */
    internal func closeEditButtonClicked(for header:TapHorizontalHeaderView) {
        delegate?.headerEndEditingButtonClicked(in: header.headerType!)
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
    @objc public func didSelectItem(at index:Int,selectCell:Bool = false) {
        let selectedViewModel = viewModel(at: index)
        // Make sure we are not in editing mode
        guard !selectedViewModel.editMode else{
            return
        }
        // Inform the view model of the selected cell that he is selected, hence, he will pass this value to his attached UIView
        selectedViewModel.didSelectItem()
        // Inform the main (outer) delegate, that an item had been selected
        delegate?.didSelect(item: selectedViewModel)
        selectedChip = selectedViewModel
        if selectCell {
            self.attachedView.collectionView.selectItem(at: .init(row: index, section: 0), animated: false, scrollPosition: .bottom)
        }
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
    
    private func assignModelsDelegate() {
        dataSource.forEach{ $0.viewModelDelegate = self }
    }
    
    /// Call this method when you think the collectionview needs to update its flow layout to reflect the correct scrolling directions
    @objc public func refreshLayout() {
        cellDelegate?.refreshLayout()
    }
}


extension TapChipHorizontalListViewModel:GenericChipViewModelDelegate {
    func logoutChip(for viewModel: TapLogoutChipViewModel) {
        delegate?.logoutChip(for: viewModel)
    }
    
    func deleteChip(for viewModel: SavedCardCollectionViewCellModel) {
        delegate?.deleteChip(for: viewModel)
    }
    
    func currencyChip(for viewModel: CurrencyChipViewModel) {
        delegate?.currencyChip(for: viewModel)
    }
    
    func applePayAuthoized(for viewModel: ApplePayChipViewCellModel, with token: TapApplePayToken) {
        delegate?.applePayAuthoized(for: viewModel, with: token)
    }
    
    func savedCard(for viewModel: SavedCardCollectionViewCellModel) {
        delegate?.savedCard(for: viewModel)
    }
    
    func gateway(for viewModel: GatewayChipViewModel) {
        delegate?.gateway(for: viewModel)
    }
    
    func goPay(for viewModel: TapGoPayViewModel) {
        delegate?.goPay(for: viewModel)
    }
    
}
