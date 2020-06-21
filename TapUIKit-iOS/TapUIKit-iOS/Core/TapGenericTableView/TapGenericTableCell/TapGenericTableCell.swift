//
//  TapGenericTableCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/21/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import class UIKit.UITableViewCell
/// This is a superclass for all the table cells views created, this will make sure all have the same interface/output and ease the parametery type in methods

class TapGenericTableCell: UITableViewCell {

    
    // MARK:- Internal methods
    
    /**
     All created chips views should have an interface to know about their selection status
     - Parameter state: True if it was just selected and false otherwise
     */
    internal func selectStatusChaned(with state:Bool) {
        return
    }
    
    /**
     Each cell generated must have an interface to tell its type
     - Returns: The corresponding cell type
     */
    internal func tapCellType() -> TapGenericCellType {
        return .ItemTableCell
    }
    
    /**
     All created cells should have an integhtrface to cnfigure itself with a given view model
     - Parameter viewModel: The view model the cell will attach itself to
     */
    internal func configureCell(with viewModel:TapGenericTableCellViewModel) {
        return
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}