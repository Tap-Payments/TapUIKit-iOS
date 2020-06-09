//
//  TapDragHandlerViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 6/9/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS

class TapDragHandlerViewController: UIViewController {

    @IBOutlet weak var dragView: TapDragHandlerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func animateSwitch(_ sender: Any) {
        
        guard let animateSwitch = sender as? UISwitch else { return }
        
        let size:CGSize = (animateSwitch.isOn) ? .init(width: 75, height: 2) : .init(width: 100, height: 10)
        
        dragView.changeHandlerSize(with: size.width, and: size.height)
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
