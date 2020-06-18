//
//  ExampleWallOfGloryViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 6/10/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS
import CommonDataModelsKit_iOS
import TapApplePayKit_iOS

class ExampleWallOfGloryViewController: UIViewController {
    
    var delegate:ToPresentAsPopupViewControllerDelegate?
    @IBOutlet weak var tapVerticalView: TapVerticalView!
    var tapMerchantHeaderViewModel:TapMerchantHeaderViewModel = .init()
    var tapAmountSectionViewModel:TapAmountSectionViewModel = .init()
    var tapChipHorizontalListViewModel:TapChipHorizontalListViewModel = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tapVerticalView.delegate = self
        // Do any additional setup after loading the view.
        createDefaultViewModels()
        // Setting up the number of lines and doing a word wrapping
        UILabel.appearance(whenContainedInInstancesOf:[UIAlertController.self]).numberOfLines = 2
        UILabel.appearance(whenContainedInInstancesOf:[UIAlertController.self]).lineBreakMode = .byWordWrapping
        
        addGloryViews()
    }
    
    
    func createDefaultViewModels() {
        tapMerchantHeaderViewModel = .init(subTitle: "Tap Payments", iconURL: "https://avatars3.githubusercontent.com/u/19837565?s=200&v=4")
        tapAmountSectionViewModel = .init(originalTransactionAmount: 10000, originalTransactionCurrency: .USD, convertedTransactionAmount: 3333.333, convertedTransactionCurrency: .KWD, numberOfItems: 10)
        
        tapMerchantHeaderViewModel.delegate = self
        tapAmountSectionViewModel.delegate = self
        
        
        var allChipsViewModel:[GenericTapChipViewModel] = []
        
        
        let applePayChipViewModel:ApplePayChipViewCellModel = ApplePayChipViewCellModel.init()
        applePayChipViewModel.configureApplePayRequest()
        allChipsViewModel.append(applePayChipViewModel)
        
        allChipsViewModel.append(GatewayChipViewModel.init(title: "KNET", icon: "https://meetanshi.com/media/catalog/product/cache/1/image/925f46717e92fbc24a8e2d03b22927e1/m/a/magento-knet-payment-354x.png"))
        allChipsViewModel.append(GatewayChipViewModel.init(title: "KNET", icon: "https://meetanshi.com/media/catalog/product/cache/1/image/925f46717e92fbc24a8e2d03b22927e1/m/a/magento-knet-payment-354x.png"))
        
        allChipsViewModel.append(GatewayChipViewModel.init(title: "BENEFIT", icon: "https://media-exp1.licdn.com/dms/image/C510BAQG0Pwkl3gsm2w/company-logo_200_200/0?e=2159024400&v=beta&t=ragD_Mg4TUCAiVGiYOmjT2orY1IKEOOe_JEokwkzvaY"))
        allChipsViewModel.append(GatewayChipViewModel.init(title: "BENEFIT", icon: "https://media-exp1.licdn.com/dms/image/C510BAQG0Pwkl3gsm2w/company-logo_200_200/0?e=2159024400&v=beta&t=ragD_Mg4TUCAiVGiYOmjT2orY1IKEOOe_JEokwkzvaY"))
        
        allChipsViewModel.append(GatewayChipViewModel.init(title: "SADAD", icon: "https://www.payfort.com/wp-content/uploads/2017/09/go_glocal_mada_logo_en.png"))
        allChipsViewModel.append(GatewayChipViewModel.init(title: "SADAD", icon: "https://www.payfort.com/wp-content/uploads/2017/09/go_glocal_mada_logo_en.png"))
        
        
        allChipsViewModel.append(TapGoPayViewModel.init(title: "GoPay Clicked"))
        
        allChipsViewModel.append(SavedCardCollectionViewCellModel.init(title: "•••• 1234", icon:"https://img.icons8.com/color/2x/amex.png"))
        allChipsViewModel.append(SavedCardCollectionViewCellModel.init(title: "•••• 5678", icon:"https://img.icons8.com/color/2x/visa.png"))
        allChipsViewModel.append(SavedCardCollectionViewCellModel.init(title: "•••• 9012", icon:"https://img.icons8.com/color/2x/mastercard-logo.png"))
        
        tapChipHorizontalListViewModel = .init(dataSource: allChipsViewModel, headerType: .GatewayListHeader)
        
        tapChipHorizontalListViewModel.delegate = self
    }
    
    func addGloryViews() {
        var views:[UIView] = []
        
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
        
        
        
        // The GatwayListSection
        let tapgatewayChipHorizontalList:TapChipHorizontalList = .init()
        tapgatewayChipHorizontalList.translatesAutoresizingMaskIntoConstraints = false
        tapgatewayChipHorizontalList.heightAnchor.constraint(equalToConstant: 90).isActive = true
        views.append(tapgatewayChipHorizontalList)
        tapgatewayChipHorizontalList.changeViewMode(with: tapChipHorizontalListViewModel)
        
        self.tapVerticalView.updateSubViews(with: views,and: .none)
    }
    
    
    func showAlert(title:String,message:String) {
        let alertController:UIAlertController = .init(title: title, message: message, preferredStyle: .alert)
        let okAction:UIAlertAction = .init(title: "OK", style: .destructive, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
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
        delegate.changeHeight(to: newSize.height + frame.origin.y + view.safeAreaInsets.bottom + 5)
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
    func itemsClicked() {
        showAlert(title: "Amount Section", message: "The items had been clicked.. I promise logic will be implemented in the next sprint :)")
    }
    func amountSectionClicked() {
        showAlert(title: "Amount Section", message: "The user clicked on the amount section, do you want me to do anything?")
    }
}


extension ExampleWallOfGloryViewController:TapChipHorizontalListViewModelDelegate {
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
        showAlert(title: "GoPay cell clicked", message: "You clicked on GoPay.")
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
