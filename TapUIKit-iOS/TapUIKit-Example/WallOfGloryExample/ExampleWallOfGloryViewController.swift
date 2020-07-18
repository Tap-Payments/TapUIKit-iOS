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
    
    var views:[UIView] = []
    var gatewaysListView:TapChipHorizontalList = .init()
    var currencyListView:TapChipHorizontalList = .init()
    var tabItemsTableView: TapGenericTableView = .init()
    var tapCardTelecomPaymentView: TapCardTelecomPaymentView = .init()
    
    var rates:[String:Double] = [:]
    
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
        let dragView:TapDragHandlerView = .init()
        dragView.translatesAutoresizingMaskIntoConstraints = false
        dragView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        views.append(dragView)
        
        // The TapMerchantHeaderView
        let merchantHeaderView:TapMerchantHeaderView = .init()
        merchantHeaderView.translatesAutoresizingMaskIntoConstraints = false
        merchantHeaderView.heightAnchor.constraint(equalToConstant: 55).isActive = true
        views.append(merchantHeaderView)
        merchantHeaderView.changeViewModel(with: tapMerchantHeaderViewModel)
        
        // The TapAmountSectionView
        let amountSectionView:TapAmountSectionView = .init()
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
        let signGoPayView: TapGoPaySignInView = .init()
        signGoPayView.delegate = self
        signGoPayView.backgroundColor = .clear
        signGoPayView.translatesAutoresizingMaskIntoConstraints = false
        signGoPayView.heightAnchor.constraint(equalToConstant: 161).isActive = true
        
        signGoPayView.setup(with: goPayBarViewModel)
        tapAmountSectionViewModel.screenChanged(to: .GoPayView)
        
        self.view.endEditing(true)
        for (index, element) in views.enumerated() {
            if element == gatewaysListView {
                self.tapVerticalView.remove(view: element, with: TapVerticalViewAnimationType.fadeOut(duration:0.25))
                self.tapVerticalView.remove(view: views[index+1], with: TapVerticalViewAnimationType.fadeOut(duration:0.25))
                views.remove(at: index)
                views.remove(at: index)
                views.append(signGoPayView)
                DispatchQueue.main.async{ [weak self] in
                    self?.tapVerticalView.add(view: signGoPayView, with: [TapVerticalViewAnimationType.slideIn(.bottom,duration: 0.5,delay: 0.25)])
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
                self.tapVerticalView.remove(view: element, with: TapVerticalViewAnimationType.none)
                self.tapVerticalView.remove(view: views[index+1], with: TapVerticalViewAnimationType.none)
                views.remove(at: index)
                views.remove(at: index)
                views.append(currencyListView)
                views.append(tabItemsTableView)
                DispatchQueue.main.async{ [weak self] in
                    self?.tapVerticalView.add(view: self!.currencyListView, with: [TapVerticalViewAnimationType.fadeIn()])
                    self?.tapVerticalView.add(view: self!.tabItemsTableView, with: [TapVerticalViewAnimationType.fadeIn()])
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
                self.tapVerticalView.remove(view: element, with: TapVerticalViewAnimationType.none)
                self.tapVerticalView.remove(view: tabItemsTableView, with: TapVerticalViewAnimationType.none)
                views.remove(at: index)
                views.remove(at: index)
                views.append(gatewaysListView)
                views.append(tapCardTelecomPaymentView)
                DispatchQueue.main.async{ [weak self] in
                    self?.tapVerticalView.add(view: self!.gatewaysListView, with: [TapVerticalViewAnimationType.fadeIn()])
                    self?.tapVerticalView.add(view: self!.tapCardTelecomPaymentView, with: [TapVerticalViewAnimationType.fadeIn()])
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
                tapAmountSectionViewModel.screenChanged(to: .DefaultView)
                DispatchQueue.main.async{ [weak self] in
                    self?.tapVerticalView.removeAllHintViews()
                    self?.tapVerticalView.add(view: self!.gatewaysListView, with: [TapVerticalViewAnimationType.fadeIn()])
                    self?.tapVerticalView.add(view: self!.tapCardTelecomPaymentView, with: [TapVerticalViewAnimationType.fadeIn()])
                }
                break
            }
        }
    }
    
    
    func closeGoPayClicked() {
        self.view.endEditing(true)
        for (index, element) in views.enumerated() {
            if let goPayElement:TapGoPaySignInView = element as? TapGoPaySignInView {
                self.tapVerticalView.remove(view: goPayElement, with: TapVerticalViewAnimationType.slideOut(.bottom, duration: 0.25))
                views.remove(at: index)
                views.append(gatewaysListView)
                views.append(tapCardTelecomPaymentView)
                tapAmountSectionViewModel.screenChanged(to: .DefaultView)
                DispatchQueue.main.async{ [weak self] in
                    self?.tapVerticalView.removeAllHintViews()
                    self?.tapVerticalView.add(view: self!.gatewaysListView, with: [TapVerticalViewAnimationType.fadeIn(duration: 0.1,delay: 0.25)])
                    self?.tapVerticalView.add(view: self!.tapCardTelecomPaymentView, with: [TapVerticalViewAnimationType.fadeIn(duration:0.1,delay: 0.25)])
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
                let hintViewModel:TapHintViewModel = .init(with: .ReadyToScan)
                let hintView:TapHintView = hintViewModel.createHintView()
                let tapCardScannerView:TapCardScannerView = .init()
                tapCardScannerView.delegate = self
                tapCardScannerView.configureScanner()
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
        showAlert(title: "\(viewModel.title ?? "") clicked", message: "Look we know that you saved the card. We promise we will make you use it soon :)")
    }
    
    func gateway(for viewModel: GatewayChipViewModel) {
        showAlert(title: "gateway cell clicked", message: "You clicked on a \(viewModel.title ?? ""). In real life example, this will open a web view to complete the payment")
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
