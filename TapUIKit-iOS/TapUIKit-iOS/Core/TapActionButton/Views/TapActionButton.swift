//
//  TapActionButton.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/16/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020
import Nuke
/// Represents the Tap Action Button View
@objc public class TapActionButton: UIView {
    
    /// The image that displays the title needed for the selected payment method. For example : Pay with KNET
    @IBOutlet weak var paymentTitleImageView: UIImageView!
    /// To control the correct width for the PAY WITH title image view. As it varies in widths, so if we
    /// dynamically adjusted the width, we will keep the ratio in tact with the provided designs
    @IBOutlet weak var paymentTitleImageViewWidthConstraint: NSLayoutConstraint!
    /// the main holder view
    @IBOutlet weak var contentView: UIView!
    /// The image used to show the laoder, success and failure animations
    @IBOutlet weak var loaderGif: UIImageView!
    /// The view holder for the uibutton
    @IBOutlet weak var viewHolder: UIView!
    /// The button itself
    @IBOutlet weak var payButton: UIButton!
    /// The width of the view holder to perform the expansion/collapsing animations when needed
    @IBOutlet weak var viewHolderWidth: NSLayoutConstraint!
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    /// The theme path to theme the TapGoPay cell in the login options bar
    private let themePath:String = "actionButton"
    /// The view model that controlls this view
    internal var viewModel:TapActionButtonViewModel? {
        didSet {
            reload()
        }
    }
    
    /// Represents the call back that need to be done after finishing the loading status
    internal var afterLoadingCallback:()->() = {}
    
    // Mark:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setInitialWidth()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        setInitialWidth()
    }
    
    /**
     Connects this tap action button view to the requied view model
     - Parameter viewModel: The tap action button view model that will handle all the UI and actions for this button view
     */
    @objc public func setup(with viewModel:TapActionButtonViewModel) {
        self.viewModel = viewModel
        self.viewModel?.viewDelegate = self
        guard let _ = TapThemeManager.currentTheme else {
            TapThemeManager.setDefaultTapTheme()
            return
        }
    }
    
    
    // MARK:- Private methods
    /// Adjusts the button to have the initil width relative to the superview width
    private func setInitialWidth() {
        // We need to wait a little bit until the view is renderd to calculate the correct needed width
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) { [weak self] in
            self?.viewHolderWidth.constant = (self?.contentView.frame.width ?? 0) - 32
            self?.viewHolder.updateConstraints()
            self?.layoutIfNeeded()
        }
    }
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.contentView = setupXIB()
        reload()
    }
    
    /// Compute the title of the payment button. This is the textual view that appears if there is no image title to be displayed
    fileprivate func fetchTextualButtonData() {
        if self.payButton.alpha != 1  && self.loaderGif.alpha == 0 {
            self.payButton.fadeIn()
        }
        payButton.setTitle(viewModel?.buttonDisplayTitle(), for: .normal)
        payButton.isUserInteractionEnabled = viewModel?.buttonStatus.isButtonEnabled() ?? false
    }
    
    /// Compute the image title to be displayed in case of anny/
    fileprivate func fetchImageTitleData() {
        // Make sure all good and we have the needed data
        self.paymentTitleImageView.image = nil
        //self.paymentTitleImageView.alpha = 0
        guard let (shouldDisplayImageTitle,imageTitleUrl) = viewModel?.paymentTitleImage(),
        shouldDisplayImageTitle else {
            self.paymentTitleImageView.isHidden = true
            if self.payButton.alpha != 1  && self.loaderGif.alpha == 0 {
                self.payButton.fadeIn()
            }
            return
        }

        Nuke.loadImage(with: imageTitleUrl, options: ImageLoadingOptions(placeholder: UIImage(),transition: .fadeIn(duration: 0.5)), into: self.paymentTitleImageView) { result in
            // Make sure that even after the time we took to load the image, we now have to show it
            guard let (shouldDisplayImageTitle,_) = self.viewModel?.paymentTitleImage(),
                  shouldDisplayImageTitle else {
                self.paymentTitleImageView.isHidden = true
                if self.payButton.alpha != 1 && self.loaderGif.alpha == 0 {
                    self.payButton.fadeIn()
                }
                return
            }
            self.payButton.alpha = 0.02
            self.paymentTitleImageView.contentMode = .scaleAspectFit
            self.paymentTitleImageView.translatesAutoresizingMaskIntoConstraints = false
            // Get the width of the provided UIImage title
            if let image:UIImage = self.paymentTitleImageView.image {
                let widthInPoints = image.size.width
                let widthInPixels = image.scale
                print("WIDTH : \(widthInPixels)")
                print("WIDTH : \(widthInPoints)")
                DispatchQueue.main.async {
                    self.paymentTitleImageViewWidthConstraint.constant = widthInPoints * 0.75
                    self.paymentTitleImageView.layoutIfNeeded()
                    self.paymentTitleImageView.updateConstraints()
                    self.paymentTitleImageView.isHidden = false
                }
            }else{
                self.paymentTitleImageView.isHidden = false
            }
            
            
            if self.paymentTitleImageView.alpha != 1 {
                self.paymentTitleImageView.fadeIn()
            }
        }
        
    }
    
    /// Fetch the displayed title from the view model
    private func fetchData() {
        // Let us compute the title of the payment button. This is the textual view that appears if there is no image title to be displayed
        fetchTextualButtonData()
        // Let us also compute the image title to be displayed in case of anny
        fetchImageTitleData()
    }
    
    /// Apply the needed logic to reload UI and localisations upon an order from the view model
    internal func reload() {
        applyTheme()
        fetchData()
    }
    
    /// Handles the logic from ui perspective when the button is clicked
    @IBAction func tapActionButtonClicked(_ sender: Any) {
        // inform the view model the button is clicked.. please do the needful
        viewModel?.didClickButton()
    }
    
    /**
     Decides the loader image gif
     - Returns: The loader gif from the TapThemeManager
     */
    internal func loaderImage() -> UIImage {
        
        return TapThemeManager.imageValue(for: "actionButton.Common.assets.loading") ?? .init()
        
    }
    
    /**
     Decides the loader image gif
     - Parameter status: Indicate which asset is required success or failure
     - Returns: The loader gif from the TapThemeManager
     */
    internal func loaderResultImage(with status:Bool) -> UIImage {
        return TapThemeManager.imageValue(for: "actionButton.Common.assets.\(status ? "success" : "error")") ?? .init()
    }
}


extension TapActionButton:TapActionButtonViewDelegate {
    
    func buttonFrame() -> CGRect {
        return bounds
    }
    
    func startLoading(completion: @escaping () -> () = {}) {
        // Save the callback we need to do after showing the result
        afterLoadingCallback = completion
        // load the gif loading image
        let loadingBudle:Bundle = Bundle.init(for: TapActionButton.self)
         
        let imageData = try? Data(contentsOf: loadingBudle.url(forResource: viewModel?.gifImageName(), withExtension: "gif")!)
        // Shring the button with showing the loader image
        shrink(with: try! UIImage(gifData: imageData!))
    }
    
    func endLoading(with success: Bool, completion: @escaping () -> () = {}) {
        // load the gif loading image based on the status
        let loadingBudle:Bundle = Bundle.init(for: TapActionButton.self)
        // Save the callback we need to do after showing the result
        afterLoadingCallback = completion
        let imageData = try? Data(contentsOf: loadingBudle.url(forResource: (success) ? viewModel?.successImageName() : viewModel?.errorImageName(), withExtension: "gif")!)
        let gif = try! UIImage(gifData: imageData!)
        loaderGif.setGifImage(gif, loopCount: 1) // Will loop forever
        if(success) {
            loaderGif.delegate = self
        }else {
            DispatchQueue.main.async {[weak self] in
                self?.viewHolder.fadeColor(toColor: .systemGray, duration: 1, completion: { _ in
                    completion()
                })
            }
        }
    }
    
    
    func expand() {
        
        loaderGif.fadeOut()
        loaderGif.delegate = nil
        viewHolderWidth.constant = frame.width - 32
        self.payButton.alpha = 0
        
        UIView.animate(withDuration: 1.0, animations: { [weak self] in
            self?.viewHolder.updateConstraints()
            self?.layoutIfNeeded()
        }) { x in
            self.payButton?.fadeIn()
        }
    }
    
    func shrink(with image:UIImage? = nil) {
        viewHolderWidth.constant = 48
        UIView.animate(withDuration: 1.0, animations: { [weak self] in
            self?.viewHolder.updateConstraints()
            self?.layoutIfNeeded()
            self?.viewModel?.delegate?.didEndLoading()
            self?.viewModel?.delegate?.didStartLoading()
        })
        
        guard let image = image else { return }
        // In the shrinkin process we need to do the following:
        
        // 1. Fade out the button itself.
        payButton.fadeOut()
        // 2. Fade out the button title if any (PAY WITH KNET for example.)
        paymentTitleImageView.fadeOut()
        // 3. Animate the background color of the button to the solid color if there is a solid color provided by the button style from the aip
        viewHolder.backgroundColor = viewModel?.loadingShrinkingBackgroundColor()
        
        loaderGif.fadeIn()
        loaderGif.delegate = nil
        loaderGif.setImage(image)
    }
}



// Mark:- Theme methods
extension TapActionButton {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        let status:TapActionButtonStatusEnum = viewModel?.buttonStatus ?? .InvalidPayment
        
        contentView.backgroundColor = status.buttonViewBackGroundColor()
        viewHolder.backgroundColor = viewModel?.backgroundColor()
        
        payButton.setTitleColor(status.buttonTitleColor(), for: .normal)
        payButton.titleLabel?.tap_theme_font = .init(stringLiteral: "\(themePath).Common.titleLabelFont")
        
        viewHolder.layer.borderColor = status.buttonBorderColor().cgColor
        viewHolder.layer.borderWidth = 1
        viewHolder.layer.cornerRadius = 24
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



extension TapActionButton:SwiftyGifDelegate {
    
    func gifDidStop(sender: UIImageView) {
        afterLoadingCallback()
    }
    
    
    
    
}

