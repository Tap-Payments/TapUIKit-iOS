//
//  TapCardTelecomPaymentView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/7/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//
import UIKit
import TapCardInputKit_iOS
import CommonDataModelsKit_iOS
import TapCardVlidatorKit_iOS
import TapThemeManager2020
// import SimpleAnimation


/// Represents a wrapper view that does the needed connections between cardtelecomBar, card input and telecom input
@IBDesignable @objc public class TapCardTelecomPaymentView: UIView {
    
    // MARK:- Internal variables
    /// last reported tap card
    internal var lastReportedTapCard:TapCard = .init()
    
    /// Computed value based on data source, will be nil if we have more than 1 brand. and will be the URL if the icon of the brand in case ONLY 1 brand
    internal var brandIconUrl:String? {
        if tapCardPhoneListViewModel.dataSource.count != 1 {
            return nil
        }else {
            return tapCardPhoneListViewModel.dataSource[0].tapCardPhoneIconUrl
        }
    }
    
    @IBOutlet weak var loadingBlurView: CardVisualEffectView!
    /// The hint view to show an error/warning message to indicate to the user what does he need to do next
    internal var hintView:TapHintView = .init()
    
    /// The view used to ask the user if he wants to save the card for later usage
    internal var saveCrdView:TapSaveCardView = .init()
    
    /// The view used to ask the user if he wants to save the card for TAP for later usage
    internal var saveCrdForTapView:TapInternalSaveCard = .init()
    
    /// Powered by tap view to be displayed within the card brands in case of a standalone card kit
    @IBOutlet weak var poweredByTapView: UIImageView!
    
    /// The view model that has the needed payment options and data source to display the payment view
    public var tapCardPhoneListViewModel:TapCardPhoneBarListViewModel = .init() {
        didSet {
            // Setup the bar view with the passed payment options list
            tapCardPhoneListView.setupView(with: tapCardPhoneListViewModel)
            // Listen to changes in the view model
            bindObserverbales()
            // Reset all the selections and the input fields
            clearViews()
        }
    }
    
    /// The view model that controls the wrapper view
    public var viewModel:TapCardTelecomPaymentViewModel?{
        didSet{
            viewModel?.tapCardTelecomPaymentView = self
            cardInputView.showScanningOption = viewModel?.showScanner ?? true
            saveCrdView.delegate = viewModel
            saveCrdForTapView.delegate = viewModel
        }
    }
    
    /// Used to collect any reactive garbage
    internal var hintStatus:TapHintViewStatusEnum? {
        didSet{
            if hintStatus != oldValue {validateHintStatus(with: hintStatus )}
        }
    }
    
    /// Represents the country that telecom options are being shown for, used to handle country code and correct phone length
    internal var tapCountry:TapCountry? {
        didSet {
            // Ons et, we need to setup the phont input view witht the new country details
            //phoneInputView.setup(with: tapCountry)
        }
    }
    
    // MARK:- Outlets
    /// The header view that displays the title of the section
    @IBOutlet weak var headerView: TapHorizontalHeaderView!
    /// The stack view will carry the components : Card input, save title view, save for tap view.
    @IBOutlet public weak var stackView: UIStackView!
    /// Represents the content view that holds all the subviews
    @IBOutlet var contentView: UIView!
    /// Represents the tab bar that holds the list of segmented availble payment options
    @IBOutlet weak var tapCardPhoneListView: TapCardPhoneBarList!
    /// Represents the card input view
    @IBOutlet public weak var cardInputView: TapCardInput! {
        didSet {
            cardInputView.delegate = self
        }
    }
    /// The view to be displayed to show the loading status waiting to show the 3ds page
    @IBOutlet weak var pre3DSLoadingView: UIView!
    /// A loader gif waiting for the 3ds page to be loaded
    @IBOutlet weak var tapLoadingGif: UIImageView!
    
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = bounds
    }
    
    @objc override func shouldShowTapView() -> Bool {
        return viewModel?.shouldShow ?? false
    }
    
    /// Creates connections and listen to events and data changes reactivly from the tab bar view model
    private func bindObserverbales() {
        // We need to know when a new segment is selected in the tab bar payment list, then we need to decide which input field should be shown
        tapCardPhoneListViewModel.selectedSegmentObserver = { [weak self] newSegmentID in
            guard newSegmentID != "" else { return }
            self?.showInputFor(for: newSegmentID)
        }
    }
    
    
    /**
     Call this method to tell the view to update the visibility of the save card switch view
     - Parameter showMerchantSave: If true, it will show up save card for merchant. False, otherwise
     - Parameter showTapSave: If true, it will show up save card for TAP. False, otherwise
     */
    internal func shouldShowSaveCardView(_ showMerchantSave:Bool, _ showTapSave:Bool) {
        // If we are in the status of saved card, this will not be visible ever
        let finalMerchantVisibility = showMerchantSave && (cardInputView.cardUIStatus == .NormalCard)
        _      = showTapSave && (cardInputView.cardUIStatus == .NormalCard)
        
        // prevent showing again if it is already shown
        guard saveCrdView.isHidden != !finalMerchantVisibility else { return }
        // Adjust visibility  the save for merchant & tap views
        saveCrdView.alpha = finalMerchantVisibility ? 0 : 1 // we make it alpha 0 if we will show it to enable fade in animation as intro
        saveCrdForTapView.alpha = 0
        
        saveCrdForTapView.ev?.dismiss()
        
        if finalMerchantVisibility {
            // Add it to the stack view first
            stackView.addArrangedSubview(saveCrdView)
            // make it not hidden
            saveCrdView.isHidden = false
            // Adjust the height constraint
            saveCrdView.snp.updateConstraints { make in
                make.height.equalTo(48)
            }
            // Update the height
            saveCrdView.layoutIfNeeded()
            saveCrdForTapView.layoutIfNeeded()
            stackView.layoutIfNeeded()
            layoutIfNeeded()
            updateHeight()
            // Time to fade in :)
            saveCrdView.fadeIn(duration: 0.75)
        }else{
            // We first fade out, then we update the layout
            // Hide it
            self.saveCrdView.isHidden = true
            // Remove it from the stackview
            self.stackView.removeArrangedSubview(self.saveCrdView)
            // Adjust the height constraint
            self.saveCrdView.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
            
            // Update the height
            self.saveCrdView.layoutIfNeeded()
            self.saveCrdForTapView.layoutIfNeeded()
            self.stackView.layoutIfNeeded()
            self.layoutIfNeeded()
            self.updateHeight()
        }
        
        /*saveCrdView.isHidden = !finalMerchantVisibility
         saveCrdForTapView.isHidden = !finalTapVisibility
         
         // Add or remove from the stackview
         if finalMerchantVisibility {
         stackView.addArrangedSubview(saveCrdView)
         }else{
         stackView.removeArrangedSubview(saveCrdView)
         }
         
         
         if finalTapVisibility {
         stackView.addArrangedSubview(saveCrdForTapView)
         }else{
         stackView.removeArrangedSubview(saveCrdForTapView)
         saveCrdForTapView.isSavedCardEnabled = false
         }
         
         
         // change the height of the save card view based on the given visibility
         saveCrdView.snp.updateConstraints { make in
         make.height.equalTo(finalMerchantVisibility ? 48 : 0)
         }
         saveCrdForTapView.snp.updateConstraints { make in
         make.height.equalTo(finalTapVisibility ? 48 : 0)
         }
         saveCrdView.layoutIfNeeded()
         saveCrdForTapView.layoutIfNeeded()
         stackView.layoutIfNeeded()
         layoutIfNeeded()
         if finalMerchantVisibility {
         saveCrdView.fadeIn(duration: 0.75)
         }
         
         if finalTapVisibility {
         saveCrdForTapView.fadeIn(duration: 0.75)
         }
         // Update the height of the total widget to reflect that
         updateHeight()*/
    }
    
    /**
     Changes the card view to show/hide the pre loading status before showing a 3ds page inside the card
     - Parameter to: If true it will be visible and invisible otherwise
     */
    internal func change3dsLoadingStatus(to:Bool) {
        let loadingBudle:Bundle = Bundle.init(for: TapActionButton.self)
        let imageData = try? Data(contentsOf: loadingBudle.url(forResource: TapThemeManager.stringValue(for: "inlineCard.loaderImage") ?? "Black-loader", withExtension: "gif")!)
        let gif = try! UIImage(gifData: imageData!)
        tapLoadingGif.setGifImage(gif, loopCount: 100) // Will loop forever
        tapLoadingGif.isHidden = true
        if to {
            pre3DSLoadingView.fadeIn()
            
            if saveCrdView.alpha == 1 && !saveCrdView.isHidden {
                saveCrdView.fadeOut(duration:0.25) { _ in
                    DispatchQueue.main.async {
                        let totalHeight:CGFloat = self.frame.height - 40 //self.saveCrdView.frame.height
                        self.snp.remakeConstraints { make in
                            make.height.equalTo(totalHeight)
                        }
                        self.layoutIfNeeded()
                    }
                }
                saveCrdForTapView.fadeOut(duration:0.25)
            }
        }else {
            pre3DSLoadingView.fadeOut()
        }
    }
    
    /**
     Call this method to tell the view to update the visibility of the supported brands bar
     - Parameter with: If true, it will show up. False, otherwise
     */
    internal func shouldShowSupportedBrands(_ with:Bool) {
        // If we are in the status of saved card, this will not be visible ever
        let finalVisibility = with && (cardInputView.cardUIStatus == .NormalCard)
        
        // change the height of the supported brands list based on the given visibility
        tapCardPhoneListView.snp.updateConstraints { make in
            make.height.equalTo(finalVisibility ? 24 : 0)
        }
        self.layoutIfNeeded()
        self.tapCardPhoneListView.layoutIfNeeded()
        self.tapCardPhoneListView.alpha = finalVisibility ? 1 : 0
        
        self.poweredByTapView.layoutIfNeeded()
        self.poweredByTapView.alpha = (finalVisibility && (viewModel?.showPoweredByTapView ?? false)) ? 1 : 0
        
        self.updateHeight()
        
        /*// Animate showing/hiding the supported brands bar
         UIView.animate(withDuration: 0.5) {
         self.stackView.layoutIfNeeded()
         
         } completion: { finished in
         if finished {
         // At the end we need to update the height of the whole widget to reflect the change in the supported bar height
         
         }
         }*/
        
    }
    
    /**
     Decides if we will show a warning view for the detected status or not. As we have extra conditions to meet based on the text field of the card element
     - Parameter status: The hint status to be reported. If nill, then we will insntruct the delegate to hide all the statuses
     */
    internal func validateHintStatus(with status:TapHintViewStatusEnum?) {
        // Make sure we have a watning status, not a NONE one
        guard let status = status, status != .None else {
            // If no hint to show, then we are ready to move on with our normal logic flow
            reportHintStatus(with: status)
            return
        }
        // let us decide the conditions based on the warning field
        var canShowHint:Bool = false
        
        switch status {
        case .WarningCVV:
            canShowHint = cardInputView.showShowHintForCVVField()
        case .WarningExpiryCVV:
            canShowHint = cardInputView.showShowHintForExpiryField()
        case .ErrorCardNumber:
            canShowHint = cardInputView.showShowHintForNumberField()
        case .WarningName:
            canShowHint = cardInputView.showShowHintForNameField()
        default:
            // If not related to warnings, we can go with the our normal logic flow
            reportHintStatus(with: status)
            return
        }
        
        // Now based on the conditions calclations we will see what to do
        if canShowHint {
            reportHintStatus(with: status)
        }else{
            //reportHintStatus(with: .None)
            hintStatus = .None
            removeHintView()
        }
    }
    
    /**
     Decides which delegate function about hint status to be called
     - Parameter status: The hint status to be reported. If nill, then we will insntruct the delegate to hide all the statuses
     */
    internal func reportHintStatus(with status:TapHintViewStatusEnum?) {
        // Check if there is a status to show, or we need to hide the hint view
        matchThemeAttributes()
        // Make sure we have a watning status, not a NONE one
        guard let status = status, status != .None else {
            // We don't have a hint to show
            viewModel?.delegate?.hideHints()
            removeHintView()
            // let us inform the parent app about the status by checking the card fields
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:  TapConstantManager.TapActionSheetStatusNotification), object: nil, userInfo: [TapConstantManager.TapActionSheetStatusNotification: viewModel?.allCardFieldsValid() ?? false ? TapActionButtonStatusEnum.ValidPayment : TapActionButtonStatusEnum.InvalidPayment] )
            return
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:  TapConstantManager.TapActionSheetStatusNotification), object: nil, userInfo: [TapConstantManager.TapActionSheetStatusNotification:TapActionButtonStatusEnum.InvalidPayment] )
        if status != .None && status != .Error {
            //viewModel?.delegate?.showHint(with: status)
            addHintView()
        }
        if status == .Error {
            viewModel?.delegate?.hideHints()
            removeHintView()
        }
    }
    
    /// Will add a warning/error hint view under the card input form to indicate to the user what does he miss
    internal func addHintView() {
        // We will have to update our height to reflect the addition of the hint view
        guard let hintStatus = hintStatus, hintView.viewModel.tapHintViewStatus != hintStatus, hintStatus != .None else {
            removeHintView()
            return
        }
        // Update the hint view type and height
        hintView.setup(with: .init(with: hintStatus))
        hintView.snp.remakeConstraints { make in
            make.height.equalTo(48)
        }
        // We need to prevent fade in animation in the case where there is already a hint and we just want to change the textual content.
        // Fade in will happen only if there is not hint view and we are going to show one
        let alreadyVisible = !hintView.isHidden
        if !alreadyVisible {
            hintView.alpha = 0
        }
        hintView.isHidden = false
        stackView.addArrangedSubview(hintView)
        updateHeight()
        if !alreadyVisible {
            hintView.fadeIn(duration: 0.75)
        }
    }
    
    /// Will remove a warning/error hint view under the card input form to indicate to the user what does he miss
    internal func removeHintView() {
        // We will have to update our height to reflect the removal of the hint view
        /*hintView.fadeOut(){_ in
         DispatchQueue.main.async {
         
         }
         }*/
        // it is not already removed
        guard !self.hintView.isHidden else { return }
        self.hintView.isHidden = true
        self.stackView.removeArrangedSubview(self.hintView)
        // Update the hint view type and height
        self.hintView.snp.remakeConstraints { make in
            make.height.equalTo(0)
        }
        hintView.setup(with: .init(with: .None))
        self.updateHeight()
    }
    
    /**
     Decides which input field should be shown based on the selected segment id
     - Parameter segment: The id of the segment of payment options we need to show the associated input
     */
    private func showInputFor(for  segment:String) {
        if segment == "telecom" {
            cardInputView.fadeOut()
            hintStatus = .Error
        }else if segment == "cards" {
            cardInputView.fadeIn()
            hintStatus = viewModel?.decideHintStatus(with: lastReportedTapCard,isCVVFocused: false)
        }
    }
    
    /// Used to reset all segment selections and input fields upon changing the data source
    internal func clearViews() {
        // Adjust the header view
        headerView.headerType = viewModel?.cardHeaderType ?? .CardInputTitle
        // Reset the card input
        cardInputView.reset()
        // Re init the card input
        cardInputView.setup(for: .InlineCardInput, showCardName: viewModel?.collectCardName ?? false, showCardBrandIcon: true, allowedCardBrands: tapCardPhoneListViewModel.dataSource.map{ $0.associatedCardBrand }.filter{ $0.brandSegmentIdentifier == "cards" }.map{ $0.rawValue }, cardsIconsUrls: tapCardPhoneListViewModel.generateBrandsWithIcons(), preloadCardHolderName: viewModel?.preloadCardHolderName ?? "", editCardName: viewModel?.editCardName ?? true, shouldFlip: viewModel?.shouldFlip ?? true, shouldThemeSelf: viewModel?.shouldThemeSelf ?? false)
        // Reset any selection done on the bar layout
        tapCardPhoneListViewModel.resetCurrentSegment()
        lastReportedTapCard = .init()
        viewModel?.delegate?.brandDetected(for: .unknown, with: .Invalid,cardStatusUI: .NormalCard, isCVVFocused: false)
        saveCrdForTapView.ev?.dismiss()
    }
    
    /// Call this to claculate the required height for the view. Takes in consideration the visibility of name row, save title, save subtitle, supported brands
    internal func updateHeight() {
        
        // Start with the height from the card input kit
        // We add to it if we need to show HINT or the Save card switch
        let (showSaveMerchant,showSaveTap) = viewModel?.shouldShowSaveCardView() ?? (false,false)
        let saveCardHeight:Double = (showSaveTap && showSaveMerchant) ? 86 : (showSaveTap || showSaveMerchant) ? 48 : 0
        
        let cardInputHeight = cardInputView.requiredHeight() + (shouldShowHintView() ? 48 : 0) + saveCardHeight
        // Let us calculate the total widget height
        let widgetHeight = cardInputHeight + 8 + tapCardPhoneListView.frame.height + headerView.frame.height
        snp.remakeConstraints { make in
            make.height.equalTo(widgetHeight)
        }
        layoutIfNeeded()
        // Now update the height of the stack view and the card input view
        stackView.snp.remakeConstraints { make in
            make.height.equalTo(cardInputHeight)
        }
        stackView.layoutIfNeeded()
        stackView.layoutSubviews()
    }
    
    /// Computes if the conditions to show a hint view are met and we have to
    private func shouldShowHintView() -> Bool {
        guard let hintStatus = hintStatus else {
            return false
        }
        return (hintStatus == .ErrorCardNumber || hintStatus == .WarningExpiryCVV || hintStatus == .WarningCVV || hintStatus == .WarningName)
    }
}

extension TapCardTelecomPaymentView: TapCardInputProtocol {
    public func cardFieldsAreFocused() {
        viewModel?.delegate?.cardFieldsAreFocused()
        //viewModel?.changeEnableStatus(to: true)
    }
    
    
    
    public func closeSavedCard() {
        viewModel?.delegate?.closeSavedCardClicked()
        headerView.headerType = viewModel?.cardHeaderType ?? .CardInputTitle
    }
    
    public func heightChanged() {
        updateHeight()
    }
    
    public func dataChanged(tapCard: TapCard,isCVVFocused:Bool) {
        hintStatus = viewModel?.decideHintStatus(with: tapCard, and: cardInputView.cardUIStatus, isCVVFocused: isCVVFocused)
        lastReportedTapCard = tapCard
        viewModel?.showHideSaveCardView()
    }
    
    public func cardDataChanged(tapCard: TapCard,cardStatusUI:CardInputUIStatus, isCVVFocused:Bool) {
        viewModel?.delegate?.cardDataChanged(tapCard: tapCard, cardStatusUI:cardStatusUI)
        lastReportedTapCard = tapCard
        hintStatus = viewModel?.decideHintStatus(with: tapCard, and: cardInputView.cardUIStatus, isCVVFocused: isCVVFocused)
        viewModel?.showHideSaveCardView()
    }
    
    public func brandDetected(for cardBrand: CardBrand, with validation: CrardInputTextFieldStatusEnum, cardStatusUI:CardInputUIStatus, isCVVFocused:Bool) {
        
        if validation == .Invalid || cardBrand == .unknown {
            tapCardPhoneListViewModel.resetCurrentSegment()
        }else if validation == .Incomplete {
            tapCardPhoneListViewModel.select(brand: cardBrand, with: false)
        }else if validation == .Valid {
            tapCardPhoneListViewModel.select(brand: cardBrand, with: true)
        }
        viewModel?.decideVisibilityOfSupportedBrandsBar()
        viewModel?.delegate?.brandDetected(for: cardBrand, with: validation, cardStatusUI: cardStatusUI, isCVVFocused: isCVVFocused)
    }
    
    public func scanCardClicked() {
        viewModel?.delegate?.scanCardClicked()
    }
    
    public func saveCardChanged(enabled: Bool) {
        
    }
    
    public func shouldAllowChange(with cardNumber: String) -> Bool {
        return viewModel?.delegate?.shouldAllowChange(with: cardNumber) ?? true
    }
}

extension TapCardTelecomPaymentView: TapPhoneInputProtocol {
    
    public func phoneBrandDetected(for cardBrand: CardBrand, with validation: CrardInputTextFieldStatusEnum) {
        
        if validation == .Invalid || cardBrand == .unknown {
            tapCardPhoneListViewModel.resetCurrentSegment()
        }else if validation == .Incomplete {
            tapCardPhoneListViewModel.select(brand: cardBrand, with: false)
        }else if validation == .Valid {
            tapCardPhoneListViewModel.select(brand: cardBrand, with: true)
        }
        
        viewModel?.delegate?.brandDetected(for: cardBrand, with: validation,cardStatusUI: .NormalCard, isCVVFocused: false)
        if validation == .Valid {
            endEditing(true)
        }
    }
    
}


extension TapCardTelecomPaymentView {
    // Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
        
        updateHeight()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        loadingBlurView.blurRadius = 10
        loadingBlurView.scale = 1
        
        // background color
        // If the card field is set to theme itself, then our parent view will be clear and coloring
        if viewModel?.shouldThemeSelf ?? false {
            stackView.backgroundColor = .clear
            saveCrdView.changeSeparatorViewVisibilty(to: false)
        }else{
            // Otherwise, the parent view will have to theme instead
            stackView.tap_theme_backgroundColor = ThemeUIColorSelector.init(keyPath: "inlineCard.commonAttributes.backgroundColor")
            saveCrdView.changeSeparatorViewVisibilty(to: true)
        }
        saveCrdView.changeBottomSeparatorViewVisibilty(to: (viewModel?.saveCardType == .All || viewModel?.saveCardType == .Tap))
        // The border color
        stackView.layer.tap_theme_borderColor = ThemeCgColorSelector.init(keyPath: "inlineCard.commonAttributes.borderColor")
        // The border width
        stackView.layer.tap_theme_borderWidth = ThemeCGFloatSelector.init(keyPath: "inlineCard.commonAttributes.borderWidth")
        // The border rounded corners
        // The whole view will be rounded if this view is fully wrapping the card fields + the save card views. Otherwise, it needs to adjust its lower corners
        // to be straight in case a hint view is visible to make them look well integrated
        cardInputView.applyRoundedCornersMask(for: [.layerMaxXMinYCorner, .layerMinXMinYCorner,[.layerMaxXMaxYCorner, .layerMinXMaxYCorner]])
        if viewModel?.shouldThemeSelf ?? false {
            if shouldShowHintView() {
                cardInputView.applyRoundedCornersMask(for: [.layerMaxXMinYCorner, .layerMinXMinYCorner])
            }
        }
        stackView.layer.tap_theme_cornerRadious = ThemeCGFloatSelector.init(keyPath: "inlineCard.commonAttributes.cornerRadius")
        pre3DSLoadingView.layer.tap_theme_cornerRadious = ThemeCGFloatSelector.init(keyPath: "inlineCard.commonAttributes.cornerRadius")
        pre3DSLoadingView.clipsToBounds = true
        loadingBlurView.layer.tap_theme_cornerRadious = ThemeCGFloatSelector.init(keyPath: "inlineCard.commonAttributes.cornerRadius")
        
        
        
        stackView.layer.shadowRadius = CGFloat(TapThemeManager.numberValue(for: "inlineCard.commonAttributes.shadow.radius")?.floatValue ?? 0)
        stackView.layer.tap_theme_shadowColor = ThemeCgColorSelector.init(keyPath: "inlineCard.commonAttributes.shadow.color")
        stackView.layer.shadowOffset = CGSize(width: CGFloat(TapThemeManager.numberValue(for: "inlineCard.commonAttributes.shadow.offsetWidth")?.floatValue ?? 0), height: CGFloat(TapThemeManager.numberValue(for: "inlineCard.commonAttributes.shadow.offsetHeight")?.floatValue ?? 0))
        stackView.layer.shadowOpacity = Float(TapThemeManager.numberValue(for: "inlineCard.commonAttributes.shadow.opacity")?.floatValue ?? 0)
        
        // Round the bottom edges of the hint view
        hintView.clipsToBounds = true
        hintView.layer.cornerRadius = stackView.layer.cornerRadius
        hintView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        // The blur 3ds overlay
        loadingBlurView.colorTint = TapThemeManager.colorValue(for: "inlineCard.blur3dsoverlay.tint")
        loadingBlurView.colorTintAlpha = CGFloat(TapThemeManager.numberValue(for: "inlineCard.blur3dsoverlay.tintAlpha")?.floatValue ?? 0)
        
        poweredByTapView.tap_theme_image = .init(keyPath: "inlineCard.poweredByTapLogo")
        
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
