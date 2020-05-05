//
//  TapRecentCardCollectionViewCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 30/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import class UIKit.UIStackView
import struct UIKit.CGSize

class TapRecentCardCollectionViewCell: TapGenericCollectionViewCell {

    @IBOutlet weak var containerView: UIStackView!
    var tapChipCard: TapChip = .init()
    var viewModel:TapCardRecentCardCellViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tapChipCard = TapChip(frame:containerView.bounds)
        containerView.addArrangedSubview(tapChipCard)
    }
    
    override func cellViewModel() -> TapCardRecentCardCellViewModel? {
        return viewModel
    }
    
    override func selectCell() {
        tapChipCard.showShadow(glowing: true)
    }
    
    override func deSelectCell() {
         tapChipCard.showShadow(glowing: false)
    }
}


extension TapRecentCardCollectionViewCell: ConfigurableCell {
    
    typealias DataType = TapCardRecentCardCellViewModel
    
    func configure(data: TapCardRecentCardCellViewModel) {
        //containerView.translatesAutoresizingMaskIntoConstraints = false
        viewModel = data
        tapChipCard.setup(viewModel: data)
        self.layoutIfNeeded()
    }
    
    func size() -> CGSize {
        return CGSize(width:tapChipCard.computeNeededWidth(),height: 40)
    }
}
