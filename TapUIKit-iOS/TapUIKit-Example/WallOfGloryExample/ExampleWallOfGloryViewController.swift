//
//  ExampleWallOfGloryViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 6/10/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS


class ExampleWallOfGloryViewController: UIViewController {
    
    var delegate:ToPresentAsPopupViewControllerDelegate?
    @IBOutlet weak var tapVerticalView: TapVerticalView!
    var tapItemsTableViewModel:TapGenericTableViewModel = .init()
    var tapMerchantViewModel:TapMerchantHeaderViewModel = .init()
    var tapAmountSectionViewModel:TapAmountSectionViewModel = .init()
    var tapGatewayChipHorizontalListViewModel:TapChipHorizontalListViewModel = .init()
    var tapGoPayChipsHorizontalListViewModel:TapChipHorizontalListViewModel = .init()
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    var tapCurrienciesChipHorizontalListViewModel:TapChipHorizontalListViewModel = .init()
    var gatewayChipsViewModel:[GenericTapChipViewModel] = []
    var goPayChipsViewModel:[GenericTapChipViewModel] = []
    var currenciesChipsViewModel:[CurrencyChipViewModel] = []
    let tapCardPhoneListViewModel:TapCardPhoneBarListViewModel = .init()
    var tapCardPhoneListDataSource:[TapCardPhoneIconViewModel] = []
    let goPayBarViewModel:TapGoPayLoginBarViewModel = .init(countries: [.init(nameAR: "الكويت", nameEN: "Kuwait", code: "965", phoneLength: 8),.init(nameAR: "مصر", nameEN: "Egypt", code: "20", phoneLength: 10),.init(nameAR: "البحرين", nameEN: "Bahrain", code: "973", phoneLength: 8)])
    let tapActionButtonViewModel: TapActionButtonViewModel = .init()
    var tapCardTelecomPaymentViewModel: TapCardTelecomPaymentViewModel = .init()
    
    var tapSaveCardSwitchViewModel: TapSwitchViewModel = .init(with: .invalidCard, merchant: "jazeera airways")
    var views:[UIView] = []
    
    var dragView:TapDragHandlerView = .init()

    
    var rates:[String:Double] = [:]
    var loadedWebPages:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tapVerticalView.delegate = self
        // Do any additional setup after  the view.
        tapVerticalView.updateKeyBoardHandling(with: true)
        createDefaultViewModels()
        // Setting up the number of lines and doing a word wrapping
        UILabel.appearance(whenContainedInInstancesOf:[UIAlertController.self]).numberOfLines = 2
        UILabel.appearance(whenContainedInInstancesOf:[UIAlertController.self]).lineBreakMode = .byWordWrapping
        addGloryViews()
    }
    
    func createDefaultViewModels() {
        tapMerchantViewModel = .init(subTitle: "Tap Payments", iconURL: "https://avatars3.githubusercontent.com/u/19837565?s=200&v=4")
        tapAmountSectionViewModel = .init(originalTransactionAmount: 10000, originalTransactionCurrency: .USD, numberOfItems: 10)
        
        tapMerchantViewModel.delegate = self
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
        tapCardTelecomPaymentViewModel = .init(with: tapCardPhoneListViewModel, and: .init(nameAR: "الكويت", nameEN: "Kuwait", code: "965", phoneLength: 8))
        tapCardTelecomPaymentViewModel.delegate = self
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
        
        tapItemsTableViewModel = .init(dataSource: itemsModels)
        tapItemsTableViewModel.delegate = self
        
        //tapItemsTableViewModel.attachedView.changeViewMode(with: tapItemsTableViewModel)
        //tapItemsTableViewModel.attachedView.translatesAutoresizingMaskIntoConstraints = false
        
        tapAmountSectionViewModel.numberOfItems = itemsModels.count
        tapAmountSectionViewModel.originalTransactionAmount = itemsModels.reduce(0.0) { (accumlator, viewModel) -> Double in
            return accumlator + viewModel.itemPrice()
        }
    }
    
    
    func addGloryViews() {
        
        
        // The drag handler
        views.append(dragView)
        
        // The TaptapMerchantHeaderViewModel.attachedView
        views.append(tapMerchantViewModel.attachedView)
        
        // The TapAmountSectionView
        views.append(tapAmountSectionViewModel.attachedView)
//        amountSectionView.changeViewModel(with: tapAmountSectionViewModel)
        
        // The GatwayListSection
        views.append(tapGoPayChipsHorizontalListViewModel.attachedView)
        views.append(tapGatewayChipHorizontalListViewModel.attachedView)
        
        // The tab bar section
        views.append(tapCardTelecomPaymentViewModel.attachedView)
        
        // Save Card switch view
        tapSaveCardSwitchViewModel.delegate = self
        views.append(tapSaveCardSwitchViewModel.attachedView)
        
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
        
        tapGatewayChipHorizontalListViewModel = .init(dataSource: gatewayChipsViewModel, headerType: .GateWayListWithGoPayListHeader)
        tapGatewayChipHorizontalListViewModel.delegate = self
        
        
        goPayChipsViewModel.append(SavedCardCollectionViewCellModel.init(title: "•••• 3333", icon:"https://img.icons8.com/color/2x/amex.png", listSource: .GoPayListHeader))
        goPayChipsViewModel.append(SavedCardCollectionViewCellModel.init(title: "•••• 4444", icon:"https://img.icons8.com/color/2x/visa.png", listSource: .GoPayListHeader))
        goPayChipsViewModel.append(SavedCardCollectionViewCellModel.init(title: "•••• 5555", icon:"https://img.icons8.com/color/2x/mastercard-logo.png", listSource: .GoPayListHeader))
        goPayChipsViewModel.append(TapLogoutChipViewModel())
        
        tapGoPayChipsHorizontalListViewModel = .init(dataSource: goPayChipsViewModel, headerType: .GoPayListHeader)
        tapGoPayChipsHorizontalListViewModel.delegate = self
        
        
        //tapGatewayChipHorizontalListViewModel.attachedView.changeViewMode(with: tapGatewayChipHorizontalListViewModel)
        //tapGoPayChipsHorizontalListViewModel.attachedView.changeViewMode(with: tapGoPayChipsHorizontalListViewModel)
        //currencyListView.changeViewMode(with: tapCurrienciesChipHorizontalListViewModel)
    }
    
    
    func showGoPay() {
        
        tapActionButtonViewModel.buttonStatus = .InvalidNext
        
        let signGoPayView: TapGoPaySignInView = .init()
        signGoPayView.delegate = self
        signGoPayView.backgroundColor = .clear
        
        
        signGoPayView.setup(with: goPayBarViewModel)
        tapAmountSectionViewModel.screenChanged(to: .GoPayView)
        
        self.view.endEditing(true)
        for (index, element) in views.enumerated() {
            if element == tapGatewayChipHorizontalListViewModel.attachedView {
                //self.tapVerticalView.updateActionButtonVisibility(to: true)
                self.tapVerticalView.remove(view: views[index-1], with: TapVerticalViewAnimationType.none)
                self.tapVerticalView.remove(view: element, with: TapVerticalViewAnimationType.none)
                self.tapVerticalView.remove(view: views[index+1], with: TapVerticalViewAnimationType.none)
                self.tapVerticalView.remove(view: views[index+2], with: TapVerticalViewAnimationType.none)
                //self.tapVerticalView.remove(view: tapActionButton, with: TapVerticalViewAnimationType.none)
                views.remove(at: index)
                views.remove(at: index)
                views.remove(at: index)
                views.remove(at: (index-1))
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
            if element == tapGatewayChipHorizontalListViewModel.attachedView {
                //self.tapVerticalView.remove(view: element, with: .fadeOut(duration: nil, delay: nil))
                //self.tapVerticalView.updateActionButtonVisibility(to: false)
                self.tapVerticalView.remove(view: views[index-1], with: TapVerticalViewAnimationType.none)
                self.tapVerticalView.remove(view: element, with: TapVerticalViewAnimationType.none)
                self.tapVerticalView.remove(view: views[index+1], with: TapVerticalViewAnimationType.none)
                self.tapVerticalView.remove(view: views[index+2], with: TapVerticalViewAnimationType.none)
                self.tapVerticalView.hideActionButton()
                //self.tapVerticalView.remove(view: tapActionButton, with: TapVerticalViewAnimationType.none)
                views.remove(at: index)
                views.remove(at: index)
                views.remove(at: index)
                views.remove(at: (index-1))
                //views.removeLast()
                views.append(tapCurrienciesChipHorizontalListViewModel.attachedView)
                views.append(tapItemsTableViewModel.attachedView)
                DispatchQueue.main.async{ [weak self] in
                    self?.tapVerticalView.add(views: [self!.tapCurrienciesChipHorizontalListViewModel.attachedView,self!.tapItemsTableViewModel.attachedView], with: [TapVerticalViewAnimationType.fadeIn()])
                    self?.tapCurrienciesChipHorizontalListViewModel.refreshLayout()
                }
                break
            }
        }
    }
    
    
    func closeItemsClicked() {
        self.view.endEditing(true)
        for (index, element) in views.enumerated() {
            if element == tapCurrienciesChipHorizontalListViewModel.attachedView {
                //self.tapVerticalView.remove(view: element, with: .fadeOut(duration: nil, delay: nil))
                //self.tapVerticalView.remove(view: tapItemsTableViewModel.attachedView, with: .fadeOut(duration: nil, delay: nil))
                //self.tapVerticalView.updateActionButtonVisibility(to: true)
                self.tapVerticalView.remove(view: element, with: TapVerticalViewAnimationType.none)
                self.tapVerticalView.remove(view: tapItemsTableViewModel.attachedView, with: TapVerticalViewAnimationType.none)
                views.remove(at: index)
                views.remove(at: index)
                views.append(tapGoPayChipsHorizontalListViewModel.attachedView)
                views.append(tapGatewayChipHorizontalListViewModel.attachedView)
                views.append(tapCardTelecomPaymentViewModel.attachedView)
                views.append(tapSaveCardSwitchViewModel.attachedView)
                //views.append(tapActionButton)
                DispatchQueue.main.async{ [weak self] in
                    self?.tapVerticalView.showActionButton()
                    self?.tapVerticalView.add(views: [self!.tapGoPayChipsHorizontalListViewModel.attachedView,self!.tapGatewayChipHorizontalListViewModel.attachedView,self!.tapCardTelecomPaymentViewModel.attachedView,self!.tapSaveCardSwitchViewModel.attachedView], with: [TapVerticalViewAnimationType.fadeIn()])
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
                //self.tapVerticalView.remove(view: tapItemsTableViewModel.attachedView, with: .fadeOut(duration: nil, delay: nil))
                scannerElement.killScanner()
                
                self.tapVerticalView.remove(view: scannerElement, with: TapVerticalViewAnimationType.none)
                views.remove(at: index)
                views.remove(at: index-1)
                views.append(tapGoPayChipsHorizontalListViewModel.attachedView)
                views.append(tapGatewayChipHorizontalListViewModel.attachedView)
                views.append(tapCardTelecomPaymentViewModel.attachedView)
                views.append(tapSaveCardSwitchViewModel.attachedView)
                tapAmountSectionViewModel.screenChanged(to: .DefaultView)
                DispatchQueue.main.async{ [weak self] in
                    self?.tapVerticalView.removeAllHintViews()
                    self?.tapVerticalView.showActionButton()
                    self?.tapVerticalView.add(view: self!.tapGoPayChipsHorizontalListViewModel.attachedView, with: [TapVerticalViewAnimationType.fadeIn()])
                    self?.tapVerticalView.add(view: self!.tapGatewayChipHorizontalListViewModel.attachedView, with: [TapVerticalViewAnimationType.fadeIn()])
                    self?.tapVerticalView.add(view: self!.tapCardTelecomPaymentViewModel.attachedView, with: [TapVerticalViewAnimationType.fadeIn()])
                    self?.tapVerticalView.add(view: self!.tapSaveCardSwitchViewModel.attachedView, with: [TapVerticalViewAnimationType.fadeIn()])
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
                views.append(tapGoPayChipsHorizontalListViewModel.attachedView)
                views.append(tapGatewayChipHorizontalListViewModel.attachedView)
                views.append(tapCardTelecomPaymentViewModel.attachedView)
                views.append(tapSaveCardSwitchViewModel.attachedView)
                //views.append(tapActionButton)
                tapAmountSectionViewModel.screenChanged(to: .DefaultView)
                DispatchQueue.main.async{ [weak self] in
                    self?.tapVerticalView.removeAllHintViews()
                    self?.tapVerticalView.add(view: self!.tapGoPayChipsHorizontalListViewModel.attachedView, with: [TapVerticalViewAnimationType.fadeIn()])
                    self?.tapVerticalView.add(view: self!.tapGatewayChipHorizontalListViewModel.attachedView, with: [TapVerticalViewAnimationType.fadeIn()])
                    self?.tapVerticalView.add(view: self!.tapCardTelecomPaymentViewModel.attachedView, with: [TapVerticalViewAnimationType.fadeIn()])
                    self?.tapVerticalView.add(view: self!.tapSaveCardSwitchViewModel.attachedView, with: [TapVerticalViewAnimationType.fadeIn()])
                    //self?.tapVerticalView.add(view: self!.tapActionButton, with: [TapVerticalViewAnimationType.fadeIn()])
                }
                break
            }
        }
    }
    
    func showScanner() {
        self.view.endEditing(true)
        for (index, element) in views.enumerated() {
            if element == tapGatewayChipHorizontalListViewModel.attachedView {
                self.tapVerticalView.remove(view: views[index-1], with: TapVerticalViewAnimationType.none)
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
                views.remove(at: (index-1))
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
       
        self.tapVerticalView.remove(view: tapAmountSectionViewModel.attachedView, with: TapVerticalViewAnimationType.fadeOut())
        self.tapVerticalView.remove(view: tapMerchantViewModel.attachedView, with: TapVerticalViewAnimationType.fadeOut())
        self.tapVerticalView.remove(view: tapGoPayChipsHorizontalListViewModel.attachedView, with: TapVerticalViewAnimationType.fadeOut())
        self.tapVerticalView.remove(view: tapGatewayChipHorizontalListViewModel.attachedView, with: TapVerticalViewAnimationType.fadeOut())
        self.tapVerticalView.remove(view: tapCardTelecomPaymentViewModel.attachedView, with: TapVerticalViewAnimationType.fadeOut())
        self.tapVerticalView.remove(view: tapSaveCardSwitchViewModel.attachedView, with: TapVerticalViewAnimationType.fadeOut())
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
    
    
    func hideGoPay() {
        self.view.endEditing(true)
        for (index, element) in views.enumerated() {
            if element == tapGoPayChipsHorizontalListViewModel.attachedView {
                self.tapVerticalView.remove(view: element, with: TapVerticalViewAnimationType.fadeOut())
                views.remove(at: index)
                self.tapGatewayChipHorizontalListViewModel.editMode(changed: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.tapGatewayChipHorizontalListViewModel.headerType = .GatewayListHeader
                }
                break
            }
        }
    }
}






extension ExampleWallOfGloryViewController:TapChipHorizontalListViewModelDelegate {
    func logoutChip(for viewModel: TapLogoutChipViewModel) {
        let logoutConfirmationAlert:UIAlertController = .init(title: "Are you sure you would like to sign out?", message: "The goPay cards will be hidden from the page and you will need to login again to use any of them.", preferredStyle: .alert)
        let confirmLogoutAction:UIAlertAction = .init(title: "Yes", style: .default) { [weak self] (_) in
            self?.hideGoPay()
        }
        let cancelLogoutAction:UIAlertAction = .init(title: "No", style: .cancel, handler: nil)
        logoutConfirmationAlert.addAction(confirmLogoutAction)
        logoutConfirmationAlert.addAction(cancelLogoutAction)
        present(logoutConfirmationAlert, animated: true, completion: nil)
    }
    
    
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
        
        // Check the type of saved card source
        
        if viewModel.listSource == .GoPayListHeader {
            // First of all deselct any selected cards in the gateways list
            tapGatewayChipHorizontalListViewModel.deselectAll()
            let authenticator = TapAuthenticate(reason: "Login into tap account")
            if authenticator.type != .none {
                tapActionButtonViewModel.buttonStatus = (authenticator.type == BiometricType.faceID) ? .FaceID : .TouchID
                authenticator.delegate = self
                authenticator.authenticate()
            }
        }else {
            // First of all deselct any selected cards in the goPay list
            tapGoPayChipsHorizontalListViewModel.deselectAll()
            // perform the charge when clicking on pay button
            tapActionButtonViewModel.buttonActionBlock = { self.startPayment(then: true) }
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
        tapGatewayChipHorizontalListViewModel.editMode(changed: true)
        tapGoPayChipsHorizontalListViewModel.editMode(changed: true)
    }
    
    
    func headerEndEditingButtonClicked(in headerType: TapHorizontalHeaderType) {
        tapGatewayChipHorizontalListViewModel.editMode(changed: false)
        tapGoPayChipsHorizontalListViewModel.editMode(changed: false)
    }
    
    func deleteChip(for viewModel: SavedCardCollectionViewCellModel) {
        showAlert(title: "DELETE A CARD", message: "You wanted to delete the card \(viewModel.title ?? "")")
    }
    
    func didSelect(item viewModel: GenericTapChipViewModel) {
        
    }
    
    
    func handleTelecomPayment(for cardBrand: CardBrand, with validation: CrardInputTextFieldStatusEnum) {
        if validation == .Valid {
            tapActionButtonViewModel.buttonStatus = .ValidPayment
            let payAction:()->() = { self.startPayment(then:true) }
            tapActionButtonViewModel.buttonActionBlock = payAction
            tapSaveCardSwitchViewModel.cardState = .validTelecom
        }else {
            tapActionButtonViewModel.buttonStatus = .InvalidPayment
            tapActionButtonViewModel.buttonActionBlock = {}
            tapSaveCardSwitchViewModel.cardState = .invalidTelecom
        }
        
        
        
        
    }
    
    func handleCardPayment(for cardBrand: CardBrand, with validation: CrardInputTextFieldStatusEnum) {
        if validation == .Valid,
            tapCardTelecomPaymentViewModel.decideHintStatus() == .None {
            tapActionButtonViewModel.buttonStatus = .ValidPayment
            let payAction:()->() = { self.startPayment(then:false) }
            tapActionButtonViewModel.buttonActionBlock = payAction
            tapSaveCardSwitchViewModel.cardState = .validCard
        }else{
            tapActionButtonViewModel.buttonStatus = .InvalidPayment
            tapActionButtonViewModel.buttonActionBlock = {}
            tapSaveCardSwitchViewModel.cardState = .invalidCard
        }
    }
    
    func startPayment(then success:Bool) {
        view.endEditing(true)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(0)) {
            for (index, element) in self.views.enumerated() {
                if element == self.tapGatewayChipHorizontalListViewModel.attachedView {
                    self.tapVerticalView.remove(view: self.views[index-1], with: TapVerticalViewAnimationType.none)
                    self.tapVerticalView.remove(view: element, with: TapVerticalViewAnimationType.none)
                    self.tapVerticalView.remove(view: self.views[index+1], with: TapVerticalViewAnimationType.none)
                    self.tapVerticalView.remove(view: self.views[index+2], with: TapVerticalViewAnimationType.none)
                    self.views.remove(at: index)
                    self.views.remove(at: index)
                    self.views.remove(at: index)
                    self.views.remove(at: (index-1))
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
                self?.tapCardTelecomPaymentViewModel.setCard(with: tapCard)
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
        self.tapVerticalView.showBlur = to
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
    func didChangeCardState(cardState: TapSwitchCardStateEnum) {
        print("current card State: \(cardState.rawValue)")
    }
    
    
    func didChangeState(state: TapSwitchEnum) {
        
        
        changeBlur(to: state != .none)
        
        if state != .none {
            self.tapActionButtonViewModel.buttonStatus = .SaveValidPayment
        }
        
        //self.tapActionButtonViewModel.buttonStatus = (state == .none) ? .ValidPayment : .SaveValidPayment
        
    }
}

extension ExampleWallOfGloryViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        if traitCollection.userInterfaceStyle == .dark {
            blurEffectView.effect = UIBlurEffect(style: .dark)
        }else {
            blurEffectView.effect = UIBlurEffect(style: .extraLight)
        }
        
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
