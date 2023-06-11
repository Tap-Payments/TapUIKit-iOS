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
        "id": "183",
        "source_id": "src_paypal",
        "name": "PayPal",
        "name_ar": "PayPal",
        "image": "https://back-end.b-cdn.net/payment_methods/paypal.png",
        "payment_type": "web",
        "supported_card_brands": [
        "VISA",
        "MASTERCARD",
        "MAESTRO",
        "VISA_ELECTRON"
        ],
        "supported_currencies": [
        "USD",
        "EUR",
        "GBP"
        ],
        "order_by": 104,
        "cc_markup": 0,
        "asynchronous": false,
        "threeDS": "Y",
        "api_version": 0,
        "api_version_minor": 0,
        "logos": {
        "dark": {
        "svg": "https://tap-assets.b-cdn.net/payment-options/v2/dark/paypal.svg",
        "png": "https://tap-assets.b-cdn.net/payment-options/v2/dark/paypal.png",
        "disabled": {
        "svg": "https://tap-assets.b-cdn.net/payment-options/v2/dark/disabled/paypal.svg",
        "png": "https://tap-assets.b-cdn.net/payment-options/v2/dark/disabled/paypal.png"
        },
        "currency_widget": {
        "svg": "https://tap-assets.b-cdn.net/payment-options/v2/dark/widget/paypal.svg",
        "png": "https://tap-assets.b-cdn.net/payment-options/v2/dark/widget/paypal.png"
        }
        },
        "light": {
        "svg": "https://tap-assets.b-cdn.net/payment-options/v2/light/paypal.svg",
        "png": "https://tap-assets.b-cdn.net/payment-options/v2/light/paypal.png",
        "disabled": {
        "svg": "https://tap-assets.b-cdn.net/payment-options/v2/light/disabled/paypal.svg",
        "png": "https://tap-assets.b-cdn.net/payment-options/v2/light/disabled/paypal.png"
        },
        "currency_widget": {
        "svg": "https://tap-assets.b-cdn.net/payment-options/v2/light/widget/paypal.svg",
        "png": "https://tap-assets.b-cdn.net/payment-options/v2/light/widget/paypal.png"
        }
        },
        "light_colored": {
        "svg": "https://tap-assets.b-cdn.net/payment-options/v2/light_colored/paypal.svg",
        "png": "https://tap-assets.b-cdn.net/payment-options/v2/light_colored/paypal.png",
        "disabled": {
        "svg": "https://tap-assets.b-cdn.net/payment-options/v2/light_colored/disabled/paypal.svg",
        "png": "https://tap-assets.b-cdn.net/payment-options/v2/light_colored/disabled/paypal.png"
        },
        "currency_widget": {
        "svg": "https://tap-assets.b-cdn.net/payment-options/v2/light_colored/widget/paypal.svg",
        "png": "https://tap-assets.b-cdn.net/payment-options/v2/light_colored/widget/paypal.png"
        }
        }
        },
        "payment_order_type": "other",
        "button_style": {
        "background": {
        "light": {
        "base_color": "#1C6DA6",
        "background_colors": [
          "#222D65",
          "#179BD7"
        ]
        },
        "dark": {
        "base_color": "#FFFFFF",
        "background_colors": [
          "#FFFFFF"
        ]
        }
        },
        "title_asset": "https://tap-assets.b-cdn.net/action-button/{theme}/{lang}/paypal"
        },
        "display_name": "PayPal",
        "default_currency": "USD"
        }
        """
        
        let jsonData = JSON.data(using: .utf8)!
        let paymentOption: PaymentOption = try! JSONDecoder().decode(PaymentOption.self, from: jsonData)
        
        
        // create amounted currency
        let convertedAmounts = [AmountedCurrency(.USD, 100, "https://tap-assets.b-cdn.net/currency/v2/light/USD.png"),
                                AmountedCurrency(.EGP, 100, "https://tap-assets.b-cdn.net/currency/v2/light/EGP.png"),
                                AmountedCurrency(.EUR, 100, "https://tap-assets.b-cdn.net/currency/v2/light/EUR.png"),
                                AmountedCurrency(.GBP, 100, "https://tap-assets.b-cdn.net/currency/v2/light/GBP.png")]
        
        let viewModel = TapCurrencyWidgetViewModel(convertedAmounts: convertedAmounts, paymentOption: paymentOption)
        
        // inject view model
        tapCurrencyWidget.changeViewModel(with: viewModel)
        viewModel.setTapCurrencyWidgetViewModelDelegate(delegate: self)
    }
    
}
extension TapCurrencyWidgetViewController: TapCurrencyWidgetViewModelDelegate {
    func confirmClicked(for viewModel: TapUIKit_iOS.TapCurrencyWidgetViewModel) {
        print("Confirm clicked")
    }
}
