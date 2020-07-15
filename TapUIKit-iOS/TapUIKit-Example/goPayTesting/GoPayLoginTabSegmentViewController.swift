//
//  GoPayLoginTabSegmentViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 7/14/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS

class GoPayLoginTabSegmentViewController: UIViewController {

    
    @IBOutlet weak var tapGoPayTitleTab: TapGoPayTitleView!
    let tapGoPayTitleViewModel:TapGoPayTitleViewModel = .init(titleStatus: .selected, titleSegment: .Email)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tapGoPayTitleTab.setup(with: tapGoPayTitleViewModel)
    }
    
    @IBAction func statusChanged(_ sender: Any) {
        guard let segment:UISegmentedControl = sender as? UISegmentedControl else { return }
        
        
        switch segment.selectedSegmentIndex {
        case 0:
            tapGoPayTitleViewModel.titleStatus = .selected
        case 1:
            tapGoPayTitleViewModel.titleStatus = .otherSegmentSelected
        default:
            return
        }
        
    }
    

}
