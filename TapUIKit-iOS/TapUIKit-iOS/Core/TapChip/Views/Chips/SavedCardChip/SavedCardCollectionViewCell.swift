//
//  SavedCardCollectionViewCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/17/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//


import TapThemeManager2020
import Nuke
import SnapKit
/// Represents the Saved card chip cell

@objc class SavedCardCollectionViewCell: GenericTapChip {
    // MARK:- Variables
    
    /// Reference to the loading view that we will display when performing delete card api
    @IBOutlet weak var deleteCardLoadingView: UIView!
    /// Reference to the loading gif, that is displaued when we are deleting a saved card chip
    @IBOutlet weak var loaderGif: UIImageView!
    /// Reference to the blur view, that is displaued when we are deleting a saved card chip
    @IBOutlet weak var blurView: CardVisualEffectView!
    /// Reference to the saved card icon image view
    @IBOutlet weak var cardBrandIconImageView: UIImageView!
    /// Reference to the saved card secured number
    @IBOutlet weak var cardSchemeLabel: UILabel!
    /// Reference to the delete icon image view
    @IBOutlet weak var deleteIconImageView: UIImageView!
    /// Reference to the delete save card button
    @IBOutlet weak var deleteCardButton: UIButton!
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    /// Holds the long press recognizer to start the card deletion process
    private var longPressRecognizer: UILongPressGestureRecognizer?
    /// view model that will control the cell view
    @objc public var viewModel:SavedCardCollectionViewCellModel = .init() {
        didSet{
            // Upon assigning a new view model we attach ourslef as the delegate
            viewModel.cellDelegate = self
            if oldValue != viewModel {
                // We reload the cell data from the view model
                reload()
            }
        }
    }
    
    // MARK:- Internal methods
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        viewModel.deleteChip()
    }
    
    func identefier() -> String {
        return viewModel.identefier()
    }
    
    override func configureCell(with viewModel: GenericTapChipViewModel) {
        // Defensive coding it is the correct view model type
        guard let correctTypeModel:SavedCardCollectionViewCellModel = viewModel as? SavedCardCollectionViewCellModel else { return }
        self.viewModel = correctTypeModel
        // Apply the editing ui if needed
        changedEditMode(to: viewModel.editMode)
        changedEditMode(to: viewModel.editMode)
        // setup the long press gesture recognizer
        setupLongPressGestureRecognizer()
    }
    
    /// Will add the long press gesture recognizer to the cell.
    internal func setupLongPressGestureRecognizer() {
        // Let us remove it, if it was added before
        if let nonNullLongPressRecognizer = longPressRecognizer {
            removeGestureRecognizer(nonNullLongPressRecognizer)
        }
        // Configure the recognizer
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(savedCardLongPressed))
        // let us add it, again
        if let nonNullLongPressRecognizer = longPressRecognizer {
            addGestureRecognizer(nonNullLongPressRecognizer)
        }
    }
    
    /// Handles the post logic needed when a saved card cell is long pressed
    @objc internal func savedCardLongPressed(sender: UILongPressGestureRecognizer) {
        // let us fire the delete process
        viewModel.deleteChip()
    }
    
    override func selectStatusChaned(with status:Bool) {
        
        // update the shadow for GoPayCell
        guard !viewModel.editMode else { return }
        applyTheme()
    }
    
    override func tapChipType() -> TapChipType {
        return .SavedCardChip
    }
    
    
    /// The path to look for theme entry in
    private var themePath:String {
        get{
            return tapChipType().themePath()
        }
    }
    
    // Mark:- Init methods
    override func awakeFromNib() {
        super.awakeFromNib()
        lastUserInterfaceStyle = self.traitCollection.userInterfaceStyle
        commonInit()
    }
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        applyTheme()
    }
    
    /// Holds the logic needed to display and fetch all the requied data and displays it inside the cell view
    func reload() {
        loadImages()
        assignLabels()
        // Apply the editing ui if needed
        changedEditMode(to: viewModel.editMode)
    }
    
    /// Responsible for all logic needed to load all images in the cell
    private func loadImages() {
        //cardBrandIconImageView.fadeOut()
        
        // Make sure we have a valid URL
        guard let iconURL:URL = URL(string: viewModel.icon ?? "") else { return }
        // load the image from the URL
        cardBrandIconImageView.downloadImage(with: iconURL, nukeOptions: nil)
    }
    
    /// Responsible for all logic needed to assign the textual info into the corresponding labels
    private func assignLabels() {
        cardSchemeLabel.text = viewModel.title
    }
}


// Mark:- Theme methods
extension SavedCardCollectionViewCell {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        let shadowPath:String = isSelected ? "selected" : "unSelected"
        
        tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        layer.tap_theme_cornerRadious = .init(keyPath: "horizontalList.chips.radius")
        //layer.shadowColor = try! UIColor(tap_hex: "#FF0000").cgColor
        layer.tap_theme_shadowColor = ThemeCgColorSelector.init(keyPath: "\(themePath).\(shadowPath).shadow.color")
        layer.shadowOffset = CGSize(width: CGFloat(TapThemeManager.numberValue(for: "\(themePath).\(shadowPath).shadow.offsetWidth")?.floatValue ?? 0), height: CGFloat(TapThemeManager.numberValue(for: "\(themePath).\(shadowPath).shadow.offsetHeight")?.floatValue ?? 0))
        layer.shadowOpacity = Float(TapThemeManager.numberValue(for: "\(themePath).\(shadowPath).shadow.opacity")?.floatValue ?? 0)
        layer.shadowRadius = CGFloat(TapThemeManager.numberValue(for: "\(themePath).\(shadowPath).shadow.radius")?.floatValue ?? 0)
        layer.tap_theme_borderColor = .init(keyPath: "\(themePath).\(shadowPath).shadow.borderColor")
        layer.tap_theme_borderWidth = .init(keyPath: "\(themePath).\(shadowPath).shadow.borderWidth")
        
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        
        cardSchemeLabel.tap_theme_font = .init(stringLiteral: "\(themePath).labelTextFont",shouldLocalise:false)
        cardSchemeLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).labelTextColor")
        
        deleteIconImageView.tap_theme_image = .init(keyPath: "\(themePath).editMode.deleteIcon")
        
        
        blurView.blurRadius = 6
        blurView.scale = 1
        blurView.layer.tap_theme_cornerRadious = .init(keyPath: "\(themePath).blurOverlay.radius")
        blurView.clipsToBounds = true
        
        blurView.colorTint = TapThemeManager.colorValue(for: "\(themePath).blurOverlay.color")
        blurView.colorTintAlpha = CGFloat(TapThemeManager.numberValue(for: "\(themePath).blurOverlay.alpha")?.floatValue ?? 0)
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



extension SavedCardCollectionViewCell:GenericCellChipViewModelDelegate {
    func changedDisabledMode(to: Bool) {
        reload()
    }
    
    
    
    func changedEditMode(to: Bool) {
        if to {
            deleteCardButton.fadeIn()
            deleteIconImageView.fadeIn()
        }else{
            deleteCardButton.fadeOut()
            deleteIconImageView.fadeOut()
        }
        self.wiggle(on: to)
    }
    
    func changeSelection(with status: Bool) {
        selectStatusChaned(with: status)
    }
    
    
    func showLoadingState() {
        let loadingBudle:Bundle = Bundle.init(for: TapActionButton.self)
        let imageData = try? Data(contentsOf: loadingBudle.url(forResource: TapThemeManager.stringValue(for: "inlineCard.loaderImage") ?? "Black-loader", withExtension: "gif")!)
        let gif = try! UIImage(gifData: imageData!)
        loaderGif.setGifImage(gif, loopCount: 100)
        
        deleteCardLoadingView.fadeIn(duration:1)
    }
    
    func hideLoadingState() {
        deleteCardLoadingView.fadeOut()
    }
    
}

