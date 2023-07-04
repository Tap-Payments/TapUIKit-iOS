//
//  CurrencyTableView.swift
//  TapUIKit-iOS
//
//  Created by MahmoudShaabanAllam on 31/05/2023.
//  Copyright © 2023 Tap Payments. All rights reserved.
//

import UIKit
import TapThemeManager2020

internal class CurrencyTableView: UIView {
    
    /// The container view that holds everything from the XIB
    @IBOutlet var containerView: UIView!
    /// The currency table view reference
    @IBOutlet weak var currencyTable: TapGenericTableView!
    
    /// view model to control currency table view
    var currencyTableViewModel:CurrencyTableViewModel = .init()
    
    /// currency widget view model to control the whole view
    var tapCurrencyWidgetViewModel: TapCurrencyWidgetViewModel?
    
    /// The path to look for theme entry in
    private let themePath = "CurrencyWidget.currencyDropDown"
    
    // Mark:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    func changeViewModel(tapCurrencyWidgetViewModel: TapCurrencyWidgetViewModel) {
        self.tapCurrencyWidgetViewModel = tapCurrencyWidgetViewModel
        currencyTableViewModel.dataSource = tapCurrencyWidgetViewModel.getSupportedCurrenciesOptions().map ({  amountedCurrency in
            let currencyTableCellViewModel = CurrencyTableCellViewModel(amountedCurrency: amountedCurrency, isSingleCell: tapCurrencyWidgetViewModel.getSupportedCurrenciesOptions().count == 1)
            return currencyTableCellViewModel
        })
    }
    
    private func commonInit() {
        self.containerView = setupXIB()
        currencyTableViewModel.delegate = self
        applyTheme()
        configureTheViewModel()
    }
    
    private func configureTheViewModel() {
        currencyTable.changeViewMode(with: currencyTableViewModel)
    }
    
}

// Mark:- Theme methods
extension CurrencyTableView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        backgroundColor = .clear
        currencyTable.tapSeparatorView.isHidden = true
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}


extension CurrencyTableView: TapGenericTableViewModelDelegate {
    func didSelectTable(item viewModel: TapGenericTableCellViewModel) {
    }
    
    func itemClicked(for viewModel: TapGenericTableCellViewModel) {
        guard let viewModel = viewModel as? CurrencyTableCellViewModel, let amountedCurrency =  viewModel.amountedCurrency else {return}
        tapCurrencyWidgetViewModel?.setSelectedAmountCurrency(selectedAmountCurrency: amountedCurrency)
    }
}

