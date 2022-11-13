//
//  CountryPicker.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 09/11/2022.
//  Copyright © 2022 Tap Payments. All rights reserved.
//

import UIKit
import CommonDataModelsKit_iOS
import SnapKit
import TapThemeManager2020

/// A delegate to listen to events fired from the country code table vew
internal protocol CountryCodePickerTableViewDelegate {
    /// Will be called onc ethe user selects a new country
    /// - Parameter country: The selected country by the user
    func didSelect(country:TapCountry)
}

/// The table view to show the list of counttry codes to select from when collecting user' contact details when saving a card for tap
internal class CountryPickerTableView: UIView {

    /// A delegate to listen to events fired from the country code tableview
    internal var delegate:CountryCodePickerTableViewDelegate?
    /// The view that holds everything
    @IBOutlet var contentView: UIView!
    /// The table view used to display different countries as required
    @IBOutlet weak var tableView: UITableView!
    /// The theme path for the countries table view
    //var themePath:String = "customerDataCollection.countryPicker.countryTable"
    /// The list of countires to select from
    var listOfCountries:[TapCountry] = [] {
        didSet {
            reloadData()
        }
    }
    /// Holds the header view
    @IBOutlet weak var headerView: TapHorizontalHeaderView!
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    /// The theme pathe
    internal let themePath:String = "customerDataCollection"
    
    //MARK: - Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - Public methods
    /// Adust the table view with the needed countries
    /// - Parameter with countries: The list of countries to be displayed
    /// - Parameter delegate:A delegate to listen to events fired from the country code table view
    public func configure(with countries:[TapCountry], delegate: CountryCodePickerTableViewDelegate? = nil) {
        self.listOfCountries = countries
        self.delegate = delegate
    }
    
    // MARK: - Private methods
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.contentView = setupXIB()
        // Adjust the needed values for the table view
        adjustTableViewData()
        // theme
        applyTheme()
    }
    
    /// Adjusts the table view data and content and delegates
    internal func adjustTableViewData() {
        // We need to load the XIB from the correct bundle which  is this bundle
        let bundle = Bundle(for: CountryCodeTableViewCell.self)
        tableView.register(UINib(nibName: TapGenericCellType.CountryCodeCell.nibName(), bundle: bundle), forCellReuseIdentifier: TapGenericCellType.CountryCodeCell.nibName())
        // Set the data source
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        
    }
    
    /// Refreshes the data in the table view and update its height
    internal func reloadData() {
        tableView.reloadData()
        tableView.snp.remakeConstraints { make in
            make.height.equalTo(CGFloat(self.listOfCountries.count) * CountryCodeTableViewCell.hountryCodeTableViewCellHeight)
        }
        tableView.layoutIfNeeded()
    }

}

// MARK: The needed theming extnesions
extension CountryPickerTableView {
    // Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        headerView.headerType = .ContactCountryPickerHeader
        
        // bg colors
        backgroundColor = .clear
        contentView.tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        tableView.tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        
        
        // the border radius
        tableView.layer.tap_theme_cornerRadious = ThemeCGFloatSelector.init(keyPath: "\(themePath).cornerRadius")
        // the shadow
        tableView.clipsToBounds = false
        tableView.layer.masksToBounds = false
        tableView.layer.shadowRadius = CGFloat(TapThemeManager.numberValue(for: "\(themePath).shadow.radius")?.floatValue ?? 0)
        tableView.layer.tap_theme_shadowColor = ThemeCgColorSelector.init(keyPath: "\(themePath).shadow.color")
        tableView.layer.shadowOffset = CGSize(width: CGFloat(TapThemeManager.numberValue(for: "\(themePath).shadow.offsetWidth")?.floatValue ?? 0), height: CGFloat(TapThemeManager.numberValue(for: "\(themePath).shadow.offsetHeight")?.floatValue ?? 0))
        tableView.layer.shadowOpacity = Float(TapThemeManager.numberValue(for: "\(themePath).shadow.opacity")?.floatValue ?? 0)
        
        
        contentView.layer.cornerRadius = 20
        contentView.clipsToBounds = true
        layoutIfNeeded()
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

// MARK: UITable view delegate and data source
extension CountryPickerTableView: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfCountries.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let countryCell:CountryCodeTableViewCell = tableView.dequeueReusableCell(withIdentifier: TapGenericCellType.CountryCodeCell.nibName(), for: indexPath) as?CountryCodeTableViewCell else { return .init() }
        countryCell.configureCell(with: listOfCountries[indexPath.row], shouldShowSeparator: listOfCountries.endIndex > (indexPath.row + 1))
        return countryCell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CountryCodeTableViewCell.hountryCodeTableViewCellHeight
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelect(country: self.listOfCountries[indexPath.row])
    }
}

