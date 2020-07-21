//
//  TapSwitch.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/19/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit

protocol TapSwitchControlDelegate: class {
    /**
     This method being called on switch change
     */
    func switchDidChange(sender: TapSwitchControl, isOn: Bool)
}

public class TapSwitchControl: UIView {

    /// The container view that holds everything from the XIB
    @IBOutlet weak private var containerView: UIView!
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    @IBOutlet weak private var switchButton: UISwitch!
    
    weak var delegate: TapSwitchControlDelegate?
    
    public var title: String? {
        didSet {
            self.titleLabel.text = title
        }
    }
    
    public var subtitle: String? {
        didSet {
            self.subtitleLabel.text = subtitle
        }
    }
    
    public var isOn: Bool = false {
        didSet {
            self.switchButton.isOn = isOn
        }
    }
    
    public var switchOnColor: UIColor? {
        didSet {
            self.switchButton.onTintColor = switchOnColor
        }
    }
    
    public var switchOffColor: UIColor? {
        didSet {
            self.switchButton.thumbTintColor = switchOnColor
        }
    }
    
    public override func awakeFromNib() {
        superview?.awakeFromNib()
//        self.configure()
    }
    
    // Mark:- Init methods
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
        self.containerView = setupXIB()
        //handlerImageView.translatesAutoresizingMaskIntoConstraints = false
//        applyTheme()
        self.switchButton.addTarget(self, action: #selector(switchToggled(sender:)), for: .valueChanged)
    }
    
    /// Updates the container view frame to the parent view bounds
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.frame = bounds
    }

    public func configure(with switchModel: TapSwitchModel) {
        self.title = switchModel.title
        self.subtitle = switchModel.subtitle
        self.isOn = switchModel.isOn
    }
    
    @objc func switchToggled(sender: UISwitch) {
        let value = sender.isOn
        print("switch value changed \(value)")
        self.delegate?.switchDidChange(sender: self, isOn: sender.isOn)
    }
}
