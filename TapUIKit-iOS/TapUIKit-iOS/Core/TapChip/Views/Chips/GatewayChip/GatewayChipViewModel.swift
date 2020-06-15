//
//  GatewayChipViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/14/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation

internal protocol GateWayChipViewModelDelegate {
    func changeSelection(with status:Bool)
}

public class GatewayChipViewModel: GenericTapChipViewModel {
    
    
    internal var cellDelegate:GateWayChipViewModelDelegate?
    
    public override func identefier() -> String {
        return "GatewayImageCollectionViewCell"
    }
    
    
    public override func didSelectItem() {
        cellDelegate?.changeSelection(with: true)
    }
    
    public override func didDeselectItem() {
        cellDelegate?.changeSelection(with: false)
    }
    
}
