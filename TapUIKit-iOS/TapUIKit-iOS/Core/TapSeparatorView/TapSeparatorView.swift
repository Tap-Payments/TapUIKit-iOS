//
//  TapSeparatorView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/9/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit

public class TapSeparatorView: UIView {
    @IBOutlet var containerView: UIView!
    @IBOutlet var separationLine: UIView!
    @IBOutlet weak var separationLineTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var separationLineLeadingConstraint: NSLayoutConstraint!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        setupXib()
    }
    
    
    /// Loads in the custom TapVerticalView Xib from the local bundle and attach it to the created frame
    private func setupXib() {
        
        // 1. Load the nib
        guard let nibs = Bundle.init(for: TapVerticalView.self).loadNibNamed("TapSeparatorView", owner: self, options: nil),
            nibs.count > 0,
            let loadedView:UIView = nibs[0] as? UIView else { return }
        
        self.containerView = loadedView
        
        // 2. Set the bounds for the container view
        self.containerView.frame = bounds
        self.containerView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        // 3. Add this container view as the subview
        addSubview(containerView)
    }

}
