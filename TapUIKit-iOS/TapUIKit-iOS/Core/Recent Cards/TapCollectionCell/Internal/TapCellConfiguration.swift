//
//  TapCellConfiguration.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 30/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import class UIKit.UIView
import struct UIKit.CGSize
import class UIKit.UICollectionView
import class UIKit.UICollectionViewCell

protocol ConfigurableCellBase: class{}

protocol ConfigurableCell:ConfigurableCellBase {
    associatedtype DataType
    func configure(data: DataType)
    func size() -> CGSize
}

protocol CellConfigurator {
    static var reuseId: String { get }
    var collectionViewCell:TapGenericCollectionViewCell? {get set}
    func configure(cell: UIView)
    func size(cell: UICollectionViewCell) -> CGSize
}


internal class CollectionCellConfigurator<CellType: ConfigurableCell, DataType>: CellConfigurator where CellType.DataType == DataType, CellType: UICollectionViewCell {
    var collectionViewCell: TapGenericCollectionViewCell?
    
    static var reuseId: String { return String(describing: CellType.self) }

    let item: DataType

    init(item: DataType) {
        self.item = item
    }

    func configure(cell: UIView) {
        (cell as! CellType).configure(data: item)
        
        if let myCell:TapGenericCollectionViewCell = cell as? TapGenericCollectionViewCell {
            collectionViewCell = myCell
        }
    }
    func size(cell: UICollectionViewCell) -> CGSize {
        return .zero
    }
}


internal class TapGenericCollectionViewCell: UICollectionViewCell {
    
    func cellViewModel() -> TapCellViewModel? {
        fatalError("Must be implemeneted by the sub class")
    }
}
