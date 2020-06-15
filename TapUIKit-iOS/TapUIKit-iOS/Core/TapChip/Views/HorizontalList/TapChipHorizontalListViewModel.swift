//
//  TapChipHorizontalListViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/15/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import RxCocoa

public class TapChipHorizontalListViewModel {
    
    // MARK:- RX Internal Observables
    internal var dataSourceObserver:BehaviorRelay<[GenericTapChipViewModel]> = .init(value: [])
    
    public var dataSource:[GenericTapChipViewModel] = [] {
        didSet{
            dataSourceObserver.accept(dataSource)
        }
    }
    
    
    public init(dataSource:[GenericTapChipViewModel]) {
        self.dataSource = dataSource
    }
    
    public init() {
    }
    
    internal func registerAllXibs(for collectionView:UICollectionView) {
        let chipCellsNames:[String] = ["GatewayImageCollectionViewCell"]
        chipCellsNames.forEach { chipName in
            let bundle = Bundle(for: TapChipHorizontalListViewModel.self)
            collectionView.register(UINib(nibName: chipName, bundle: bundle), forCellWithReuseIdentifier: chipName)
        }
    }
    
    func numberOfSections() -> Int {
        1
    }
    
    func numberOfRows() -> Int {
        dataSource.count
    }
    
    func viewModel(at index:Int) -> GenericTapChipViewModel {
        return dataSource[index]
    }
    
    
    
    func dequeuCell(in collectionView:UICollectionView, at indexPath:IndexPath) -> GenericTapChip {
        
        let cell:GenericTapChip = collectionView.dequeueReusableCell(withReuseIdentifier: "GatewayImageCollectionViewCell", for: indexPath) as! GenericTapChip
        let currentViewModel = viewModel(at: indexPath.row)
        
        switch currentViewModel.identefier() {
        case "GatewayImageCollectionViewCell":
            return (cell as! GatewayImageCollectionViewCell)
        default:
            return cell
        }
    }
    
}
