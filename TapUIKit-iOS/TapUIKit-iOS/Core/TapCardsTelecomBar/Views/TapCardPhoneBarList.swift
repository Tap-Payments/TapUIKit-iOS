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

public class TapCardPhoneBarList: UIView {

    /// Represents the content view that holds all the subviews
    @IBOutlet var contentView: UIView!
    /// Represents the holder layout for our icons horizontal bar views
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var underLineLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var underLineWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var underLineBar: UIProgressView! {
        didSet{
            underLineBar.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    internal var maxWidth:CGFloat = 50
    
    internal var viewModel:TapCardPhoneBarListViewModel? {
        didSet{
            viewModel?.viewDelegate = self
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
    
    private func bindObservables() {
        // Defensive coding to make sure there is a view model
        guard let viewModel = viewModel else { return }
        viewModel.dataSourceObserver
            .distinctUntilChanged()
            .filter{ $0.count > 0 }
            .subscribe(onNext: { [weak self] (dataSource) in
                self?.relodData(with: viewModel.generateViews(with: self?.maxWidth ?? 60))
        }).disposed(by: disposeBag)
        
        
        viewModel.selectedIconValidatedObserver.distinctUntilChanged()
            .subscribe(onNext: { [weak self] (validated) in
                self?.themeBar(selectionValid: validated)
            }).disposed(by: disposeBag)
    }
    
    
    internal func relodData(with views:[TapCardPhoneIconView] = []) {
        // Hide the bar
        underLineBar.alpha = 0
        // Hide it
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
            // Show it
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
