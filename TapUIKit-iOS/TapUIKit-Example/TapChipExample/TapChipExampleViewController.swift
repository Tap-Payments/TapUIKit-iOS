//
//  TapChipExampleViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 28/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS

class TapChipExampleViewController: UIViewController {

    @IBOutlet weak var tapChipHolder: UIView!
    lazy var chipText = "∙∙∙∙ 1234"
    lazy var showLeftAccessory:Bool = true
    lazy var showRightAccessory:Bool = true
    var tapChip:TapChip?
    lazy var tapChipViewModel:TapChipCellViewModel = .init()
    let leftAccessory:TapChipAccessoryView = TapChipAccessoryView(image: UIImage(named: "visa")) { (tapChip) in
        tapChip.showShadow(glowing: true)
    }
    let rightAccessory:TapChipAccessoryView = TapChipAccessoryView(image: UIImage(named: "mastercard"))  { (tapChip) in
        tapChip.showShadow(glowing: false)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTapChip()
    }
    
    
    func setupTapChip() {
        if let nonNullTapChip = tapChip {
            nonNullTapChip.removeFromSuperview()
        }
        
        tapChip = TapChip(frame:tapChipHolder.bounds)
        tapChipHolder.addSubview(tapChip!)
        
        tapChipViewModel = .init(leftAccessory: leftAccessory, rightAccessory: rightAccessory, bodyContent: chipText)
        
        tapChip!.setup(viewModel: tapChipViewModel)
    }
    
    @IBAction func leftAccessoryChanged(_ sender: Any) {
        
        if let uiswitch:UISwitch = sender as? UISwitch {
            tapChipViewModel.leftAccessory =  (uiswitch.isOn) ? leftAccessory : nil
        }
    }
    
    @IBAction func rightAccessoryChanged(_ sender: Any) {
        if let uiswitch:UISwitch = sender as? UISwitch {
            tapChipViewModel.rightAccessory =  (uiswitch.isOn) ? rightAccessory : nil
        }
    }
    
    @IBAction func changeTextClicked(_ sender: Any) {
        let ac = UIAlertController(title: "Chip Content", message: "Enter a string value", preferredStyle: .alert)
        ac.addTextField()
        // Define what to do when the user fills in the value
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac, weak self] _ in
            let answer = ac.textFields![0]
            
            if let contentValue:String = answer.text {
                self?.chipText = contentValue
                DispatchQueue.main.async {[weak self] in
                    self?.tapChipViewModel.bodyContent =  self?.chipText ?? ""
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(submitAction)
        ac.addAction(cancelAction)
        DispatchQueue.main.async {[weak self] in
            self?.present(ac, animated: true, completion: nil)
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
