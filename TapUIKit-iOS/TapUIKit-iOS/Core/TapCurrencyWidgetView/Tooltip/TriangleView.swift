//
//  TriangleView.swift
//  TapUIKit-iOS
//
//  Created by MahmoudShaabanAllam on 04/06/2023.
//  Copyright © 2023 Tap Payments. All rights reserved.
//

import Foundation
import TapThemeManager2020
/// Triangle point to up view
internal class UpTriangleView : UIView {
    
    private let themePath: String = "CurrencyWidget.currencyDropDown"

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let color = TapThemeManager.colorValue(for: "\(themePath).backgroundColor") ?? .white
        let borderColor = TapThemeManager.colorValue(for: "\(themePath).borderColor") ?? .white
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.minY))
        context.closePath()
        context.setFillColor(color.cgColor)
        
        if let path = context.path {
            context.setStrokeColor(borderColor.cgColor)
            context.strokePath()
            context.addPath(path)
        }
        
        context.fillPath()
    }
}

/// Triangle point to down view
internal class DownTriangleView : UIView {
    
    private let themePath: String = "CurrencyWidget.currencyDropDown"

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let color = TapThemeManager.colorValue(for: "\(themePath).backgroundColor") ?? .white
        let borderColor = TapThemeManager.colorValue(for: "\(themePath).borderColor") ?? .white
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.maxY))
        context.closePath()
        context.setFillColor(color.cgColor)

        if let path = context.path {
            context.setStrokeColor(borderColor.cgColor)
            context.strokePath()
            context.addPath(path)
        }
        
        context.fillPath()
    }
}

/// Triangle point to left view
internal class LeftTriangleView : UIView {
    
    private let themePath: String = "CurrencyWidget.currencyDropDown"

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let color = TapThemeManager.colorValue(for: "\(themePath).backgroundColor") ?? .white
        let borderColor = TapThemeManager.colorValue(for: "\(themePath).borderColor") ?? .white
        context.beginPath()
        context.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.minX, y: (rect.maxY / 2.0)))
        context.closePath()
        context.setFillColor(color.cgColor)
        
        if let path = context.path {
            context.setStrokeColor(borderColor.cgColor)
            context.strokePath()
            context.addPath(path)
        }
        
        context.fillPath()
    }
}

/// Triangle point to right view
internal class RightTriangleView : UIView {
    
    private let themePath: String = "CurrencyWidget.currencyDropDown"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let color = TapThemeManager.colorValue(for: "\(themePath).backgroundColor") ?? .white
        let borderColor = TapThemeManager.colorValue(for: "\(themePath).borderColor") ?? .white
        
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: (rect.maxY / 2.0)))
        context.closePath()
        context.setFillColor(color.cgColor)
        
        if let path = context.path {
            context.setStrokeColor(borderColor.cgColor)
            context.strokePath()
            context.addPath(path)
        }
        
        context.fillPath()
    }
}


