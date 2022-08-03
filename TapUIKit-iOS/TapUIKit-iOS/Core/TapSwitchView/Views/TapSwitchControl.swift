//
//  TapSwitch.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/19/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import LocalisationManagerKit_iOS

/// A protocol to be used to fire functions and events in the associated view
protocol TapSwitchControlDelegate {
    /**
     Instructs the parent view that the switch state is changed
     - Parameter sender: the sender switch control
     - Parameter isOn:  is the swtich is on currentyly. true if its on
     */
    func switchDidChange(sender: TapSwitchControl, isOn: Bool)
}

/// The view  that renders a tap switch control view
@objc public class TapSwitchControl: UIView {
    
    /// The container view that holds everything from the XIB
    @IBOutlet weak internal var containerView: UIView!
    /// Represents the main title text for the switch control view
    @IBOutlet weak private var titleLabel: UILabel!
    /// Represents the subtitle text for the switch control view
    @IBOutlet weak private var subtitleLabel: UILabel!
    /// Represents the notes text for the switch control view
    @IBOutlet weak private var notesLabel: UILabel!
    /// Represents the switch view button that switch off / on the view
    @IBOutlet weak private var switchButton: UISwitch!
    /// Represents the separator view to be shown in the bottom of the view
    @IBOutlet weak private var separator: UIView!
    
    @IBOutlet var toBeLocalizedLabels: [UILabel]!
    
    /// A protocol to communicate between switch control view and the parent view
    var delegate: TapSwitchControlDelegate?
    
    /// Represents a flag to hide / show the switch. hide the switch if set true
    @objc public var hideSwitch: Bool = false {
        didSet {
            self.switchButton.isHidden = hideSwitch
        }
    }
    /// Represents the  main title text
    @objc public var title: String? {
        didSet {
            self.titleLabel.text = title
        }
    }
    /// Represents the  subtitle text
    @objc public var subtitle: String? {
        didSet {
            self.subtitleLabel.text = subtitle
        }
    }
    /// Represents the notes text
    @objc public var notes: String? {
        didSet {
            self.notesLabel.text = notes
        }
    }
    /// Represents the font of title label text
    @objc public var titleFont: UIFont = .systemFont(ofSize: 12) {
        didSet {
            self.titleLabel.font = titleFont
        }
    }
    /// Represents the font of subtitle label text
    @objc public var subtitleFont: UIFont = .systemFont(ofSize: 12) {
        didSet {
            self.subtitleLabel.font = subtitleFont
        }
    }
    /// Represents the font of notes label text
    @objc public var notesFont: UIFont = .systemFont(ofSize: 12) {
        didSet {
            self.notesLabel.font = notesFont
        }
    }
    /// Represents the text color of title label
    @objc public var titleTextColor: UIColor = .white {
        didSet {
            self.titleLabel.textColor = titleTextColor
        }
    }
    /// Represents the text color of subtitle label
    @objc public var subtitleTextColor: UIColor = .white {
        didSet {
            self.subtitleLabel.textColor = subtitleTextColor
        }
    }
    /// Represents the text color of notes label
    @objc public var notesTextColor: UIColor = .white {
        didSet {
            self.notesLabel.textColor = notesTextColor
        }
    }
    /// Represents a flag to set the switch button to on / off. set to ture to make it on
    @objc public var isOn: Bool = false {
        didSet {
            self.switchButton.isOn = isOn
        }
    }
    /// Represents the color of the switch button when state is on
    @objc public var switchOnColor: UIColor? {
        didSet {
            self.switchButton.onTintColor = switchOnColor
        }
    }
    /// Represents the color of the switch button when state is off
    @objc public var switchOffColor: UIColor? {
        didSet {
            self.switchButton.thumbTintColor = switchOnColor
        }
    }
    /// Represents if the view should show separator or no. set to true to show it
    @objc public var showSeparator: Bool = false {
        didSet {
            self.separator.isHidden = !self.showSeparator
        }
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
        toBeLocalizedLabels.forEach{ $0.semanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight }
        self.separator.isHidden = true
        self.switchButton.addTarget(self, action: #selector(switchToggled(sender:)), for: .valueChanged)
    }
    
    /// Updates the container view frame to the parent view bounds
    @objc public override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.frame = bounds
    }
    
    /// Configures the labels and buttons of the switch control view
    /// - Parameter switchModel: the switch model used to manage the view properties
    @objc public func configure(with switchModel: TapSwitchModel) {
        self.title = switchModel.title
        self.subtitle = switchModel.subtitle
        self.isOn = switchModel.isOn
        self.notes = switchModel.notes
    }
    
    /// Called when the switch button state change.
    /// - Parameter sender: the sender switch view which has been toggled
    @objc func switchToggled(sender: UISwitch) {
        let value = sender.isOn
        print("switch value changed \(value)")
        self.delegate?.switchDidChange(sender: self, isOn: sender.isOn)
    }
}
