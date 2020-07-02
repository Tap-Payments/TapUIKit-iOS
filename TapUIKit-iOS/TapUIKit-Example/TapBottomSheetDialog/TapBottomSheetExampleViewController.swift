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
    @IBOutlet weak var conerRadiusLabel: UILabel!
    @IBOutlet weak var eventsTextView: UITextView!
    @IBOutlet weak var heightSlider: UISlider!
    
    var showWallOfGlory:Bool = false
    var bottomSheetBackgroundColor:UIColor? = .init(white: 0, alpha: 0.5)
    var bottomSheetBlurEffect:UIBlurEffect? = nil
    var dismissWhenClickOutSide:Bool = true
    var initialHeight:CGFloat = 100
    var cornerRadius:CGFloat = 12
    var bottomSheetController = TapBottomSheetDialogViewController()
    var toPresentController:ToPresentAsPopupViewController {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ToPresentAsPopupViewController") as! ToPresentAsPopupViewController
        vc.delegate = self
        return vc
    }
    var gloryPresentController:ExampleWallOfGloryViewController {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ExampleWallOfGloryViewController") as! ExampleWallOfGloryViewController
        vc.delegate = self
        
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if showWallOfGlory {
            initialHeight =  139
            initialHeightLabel.text = "Computed Initial Height \(Int(initialHeight)) PX"
            heightSlider.isEnabled = false
            heightSlider.isUserInteractionEnabled = false
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backgroundColorClicked(_ sender: Any) {
        
        let alertController:UIAlertController = .init(title: "Color or Theme Manager?", message: "Provide a single color, or you can use the default theme manager that will listen for dark mode", preferredStyle: .actionSheet)
        
        let colorSelection:UIAlertAction = .init(title: "Color", style: .default) { [weak self] (_) in
            // Create a SheetyColors view with your configuration
            let config = SheetyColorsConfig(alphaEnabled: true, hapticFeedbackEnabled: true, initialColor: self?.bottomSheetBackgroundColor ?? .white, title: "Background color", type: .rgb)
            let sheetyColors = SheetyColorsController(withConfig: config)
            
            // Add a button to accept the selected color
            let selectAction = UIAlertAction(title: "Select Color", style: .destructive, handler: { [weak self] _ in
                self?.bottomSheetBackgroundColor = sheetyColors.color
            })
            
            sheetyColors.addAction(selectAction)
            
            self?.present(sheetyColors, animated: true, completion: nil)
        }
        
        let themeManagerAction:UIAlertAction = .init(title: "Tap Theme Manager", style: .default) { [weak self] _ in
            self?.bottomSheetBackgroundColor = nil
        }
        
        
        alertController.addAction(colorSelection)
        alertController.addAction(themeManagerAction)
        
        present(alertController, animated: true, completion: nil)
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
            case 4:
                bottomSheetBlurEffect = .init(style: .regular)
            default:
                break
        }
        
    }
    
    @IBAction func showPopupClicked(_ sender: Any) {
        
        bottomSheetController = TapBottomSheetDialogViewController()
        bottomSheetController.dataSource = self
        bottomSheetController.delegate = self
        bottomSheetController.modalPresentationStyle = .overCurrentContext
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
    
    @IBAction func cornerRadiusliderChanged(_ sender: Any) {
        guard let sender:UISlider = sender as? UISlider else { return }
        
        cornerRadius = CGFloat(sender.value)
        conerRadiusLabel.text = "Corner Radius \(Int(cornerRadius)) PX"
    }
}

extension TapBottomSheetExampleViewController:TapBottomSheetDialogDataSource {
    
    func tapBottomSheetBackGroundColor() -> UIColor? {
        return bottomSheetBackgroundColor
    }
    
    func tapBottomSheetBlurEffect() -> UIBlurEffect? {
        return bottomSheetBlurEffect
    }
    
    
    func tapBottomSheetViewControllerToPresent() -> UIViewController? {
        return showWallOfGlory ? gloryPresentController : toPresentController
    }
    
    func tapBottomSheetShouldAutoDismiss() -> Bool {
        return dismissWhenClickOutSide
    }
    
    
    func tapBottomSheetInitialHeight() -> CGFloat {
        return initialHeight
    }
    
    func tapBottomSheetControllerRadious() -> CGFloat {
        return cornerRadius
    }
    
    func tapBottomSheetRadiousCorners() -> CACornerMask {
        return [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func tapBottomSheetStickingPoints() -> [CGFloat] {
        return [20,100,200,300,400,500,600]
    }
}


extension TapBottomSheetExampleViewController: TapBottomSheetDialogDelegate {
    
    
    func tapBottomSheetPresented() {
        eventsTextView.text = "Controller presented\n\(eventsTextView.text ?? "")"
    }
    
    func tapBottomSheetWillDismiss() {
        eventsTextView.text = "Controller will dismiss\n\(eventsTextView.text ?? "")"
    }
    
    func tapBottomSheetDidTapOutside() {
        eventsTextView.text = "Controller did tap outside\n\(eventsTextView.text ?? "")"
    }
    
    func tapBottomSheetHeightChanged(with newHeight: CGFloat) {
        eventsTextView.text = "Controller changed height with \(newHeight)\n\(eventsTextView.text ?? "")"
    }
    
}


extension TapBottomSheetExampleViewController : ToPresentAsPopupViewControllerDelegate {
    func dismissMySelfClicked() {
        bottomSheetController.dismissTheController()
    }
    
    func changeHeightClicked() {
        bottomSheetController.changeHeight(to: CGFloat(Int.random(in: 50 ..< 600)))
    }
    
    
    func updateStackViews(with views: [UIView]) {
        
    }
    
    func changeHeight(to newHeight: CGFloat) {
        bottomSheetController.changeHeight(to: newHeight + 5)
    }
}
