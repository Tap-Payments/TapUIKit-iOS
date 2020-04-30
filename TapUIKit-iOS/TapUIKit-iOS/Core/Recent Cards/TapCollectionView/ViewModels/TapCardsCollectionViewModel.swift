//
//  TapCardsCollectionViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 30/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import class UIKit.UICollectionView
import class UIKit.UINib

@objc public class TapCardsCollectionViewModel:NSObject {
    
    internal lazy var dataSource:[CellConfigurator] = []
    
    internal func numberOfItems() -> Int {
        return dataSource.count
    }
    
    internal func cellConfigurator(at indexPath:IndexPath) -> CellConfigurator {
        return dataSource[indexPath.row]
    }
    
    internal func didSelectItem(at indexPath:IndexPath) {
        
    }
    
    internal func registerCells(on collectionView:UICollectionView) {
        
        collectionView.register(UINib(nibName:String(describing: TapRecentCardCollectionViewCell.self), bundle: Bundle(for: TapRecentCardCollectionViewCell.self)), forCellWithReuseIdentifier: String(describing: TapRecentCardCollectionViewCell.self))
        collectionView.register(UINib(nibName:String(describing: TapGoPayCollectionViewCell.self), bundle: Bundle(for: TapGoPayCollectionViewCell.self)), forCellWithReuseIdentifier: String(describing: TapGoPayCollectionViewCell.self))
    }
    
    
    @objc public convenience init(with models:[TapCellViewModel]) {
        self.init()
        dataSource = models.map{ $0.convertToCellConfigrator() }
    }
    
    
    override internal init() {
        super.init()
    }
    
}
