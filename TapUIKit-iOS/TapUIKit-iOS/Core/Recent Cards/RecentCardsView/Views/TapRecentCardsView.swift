//
//  TapRecentCardsView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 03/05/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//


import SnapKit

/// Represents the Tap view that fully shows the recent cards view as per the design
@objc public class TapRecentCardsView: UIView {

    /// This is the button to represent the left button in the UI
    internal lazy var leftButton:UIButton = UIButton()
    /// This is the button to represent the right button in the UI
    internal lazy var rightButton:UIButton = UIButton()
    /// This is the view that will hold the buttons above the collection view
    internal lazy var headerView:UIView = UIView()
    /// This is the recent cards collection view
    internal lazy var recentCardsCollectionView:TapRecentCollectionView = TapRecentCollectionView()
    
    
    @objc public func setup() {
        
    }
    
}
