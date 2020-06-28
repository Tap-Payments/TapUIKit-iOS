//
//  TapCardPhoneIconView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/28/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020
import RxSwift
import Nuke
import SimpleAnimation

/// Represent the icon cell inside the horizontal bar of cards and telecom operators
public class TapCardPhoneIconView: UIView {
    /// Represents the content view that holds all the subviews
    @IBOutlet var contentView: UIView!
    /// Represents the icon of the card/telecom operator image view
    @IBOutlet weak var iconImageView: UIImageView!
    
    /// Rerpesents the loaded full colored image for the icon, will be used to show colored and grayscale version
    internal var iconImage:UIImage? = nil
    internal var viewModel:TapCardPhoneIconViewModel? {
        didSet{
            bindObservables()
        }
    }
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    /// The path to look for theme entry in
    private let themePath = "cardPhoneList.icon"
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
        // Icon url change callback
        Observable.combineLatest(viewModel.tapCardPhoneIconUrlObserver, viewModel.tapCardPhoneIconStatusObserver)
            .subscribe(onNext: { [weak self] (iconURL, iconStatus) in
                self?.loadIcon(from: iconURL, with: iconStatus)
                self?.applyTheme()
            }).disposed(by: disposeBag)
    }
    
    
    private func loadIcon(from url:String, with status:TapCardPhoneIconStatus) {
        // defensive coding to make sure it is a correct URL
        guard let iconURL = URL(string: url) else { return }
        
        let options = ImageLoadingOptions(
            transition: .fadeIn(duration: 0.2)
        )
        // Time to load the image iconf rom the given URL
        Nuke.loadImage(with: iconURL,options:options, into: iconImageView) { [weak self] _ in
            // Then based on the status we see, we will use teh icon as is or we will convert to black and white version
            if status == .otherIconIsSelected {
                // Another icon is specifically chosen, hence we need to show all others as grayscale
                self?.iconImageView.image = self?.iconImageView.image?.toGrayScale()
            }
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
    public func setupView(with viewModel:TapCardPhoneIconViewModel) {
        self.viewModel = viewModel
    }
}



// Mark:- Theme methods
extension TapCardPhoneIconView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        let status:TapCardPhoneIconStatus = viewModel?.tapCardPhoneIconStatus ?? .selected
        
        tap_theme_backgroundColor = .init(keyPath: "\(themePath).\(status.themePath()).backgroundColor")
        iconImageView.tap_theme_alpha = .init(keyPath: "\(themePath).\(status.themePath()).alpha")
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

