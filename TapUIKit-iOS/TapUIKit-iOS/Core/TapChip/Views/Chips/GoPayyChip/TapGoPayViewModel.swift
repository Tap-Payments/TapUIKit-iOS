//
//  TapGoPayCollectionViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/16/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation

internal protocol TapGoPayViewModelDelegate {
    func changeSelection(with status:Bool)
    func changeGoPayStatus(with status:TapGoPayStatus)
}

public class TapGoPayViewModel: GenericTapChipViewModel {
    
    internal var cellDelegate:TapGoPayViewModelDelegate?
    
    public var tapGoPayStatus:TapGoPayStatus = .logIn {
        didSet{
            
        }
    }
    
    public init(title: String? = nil, icon: String? = nil,tapGoPayStatus:TapGoPayStatus = .logIn) {
        super.init(title: title, icon: icon)
        self.tapGoPayStatus = tapGoPayStatus
    }
    
    public override func identefier() -> String {
        return "TapGoPayChipCollectionViewCell"
    }
    
    
    public override func didSelectItem() {
        cellDelegate?.changeSelection(with: true)
    }
    
    public override func didDeselectItem() {
        cellDelegate?.changeSelection(with: false)
    }
}


public enum TapGoPayStatus {
    case logIn
    case loggedIn
    
    func themePath() -> String {
        switch self {
        case .logIn:
            return "logIn"
        case .loggedIn:
            return "loggedIn"
        }
    }
}
