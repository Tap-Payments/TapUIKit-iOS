//
//  ToPresentAsPopupViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 6/3/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS
protocol  ToPresentAsPopupViewControllerDelegate {
    func dismissMySelfClicked()
    func changeHeightClicked()
    func updateStackViews(with views:[UIView])
}
class ToPresentAsPopupViewController: UIViewController {

    var delegate:ToPresentAsPopupViewControllerDelegate?
    @IBOutlet weak var tapVerticalView: TapVerticalView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissMySelfClicked(_ sender: Any) {
        //self.dismissTheController()
        guard let delegate = delegate else { return }
        delegate.dismissMySelfClicked()
    }
    
    @IBAction func changeHeightClicked(_ sender: Any) {
        guard let delegate = delegate else { return }
        delegate.changeHeightClicked()
        //self.changeHeight(to: CGFloat(Int.random(in: 50 ..< 600)))
    }
    
    
    @IBAction func changeTheViewsDynamically(_ sender: Any) {
        
        var views:[UIView] = []
        for _ in 1..<Int.random(in: 1 ..< 5) {
            let newView:UIView = .init()
            newView.backgroundColor =  UIColor(red: .random(in: 0...1),
                                                     green: .random(in: 0...1),
                                                     blue: .random(in: 0...1),
                                                     alpha: 1.0)
            newView.translatesAutoresizingMaskIntoConstraints = false
            newView.heightAnchor.constraint(equalToConstant: CGFloat.random(in: 50 ..< 100)).isActive = true
            views.append(newView)
        }
        
        tapVerticalView.updateSubViews(with: views)
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
