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
        let leftAccessory:TapChipAccessoryView = TapChipAccessoryView(image: UIImage(named: "visa")) { (tapChip) in
            tapChip.showShadow(glowing: true)
        }
        let rightAccessory:TapChipAccessoryView = TapChipAccessoryView(image: UIImage(named: "mastercard"))  { (tapChip) in
            tapChip.showShadow(glowing: false)
        }
        
        if showLeftAccessory && showRightAccessory {
            tapChip!.setup(contentString: chipText, rightAccessory: rightAccessory, leftAccessory: leftAccessory)
        }else if showLeftAccessory {
            tapChip!.setup(contentString: chipText, leftAccessory: leftAccessory)
        }else if showRightAccessory {
            tapChip!.setup(contentString: chipText, rightAccessory: rightAccessory)
        }else {
            tapChip!.setup(contentString: chipText)
        }
    }
    
    @IBAction func leftAccessoryChanged(_ sender: Any) {
        
        if let uiswitch:UISwitch = sender as? UISwitch {
            showLeftAccessory = uiswitch.isOn
            setupTapChip()
        }
    }
    
    @IBAction func rightAccessoryChanged(_ sender: Any) {
        if let uiswitch:UISwitch = sender as? UISwitch {
            showRightAccessory = uiswitch.isOn
            setupTapChip()
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
                    self?.setupTapChip()
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
