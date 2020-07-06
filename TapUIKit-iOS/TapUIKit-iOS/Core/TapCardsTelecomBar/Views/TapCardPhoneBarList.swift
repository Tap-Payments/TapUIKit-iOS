//
//  TapCardPhoneBarList.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/29/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020
import RxSwift
import SimpleAnimation
import EasyAnimation

/// Represent the view of tab bar list
public class TapCardPhoneBarList: UIView {

    /// Represents the content view that holds all the subviews
    @IBOutlet var contentView: UIView!
    /// Represents the holder layout for our icons horizontal bar views
    @IBOutlet weak var stackView: UIStackView!
    /// Represents the leading constraint for the under line view
    @IBOutlet weak var underLineLeadingConstraint: NSLayoutConstraint!
    /// Represents the width constraint for the under line view
    @IBOutlet weak var underLineWidthConstraint: NSLayoutConstraint!
    /// Represents the under line view
    @IBOutlet weak var underLineBar: UIProgressView! {
        didSet{
            // We need to make it changable regardless of the constraint
            underLineBar.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    /// Represents the max width the tabs can expand to
    internal var maxWidth:CGFloat = 50
    
    /// Represents the View model that controls the actions and the ui of the card/phone tab bar
    internal var viewModel:TapCardPhoneBarListViewModel? {
        didSet{
            // Once set, we delcare ourself as the view delegate for the view model
            viewModel?.viewDelegate = self
            // We wire up the notifications from the view model to our channels
            bindObservables()
        }
    }
    
    
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    /// The path to look for theme entry in
    private let themePath = "cardPhoneList"
    /// The disposing bag for all reactive observables
    private var disposeBag:DisposeBag = .init()
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
        self.contentView = setupXIB()
        applyTheme()
    }
    
    /// Used to bind all the needed reactive observables to its matching logic and functions
    private func bindObservables() {
        // Defensive coding to make sure there is a view model
        guard let viewModel = viewModel else { return }
        // Listen to the change in the data source (the tabs to be rendered)
        viewModel.dataSourceObserver
            .distinctUntilChanged()
            .filter{ $0.count > 0 }
            .subscribe(onNext: { [weak self] (dataSource) in
                // On a new data sourec, we need to reload our data
                self?.relodData(with: viewModel.generateViews(with: self?.maxWidth ?? 60))
        }).disposed(by: disposeBag)
        
        // Listen to the change of the validation result of the selected tab
        viewModel.selectedIconValidatedObserver.distinctUntilChanged()
            .subscribe(onNext: { [weak self] (validated) in
                // When the validation of the selection changes, we need to re theme our underline view
                self?.themeBar(selectionValid: validated)
                self?.isUserInteractionEnabled = !validated
            }).disposed(by: disposeBag)
    }
    
    /**
     Handles the logic for drawing the tabs
     - Parameter views: The list of tabs we need to draw in the tab bar list view
     */
    internal func relodData(with views:[TapCardPhoneIconView] = []) {
        // Hide the bar
        underLineBar.alpha = 0
        underLineLeadingConstraint.constant = 0
        underLineBar.updateConstraints()
        underLineBar.layoutIfNeeded()
        // Hide the current tabs
        stackView.popOut(duration: 0.1) {[weak self] _ in
            guard let nonNullSelf = self else { return }
            
            // Remove all subviews first
            let arrangedSubviews = nonNullSelf.stackView.arrangedSubviews
            arrangedSubviews.forEach({
                nonNullSelf.stackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            })
            // Update it with the latest views
            views.forEach({ nonNullSelf.stackView.addArrangedSubview($0) })
            //nonNullSelf.stackView.layoutIfNeeded()
            // Show the new tabs
            nonNullSelf.stackView.popIn(duration:0.1)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = bounds
    }
    
    /**
     Apply the needed setup and attach the passed view model
     - Parameter viewModel: The TapCardPhoneIconViewModel responsible for controlling this icon view
     */
    public func setupView(with viewModel:TapCardPhoneBarListViewModel) {
        self.viewModel = viewModel
    }
    
}


// Mark:- Theme methods
extension TapCardPhoneBarList {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        
        maxWidth = (TapThemeManager.numberValue(for: "\(themePath).maxWidth") as? CGFloat) ?? 50
        
        let stackMargin:CGFloat = (TapThemeManager.numberValue(for: "\(themePath).insets") as? CGFloat) ?? 28
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: stackMargin, bottom: 0, trailing: stackMargin)
        
        themeBar()
    }
    
    /**
     Applies the correct theme for the underline view
     - Parameter selectionValid: Indicates whether the current selected tab is a valid selection or not, as this affects the theme of the underline view
     */
    private func themeBar(selectionValid:Bool = false) {
        let selectionThemePath:String = selectionValid ? "selected" : "unselected"
        underLineBar.tap_theme_progressTintColor = .init(keyPath: "\(themePath).underline.\(selectionThemePath).backgroundColor")
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        
        guard lastUserInterfaceStyle != self.traitCollection.userInterfaceStyle else {
            return
        }
        lastUserInterfaceStyle = self.traitCollection.userInterfaceStyle
        applyTheme()
    }
}



extension TapCardPhoneBarList:TapCardPhoneBarListViewModelDelegate {
    
    func calculatedSpacing() -> CGFloat {
        
        // We need to make sure first if we have more than 1 tab inside the tab bar
        guard stackView.arrangedSubviews.count > 1 else { return 0 }
        // Otherwise, we send the spacing which is the edge to edge spacing between two tabs
        return ((stackView.arrangedSubviews[1].frame.minX - stackView.arrangedSubviews[0].frame.maxX) / 2) + 2
        
    }
    func animateBar(to x: CGFloat, with width: CGFloat) {
        
        underLineBar.layoutIfNeeded()
        underLineBar.updateConstraints()
        self.underLineLeadingConstraint.constant = x
        self.underLineWidthConstraint.constant = width
        
        UIView.animate(withDuration: 0.3, animations: {
                        self.underLineBar.alpha = 1
                        self.underLineBar.layoutIfNeeded()
                        self.underLineBar.updateConstraints()
                        self.layoutIfNeeded()
        }, completion: {_ in
            print(self.underLineBar.frame)
        })
    }
}
