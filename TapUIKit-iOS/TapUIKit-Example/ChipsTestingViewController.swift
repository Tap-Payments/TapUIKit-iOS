//
//  ChipsTestingViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 6/15/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS

class ChipsTestingViewController: UIViewController {

    
    @IBOutlet weak var horizontalList: TapChipHorizontalList!
    var viewModel:TapChipHorizontalListViewModel = .init()
    var allChipsViewModel:[GenericTapChipViewModel] = []
    var filteredChipsViewModel:[GenericTapChipViewModel] = []
    @IBOutlet weak var knetSwitch:UISwitch!
    @IBOutlet weak var benefitSwitch:UISwitch!
    @IBOutlet weak var sadadSwitch:UISwitch!
    @IBOutlet weak var goPaySwitch:UISwitch!
    @IBOutlet weak var savedCardSwitch:UISwitch!
    @IBOutlet weak var headerSwitch:UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        
        viewModel = .init(dataSource: filteredChipsViewModel, headerType: .GatewayListHeader)
        
        horizontalList.changeViewMode(with: viewModel)
        
        viewModel.delegate = self
        
        filter()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func switchChanged(_ sender: Any) {
        if sender as? UISwitch == headerSwitch {
            viewModel.headerType = headerSwitch.isOn ?  .GatewayListHeader : nil
        }else {
            filter()
        }
    }
    
    func filter() {
        filteredChipsViewModel = []
        
        if knetSwitch.isOn {
            filteredChipsViewModel.append(allChipsViewModel[0])
            filteredChipsViewModel.append(allChipsViewModel[1])
        }
        
        if benefitSwitch.isOn {
            filteredChipsViewModel.append(allChipsViewModel[2])
            filteredChipsViewModel.append(allChipsViewModel[3])
        }
        
        if sadadSwitch.isOn {
            filteredChipsViewModel.append(allChipsViewModel[4])
            filteredChipsViewModel.append(allChipsViewModel[5])
        }
        
        if goPaySwitch.isOn {
            filteredChipsViewModel.append(allChipsViewModel[6])
        }
        
        if savedCardSwitch.isOn {
            filteredChipsViewModel.append(allChipsViewModel[7])
            filteredChipsViewModel.append(allChipsViewModel[8])
            filteredChipsViewModel.append(allChipsViewModel[9])
        }
        
        
        viewModel.headerType = headerSwitch.isOn ?  .GatewayListHeader : nil
        
        viewModel.dataSource = filteredChipsViewModel
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

extension ChipsTestingViewController:TapChipHorizontalListViewModelDelegate {
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
        
        if let viewModel:GatewayChipViewModel = viewModel as? GatewayChipViewModel {
            showAlert(title: "gateway cell clicked", message: "You clicked on a \(viewModel.title ?? ""). In real life example, this will open a web view to complete the payment")
        }else if let _:TapGoPayViewModel = viewModel as? TapGoPayViewModel {
            showAlert(title: "GoPay cell clicked", message: "You clicked on GoPay.")
        }else if let _:SavedCardCollectionViewCellModel = viewModel as? SavedCardCollectionViewCellModel {
            showAlert(title: "\(viewModel.title ?? "") clicked", message: "Look we know that you saved the card. We promise we will make you use it soon :)")
        }
    }
}




