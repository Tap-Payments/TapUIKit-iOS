//
//  TapSeparatorCollectionViewCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 30/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import struct UIKit.CGSize

class TapSeparatorCollectionViewCell: TapGenericCollectionViewCell {

     override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func cellViewModel() -> TapCellViewModel? {
        return nil
    }
    
    override func selectCell() {}
    override func deSelectCell() {}

}


extension TapSeparatorCollectionViewCell: ConfigurableCell {
    
    func configure(data: TapSeparatorViewModel) {
        
        self.layoutIfNeeded()
    }
    
    func size() -> CGSize {
        return .zero
    }
    
    typealias DataType = TapSeparatorViewModel
    
    
}
