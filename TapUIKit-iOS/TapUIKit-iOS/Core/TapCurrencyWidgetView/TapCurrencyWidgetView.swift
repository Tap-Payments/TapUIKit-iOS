//
//  TapCurrencyWidgetView.swift
//  TapUIKit-iOS
//
//  Created by MahmoudShaabanAllam on 24/05/2023.
//  Copyright © 2023 Tap Payments. All rights reserved.
//

import UIKit

class TapCurrencyWidgetView: UIView {


    /// The container view that holds everything from the XIB
    @IBOutlet var containerView: UIView!
    /// The confirm button to change the currency to be accepted by this provider
    @IBOutlet weak var confirmButton: UIButton!
    /// The amount label which displays amount after conversion to be used with this provider
    @IBOutlet weak var amountLabel: UILabel!
    /// The currency View image view which displays currency to be used with this provider
    @IBOutlet weak var currencyImageView: UIImageView!
    /// The hint label  which displays the CurrencyWidget hint
    @IBOutlet weak var hintLabel: UILabel!
    /// The provider image view which displays the provider logo
    @IBOutlet weak var providerImageView: UIImageView!

    
    // Mark:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.containerView = setupXIB()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// When user click on confirm button
    @IBAction func confirmClicked(_ sender: Any) {
    }
    
}
