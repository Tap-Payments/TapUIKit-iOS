//
//  TapSwitch.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/19/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit

public class TapSwitch: UIView {

    private var contentView: UIView?

    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var detailsLabel: UILabel!
    @IBOutlet weak private var switchButton: UISwitch!
    
    public override func awakeFromNib() {
        superview?.awakeFromNib()
//        self.configure()
    }
    
    // MARK:- Init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
    }
    
    private func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "TapOtpController", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

}
