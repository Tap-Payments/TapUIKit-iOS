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
    
    var bottomSheetBackgroundColor:UIColor = .init(white: 0, alpha: 0.5)
    var bottomSheetBlurEffect:UIBlurEffect? = nil
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}

extension TapBottomSheetExampleViewController:TapBottomSheetDialogDataSource {
    
    func backGroundColor() -> UIColor {
        return bottomSheetBackgroundColor
    }
    
    func blurEffect() -> UIBlurEffect? {
        return bottomSheetBlurEffect
    }
    
    
    func viewControllerToPresent() -> TapPresentableViewController? {
        return toPresentController
    }
    
    
    func modalControllerRadious() -> CGFloat {
        return 20
    }
    
}
