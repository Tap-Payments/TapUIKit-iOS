//
//  InlineCardInput.swift
//  TapCardInputKit-iOS
//
//  Created by Osama Rabie on 08/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapCardVlidatorKit_iOS
import TapThemeManager2020
import LocalisationManagerKit_iOS

/// This extension provides the methods needed to setupu the views in the case of inline card input mode
extension TapCardInput {
    
    
    /**
     This method does the logic of developing the correct layout constraint for all the sub views to make suer it looks as the provided UI
     */
    internal func setupInlineConstraints() {
        
        // Defines the constrints for the card icon image vie
        icon.snp.remakeConstraints { (make) in
            make.width.equalTo(24)
            make.leading.equalToSuperview().offset(12)
            make.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        
        // Defines the constrints for the scan card button
        scanButton.snp.remakeConstraints { (make) in
            make.width.equalTo(24)
            make.trailing.equalToSuperview().offset(-12)
            make.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        // Defines the constrints for the card number field
        cardNumber.snp.remakeConstraints { (make) in
            // We set the card number width to the mimimum width based on its min visible characters attribute
            make.width.equalTo(cardNumber.calculatedWidth())
            make.height.equalToSuperview().dividedBy(2)
            make.leading.equalTo(icon.snp.trailing).offset(10)
            make.centerY.equalTo(icon.snp.centerY).offset((TapLocalisationManager.shared.localisationLocale == "ar") ? 4 : 0)
        }
        
        // Defines the constrints for the card expiry field
        cardExpiry.snp.remakeConstraints { (make) in
            // We set the card expiry width to the mimimum width based on its min visible characters attribute
            make.width.equalTo(cardExpiry.calculatedWidth())
            make.height.equalToSuperview().dividedBy(2)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(cardNumber.snp.centerY)
            //make.leading.greaterThanOrEqualTo(cardNumber.snp.trailing).offset(23)
        }
        
        // Defines the constrints for the card cvv field
        cardCVV.snp.remakeConstraints { (make) in
            // We set the card cvv width to the mimimum width based on its min visible characters attribute
            make.width.equalTo(cardCVV.calculatedWidth())
            make.height.equalToSuperview().dividedBy(2)
            make.trailing.equalTo(scanButton.snp.leading).offset(-0)
            make.centerY.equalTo(cardNumber.snp.centerY)
            //make.leading.greaterThanOrEqualTo(cardExpiry.snp.trailing).offset(23)
        }
        
        
        if showCardName {
            // Defines the constrints for the card cvv field
            cardName.snp.remakeConstraints { (make) in
                // We set the card cvv width to the mimimum width based on its min visible characters attribute
                make.leading.equalTo(icon.snp.leading)
                make.trailing.equalTo(cardCVV.snp.trailing)
                make.height.equalToSuperview().dividedBy(2)
                make.top.equalTo(icon.snp.bottom).offset(10)
                //make.leading.greaterThanOrEqualTo(cardExpiry.snp.trailing).offset(23)
            }
        }
        
        layoutIfNeeded()
        
    }
    
    /// This method will add the subviews needed in the inline mode for the super view
    internal func addInlineViews() {
        
        // Set the scroll view attribtes
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.alwaysBounceVertical = false
        //self.addSubview(scrollView)
        
        // Set the stack view attribtes
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.backgroundColor = .clear
        stackView.spacing = computedSpace
        stackView.distribution = .fillProportionally
        //scrollView.addSubview(stackView)
        
        // Add the card fields to the stack view in order
        fields.forEach { (field) in
            //stackView.addArrangedSubview(field)
            addSubview(field)
        }
        cardCVV.alignment = .right
        cardExpiry.alpha = 0
        cardCVV.alpha = 0
        cardName.alpha = 0
        // Add other fields not inside the scrolling areas
        addSubview(icon)
        addSubview(scanButton)
    }
    
    
    /// Call this method if you want to hide the card name field
    internal func removeCardName() {
        cardName.isHidden = true
        cardName.snp.makeConstraints { (make) in
            make.width.greaterThanOrEqualTo(0)
        }
    }
    
    /// This method will expand the fields that are declared to fill in the remainig empty space width wise. So if the parent view has empty space after adding all the views, then some fields will expand to fill in this space and gives better experience like card number or card name
    internal func calculateAutoMinWidths() {
        
        // Holds the last X point filled by a view
        var lastFilledPoint:CGFloat = 0
        // Holds all the fields that are declared to fill in the empty width, so we distribute the remaining space equally across them
        var fillingSpaceComponents:[TapCardTextField] = []
        
        // Loop through the stack view subviews INORDER to get the needed data in
        stackView.arrangedSubviews.forEach { (subView) in
            // Save the last filled X point while going in the loop
            lastFilledPoint = subView.frame.maxX
            
            // Check if the current field is of TapCardTextField
            if let cardField = subView as? TapCardTextField {
                // Check if it is delcared to fill in the empty space, if yes then marke it and save it
                if cardField.fillBiggestAvailableSpace {
                    fillingSpaceComponents.append(cardField)
                }
            }
        }
        
        // we need to make sure that the data we collected is correct. At some points, tghe method may be called before axctually laying out the views so we need to try again in a very short time
        if lastFilledPoint == 0 || self.scrollView.frame.width == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + (0.1)) { [weak self] in
                self?.calculateAutoMinWidths()
            }
            return
        }
        
        // If no field was delcared to fill in empty space, then we have nothing to do
        if fillingSpaceComponents.count == 0 {return}
        
        // Now it is the time to calculate the actual empty space we have beyond the last subview and distribute them across the marked fields
        
        // Get the total width
        let totalWidth = frame.width - computedSpace
        // Calculate the extra space that will add to the marked fields equally
        let extraSpaceWidthValue = (totalWidth - lastFilledPoint) / CGFloat(fillingSpaceComponents.count)
        
        // If there is no extra space to add then we can do nothing
        if extraSpaceWidthValue <= 0 {return}
        
        fillingSpaceComponents.forEach { (cardField) in
            // For each field add its share of the etxra space
            let newWidth = cardField.frame.width + extraSpaceWidthValue
            cardField.autoMinCalculatedWidth = newWidth
            cardField.snp.makeConstraints { (make) in
                make.width.greaterThanOrEqualTo(newWidth)
            }
            
        }
        
        self.scrollView.layoutIfNeeded()
    }
    
    
    
    internal func updateWidths(for subView:UIView?) {
        guard cardInputMode == .InlineCardInput else {return}
        if let nonNullView:TapCardTextField = subView as? TapCardTextField {
            //scrollView.layoutIfNeeded()
            layoutIfNeeded()
            
            performCvvAnimation()
            
            guard nonNullView == cardNumber else { return }
            
            // Determine the widths and the visibilot of the text fields based on the logic:
            // if there is a valid caard number we show all the fields.
            // If the card number is not focused, we show only the last four digits
            nonNullView.snp.updateConstraints( { [weak self] make in
                if let nonNullProtocolImplemented:CardInputTextFieldProtocol = nonNullView as? CardInputTextFieldProtocol {
                    make.width.equalTo(nonNullProtocolImplemented.calculatedWidth())
                    self?.updateConstraints()
                }
            })
            
            let correctNumberText:String = nonNullView.isEditing ? (tapCard.tapCardNumber ?? "") : String(tapCard.tapCardNumber?.suffix(4) ?? "")
            let spacing = CardValidator.cardSpacing(cardNumber: correctNumberText.onlyDigits())
            nonNullView.text = correctNumberText.cardFormat(with: spacing)
            
            // Set the visibilog of cvv and expirty based on the validty of the card number
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.cardExpiry.alpha = (nonNullView.isEditing || !self!.cardNumber.isValid(cardNumber: self?.tapCard.tapCardNumber)) ? 0 : 1
                self?.cardCVV.alpha = (nonNullView.isEditing || !self!.cardNumber.isValid(cardNumber: self?.tapCard.tapCardNumber)) ? 0 : 1
                self?.cardName.alpha = (nonNullView.isEditing || !self!.cardNumber.isValid(cardNumber: self?.tapCard.tapCardNumber)) ? 0 : 1
                self?.layoutIfNeeded()
            })
        }
    }
    
    /// Method to perform the flipping animation for the card icon when the CVV is focused
    internal func performCvvAnimation() {
        
        // Fetch the cvv icon from the the theme file
        let cvvPlaceHolder:UIImage =  TapThemeManager.imageValue(for: "\(themePath).commonAttributes.cvvPlaceHolder",from: Bundle(for: type(of: self)))!
        var newImage:UIImage? = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) { [weak self] in
            
            guard let nonNullSelf = self else { return }
            // Determine whether we need to show the card cvv icon ot the original icon
            if !(nonNullSelf.cardExpiry.isEditing || nonNullSelf.cardNumber.isEditing || nonNullSelf.cardName.isEditing) && nonNullSelf.cardCVV.isEditing {
                nonNullSelf.lastShownIcon = (nonNullSelf.icon.image != cvvPlaceHolder) ? nonNullSelf.icon.image : nonNullSelf.lastShownIcon
                newImage = cvvPlaceHolder
            }else if let nonNullImage = nonNullSelf.lastShownIcon, nonNullSelf.lastShownIcon != nonNullSelf.icon.image {
                let (brand,_) = nonNullSelf.cardBrandWithStatus()
                if let _ = nonNullSelf.shouldShowCardIcon(for: brand ?? .unknown) {
                    newImage = nonNullImage
                }else{
                    newImage = TapThemeManager.imageValue(for: "\(nonNullSelf.themePath).iconImage.image",from: Bundle(for: type(of: nonNullSelf)))
                }
            }
            
            // Perfom the icon change with flipping animation
            guard let nonNullNewImage:UIImage = newImage, nonNullNewImage != self?.icon.image else { return }
            nonNullSelf.icon.layer.removeAllAnimations()
            UIView.transition(with: nonNullSelf.icon, duration: 0.2, options: .transitionFlipFromLeft, animations: { [weak self] in
                self?.icon.image = nonNullNewImage
            })
        }
        
    }
    
}
