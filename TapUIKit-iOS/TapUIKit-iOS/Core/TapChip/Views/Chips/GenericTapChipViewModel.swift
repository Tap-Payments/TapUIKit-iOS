//
//  GenericTapChipViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/14/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation

public class GenericTapChipViewModel {
    
    public var title:String?
    public var icon:String?
    
    
    public init(title:String? = nil, icon:String? = nil) {
        self.title = title
        self.icon = icon
    }
    
    func identefier() -> String {
        return ""
    }
    
    
    func didSelectItem() {
        return
    }
    
    func didDeselectItem() {
        return
    }
    
}
