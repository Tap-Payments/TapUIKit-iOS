//
//  ItemTableViewCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/21/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020

class ItemTableViewCell: TapGenericTableCell {
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemDiscountPriceLabel: UILabel!
    @IBOutlet weak var itemQuantityView: UIView!
    @IBOutlet weak var itemQuantityLabel: UILabel!
    @IBOutlet weak var separatorView: TapSeparatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
