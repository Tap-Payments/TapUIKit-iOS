//
//  TapGoPayCollectionViewCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 30/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit

class TapGoPayCollectionViewCell: TapGenericCollectionViewCell {

    @IBOutlet weak var containterView: UIStackView!
    var tapChipCard: TapChip = .init()
    var viewModel:TapGoPayCellViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tapChipCard = TapChip(frame:containterView.bounds)
        containterView.addArrangedSubview(tapChipCard)
        // Initialization code
    }
    
    override func cellViewModel() -> TapGoPayCellViewModel? {
        return viewModel
    }

}

extension TapGoPayCollectionViewCell: ConfigurableCell {
    typealias DataType = TapGoPayCellViewModel
    
    func configure(data: TapGoPayCellViewModel) {
        
        viewModel = data
        
        tapChipCard.setup(viewModel: data)
        
        self.layoutIfNeeded()
    }
    
    func size() -> CGSize {
        return CGSize(width:tapChipCard.computeNeededWidth(),height: 40)
    }
}
