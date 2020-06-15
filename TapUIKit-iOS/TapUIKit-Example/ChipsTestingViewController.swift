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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allChipsViewModel.append(GatewayChipViewModel.init(title: "KNET", icon: "https://meetanshi.com/media/catalog/product/cache/1/image/925f46717e92fbc24a8e2d03b22927e1/m/a/magento-knet-payment-354x.png"))
        allChipsViewModel.append(GatewayChipViewModel.init(title: "KNET", icon: "https://meetanshi.com/media/catalog/product/cache/1/image/925f46717e92fbc24a8e2d03b22927e1/m/a/magento-knet-payment-354x.png"))
        
        allChipsViewModel.append(GatewayChipViewModel.init(title: "BENEFIT", icon: "https://media-exp1.licdn.com/dms/image/C510BAQG0Pwkl3gsm2w/company-logo_200_200/0?e=2159024400&v=beta&t=ragD_Mg4TUCAiVGiYOmjT2orY1IKEOOe_JEokwkzvaY"))
        allChipsViewModel.append(GatewayChipViewModel.init(title: "BENEFIT", icon: "https://media-exp1.licdn.com/dms/image/C510BAQG0Pwkl3gsm2w/company-logo_200_200/0?e=2159024400&v=beta&t=ragD_Mg4TUCAiVGiYOmjT2orY1IKEOOe_JEokwkzvaY"))
        
        allChipsViewModel.append(GatewayChipViewModel.init(title: "SADAD", icon: "https://www.payfort.com/wp-content/uploads/2017/09/go_glocal_mada_logo_en.png"))
        allChipsViewModel.append(GatewayChipViewModel.init(title: "SADAD", icon: "https://www.payfort.com/wp-content/uploads/2017/09/go_glocal_mada_logo_en.png"))
        
        filteredChipsViewModel.append(contentsOf: allChipsViewModel)
        
        viewModel = .init(dataSource: allChipsViewModel)
        
        horizontalList.changeViewMode(with: viewModel)
        
        viewModel.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func switchChanged(_ sender: Any) {
        filter()
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
    
    func didSelect(item viewModel: GenericTapChipViewModel) {
        
        if let viewModel:GatewayChipViewModel = viewModel as? GatewayChipViewModel {
            showAlert(title: "gateway cell clicked", message: "You clicked on a \(viewModel.title ?? ""). In real life example, this will open a web view to complete the payment")
        }
    }
}




