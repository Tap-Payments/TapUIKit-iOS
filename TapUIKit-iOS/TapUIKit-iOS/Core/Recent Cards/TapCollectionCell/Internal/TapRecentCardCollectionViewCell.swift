//
//  TapRecentCardCollectionViewCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 30/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit

class TapRecentCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIStackView!
    var tapChipCard: TapChip?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}


extension TapRecentCardCollectionViewCell: ConfigurableCell {
    
    typealias DataType = TapCardRecentCardCellViewModel
    
    func configure(data: TapCardRecentCardCellViewModel) {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        tapChipCard = TapChip(frame:containerView.bounds)
        containerView.addArrangedSubview(tapChipCard!)
        tapChipCard!.setup(viewModel: data)
        self.layoutIfNeeded()
    }
    
    func size() -> CGSize {
        return CGSize(width:tapChipCard!.computeNeededWidth(),height: 40)
    }
}
