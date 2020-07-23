//
//  ExampleWallOfGloryViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 6/10/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS
import TapApplePayKit_iOS
import CommonDataModelsKit_iOS
import LocalisationManagerKit_iOS
import TapCardVlidatorKit_iOS
import TapCardInputKit_iOS
import TapCardScanner_iOS
import AVFoundation
import WebKit

class ExampleWallOfGloryViewController: UIViewController {
    
    var delegate:ToPresentAsPopupViewControllerDelegate?
    @IBOutlet weak var tapVerticalView: TapVerticalView!
    var tapItemsTableViewModel:TapGenericTableViewModel = .init()
    var tapMerchantHeaderViewModel:TapMerchantHeaderViewModel = .init()
    var tapAmountSectionViewModel:TapAmountSectionViewModel = .init()
    var tapGatewayChipHorizontalListViewModel:TapChipHorizontalListViewModel = .init()
    var tapCurrienciesChipHorizontalListViewModel:TapChipHorizontalListViewModel = .init()
    var gatewayChipsViewModel:[GenericTapChipViewModel] = []
    var currenciesChipsViewModel:[CurrencyChipViewModel] = []
    let tapCardPhoneListViewModel:TapCardPhoneBarListViewModel = .init()
    var tapCardPhoneListDataSource:[TapCardPhoneIconViewModel] = []
    let goPayBarViewModel:TapGoPayLoginBarViewModel = .init(countries: [.init(nameAR: "الكويت", nameEN: "Kuwait", code: "965", phoneLength: 8),.init(nameAR: "مصر", nameEN: "Egypt", code: "20", phoneLength: 10),.init(nameAR: "البحرين", nameEN: "Bahrain", code: "973", phoneLength: 8)])
    let tapActionButtonViewModel: TapActionButtonViewModel = .init()
    let tapSaveCardSwitchViewModel: TapSwitchViewModel = .init(mainSwitch: TapSwitchModel(title: "For faster and easier checkout,save your mobile number.", subtitle: ""), goPaySwitch: TapSwitchModel(title: "Save for goPay Checkouts", subtitle: "By enabling goPay, your mobile number will be saved with Tap Payments to get faster and more secure checkouts in multiple apps and websites.", notes: "Please check your email or SMS’s in order to complete the goPay Checkout signup process."))
    
    var views:[UIView] = []
    var gatewaysListView:TapChipHorizontalList = .init()
    var currencyListView:TapChipHorizontalList = .init()
    var tabItemsTableView: TapGenericTableView = .init()
    var tapCardTelecomPaymentView: TapCardTelecomPaymentView = .init()
    var dragView:TapDragHandlerView = .init()
    var merchantHeaderView:TapMerchantHeaderView = .init()
    var amountSectionView:TapAmountSectionView = .init()
    var tapSaveCardSwitchView:TapSwitchView = .init()
    
    var rates:[String:Double] = [:]
    var loadedWebPages:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tapVerticalView.delegate = self
        // Do any additional setup after loading the view.
        tapVerticalView.updateKeyBoardHandling(with: true)
        createDefaultViewModels()
        // Setting up the number of lines and doing a word wrapping
        UILabel.appearance(whenContainedInInstancesOf:[UIAlertController.self]).numberOfLines = 2
        UILabel.appearance(whenContainedInInstancesOf:[UIAlertController.self]).lineBreakMode = .byWordWrapping
        addGloryViews()
    }
    
    func createDefaultViewModels() {
        tapMerchantHeaderViewModel = .init(subTitle: "Tap Payments", iconURL: "https://avatars3.githubusercontent.com/u/19837565?s=200&v=4")
        tapAmountSectionViewModel = .init(originalTransactionAmount: 10000, originalTransactionCurrency: .USD, numberOfItems: 10)
        
        tapMerchantHeaderViewModel.delegate = self
        tapAmountSectionViewModel.delegate = self
        
        tapActionButtonViewModel.buttonStatus = .InvalidPayment
        
        
        createTabBarViewModel()
        createGatewaysViews()
        createItemsViewModel()
    }
    
    func createTabBarViewModel() {
        tapCardPhoneListDataSource.append(.init(associatedCardBrand: .visa, tapCardPhoneIconUrl: "https://img.icons8.com/color/2x/visa.png"))
        tapCardPhoneListDataSource.append(.init(associatedCardBrand: .masterCard, tapCardPhoneIconUrl: "https://img.icons8.com/color/2x/mastercard.png"))
        tapCardPhoneListDataSource.append(.init(associatedCardBrand: .americanExpress, tapCardPhoneIconUrl: "https://img.icons8.com/color/2x/amex.png"))
        tapCardPhoneListDataSource.append(.init(associatedCardBrand: .mada, tapCardPhoneIconUrl: "https://i.ibb.co/S3VhxmR/796px-Mada-Logo-svg.png"))
        tapCardPhoneListDataSource.append(.init(associatedCardBrand: .viva, tapCardPhoneIconUrl: "https://i.ibb.co/cw5y89V/unnamed.png"))
        tapCardPhoneListDataSource.append(.init(associatedCardBrand: .wataniya, tapCardPhoneIconUrl: "https://i.ibb.co/PCYd8Xm/ooredoo-3x.png"))
        tapCardPhoneListDataSource.append(.init(associatedCardBrand: .zain, tapCardPhoneIconUrl: "https://i.ibb.co/mvkJXwF/zain-3x.png"))
        
        tapCardPhoneListViewModel.dataSource = tapCardPhoneListDataSource
    }
    
    func createItemsViewModel() {
        var itemsModels:[ItemCellViewModel] = []
        for i in 1...Int.random(in: 3..<20) {
            var itemTitle:String = "Item Title # \(i)"
            if i % 5 == 4 {
                itemTitle = "VERY LOOOOOOOOOOOOOONG ITEM TITLE Item Title # \(i)"
            }
            let itemDescriptio:String = "Item Description # \(i)"
            let itemPrice:Double = Double.random(in: 10..<4000)
            let itemQuantity:Int = Int.random(in: 1..<10)
            let itemDiscountValue:Double = Double.random(in: 0..<itemPrice)
            var itemDiscount:DiscountModel? = .init(type: .Fixed, value: itemDiscountValue)
            if i % 5 == 2 {
                itemDiscount = nil
            }
            let itemModel:ItemModel = .init(title: itemTitle, description: itemDescriptio, price: itemPrice, quantity: itemQuantity, discount: itemDiscount)
            itemsModels.append(.init(itemModel: itemModel, originalCurrency:(tapCurrienciesChipHorizontalListViewModel.selectedChip as! CurrencyChipViewModel).currency ))
        }
        
        tapItemsTableViewModel.dataSource = itemsModels
        tapItemsTableViewModel.delegate = self
        let heightConstraint = tabItemsTableView.heightAnchor.constraint(equalToConstant: CGFloat((itemsModels.count+1) * 70))
        heightConstraint.isActive = true
        tapItemsTableViewModel.heightConstraint = heightConstraint
        tabItemsTableView.changeViewMode(with: tapItemsTableViewModel)
        tabItemsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        tapAmountSectionViewModel.numberOfItems = itemsModels.count
        tapAmountSectionViewModel.originalTransactionAmount = itemsModels.reduce(0.0) { (accumlator, viewModel) -> Double in
            return accumlator + viewModel.itemPrice()
        }
    }
    
    
    func addGloryViews() {
        
        
        // The drag handler
        dragView.translatesAutoresizingMaskIntoConstraints = false
        dragView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        views.append(dragView)
        
        // The TapMerchantHeaderView
        merchantHeaderView.translatesAutoresizingMaskIntoConstraints = false
        merchantHeaderView.heightAnchor.constraint(equalToConstant: 55).isActive = true
        views.append(merchantHeaderView)
        merchantHeaderView.changeViewModel(with: tapMerchantHeaderViewModel)
        
        // The TapAmountSectionView
        amountSectionView.translatesAutoresizingMaskIntoConstraints = false
        amountSectionView.heightAnchor.constraint(equalToConstant: 59).isActive = true
        views.append(amountSectionView)
        amountSectionView.changeViewModel(with: tapAmountSectionViewModel)
        
        let vv:UIView = .init()
        vv.translatesAutoresizingMaskIntoConstraints = false
        vv.heightAnchor.constraint(equalToConstant: 36).isActive = true
        vv.backgroundColor = .clear
        //views.append(vv)
        
        // The GatwayListSection
        views.append(gatewaysListView)
        
        // The tab bar section
        tapCardTelecomPaymentView.delegate = self
        tapCardTelecomPaymentView.translatesAutoresizingMaskIntoConstraints = false
        tapCardTelecomPaymentView.tapCardPhoneListViewModel = tapCardPhoneListViewModel
        tapCardTelecomPaymentView.heightAnchor.constraint(equalToConstant: tapCardTelecomPaymentView.requiredHeight()).isActive = true
        tapCardTelecomPaymentView.tapCountry = .init(nameAR: "الكويت", nameEN: "Kuwait", code: "965", phoneLength: 8)
        views.append(tapCardTelecomPaymentView)
        
        // Save Card switch view
        views.append(tapSaveCardSwitchView)
        tapSaveCardSwitchViewModel.delegate = self
        tapSaveCardSwitchView.setup(with: tapSaveCardSwitchViewModel, adjustConstraints: true)
        
        // The button
        self.tapVerticalView.setupActionButton(with: tapActionButtonViewModel)
        self.tapVerticalView.updateSubViews(with: views,and: .none)
    }
    
    
    func showAlert(title:String,message:String) {
        let alertController:UIAlertController = .init(title: title, message: message, preferredStyle: .alert)
        let okAction:UIAlertAction = .init(title: "OK", style: .destructive, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    func createGatewaysViews() {
        currenciesChipsViewModel = [CurrencyChipViewModel.init(currency: .USD),CurrencyChipViewModel.init(currency: .AED),CurrencyChipViewModel.init(currency: .SAR),CurrencyChipViewModel.init(currency: .KWD),CurrencyChipViewModel.init(currency: .BHD),CurrencyChipViewModel.init(currency: .QAR),CurrencyChipViewModel.init(currency: .OMR),CurrencyChipViewModel.init(currency: .EGP),CurrencyChipViewModel.init(currency: .JOD)]
        tapCurrienciesChipHorizontalListViewModel = .init(dataSource: currenciesChipsViewModel, headerType: .NoHeader,selectedChip: currenciesChipsViewModel[0])
        tapCurrienciesChipHorizontalListViewModel.delegate = self
        
        
        let applePayChipViewModel:ApplePayChipViewCellModel = ApplePayChipViewCellModel.init()
        applePayChipViewModel.configureApplePayRequest()
        gatewayChipsViewModel.append(applePayChipViewModel)
        
        gatewayChipsViewModel.append(GatewayChipViewModel.init(title: "KNET", icon: "https://meetanshi.com/media/catalog/product/cache/1/image/925f46717e92fbc24a8e2d03b22927e1/m/a/magento-knet-payment-354x.png"))
        gatewayChipsViewModel.append(GatewayChipViewModel.init(title: "KNET", icon: "https://meetanshi.com/media/catalog/product/cache/1/image/925f46717e92fbc24a8e2d03b22927e1/m/a/magento-knet-payment-354x.png"))
        
        gatewayChipsViewModel.append(GatewayChipViewModel.init(title: "BENEFIT", icon: "https://media-exp1.licdn.com/dms/image/C510BAQG0Pwkl3gsm2w/company-logo_200_200/0?e=2159024400&v=beta&t=ragD_Mg4TUCAiVGiYOmjT2orY1IKEOOe_JEokwkzvaY"))
        gatewayChipsViewModel.append(GatewayChipViewModel.init(title: "BENEFIT", icon: "https://media-exp1.licdn.com/dms/image/C510BAQG0Pwkl3gsm2w/company-logo_200_200/0?e=2159024400&v=beta&t=ragD_Mg4TUCAiVGiYOmjT2orY1IKEOOe_JEokwkzvaY"))
        
        gatewayChipsViewModel.append(GatewayChipViewModel.init(title: "SADAD", icon: "https://www.payfort.com/wp-content/uploads/2017/09/go_glocal_mada_logo_en.png"))
        gatewayChipsViewModel.append(GatewayChipViewModel.init(title: "SADAD", icon: "https://www.payfort.com/wp-content/uploads/2017/09/go_glocal_mada_logo_en.png"))
        
        
        gatewayChipsViewModel.append(TapGoPayViewModel.init(title: "GoPay Clicked"))
        
        gatewayChipsViewModel.append(SavedCardCollectionViewCellModel.init(title: "•••• 1234", icon:"https://img.icons8.com/color/2x/amex.png"))
        gatewayChipsViewModel.append(SavedCardCollectionViewCellModel.init(title: "•••• 5678", icon:"https://img.icons8.com/color/2x/visa.png"))
        gatewayChipsViewModel.append(SavedCardCollectionViewCellModel.init(title: "•••• 9012", icon:"https://img.icons8.com/color/2x/mastercard-logo.png"))
        
        tapGatewayChipHorizontalListViewModel = .init(dataSource: gatewayChipsViewModel, headerType: .GatewayListHeader)
        tapGatewayChipHorizontalListViewModel.delegate = self
        
        
        gatewaysListView.translatesAutoresizingMaskIntoConstraints = false
        gatewaysListView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        gatewaysListView.changeViewMode(with: tapGatewayChipHorizontalListViewModel)
        
        
        
        currencyListView.translatesAutoresizingMaskIntoConstraints = false
        currencyListView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        currencyListView.changeViewMode(with: tapCurrienciesChipHorizontalListViewModel)
    }
    
    
    func showGoPay() {
        
        tapActionButtonViewModel.buttonStatus = .InvalidNext
        
        let signGoPayView: TapGoPaySignInView = .init()
        signGoPayView.delegate = self
        signGoPayView.backgroundColor = .clear
        signGoPayView.translatesAutoresizingMaskIntoConstraints = false
        signGoPayView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        signGoPayView.setup(with: goPayBarViewModel)
        tapAmountSectionViewModel.screenChanged(to: .GoPayView)
        
        self.view.endEditing(true)
        for (index, element) in views.enumerated() {
            if element == gatewaysListView {
                //self.tapVerticalView.updateActionButtonVisibility(to: true)
                self.tapVerticalView.remove(view: element, with: TapVerticalViewAnimationType.none)
                self.tapVerticalView.remove(view: views[index+1], with: TapVerticalViewAnimationType.none)
                self.tapVerticalView.remove(view: views[index+2], with: TapVerticalViewAnimationType.none)
                //self.tapVerticalView.remove(view: tapActionButton, with: TapVerticalViewAnimationType.none)
                views.remove(at: index)
                views.remove(at: index)
                views.remove(at: index)
                //views.removeLast()
                views.append(signGoPayView)
                //views.append(tapActionButton)
                DispatchQueue.main.async{ [weak self] in
                    self?.tapVerticalView.add(view: signGoPayView, with: [TapVerticalViewAnimationType.fadeIn()])
                    //self?.tapVerticalView.add(view: self!.tapActionButton, with: [TapVerticalViewAnimationType.fadeIn()])
                }
                break
            }
        }
        
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


extension ExampleWallOfGloryViewController: TapVerticalViewDelegate {
    
    func innerSizeChanged(to newSize: CGSize, with frame: CGRect) {
        print("DELEGATE CALL BACK WITH SIZE \(newSize) and Frame of :\(frame)")
        guard let delegate = delegate else { return }
        
        delegate.changeHeight(to: newSize.height + frame.origin.y + view.safeAreaBottom)
    }
    
}


extension ExampleWallOfGloryViewController:TapMerchantHeaderViewDelegate {
    func iconClicked() {
        showAlert(title: "Merchant Header", message: "You can make any action needed based on clicking the Profile Logo ;)")
    }
    func merchantHeaderClicked() {
        showAlert(title: "Merchant Header", message: "The user clicked on the header section, do you want me to do anything?")
    }
}


extension ExampleWallOfGloryViewController:TapAmountSectionViewModelDelegate {
    func showItemsClicked() {
        self.view.endEditing(true)
        for (index, element) in views.enumerated() {
            if element == gatewaysListView {
                //self.tapVerticalView.remove(view: element, with: .fadeOut(duration: nil, delay: nil))
                //self.tapVerticalView.updateActionButtonVisibility(to: false)
                self.tapVerticalView.remove(view: element, with: TapVerticalViewAnimationType.none)
                self.tapVerticalView.remove(view: views[index+1], with: TapVerticalViewAnimationType.none)
                self.tapVerticalView.remove(view: views[index+2], with: TapVerticalViewAnimationType.none)
                self.tapVerticalView.hideActionButton()
                //self.tapVerticalView.remove(view: tapActionButton, with: TapVerticalViewAnimationType.none)
                views.remove(at: index)
                views.remove(at: index)
                views.remove(at: index)
                //views.removeLast()
                views.append(currencyListView)
                views.append(tabItemsTableView)
                DispatchQueue.main.async{ [weak self] in
                    self?.tapVerticalView.add(view: self!.currencyListView, with: [TapVerticalViewAnimationType.fadeIn()])
                    self?.tapVerticalView.add(view: self!.tabItemsTableView, with: [TapVerticalViewAnimationType.fadeIn()])
                    self?.tapCurrienciesChipHorizontalListViewModel.refreshLayout()
                }
                break
            }
        }
    }
    
    
    func closeItemsClicked() {
        self.view.endEditing(true)
        for (index, element) in views.enumerated() {
            if element == currencyListView {
                //self.tapVerticalView.remove(view: element, with: .fadeOut(duration: nil, delay: nil))
                //self.tapVerticalView.remove(view: tabItemsTableView, with: .fadeOut(duration: nil, delay: nil))
                //self.tapVerticalView.updateActionButtonVisibility(to: true)
                self.tapVerticalView.remove(view: element, with: TapVerticalViewAnimationType.none)
                self.tapVerticalView.remove(view: tabItemsTableView, with: TapVerticalViewAnimationType.none)
                views.remove(at: index)
                views.remove(at: index)
                views.append(gatewaysListView)
                views.append(tapCardTelecomPaymentView)
                views.append(tapSaveCardSwitchView)
                //views.append(tapActionButton)
                DispatchQueue.main.async{ [weak self] in
                    self?.tapVerticalView.showActionButton()
                    self?.tapVerticalView.add(view: self!.gatewaysListView, with: [TapVerticalViewAnimationType.fadeIn()])
                    self?.tapVerticalView.add(view: self!.tapCardTelecomPaymentView, with: [TapVerticalViewAnimationType.fadeIn()])
                    self?.tapVerticalView.add(view: self!.tapSaveCardSwitchView, with: [TapVerticalViewAnimationType.fadeIn()])
                    //self?.tapVerticalView.add(view: self!.tapActionButton, with: [TapVerticalViewAnimationType.fadeIn()])
                }
                break
            }
        }
    }
    func amountSectionClicked() {
        showAlert(title: "Amount Section", message: "The user clicked on the amount section, do you want me to do anything?")
    }
    
    func closeScannerClicked() {
        self.view.endEditing(true)
        for (index, element) in views.enumerated() {
            if let scannerElement:TapCardScannerView = element as? TapCardScannerView {
                //self.tapVerticalView.remove(view: element, with: .fadeOut(duration: nil, delay: nil))
                //self.tapVerticalView.remove(view: tabItemsTableView, with: .fadeOut(duration: nil, delay: nil))
                scannerElement.killScanner()
                
                self.tapVerticalView.remove(view: scannerElement, with: TapVerticalViewAnimationType.none)
                views.remove(at: index)
                views.remove(at: index-1)
                views.append(gatewaysListView)
                views.append(tapCardTelecomPaymentView)
                views.append(tapSaveCardSwitchView)
                tapAmountSectionViewModel.screenChanged(to: .DefaultView)
                DispatchQueue.main.async{ [weak self] in
                    self?.tapVerticalView.removeAllHintViews()
                    self?.tapVerticalView.showActionButton()
                    self?.tapVerticalView.add(view: self!.gatewaysListView, with: [TapVerticalViewAnimationType.fadeIn()])
                    self?.tapVerticalView.add(view: self!.tapCardTelecomPaymentView, with: [TapVerticalViewAnimationType.fadeIn()])
                    self?.tapVerticalView.add(view: self!.tapSaveCardSwitchView, with: [TapVerticalViewAnimationType.fadeIn()])
                }
                break
            }
        }
    }
    
    
    func closeGoPayClicked() {
        self.view.endEditing(true)
        tapActionButtonViewModel.buttonStatus = .InvalidPayment
        self.changeBlur(to: false)
        for (index, element) in views.enumerated() {
            if let goPayElement:TapGoPaySignInView = element as? TapGoPaySignInView {
                goPayElement.stopOTPTimers()
                //self.tapVerticalView.updateActionButtonVisibility(to: true)
                self.tapVerticalView.remove(view: goPayElement, with: TapVerticalViewAnimationType.none)
                //self.tapVerticalView.remove(view: tapActionButton, with: TapVerticalViewAnimationType.none)
                views.remove(at: index)
                //views.removeLast()
                views.append(gatewaysListView)
                views.append(tapCardTelecomPaymentView)
                views.append(tapSaveCardSwitchView)
                //views.append(tapActionButton)
                tapAmountSectionViewModel.screenChanged(to: .DefaultView)
                DispatchQueue.main.async{ [weak self] in
                    self?.tapVerticalView.removeAllHintViews()
                    self?.tapVerticalView.add(view: self!.gatewaysListView, with: [TapVerticalViewAnimationType.fadeIn()])
                    self?.tapVerticalView.add(view: self!.tapCardTelecomPaymentView, with: [TapVerticalViewAnimationType.fadeIn()])
                    self?.tapVerticalView.add(view: self!.tapSaveCardSwitchView, with: [TapVerticalViewAnimationType.fadeIn()])
                    //self?.tapVerticalView.add(view: self!.tapActionButton, with: [TapVerticalViewAnimationType.fadeIn()])
                }
                break
            }
        }
    }
    
    func showScanner() {
        self.view.endEditing(true)
        for (index, element) in views.enumerated() {
            if element == gatewaysListView {
                self.tapVerticalView.remove(view: element, with: TapVerticalViewAnimationType.none)
                self.tapVerticalView.remove(view: views[index+1], with: TapVerticalViewAnimationType.none)
                self.tapVerticalView.remove(view: views[index+2], with: TapVerticalViewAnimationType.none)
                self.tapVerticalView.hideActionButton()
                let hintViewModel:TapHintViewModel = .init(with: .ReadyToScan)
                let hintView:TapHintView = hintViewModel.createHintView()
                let tapCardScannerView:TapCardScannerView = .init()
                tapCardScannerView.delegate = self
                tapCardScannerView.configureScanner()
                views.remove(at: index)
                views.remove(at: index)
                views.remove(at: index)
                views.append(hintView)
                views.append(tapCardScannerView)
                tapAmountSectionViewModel.screenChanged(to: .ScannerView)
                DispatchQueue.main.async{ [weak self] in
                    self?.tapVerticalView.attach(hintView: hintView, to: TapAmountSectionView.self,with: true)
                    self?.tapVerticalView.add(view: tapCardScannerView, with: [TapVerticalViewAnimationType.fadeIn()],shouldFillHeight: true)
                }
                break
            }
        }
    }
    
    func showWebView(with url:URL) {
       
        let webViewModel:TapWebViewModel = .init()
        webViewModel.delegate = self
        
        let webView:TapWebView = .init()
        webView.setup(with: webViewModel)
       
        self.tapVerticalView.remove(view: merchantHeaderView, with: TapVerticalViewAnimationType.fadeOut())
        self.tapVerticalView.remove(view: amountSectionView, with: TapVerticalViewAnimationType.fadeOut())
        self.tapVerticalView.remove(view: gatewaysListView, with: TapVerticalViewAnimationType.fadeOut())
        self.tapVerticalView.remove(view: tapCardTelecomPaymentView, with: TapVerticalViewAnimationType.fadeOut())
        self.tapVerticalView.remove(view: tapSaveCardSwitchView, with: TapVerticalViewAnimationType.fadeOut())
        self.tapActionButtonViewModel.startLoading()
        views = []
        views.append(webView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self] in
            self?.tapVerticalView.hideActionButton()
            self?.tapVerticalView.add(view: webView, with: [TapVerticalViewAnimationType.fadeIn()],shouldFillHeight: true)
            webViewModel.load(with: url)
        }
    }
    
    
    func closeWebView() {
        self.view.endEditing(true)
        for (_, element) in views.enumerated() {
            if element.isKind(of: TapWebView.self) {
                self.tapVerticalView.remove(view: element, with: TapVerticalViewAnimationType.fadeOut())
                self.tapVerticalView.showActionButton()
            }
            break
        }
        self.tapActionButtonViewModel.startLoading()
        views = []
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self] in
            self?.tapActionButtonViewModel.endLoading(with: true, completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    self?.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
}






extension ExampleWallOfGloryViewController:TapChipHorizontalListViewModelDelegate {
    func currencyChip(for viewModel: CurrencyChipViewModel) {
        
        tapItemsTableViewModel.dataSource.forEach { (genericCellModel) in
            if let itemViewModel:ItemCellViewModel = genericCellModel as? ItemCellViewModel {
                itemViewModel.convertCurrency = viewModel.currency
            }
        }
        
        tapAmountSectionViewModel.convertedTransactionCurrency = viewModel.currency
    }
    
    func applePayAuthoized(for viewModel: ApplePayChipViewCellModel, with token: TapApplePayToken) {
        showAlert(title: " Pay", message: "Token:\n\(token.stringAppleToken ?? "")")
    }
    
    func savedCard(for viewModel: SavedCardCollectionViewCellModel) {
        //showAlert(title: "\(viewModel.title ?? "") clicked", message: "Look we know that you saved the card. We promise we will make you use it soon :)")
        tapActionButtonViewModel.buttonStatus = .ValidPayment
        
        let authenticator = TapAuthenticate(reason: "Login into tap account")
        if authenticator.type != .none {
            tapActionButtonViewModel.buttonStatus = (authenticator.type == BiometricType.faceID) ? .FaceID : .TouchID
            authenticator.delegate = self
            authenticator.authenticate()
        }
    }
    
    func gateway(for viewModel: GatewayChipViewModel) {
        //showAlert(title: "gateway cell clicked", message: "You clicked on a \(viewModel.title ?? ""). In real life example, this will open a web view to complete the payment")
        //tapActionButtonViewModel.buttonStatus = .ValidPayment
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:  TapConstantManager.TapActionSheetStatusNotification), object: nil, userInfo: [TapConstantManager.TapActionSheetStatusNotification:TapActionButtonStatusEnum.ValidPayment] )
        
        let gatewayActionBlock:()->() = { [weak self] in
            self?.showWebView(with: URL(string: "https://www.google.com")!)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:  TapConstantManager.TapActionSheetBlockNotification), object: nil, userInfo: [TapConstantManager.TapActionSheetBlockNotification:gatewayActionBlock] )
    }
    
    func goPay(for viewModel: TapGoPayViewModel) {
        //showAlert(title: "GoPay cell clicked", message: "You clicked on GoPay.")
        showGoPay()
    }
    
    func headerLeftButtonClicked(in headerType: TapHorizontalHeaderType) {
        if headerType == .GatewayListHeader {
            return
        }
    }
    
    func headerRightButtonClicked(in headerType: TapHorizontalHeaderType) {
        if headerType == .GatewayListHeader {
            showAlert(title: "Right button for Gateway Header", message: "I promise you will be able to edit these list afterwards :)")
        }
    }
    
    func didSelect(item viewModel: GenericTapChipViewModel) {
        
    }
    
    
    func handleTelecomPayment(for cardBrand: CardBrand, with validation: CrardInputTextFieldStatusEnum) {
        if validation == .Valid {
            tapActionButtonViewModel.buttonStatus = .ValidPayment
            let payAction:()->() = { self.startPayment(then:true) }
            tapActionButtonViewModel.buttonActionBlock = payAction
        }else {
            tapActionButtonViewModel.buttonStatus = .InvalidPayment
            tapActionButtonViewModel.buttonActionBlock = {}
        }
    }
    
    func handleCardPayment(for cardBrand: CardBrand, with validation: CrardInputTextFieldStatusEnum) {
        if validation == .Valid,
            tapCardTelecomPaymentView.decideHintStatus() == nil {
            tapActionButtonViewModel.buttonStatus = .ValidPayment
            let payAction:()->() = { self.startPayment(then:false) }
            tapActionButtonViewModel.buttonActionBlock = payAction
        }else{
            tapActionButtonViewModel.buttonStatus = .InvalidPayment
            tapActionButtonViewModel.buttonActionBlock = {}
        }
    }
    
    func startPayment(then success:Bool) {
        view.endEditing(true)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(0)) {
            for (index, element) in self.views.enumerated() {
                if element == self.gatewaysListView {
                    self.tapVerticalView.remove(view: element, with: TapVerticalViewAnimationType.none)
                    self.tapVerticalView.remove(view: self.views[index+1], with: TapVerticalViewAnimationType.none)
                    self.views.remove(at: index)
                    self.views.remove(at: index)
                    self.tapActionButtonViewModel.startLoading()
                    break
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(3500)) {
            self.tapActionButtonViewModel.endLoading(with: success, completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500)) {
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
        
        
    }
}

extension ExampleWallOfGloryViewController: TapAuthenticateDelegate {
    func authenticationSuccess() {
        print("authenticationSuccess")
        startPayment(then: true)
    }
    
    func authenticationFailed(with error: Error?) {
        print("authenticationFailed")
        tapActionButtonViewModel.buttonStatus = .ValidPayment
        tapActionButtonViewModel.expandButton()
    }
}


extension ExampleWallOfGloryViewController:TapCardTelecomPaymentProtocol {
   
    func showHint(with status: TapHintViewStatusEnum) {
        let hintViewModel:TapHintViewModel = .init(with: status)
        let hintView:TapHintView = hintViewModel.createHintView()
        tapVerticalView.attach(hintView: hintView, to: TapCardTelecomPaymentView.self,with: true)
    }
    
    func hideHints() {
        tapVerticalView.removeAllHintViews()
    }
    
    func cardDataChanged(tapCard: TapCard) {
        
    }
    
    func brandDetected(for cardBrand: CardBrand, with validation: CrardInputTextFieldStatusEnum) {
        //tapActionButtonViewModel.buttonStatus = (validation == .Valid) ? .ValidPayment : .InvalidPayment
        // Based on the detected brand type we decide the action button status
        if cardBrand.brandSegmentIdentifier == "telecom" {
            handleTelecomPayment(for: cardBrand, with: validation)
        }else if cardBrand.brandSegmentIdentifier == "cards" {
            handleCardPayment(for: cardBrand, with: validation)
        }
    }
    
    func scanCardClicked() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self] response in
            if response {
                //access granted
                DispatchQueue.main.asyncAfter(deadline: .now()) {[weak self] in
                    self?.showScanner()
                }
            }
        }
    }
}


extension ExampleWallOfGloryViewController:TapGenericTableViewModelDelegate {
    func didSelectTable(item viewModel: TapGenericTableCellViewModel) {
        return
    }
    
    func itemClicked(for viewModel: ItemCellViewModel) {
        showAlert(title: viewModel.itemTitle(), message: "You clicked on the item.. Look until now, clicking an item is worthless we are just showcasing 🙂")
    }
}

extension ExampleWallOfGloryViewController:TapInlineScannerProtocl {
    func tapFullCardScannerDimissed() {
        
    }
    
    func tapCardScannerDidFinish(with tapCard: TapCard) {
        
        let hintViewModel:TapHintViewModel = .init(with: .Scanned)
        let hintView:TapHintView = hintViewModel.createHintView()
        tapVerticalView.attach(hintView: hintView, to: TapAmountSectionView.self,with: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500)) { [weak self] in
            self?.closeScannerClicked()
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) { [weak self] in
                self?.tapCardTelecomPaymentView.setCard(with: tapCard)
            }
        }
    }
    
    func tapInlineCardScannerTimedOut(for inlineScanner: TapInlineCardScanner) {
        
    }
    
    
}


extension ExampleWallOfGloryViewController: TapGoPaySignInViewProtocol {
    func countryCodeClicked() {
        
    }
    
    func changeBlur(to:Bool) {
        self.tapVerticalView.backgroundColor = (to) ? try! UIColor(tap_hex: "#f9f9f9C6") : try! UIColor(tap_hex: "#f4f4f4")
    }
    
    func signIn(with email: String, and password: String) {
       demoSigning()
    }
    
    
    func signIn(phone: String, and otp: String) {
        demoSigning()
    }
    
    
    
    func demoSigning() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.tapActionButtonViewModel.startLoading()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(3500)) {
            self.tapActionButtonViewModel.endLoading(with: true, completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500)) {
                    self.closeGoPayClicked()
                    self.tapActionButtonViewModel.buttonStatus = .InvalidPayment
                    self.tapActionButtonViewModel.expandButton()
                }
            })
        }
    }
    
    
}


extension UIView {
    
    var safeAreaBottom: CGFloat {
        if #available(iOS 11, *) {
            if let window = UIApplication.shared.keyWindowInConnectedScenes {
                return window.safeAreaInsets.bottom
            }
        }
        return 0
    }
    
    var safeAreaTop: CGFloat {
        if #available(iOS 11, *) {
            if let window = UIApplication.shared.keyWindowInConnectedScenes {
                return window.safeAreaInsets.top
            }
        }
        return 0
    }
}

extension UIApplication {
    var keyWindowInConnectedScenes: UIWindow? {
        return windows.first(where: { $0.isKeyWindow })
    }
}


extension ExampleWallOfGloryViewController: TapSwitchViewModelDelegate {
    
    func didChangeState(state: TapSwitchEnum) {
        
        self.tapVerticalView.backgroundColor = (state != .none) ? try! UIColor(tap_hex: "#f9f9f9C6") : try! UIColor(tap_hex: "#f4f4f4")
        
        self.tapActionButtonViewModel.buttonStatus = (state == .none) ? .ValidPayment : .SaveValidPayment
        
    }
}

extension ExampleWallOfGloryViewController:TapWebViewModelDelegate {
    func willLoad(request: URLRequest) -> WKNavigationActionPolicy {
        return .allow
    }
    
    func didLoad(url: URL?) {
        loadedWebPages += 1
        if loadedWebPages > 2 {
            closeWebView()
        }
    }
    
    func didFail(with error: Error, for url: URL?) {
        
    }
}
