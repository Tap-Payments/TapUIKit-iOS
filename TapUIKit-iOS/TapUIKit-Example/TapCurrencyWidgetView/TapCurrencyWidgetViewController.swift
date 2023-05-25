//
//  TapCurrencyWidgetViewController.swift
//  TapUIKit-Example
//
//  Created by MahmoudShaabanAllam on 24/05/2023.
//  Copyright © 2023 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS

class TapCurrencyWidgetViewController: UIViewController {
    
    
    @IBOutlet weak var tapCurrencyWidget: TapCurrencyWidgetView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // create payment option
        let JSON = """
        {
                "id": "50",
                "name": "OMANNET",
                "name_ar": "OMANNET",
                "image": "https://back-end.b-cdn.net/payment_methods/omannet.png",
                "payment_type": "card",
                "supported_card_brands": [
                  "OMANNET",
                  "OMAN_NET"
                ],
                "supported_currencies": [
                  "OMR"
                ],
                "order_by": 22,
                "cc_markup": 0,
                "asynchronous": false,
                "threeDS": "Y",
                "api_version": 0,
                "api_version_minor": 0,
                "logos": {
                  "dark": {
                    "svg": "https://tap-assets.b-cdn.net/payment-options/v2/dark/omannet.svg",
                    "png": "https://tap-assets.b-cdn.net/payment-options/v2/dark/omannet.png",
                    "disabled": {
                      "svg": "https://tap-assets.b-cdn.net/payment-options/v2/dark/disabled/omannet.svg",
                      "png": "https://tap-assets.b-cdn.net/payment-options/v2/dark/disabled/omannet.png"
                    },
                    "currency_widget": {
                      "svg": "https://tap-assets.b-cdn.net/payment-options/v2/dark/widget/omannet.svg",
                      "png": "https://tap-assets.b-cdn.net/payment-options/v2/dark/widget/omannet.png"
                    }
                  },
                  "light": {
                    "svg": "https://tap-assets.b-cdn.net/payment-options/v2/light/omannet.svg",
                    "png": "https://tap-assets.b-cdn.net/payment-options/v2/light/omannet.png",
                    "disabled": {
                      "svg": "https://tap-assets.b-cdn.net/payment-options/v2/light/disabled/omannet.svg",
                      "png": "https://tap-assets.b-cdn.net/payment-options/v2/light/disabled/omannet.png"
                    },
                    "currency_widget": {
                      "svg": "https://tap-assets.b-cdn.net/payment-options/v2/light/widget/omannet.svg",
                      "png": "https://tap-assets.b-cdn.net/payment-options/v2/light/widget/omannet.png"
                    }
                  },
                  "light_colored": {
                    "svg": "https://tap-assets.b-cdn.net/payment-options/v2/light_colored/omannet.svg",
                    "png": "https://tap-assets.b-cdn.net/payment-options/v2/light_colored/omannet.png",
                    "disabled": {
                      "svg": "https://tap-assets.b-cdn.net/payment-options/v2/light_colored/disabled/omannet.svg",
                      "png": "https://tap-assets.b-cdn.net/payment-options/v2/light_colored/disabled/omannet.png"
                    },
                    "currency_widget": {
                      "svg": "https://tap-assets.b-cdn.net/payment-options/v2/light_colored/widget/omannet.svg",
                      "png": "https://tap-assets.b-cdn.net/payment-options/v2/light_colored/widget/omannet.png"
                    }
                  }
                },
                "button_style": {
                  "background": {
                    "light": {
                      "base_color": "#000000",
                      "background_colors": [
                        "#000000"
                      ]
                    },
                    "dark": {
                      "base_color": "#FFFFFF",
                      "background_colors": [
                        "#FFFFFF"
                      ]
                    }
                  },
                  "title_asset": "https://tap-assets.b-cdn.net/action-button/{theme}/{lang}/omannet"
                },
                "payment_order_type": "card",
                "display_name": "OmanNet",
                "default_currency": "OMR"
              }
        """
        
        let jsonData = JSON.data(using: .utf8)!
        let paymentOption: PaymentOption = try! JSONDecoder().decode(PaymentOption.self, from: jsonData)
        
        
        // create amounted currency
        let amountedCurrency = AmountedCurrency(.USD, 100, "https://tap-assets.b-cdn.net/payment-options/v2/light/disabled/benefit.png")
        
        let viewModel = TapCurrencyWidgetViewModel(convertedAmount: amountedCurrency, paymentOption: paymentOption)
        
        // inject view model
        tapCurrencyWidget.changeViewModel(with: viewModel)
        viewModel.setTapCurrencyWidgetViewModelDelegate(delegate: self)
    }
    
}
extension TapCurrencyWidgetViewController: TapCurrencyWidgetViewModelDelegate {
    func confirmClicked() {
        print("Clicked")
    }
}
