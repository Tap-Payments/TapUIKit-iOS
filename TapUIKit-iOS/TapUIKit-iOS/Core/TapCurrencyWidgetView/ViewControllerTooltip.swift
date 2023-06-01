//
//  ViewControllerTooltip.swift
//  TapUIKit-iOS
//
//  Created by MahmoudShaabanAllam on 31/05/2023.
//  Copyright © 2023 Tap Payments. All rights reserved.
//

import Foundation

import UIKit

class TooltipController: Tooltip {
   
    
    
    init(view: UIView, direction: TooltipDirection, viewToShow: UIView, height: CGFloat, width: CGFloat) {
        self.view = view
        self.direction = direction
        self.key = "ds"
        self.viewToShow = viewToShow
        self.height = height
        self.width = width
    }
    var key: String
    
    var view: UIView
    
    var direction: TooltipDirection
    
    var viewToShow: UIView
    
    var height: CGFloat
    
    var width: CGFloat
    
    
}
//enum ViewControllerTooltip: Tooltip {
//    var viewToShow: UIView
//
//    var height: CGFloat
//
//    var width: CGFloat
//
//    case title(in: UIView)
//    case image(in: UIView)
//    case button(in: UIView)
//
//    var key: String {
//        let prefix: String = "tooltip_didshow_"
//        switch self {
//        case .title: return "\(prefix)title"
//        case .image: return "\(prefix)image"
//        case .button: return "\(prefix)button"
//        }
//    }
//
//    var didShow: Bool {
//        return false
//    }
//
//    func setShown() {
//        UserDefaults.standard.set(true, forKey: key)
//    }
//
//    var direction: TooltipDirection {
//        switch self {
//        case .title: return .up
//        case .image: return .up
//        case .button: return .up
//        }
//    }
//
//    var title: String? {
//        return nil
//    }
//
//    var message: String {
//        switch self {
//        case .title: return "This is the title"
//        case .image: return "This is the image"
//        case .button: return "This is the button"
//        }
//    }
//
//    var view: UIView {
//        switch self {
//        case let .title(view):
//            return view
//        case let .image(view):
//            return view
//        case let .button(view):
//            return view
//        }
//    }
//}

