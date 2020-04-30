//
//  TapCollectionViewCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 29/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import struct UIKit.CGSize
import class UIKit.UIView
import UIKit


public protocol TapCollectionViewCell {
    associatedtype DataType
    func configure(data: DataType)
    func size()->CGSize
}


public protocol CellConfigurator {
    static var reuseId: String { get }
    func configure(cell: UIView)
}

public class CollectionCellConfigurator<CellType: TapCollectionViewCell, DataType>: CellConfigurator where CellType.DataType == DataType, CellType: UICollectionViewCell {
    public static var reuseId: String { return String(describing: CellType.self) }
    
    let item: DataType

    public init(item: DataType) {
        self.item = item
    }

    public func configure(cell: UIView) {
        (cell as! CellType).configure(data: item)
    }
}
