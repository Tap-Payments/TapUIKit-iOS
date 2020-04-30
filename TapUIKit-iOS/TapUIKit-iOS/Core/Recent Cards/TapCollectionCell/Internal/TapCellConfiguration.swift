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

protocol ConfigurableCell {
    associatedtype DataType
    func configure(data: DataType)
    func size() -> CGSize
}

protocol CellConfigurator {
    static var reuseId: String { get }
    func configure(cell: UIView)
}


internal class CollectionCellConfigurator<CellType: ConfigurableCell, DataType>: CellConfigurator where CellType.DataType == DataType, CellType: UICollectionViewCell {
    static var reuseId: String { return String(describing: CellType.self) }

    let item: DataType

    init(item: DataType) {
        self.item = item
    }

    func configure(cell: UIView) {
        (cell as! CellType).configure(data: item)
    }
}
