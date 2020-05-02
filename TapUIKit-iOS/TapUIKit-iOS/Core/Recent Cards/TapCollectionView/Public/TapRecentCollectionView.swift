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
    /// States if the view is using the default TAP theme or a custom one
    internal lazy var applyingDefaultTheme:Bool = true
    /// The current theme being applied
    internal var themingDictionary:NSDictionary?
    /// This defines in which path should we look into the theme based on the card input mode
    internal var themePath:String = "recentCards.collectionView"
    /// Defines if we need to apply a theme from our own, default is false. This is used if the caller already applied a theme
    internal lazy var themeAlreadyApplied:Bool = false
    
    internal static var weSetTheTheme:Bool?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /**
     Setupu the view by passing in the viewModel
     - Parameter viewModel: The view model that has the needed info to be shown and rendered inside the view
     - Parameter themeDictionary: Defines the theme needed to be applied as a dictionary if any. Default is nil
     - Parameter jsonTheme: Defines the theme needed to be applied as a json file file name if any. Default is nil
     - Parameter themeAlreadyApplied: Defines if we need to apply a theme from our own, default is false. This is used if the caller already applied a theme
     */
    @objc public func setup(with viewModel:TapCardsCollectionViewModel, themeDictionary:NSDictionary? = nil,jsonTheme:String? = nil,themeAlreadyApplied: Bool = false) {
        // Save the view
        self.viewModel = viewModel
        self.themeAlreadyApplied = themeAlreadyApplied
        // Decide which theme we will use
        if themeAlreadyApplied {
            themingDictionary = TapThemeManager.currentTheme
        }else {
            configureThemeSource(themeDictionary: themingDictionary, jsonTheme: jsonTheme)
        }
        // Kick off the layout inflation
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
        // In here we do listen to the trait collection change event :), this leads to changing the theme based on dark or light mode activated by the user at run time.
         guard applyingDefaultTheme && !themeAlreadyApplied else {
                   // We will do nothing, if the view is using a customised given theme as it should be handled by the caller.
                   return
               }
        // If the view is set to use the default theme, hence, we change the theme based on the dark or light mode is activated
        applyDefaultTheme()
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
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        // splace between two cell horizontally
        return CGFloat(TapThemeManager.numberValue(for: "\(themePath).spaceBetweenCells")?.floatValue ?? 0)
    }
}

extension TapRecentCollectionView {
    /**
       Method used to decide which theme will we use from a given dict, given json or the default one
       - Parameter themeDictionary: Defines the theme needed to be applied as a dictionary if any. Default is nil
       - Parameter jsonTheme: Defines the theme needed to be applied as a json file file name if any. Default is nil
       */
    internal func configureThemeSource(themeDictionary: NSDictionary? = nil, jsonTheme: String? = nil) {
        guard let themeDict = themeSelector(themeDictionary: themeDictionary, jsonTheme: jsonTheme) else {
            // Then we se the default theme
            applyingDefaultTheme = true
            applyDefaultTheme()
            return
        }
        applyingDefaultTheme = false
        themingDictionary = themeDict
    }
    
    /// Internal helper method to apply the default theme
    internal func applyDefaultTheme() {
       // Check if there is a theme already applied
        if themeAlreadyApplied {
            return
        }
        // Check if the file exists
        let bundle:Bundle = Bundle(for: type(of: self))
        guard let jsonDict = loadTheme(from: bundle, lightModeName: "DefaultLightTheme", darkModeName: "DefaultDarkTheme") else {
            return
        }
        
        themingDictionary = jsonDict
        applyingDefaultTheme = true
    }
    
     /// This method is responsible for applying the correct theme and setting and matching the theme attributes
       @objc public func applyTheme(themingDict:NSDictionary? = nil) {
           // Defensive coding to make sure theme is alredy selected before actually applying one
           if !themeAlreadyApplied {
               if let nonNullThemingDict = themingDict {
                   self.themingDictionary = nonNullThemingDict
                   applyingDefaultTheme = false
               }
               guard let nonNullThemingDictionary = themingDictionary else {return}
               TapThemeManager.setTapTheme(themeDict: nonNullThemingDictionary)
           }
           matchThemeAttribtes()
           
       }
    
    /// This method matches the correct ui elements to its theme path inside the theme object
    internal func matchThemeAttribtes() {
       // background color
        self.tap_theme_backgroundColor = ThemeUIColorSelector.init(keyPath: "\(themePath).backgroundColor")
        // The border color
        self.layer.tap_theme_borderColor = ThemeCgColorSelector.init(keyPath: "\(themePath).borderColor")
        // The border width
        self.layer.tap_theme_borderWidth = ThemeCGFloatSelector.init(keyPath: "\(themePath).borderWidth")
        // The border rounded corners
        self.layer.tap_theme_cornerRadious = ThemeCGFloatSelector.init(keyPath: "\(themePath).cornerRadius")
    }
}

