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
import class UIKit.UICollectionViewFlowLayout
import MOLH
/// Protocol that defines the methods and data inside our Tap Generic cell, to be used to allow the collectionview to render cells without actually knowing them
protocol ConfigurableCell {
    /// The generic data type of the cell
    associatedtype DataType
    /**
        Each cell will override this method to do the needed UI configuration based on the given data
     - Parameter data: The generic view model object will be passed based on the cell type and the cell will use it in displaying and rendering itself UI wise
     */
    func configure(data: DataType)
    /**
     Each cell will override this to tell whoever is interesed what is the needed size to be fully displayed
     - Returns: The size needed by the cell to be fully displayed
     */
    func size() -> CGSize
}

/// Protocol to wrap our generic cells class and map between the generic cells and the external callers
protocol CellConfigurator {
    /// Will compue the reuse id to be used in dequeing the cells
    static var reuseId: String { get }
    /// Will hold an instance of the actual uicollectionviewcell this wrapper represents
    var collectionViewCell:TapGenericCollectionViewCell? {get set}
    func configure(cell: UIView)
    func size(cell: UICollectionViewCell) -> CGSize
}

/// This class maps each cell based on the given cell type to its original cell and applies its own logic
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

/// Represents the generic TapCollectoinView cell which defines a single point communication and the needed methods to be implemnented by each cell
internal class TapGenericCollectionViewCell: UICollectionViewCell {
    
    /**
     Gives back the inner view model used by the cell to display itself
     - Returns: The view model controlling the cell
     */
    func cellViewModel() -> TapCellViewModel? {
        fatalError("Must be implemeneted by the sub class")
    }
    /// Holds the logic needed by each cell UI wise when it is selected
    func selectCell() {
        fatalError("Must be implemeneted by the sub class")
    }
    /// Holds the logic needed by each cell UI wise when it is deselected
    func deSelectCell() {
        fatalError("Must be implemeneted by the sub class")
    }
}


internal class flippableCollectionLayout:UICollectionViewFlowLayout{
    override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return MOLHLanguage.isRTLLanguage()
    }
}

