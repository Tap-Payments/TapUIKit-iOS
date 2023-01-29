//
//  CustomerContactDataCollectionViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 03/11/2022.
//  Copyright © 2022 Tap Payments. All rights reserved.
//

import Foundation
import UIKit
import CommonDataModelsKit_iOS
import TapThemeManager2020
import LocalisationManagerKit_iOS

/// The view model that controls the customer contact data collection view
@objc public class CustomerContactDataCollectionViewModel:NSObject {
    
    // MARK: Internal variables
    
    /// Reference tot he View used to display the fields data collection for customer when saving a card for tap to be rendered
    internal var customerContactDataCollectionView:CustomerContactDataCollectionView?
    /// Defines which fields should be collected. Accepted format: .email, .phone
    internal var toBeCollectedData:[SaveCardCustomerDataSFieldEnum]
    /// The list of countries the user can select from
    internal var allowedCountries:[TapCountry]
    /// The default country to select on load
    internal var selectedCountry:TapCountry?
    /// The  theme path to theme the country cell
    var themePath:String = "customerDataCollection.countryPicker.countryCell"
    /// The theme configuration for the country picker table view
    internal var configMaker = Config(
        countryNameTextColor: TapThemeManager.colorValue(for: "customerDataCollection.countryPicker.countryCell.titleLabelColor")!,
        countryNameTextFont: TapThemeManager.fontValue(for: "customerDataCollection.countryPicker.countryCell.titleLabelFont")!,
        selectedCountryCodeBackgroundColor: .green,
        closeButtonText: TapLocalisationManager.shared.localisedValue(for: "Common.cancel", with: TapCommonConstants.pathForDefaultLocalisation()), titleTextColor: TapThemeManager.colorValue(for: "customerDataCollection.countryPicker.countryTable.titleColor")!,
        titleFont: TapThemeManager.fontValue(for: "customerDataCollection.countryPicker.countryTable.titleFont")!,
        titleText: TapLocalisationManager.shared.localisedValue(for: "HorizontalHeaders.SaveCardHeader.contactCountryPickerHeader", with: TapCommonConstants.pathForDefaultLocalisation()),
        separatorColor: TapThemeManager.colorValue(for: "tapSeparationLine.backgroundColor")!
    )
    // MARK: Public variables
    
    /// Public Reference tothe View used to display the fields data collection for customer when saving a card for tap to be rendered
    @objc public var attachedView:CustomerContactDataCollectionView {
        return customerContactDataCollectionView ?? .init()
    }
    
    
    // MARK: Public functions
    /// Creates the view model that controls the customer contact data collection view
    /// - Parameter toBeCollectedData: Defines which fields should be collected. Accepted format: .email, .phone
    /// - Parameter allowedCountries: The list of countries the user can select from
    /// - Parameter selectedCountry: The default country to select on load
    public init(toBeCollectedData:[SaveCardCustomerDataSFieldEnum], allowedCountries:[TapCountryCode], selectedCountry:TapCountryCode) {
        self.toBeCollectedData = toBeCollectedData
        self.allowedCountries = TapCountry.getCountryDetails(fromEnums: allowedCountries)
        self.selectedCountry = TapCountry.getCountryDetails(fromEnums: [selectedCountry]).first
        super.init()
        defer{
            self.customerContactDataCollectionView = .init()
            self.customerContactDataCollectionView?.setupView(with: self)
            reloadData()
        }
    }
    
    
    // MARK: Internal functions
    /// Reloads and redraws the uiview based on the provided data
    internal func reloadData() {
        // Set the view model
        //customerContactDataCollectionView = .init()
        //customerContactDataCollectionView?.viewModel = self
        
        // update the visbilities of the text fields
        customerContactDataCollectionView?.showHideViews()
        // Adjust the height of the view
        customerContactDataCollectionView?.updateHeight()
        // Adjust the phone country text
        customerContactDataCollectionView?.reloadPhone()
    }
    
    /// Defines what is the height required by this view to show its elements fully
    internal func requiredHeightForFieldsContainer() -> CGFloat {
        // Calculate the needed height of the the text fields
        return 48.0 * CGFloat(toBeCollectedData.count)
    }
    
    /// Defines what is the height required by this view to show its elements fully
    internal func requiredHeight() -> CGFloat {
        // Height for fields
        let heightForFields:CGFloat = requiredHeightForFieldsContainer() + 8
        // The header required height
        let heightForHeader:CGFloat = 30.0
        // The spacing we need
        let spacingRequired:CGFloat = 8.0+16.0
        
        return heightForHeader + heightForFields + spacingRequired
    }
    
    /// Handles the logic needed to be done whenever the user clicks on the country code picker in the UI
    internal func countryPickerClicked() {
        guard let topController:UIViewController = UIViewController.topViewController()
        else { return }
        
        CountryManager.shared.config = configMaker
        CountryManager.shared.localeIdentifier = TapLocalisationManager.shared.localisationLocale ?? "en"
        let countryPicker = CountryPickerViewController()
        
        countryPicker.selectedCountry = selectedCountry?.countryCode.rawValue ?? "KW"
        countryPicker.delegate = self
        topController.present(countryPicker, animated: true)
    }
}


extension CustomerContactDataCollectionViewModel: CountryPickerDelegate {
    public func countryPicker(didSelect country: Country) {
        if  let countryCode:TapCountryCode = TapCountryCode(rawValue: country.isoCode),
            let countryModel:TapCountry = TapCountry.getCountryDetails(fromEnums: [countryCode]).first {
            selectedCountry = countryModel
            customerContactDataCollectionView?.reloadPhone()
        }
    }
    
}

internal extension UIViewController {
    static func topViewController(_ viewController: UIViewController? = nil) -> UIViewController? {
        let viewController = viewController ?? UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        
        if let navigationController = viewController as? UINavigationController,
           !navigationController.viewControllers.isEmpty
        {
            return self.topViewController(navigationController.viewControllers.last)
            
        } else if let tabBarController = viewController as? UITabBarController,
                  let selectedController = tabBarController.selectedViewController
        {
            return self.topViewController(selectedController)
            
        } else if let presentedController = viewController?.presentedViewController {
            return self.topViewController(presentedController)
            
        }
        
        return viewController
    }
}

/// An extension to allow creatung full county details from the country iso enums only
internal extension TapCountry {
    
    /// Creates a full country details based
    static func getCountryDetails(fromEnums:[TapCountryCode]) -> [TapCountry] {
        
        var countries:[TapCountry] = []
        
        // Convert each coutry iso code to full county details
        fromEnums.forEach { countryCode in
            // get the calling code
            let callingCode:String      = getCountryPhonceCode(countryCode: countryCode)
            // get the localised names
            if let englishName:String   = Locale(identifier: "en_US").localizedString(forRegionCode: countryCode.rawValue),
               let arabicName:String    = Locale(identifier: "ar_US").localizedString(forRegionCode: countryCode.rawValue) {
                // Create a country object out of it
                countries.append(.init(nameAR: arabicName, nameEN: englishName, code: callingCode, phoneLength: 8, countryCode: countryCode))
            }
        }
        
        return countries
    }
    
    
    static func getCountryPhonceCode (countryCode: TapCountryCode) -> String
    {
        let countryDictionary  = ["AF":"93",
                                  "AL":"355",
                                  "DZ":"213",
                                  "AS":"1",
                                  "AD":"376",
                                  "AO":"244",
                                  "AI":"1",
                                  "AG":"1",
                                  "AR":"54",
                                  "AM":"374",
                                  "AW":"297",
                                  "AU":"61",
                                  "AT":"43",
                                  "AZ":"994",
                                  "BS":"1",
                                  "BH":"973",
                                  "BD":"880",
                                  "BB":"1",
                                  "BY":"375",
                                  "BE":"32",
                                  "BZ":"501",
                                  "BJ":"229",
                                  "BM":"1",
                                  "BT":"975",
                                  "BA":"387",
                                  "BW":"267",
                                  "BR":"55",
                                  "IO":"246",
                                  "BG":"359",
                                  "BF":"226",
                                  "BI":"257",
                                  "KH":"855",
                                  "CM":"237",
                                  "CA":"1",
                                  "CV":"238",
                                  "KY":"345",
                                  "CF":"236",
                                  "TD":"235",
                                  "CL":"56",
                                  "CN":"86",
                                  "CX":"61",
                                  "CO":"57",
                                  "KM":"269",
                                  "CG":"242",
                                  "CK":"682",
                                  "CR":"506",
                                  "HR":"385",
                                  "CU":"53",
                                  "CY":"537",
                                  "CZ":"420",
                                  "DK":"45",
                                  "DJ":"253",
                                  "DM":"1",
                                  "DO":"1",
                                  "EC":"593",
                                  "EG":"20",
                                  "SV":"503",
                                  "GQ":"240",
                                  "ER":"291",
                                  "EE":"372",
                                  "ET":"251",
                                  "FO":"298",
                                  "FJ":"679",
                                  "FI":"358",
                                  "FR":"33",
                                  "GF":"594",
                                  "PF":"689",
                                  "GA":"241",
                                  "GM":"220",
                                  "GE":"995",
                                  "DE":"49",
                                  "GH":"233",
                                  "GI":"350",
                                  "GR":"30",
                                  "GL":"299",
                                  "GD":"1",
                                  "GP":"590",
                                  "GU":"1",
                                  "GT":"502",
                                  "GN":"224",
                                  "GW":"245",
                                  "GY":"595",
                                  "HT":"509",
                                  "HN":"504",
                                  "HU":"36",
                                  "IS":"354",
                                  "IN":"91",
                                  "ID":"62",
                                  "IQ":"964",
                                  "IE":"353",
                                  "IL":"972",
                                  "IT":"39",
                                  "JM":"1",
                                  "JP":"81",
                                  "JO":"962",
                                  "KZ":"77",
                                  "KE":"254",
                                  "KI":"686",
                                  "KW":"965",
                                  "KG":"996",
                                  "LV":"371",
                                  "LB":"961",
                                  "LS":"266",
                                  "LR":"231",
                                  "LI":"423",
                                  "LT":"370",
                                  "LU":"352",
                                  "MG":"261",
                                  "MW":"265",
                                  "MY":"60",
                                  "MV":"960",
                                  "ML":"223",
                                  "MT":"356",
                                  "MH":"692",
                                  "MQ":"596",
                                  "MR":"222",
                                  "MU":"230",
                                  "YT":"262",
                                  "MX":"52",
                                  "MC":"377",
                                  "MN":"976",
                                  "ME":"382",
                                  "MS":"1",
                                  "MA":"212",
                                  "MM":"95",
                                  "NA":"264",
                                  "NR":"674",
                                  "NP":"977",
                                  "NL":"31",
                                  "AN":"599",
                                  "NC":"687",
                                  "NZ":"64",
                                  "NI":"505",
                                  "NE":"227",
                                  "NG":"234",
                                  "NU":"683",
                                  "NF":"672",
                                  "MP":"1",
                                  "NO":"47",
                                  "OM":"968",
                                  "PK":"92",
                                  "PW":"680",
                                  "PA":"507",
                                  "PG":"675",
                                  "PY":"595",
                                  "PE":"51",
                                  "PH":"63",
                                  "PL":"48",
                                  "PT":"351",
                                  "PR":"1",
                                  "QA":"974",
                                  "RO":"40",
                                  "RW":"250",
                                  "WS":"685",
                                  "SM":"378",
                                  "SA":"966",
                                  "SN":"221",
                                  "RS":"381",
                                  "SC":"248",
                                  "SL":"232",
                                  "SG":"65",
                                  "SK":"421",
                                  "SI":"386",
                                  "SB":"677",
                                  "ZA":"27",
                                  "GS":"500",
                                  "ES":"34",
                                  "LK":"94",
                                  "SD":"249",
                                  "SR":"597",
                                  "SZ":"268",
                                  "SE":"46",
                                  "CH":"41",
                                  "TJ":"992",
                                  "TH":"66",
                                  "TG":"228",
                                  "TK":"690",
                                  "TO":"676",
                                  "TT":"1",
                                  "TN":"216",
                                  "TR":"90",
                                  "TM":"993",
                                  "TC":"1",
                                  "TV":"688",
                                  "UG":"256",
                                  "UA":"380",
                                  "AE":"971",
                                  "GB":"44",
                                  "US":"1",
                                  "UY":"598",
                                  "UZ":"998",
                                  "VU":"678",
                                  "WF":"681",
                                  "YE":"967",
                                  "ZM":"260",
                                  "ZW":"263",
                                  "BO":"591",
                                  "BN":"673",
                                  "CC":"61",
                                  "CD":"243",
                                  "CI":"225",
                                  "FK":"500",
                                  "GG":"44",
                                  "VA":"379",
                                  "HK":"852",
                                  "IR":"98",
                                  "IM":"44",
                                  "JE":"44",
                                  "KP":"850",
                                  "KR":"82",
                                  "LA":"856",
                                  "LY":"218",
                                  "MO":"853",
                                  "MK":"389",
                                  "FM":"691",
                                  "MD":"373",
                                  "MZ":"258",
                                  "PS":"970",
                                  "PN":"872",
                                  "RE":"262",
                                  "RU":"7",
                                  "BL":"590",
                                  "SH":"290",
                                  "KN":"1",
                                  "LC":"1",
                                  "MF":"590",
                                  "PM":"508",
                                  "VC":"1",
                                  "ST":"239",
                                  "SO":"252",
                                  "SJ":"47",
                                  "SY":"963",
                                  "TW":"886",
                                  "TZ":"255",
                                  "TL":"670",
                                  "VE":"58",
                                  "VN":"84",
                                  "VG":"284",
                                  "VI":"340"]
        if let countryCode = countryDictionary[countryCode.rawValue] {
            return countryCode
        }
        return ""
    }
}
