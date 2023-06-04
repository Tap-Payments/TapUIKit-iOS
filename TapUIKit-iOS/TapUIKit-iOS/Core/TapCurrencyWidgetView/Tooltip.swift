//
//  ToolTip.swift
//  TapUIKit-iOS
//
//  Created by MahmoudShaabanAllam on 04/06/2023.
//  Copyright © 2023 Tap Payments. All rights reserved.
//

import Foundation

protocol Tooltip {
    var view: UIView {get}
    var viewToShow: UIView {get}
    var height: CGFloat {get}
    var width: CGFloat {get}
    var direction: TooltipDirection {get}
    var language: String {get}
}

extension Tooltip {
    func addSnapshot(to parentView: UIView?) {
        guard direction != .center else { return }
        parentView?.addSnapshot(of: view)
    }
}

protocol ToolTipDelegate: NSObject {
    func toolTipDidComplete()
}

extension UIView {
    fileprivate var snapshot: UIImage? {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let image = renderer.image { ctx in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
        }
        return image
    }

    fileprivate func addSnapshot(of view: UIView) {
        guard let snapshot = view.snapshot else { return }
        let imageView = SnapshotView(image: snapshot)
        let globalPoint = convert(view.frame.origin, from: view.superview)
        imageView.frame = CGRect(origin: globalPoint, size: view.frame.size)
        imageView.fadeIn()
    }
}
