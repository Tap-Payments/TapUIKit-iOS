//
//  TapCardsCollectionViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 30/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import class UIKit.UICollectionView
import class UIKit.UINib

@objc public protocol TapCardsCollectionProtocol {
    @objc func recentCardClicked(with viewModel:TapCardRecentCardCellViewModel)
    @objc func goPayClicked(with viewModel:TapGoPayCellViewModel)
}
@objc public class TapCardsCollectionViewModel:NSObject {
    
    internal lazy var dataSource:[CellConfigurator] = []
    
    @objc public var delegate:TapCardsCollectionProtocol?
    
    internal func numberOfItems() -> Int {
        return dataSource.count
    }
    
    internal func cellConfigurator(at indexPath:IndexPath) -> CellConfigurator {
        return dataSource[indexPath.row]
    }
    
    internal func didSelectItem(at indexPath:IndexPath) {
        handleItemSelection(cell: cellConfigurator(at: indexPath))
    }
    
    internal func registerCells(on collectionView:UICollectionView) {
        
        collectionView.register(UINib(nibName:String(describing: TapRecentCardCollectionViewCell.self), bundle: Bundle(for: TapRecentCardCollectionViewCell.self)), forCellWithReuseIdentifier: String(describing: TapRecentCardCollectionViewCell.self))
        collectionView.register(UINib(nibName:String(describing: TapGoPayCollectionViewCell.self), bundle: Bundle(for: TapGoPayCollectionViewCell.self)), forCellWithReuseIdentifier: String(describing: TapGoPayCollectionViewCell.self))
         collectionView.register(UINib(nibName:String(describing: TapSeparatorCollectionViewCell.self), bundle: Bundle(for: TapSeparatorCollectionViewCell.self)), forCellWithReuseIdentifier: String(describing: TapSeparatorCollectionViewCell.self))
    }
    
    
    @objc public convenience init(with models:[TapCellViewModel]) {
        self.init()
        dataSource = models.map{ $0.convertToCellConfigrator() }
    }
    
    internal func handleItemSelection(cell: CellConfigurator) {
        
        if let clickedCell:TapGenericCollectionViewCell = cell.collectionViewCell,
           let nonNullDelegate = delegate{
            switch clickedCell.cellViewModel().self {
            case is TapGoPayCellViewModel:
                nonNullDelegate.goPayClicked(with: clickedCell.cellViewModel() as! TapGoPayCellViewModel)
            case is TapCardRecentCardCellViewModel:
                nonNullDelegate.recentCardClicked(with: clickedCell.cellViewModel() as! TapCardRecentCardCellViewModel)
            default:
                break
            }
            
        }
    }
    
    override internal init() {
        super.init()
    }
    
}
