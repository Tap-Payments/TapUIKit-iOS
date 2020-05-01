//
//  TapSeparatorCollectionViewCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 30/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit

class TapSeparatorCollectionViewCell: TapGenericCollectionViewCell {

    //@IBOutlet weak var containerView: UIStackView!
    //var imageView: UIImageView = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        /*imageView.image = UIImage.loadLocally(with: "separator", from: type(of: self))
        imageView.contentMode = .scaleToFill
        containerView.addArrangedSubview(imageView)*/
        //containerView.alignment = .center
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
