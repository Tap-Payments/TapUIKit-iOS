//
//  TapRecentCardCollectionViewCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 29/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import SnapKit

public class TapRecentCardCollectionViewCell: UICollectionViewCell {
    
    lazy var tapCardChip:TapChip = TapChip.init()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        contentView.addSubview(tapCardChip)
        tapCardChip.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TapRecentCardCollectionViewCell: TapCollectionViewCell {
    
    public typealias DataType = TapCardRecentCardCellViewModel
    
    public func configure(data: TapCardRecentCardCellViewModel) {
        tapCardChip.setup(viewModel: data)
    }
    
    public func size() -> CGSize {
        return CGSize(width: 0,height: 0)
    }
}
