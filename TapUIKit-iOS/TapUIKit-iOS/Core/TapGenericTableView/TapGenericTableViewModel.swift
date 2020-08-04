//
//  TapGenericTableDelegate.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/21/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import class UIKit.UITableView
import class UIKit.UINib
import struct UIKit.CGSize
import class UIKit.NSLayoutConstraint
/// This is the public protocol for outer components to listen to events and data fired from this view model and its attached view
@objc public protocol TapGenericTableViewModelDelegate {
    /**
     The event will be fired when a cell is selected in the attacjed UITableView
     - Parameter viewModel: Represents the attached view model of the selectec cell view
     */
    @objc func didSelectTable(item viewModel:TapGenericTableCellViewModel)
    
    /**
     The event will be fired when the user cliks on an Item cell
     - Parameter viewModel: Represents The attached view model
     */
    @objc func itemClicked(for viewModel:ItemCellViewModel)
    
    //func contentSizeChanged(to newSize:CGSize)
}

/// This is the internal protocol for communication between the view model and its attached UIView
internal protocol TapCellGenericTableViewModelDelegate {
    /**
     The event will be fired when the data source of the view model had been changed hence the UIVIew needds to start updating itself
     - Parameter dataSource: Represents the new datasource if needed
     */
    func reload(new dataSource:[TapGenericTableCellViewModel])
    func reloadRows(at indexPaths:[IndexPath])
}

/// This is the view model that adjusts and adapts the info shown in any Tap Generic TableView. It accepts and arranges different cells view models through one place
@objc public class TapGenericTableViewModel:NSObject {
    
    // Mark:- Private Variables
    
    /// Reference to the table view itself as UI that will be rendered
    internal var tableView: TapGenericTableView?
    
    // Mark:- public Variables
    /// Public Reference to the table view itself as UI that will be rendered
    @objc public var attachedView:TapGenericTableView {
        return tableView ?? .init()
    }
    
    /// The data source which represents the list of view models to be displayed inside the UITableView
    @objc public var dataSource:[TapGenericTableCellViewModel] = [] {
        didSet{
            // When it is changed, we need to inform the attached view that he needs to reload itself now
            cellDelegate?.reload(new: dataSource)
            assignModelsDelegate()
        }
    }
    
    
    /// Used to change the height of the table as per the UI requirments at run time
    @objc public var heightConstraint:NSLayoutConstraint?
    
    /// Attach yourself to this delegate to start getting events fired from this view model and its attached UITableView
    @objc public var delegate:TapGenericTableViewModelDelegate?
    
    /// Attach yourself to this delegare if you are the associated view so you can be instructed by actions you have to do
    internal var cellDelegate:TapCellGenericTableViewModelDelegate?
    
    // Mark:- Public methods
    /**
     Creates the ViewModel and makes it ready for work
     - Parameter dataSource: The list of viewmodels that will be rendered as list of UIViews in the UITableView
     */
    @objc public init(dataSource:[TapGenericTableCellViewModel]) {
        super.init()
        // Create the attached table view instance
        tableView = .init()
        tableView?.translatesAutoresizingMaskIntoConstraints = false
        // Assign self to be the delegate of the table created
        tableView?.changeViewMode(with: self)
        defer {
            self.dataSource = dataSource
        }
    }
    
    /// Creates empty view model, added for convience
    @objc public override init() {super.init()}
    
    // Mark:- Internal methods
    
    /**
     Logic to attach and register all created custom XIB files and classes to a provided table view. Helps in automating the process and no need to do a custom code for each created XIB custom cell.
     - Parameter tableView: The UITableView you want to register all created custom Tap Cells to it
     */
    internal func registerAllXibs(for tableView:UITableView) {
        // Fetch all availble chip cells views
        let tableCellsNames:[String] = TapGenericCellType.allCases.map{ $0.nibName() }
        // For each one of them, register its XIB and class to the provided table view
        tableCellsNames.forEach { cellName in
            // We need to load teh XIB from the correct bundle which  is this bundle
            let bundle = Bundle(for: TapGenericTableCellViewModel.self)
            tableView.register(UINib(nibName: cellName, bundle: bundle), forCellReuseIdentifier: cellName)
        }
    }
    
    /**
     Calclates teh number of sections to be displayed inside the attached tableview
     - Returns: The number of sections  to be displayed
     */
    internal func numberOfSections() -> Int {
        1
    }
    
    /**
     Calclates teh number of items to be displayed for a section
     - Parameter section: The section you want to know the number of items in, default is 0
     - Returns: The number of items  to be displayed in the provided section
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
     Fetches the correct view model associated to a certain cell
     - Parameter index: The position of the cell you want the view model of it
     - Returns: The view model that is associated to the given cell index
     */
    internal func viewModel(at index:Int) -> TapGenericTableCellViewModel {
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
        delegate?.didSelectTable(item: selectedViewModel)
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
     - Parameter tableView: Which collection view we need to display the cell in
     - Parameter indexPath: The posotion of the required cell to be loaded
     - Returns: A subclass of the TapGenericTableCell based on the type of its view model
     */
    internal func dequeuCell(in tableView:UITableView, at indexPath:IndexPath) -> TapGenericTableCell {
        
        // Get the associated view model at the given index
        let currentViewModel = viewModel(at: indexPath.row)
        // Generically fetch the cell at the provided position
        let cell:TapGenericTableCell = tableView.dequeueReusableCell(withIdentifier: currentViewModel.identefier(), for: indexPath) as! TapGenericTableCell
        // Based on the type of the viewmodel we define which subclass the cell will be
        return currentViewModel.correctCellType(for: cell)
    }
    
    private func assignModelsDelegate() {
        dataSource.forEach{ $0.viewModelDelegate = self }
    }
    
    /// Call this method when you think the table view shoud re render itsel to reflect some ui changes
    @objc public func reloadCells() {
        cellDelegate?.reload(new: dataSource)
    }
}


extension TapGenericTableViewModel:TapGenericCellViewModelDelegate {
    func reloadRows(at indexPaths: [IndexPath]) {
        cellDelegate?.reloadRows(at: indexPaths)
    }
    
    func itemClicked(for viewModel: ItemCellViewModel) {
        delegate?.itemClicked(for: viewModel)
    }
}
