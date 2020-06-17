//
//  TapHorizontalHeaderView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/17/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit

protocol TapHorizontalDelegate {
    func rightAccessoryClicked(for view:TapGatewyHorizontalHeaderView)
    func leftAccessoryClicked(for view:TapGatewyHorizontalHeaderView)
}

class TapGatewyHorizontalHeaderView: UIView {
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet var contentView: UIView!

}
