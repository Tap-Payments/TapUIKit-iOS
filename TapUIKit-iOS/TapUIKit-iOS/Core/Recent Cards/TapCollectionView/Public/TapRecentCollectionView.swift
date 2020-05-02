//
//  TapRecentCollectionView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 30/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import SnapKit
import TapThemeManager2020

/// This class represents the UIView that Tap uses to show the list of the recently used card scrollable view
@objc public class TapRecentCollectionView: UIView {

    /// The view model that has the data to be shown inside the view and responsible for firing events
    private var viewModel:TapCardsCollectionViewModel = .init()
    /// The collection view that will be used to show a horizontal scrollable list of recent cards
    private lazy var collectionView:UICollectionView = UICollectionView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /**
     Setupu the view by passing in the viewModel
     - Parameter viewModel: The view model that has the needed info to be shown and rendered inside the view
     */
    @objc public func setup(with viewModel:TapCardsCollectionViewModel) {
        // Save the view
        self.viewModel = viewModel
        // Setup the needed views and constraints
        setupViews()
    }
    
    /// The method that is used to apply the logic of adding, arranging and setting up the constraints of the subviews
    internal func setupViews() {
        // We start by applying the theme
        applyTheme()
        // We add the views now to our main container
        addViews()
        // We add the constraints needed to correctly layout the views
        addConstrains()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    internal func applyTheme() {
        
        // Check if the file exists
        let bundle:Bundle = Bundle(for: type(of: self))
        // Based on the current display mode, we decide which default theme file we will use
        let themeFile:String = (self.traitCollection.userInterfaceStyle == .dark) ? "DefaultDarkTheme" : "DefaultLightTheme"
        // Defensive code to make sure all is loaded correctly
        guard let jsonPath = bundle.path(forResource: themeFile, ofType: "json") else {
            print("TapThemeManager WARNING: Can't find json 'DefaultTheme'")
            return
        }
        // Check if the file is correctly parsable
        guard
            let data = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)),
            let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed),
            let jsonDict = json as? NSDictionary else {
                print("TapThemeManager WARNING: Can't read json 'DefaultTheme' at: \(jsonPath)")
                return
        }
        TapThemeManager.setTapTheme(themeDict: jsonDict)
    }
    
    /// Method used to add and configure the subviews
    internal func addViews() {
        
        // Adjust the flow layout of the collection view by setting the spacing and the scrolling direction
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.estimatedItemSize =  UICollectionViewFlowLayout.automaticSize
        flowLayout.scrollDirection = .horizontal
        // Set some priminarly configurations for the collection view
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = false
        addSubview(collectionView)
        
        // We will ask the view model to register all the needed custom cells to be displayed on our collection view
        viewModel.registerCells(on: collectionView)
    }
    
    /// Method used to setup the needed constraints that will aid to correctly render the sub views
    internal func addConstrains() {
        
        // Make the collection view fills in the passed super view
        collectionView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
        }
    }
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
           super.traitCollectionDidChange(previousTraitCollection)
        // If we are using the default theme, then we will listen to the display mode changes and apply light or dark mode respectively
           applyTheme()
       }
}

// Extension that will implement the needed logic to configure and listen to events coming in the collection voew
extension TapRecentCollectionView:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Ask the view model to tell us what is the number of items we need to show
        return viewModel.numberOfItems()
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Load the generic cell configurator from the view model for the certain index path
        let cellConfig:CellConfigurator = viewModel.cellConfigurator(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: type(of: cellConfig).reuseId, for: indexPath)
        
        // Ask the cell to configure itself
        cellConfig.configure(cell: cell)
        cell.layoutIfNeeded()
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Inform the view model that user selected a certain cell
        viewModel.didSelectItem(at: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // Inform the view model that user deselected a certain cell
        viewModel.didDeSelectItem(at: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        // splace between two cell horizonatally
        return 8
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        // splace between two cell vertically
        return 7
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        // give space top left bottom and right for cells
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
   
}

