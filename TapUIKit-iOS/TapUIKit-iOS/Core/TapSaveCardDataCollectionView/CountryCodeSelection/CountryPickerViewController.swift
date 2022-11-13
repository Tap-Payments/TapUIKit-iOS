//
//  CountryPickerViewController.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 10/11/2022.
//  Copyright © 2022 Tap Payments. All rights reserved.
//

import UIKit
import CommonDataModelsKit_iOS
import TapThemeManager2020

/// A delegate to listen to events fired from the country code picker controller
internal protocol CountryCodePickerViewControllerDelegate {
    /// Will be called onc ethe user selects a new country
    /// - Parameter country: The selected country by the user
    func didSelect(country:TapCountry)
}

/// The uiviewcontroller used to display the country picker as popup
internal class CountryPickerViewController: UIViewController {
    /// The country picker view
    @IBOutlet var cuntryTableView:CountryPickerTableView!
    /// A delegate to listen to events fired from the country code picker controller
    internal var delegate:CountryCodePickerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    // MARK: - internal methods
    /// Adust the table view with the needed countries
    /// - Parameter with countries: The list of countries to be displayed
    /// - Parameter delegate:A delegate to listen to events fired from the country code picker controller
    internal func configure(with countries:[TapCountry], delegate:CountryCodePickerViewControllerDelegate? = nil) {
        self.cuntryTableView.configure(with: countries, delegate: self)
        self.delegate = delegate
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension CountryPickerViewController:CountryCodePickerTableViewDelegate {
    func didSelect(country: TapCountry) {
        delegate?.didSelect(country: country)
        dismiss(animated: true)
    }
}
