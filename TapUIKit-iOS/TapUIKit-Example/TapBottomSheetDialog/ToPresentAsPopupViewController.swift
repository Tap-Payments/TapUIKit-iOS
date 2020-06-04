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
}
class ToPresentAsPopupViewController: UIViewController {

    var delegate:ToPresentAsPopupViewControllerDelegate?
    
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
