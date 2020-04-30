//
//  TapGoPayCollectionViewCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 30/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit

class TapGoPayCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containterView: UIStackView!
    var tapCardChip: TapChip?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

extension TapGoPayCollectionViewCell: ConfigurableCell {
    typealias DataType = TapGoPayCellViewModel
    
    func configure(data: TapGoPayCellViewModel) {
        tapCardChip = TapChip(frame:containterView.bounds)
        containterView.addArrangedSubview(tapCardChip!)
        tapCardChip!.setup(viewModel: data)
        self.layoutIfNeeded()
    }
    
    func size() -> CGSize {
        return CGSize(width:tapCardChip!.computeNeededWidth(),height: 40)
    }
}
