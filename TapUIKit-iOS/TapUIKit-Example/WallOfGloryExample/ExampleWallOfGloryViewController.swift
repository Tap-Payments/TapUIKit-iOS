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
    var tapMerchantHeaderViewModel:TapMerchantHeaderViewModel = .init()
    
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
        
        
        self.tapVerticalView.updateSubViews(with: views,and: .none)
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
        delegate.changeHeight(to: newSize.height + frame.origin.y + view.safeAreaInsets.bottom + 30)
    }
    
}
