//
//  TapSwitch.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/19/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit

protocol TapSwitchControlDelegate {
    /**
     This method being called on switch change
     */
    func switchDidChange(sender: TapSwitchControl, isOn: Bool)
}

public class TapSwitchControl: UIView {

    /// The container view that holds everything from the XIB
    @IBOutlet weak internal var containerView: UIView!
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    @IBOutlet weak private var notesLabel: UILabel!

    @IBOutlet weak private var switchButton: UISwitch!
    @IBOutlet weak private var separator: UIView!

    
    var delegate: TapSwitchControlDelegate?
    
    public var hideSwitch: Bool = false {
        didSet {
            self.switchButton.isHidden = hideSwitch
        }
    }
    
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
    
    public var notes: String? {
        didSet {
            self.notesLabel.text = notes
        }
    }
    
    public var titleFont: UIFont = .systemFont(ofSize: 12) {
        didSet {
            self.titleLabel.font = titleFont
        }
    }
    
    public var subtitleFont: UIFont = .systemFont(ofSize: 12) {
        didSet {
            self.subtitleLabel.font = subtitleFont
        }
    }
    
    public var notesFont: UIFont = .systemFont(ofSize: 12) {
        didSet {
            self.notesLabel.font = notesFont
        }
    }
    
    public var titleTextColor: UIColor = .white {
        didSet {
            self.titleLabel.textColor = titleTextColor
        }
    }
    
    public var subtitleTextColor: UIColor = .white {
        didSet {
            self.subtitleLabel.textColor = subtitleTextColor
        }
    }
    
    public var notesTextColor: UIColor = .white {
        didSet {
            self.notesLabel.textColor = notesTextColor
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
    
    public var showSeparator: Bool = false {
        didSet {
            self.separator.isHidden = !self.showSeparator
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
        self.separator.isHidden = true
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
        self.notes = switchModel.notes
    }
    
    @objc func switchToggled(sender: UISwitch) {
        let value = sender.isOn
        print("switch value changed \(value)")
        self.delegate?.switchDidChange(sender: self, isOn: sender.isOn)
    }
}
