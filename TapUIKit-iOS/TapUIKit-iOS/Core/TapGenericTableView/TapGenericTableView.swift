//
//  TapGenericTableView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/21/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020

/// Represents Tap representation of a Table view
class TapGenericTableView: UIView {

    // Mark:- Variables
    
    /// The reference to the backbone tableview used
    @IBOutlet weak var tableView: UITableView!
    /// The content view that holds all inner views inside the view
    @IBOutlet weak var contentView:UIView!
    
    /// Keeps track of the last applied theme value
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    
    /// The view model that controls the data to be displayed and the events to be fired
    public var viewModel:TapGenericTableViewModel = .init() {
        didSet{
            // Whenever the view model is assigned, we delcare ourself as the cell delegate to start getting orders
            viewModel.cellDelegate = self
        }
    }
    
    /// Represents the theme path to look for to UI this list
    private let themePath:String = "itemsList"
    
    // Mark:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    /// The method handles the logic needed to update the displayed items and their statuses upon request
    private func reloadData() {
        tableView.reloadSections([0], with: .fade)
    }
    
    // Mark:- Public methods
    
    /**
     This instructs the view that we need to assign a new view model
     - Parameter viewModel: The view model you want to attach to the vie
     */
    public func changeViewMode(with viewModel:TapGenericTableViewModel) {
        self.viewModel = viewModel
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = bounds
    }
    
    // Mark:- Private methods
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        // First thing we load the XIB file and attach it to the curren view
        self.contentView = setupXIB()
        // Second, theme it please!
        applyTheme()
        // Third, we do all the configurations needed as one time setup to our collection view
        configureTableView()
    }
    
    /// All the configurations needed as one time setup to our table view
    private func configureTableView() {
        
        // Attach and register all created generic cells to the table view
        viewModel.registerAllXibs(for: tableView)
        
        // Declare ourself as the data source and delegae for the table view
        tableView.dataSource = self
        tableView.delegate = self
    }

}

extension TapGenericTableView:TapCellGenericTableViewModelDelegate {
    
    func reload(new dataSource: [TapGenericTableCellViewModel]) {
        reloadData()
    }
}



// Mark:- Theme methods
extension TapGenericTableView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        self.tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        
        guard lastUserInterfaceStyle != self.traitCollection.userInterfaceStyle else {
            return
        }
        lastUserInterfaceStyle = self.traitCollection.userInterfaceStyle
        applyTheme()
    }
}


extension TapGenericTableView:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(for: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = viewModel.viewModel(at: indexPath.row)
        let cell:TapGenericTableCell = viewModel.dequeuCell(in: tableView, at: indexPath)
        cell.configureCell(with: model)
        return cell
    }
}