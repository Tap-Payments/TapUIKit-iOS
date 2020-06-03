//
//  TapBottomSheetExampleViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 6/3/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import SheetyColors
import TapUIKit_iOS

class TapBottomSheetExampleViewController: UIViewController {
    
    
    @IBOutlet weak var blurEffectSegment: UISegmentedControl!
    @IBOutlet weak var initialHeightLabel: UILabel!
    
    var bottomSheetBackgroundColor:UIColor = .init(white: 0, alpha: 0.5)
    var bottomSheetBlurEffect:UIBlurEffect? = nil
    var dismissWhenClickOutSide:Bool = true
    var initialHeight:CGFloat = 100
    var toPresentController:ToPresentAsPopupViewController {
        storyboard?.instantiateViewController(withIdentifier: "ToPresentAsPopupViewController") as! ToPresentAsPopupViewController
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backgroundColorClicked(_ sender: Any) {
        // Create a SheetyColors view with your configuration
        let config = SheetyColorsConfig(alphaEnabled: true, hapticFeedbackEnabled: true, initialColor: bottomSheetBackgroundColor, title: "Background color", type: .rgb)
        let sheetyColors = SheetyColorsController(withConfig: config)
        
        // Add a button to accept the selected color
        let selectAction = UIAlertAction(title: "Select Color", style: .destructive, handler: { [weak self] _ in
            self?.bottomSheetBackgroundColor = sheetyColors.color
        })
        
        sheetyColors.addAction(selectAction)
        
        // Add a cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheetyColors.addAction(cancelAction)
        
        present(sheetyColors, animated: true, completion: nil)
    }
    
    @IBAction func blurEffectChanged(_ sender: Any) {
        
        switch blurEffectSegment.selectedSegmentIndex {
            case 0:
                bottomSheetBlurEffect = nil
            case 1:
                bottomSheetBlurEffect = .init(style: .extraLight)
            case 2:
                bottomSheetBlurEffect = .init(style: .light)
            case 3:
                bottomSheetBlurEffect = .init(style: .dark)
            default:
                break
        }
        
    }
    
    @IBAction func showPopupClicked(_ sender: Any) {
        
        let bottomSheetController = TapBottomSheetDialogViewController()
        bottomSheetController.dataSource = self
        
        present(bottomSheetController, animated: true, completion: nil)
        
    }
    @IBAction func dismissSwitchChanged(_ sender: Any) {
        guard let sender:UISwitch = sender as? UISwitch else { return }
        dismissWhenClickOutSide = sender.isOn
    }
    @IBAction func initialHeightSliderChanged(_ sender: Any) {
        guard let sender:UISlider = sender as? UISlider else { return }
        
        initialHeight = CGFloat(sender.value)
        initialHeightLabel.text = "Initial Height \(Int(initialHeight)) PX"
    }
}

extension TapBottomSheetExampleViewController:TapBottomSheetDialogDataSource {
    
    func tapBottomSheetBackGroundColor() -> UIColor {
        return bottomSheetBackgroundColor
    }
    
    func tapBottomSheetBlurEffect() -> UIBlurEffect? {
        return bottomSheetBlurEffect
    }
    
    
    func tapBottomSheetViewControllerToPresent() -> TapPresentableViewController? {
        return toPresentController
    }
    
    func tapBottomSheetShouldAutoDismiss() -> Bool {
        return dismissWhenClickOutSide
    }
    
    
    func tapBottomSheetInitialHeight() -> CGFloat {
        return initialHeight
    }
    
    
    func tapBottomSheetStickingPoints() -> [CGFloat] {
        return [50,100,200,300,400,500,600]
    }
}
