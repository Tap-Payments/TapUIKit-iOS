//
//  TooltipManager.swift
//  TapUIKit-iOS
//
//  Created by MahmoudShaabanAllam on 04/06/2023.
//  Copyright © 2023 Tap Payments. All rights reserved.
//

import Foundation

class TooltipManager: NSObject {
    
    private var parentView: UIView?
    private var tooltipToShow: Tooltip?
    var didSetupTooltips: Bool = false
    weak var delegate: ToolTipDelegate?
    
    func setup(tooltipToShow: Tooltip, mainView: UIView) {
        didSetupTooltips = true
        self.tooltipToShow = tooltipToShow
        parentView = mainView
    }
    
    func showToolTip() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        parentView?.addDarkView { [weak self] darkView in
            self?.show()
            darkView.addGestureRecognizer(tapGesture)
        }
    }
    func removeTooltips() {
        parentView?.removeTooltipView()
        parentView?.removeDarkView()
        self.delegate?.toolTipDidComplete()
    }
    
    @objc private func viewTapped() {
        removeTooltips()
    }
    
    private func show() {
        guard let tooltipToShow = tooltipToShow else { return }
        tooltipToShow.addSnapshot(to: parentView)
        tooltipToShow.view.showTooltip(viewToShow:tooltipToShow.viewToShow,
                                       height: tooltipToShow.height,
                                       width: tooltipToShow.width,
                                       direction: tooltipToShow.direction,
                                       inView: parentView,
                                       pointView: tooltipToShow.view,
                                       onHide: { [weak self] in
            self?.delegate?.toolTipDidComplete()
            self?.parentView?.removeSnapshots()
        })
    }
    
}


enum TooltipDirection {
    case up
    case down
    case right
    case left
    case center
    
    var isVertical: Bool {
        switch self {
        case .up, .down:
            return true
        default:
            return false
        }
    }
    
    var isHorizontal: Bool {
        switch self {
        case .right, .left:
            return true
        default:
            return false
        }
    }
}

extension UIView {
    
    fileprivate func removeSnapshots() {
        subviews.filter({ $0 is SnapshotView }).forEach { (view) in
            view.fadeOut {
                view.removeFromSuperview()
            }
        }
    }
    
    fileprivate func addDarkView(completion: ((UIView) -> Void)? = nil) {
        removeDarkView()
        
        DispatchQueue.main.async {
            let darkView = DarkView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
            darkView.backgroundColor = UIColor.clear
            self.addSubview(darkView)
            
            NSLayoutConstraint.activate([
                darkView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
                darkView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
                darkView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
                darkView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)
            ])
            
            darkView.fadeIn {
                completion?(darkView)
            }
        }
    }
    
    fileprivate func removeDarkView() {
        DispatchQueue.main.async {
            for subview in self.subviews {
                if let subview = subview as? DarkView {
                    subview.fadeOut() {
                        subview.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    fileprivate var showingDarkView: Bool {
        return subviews.first(where: { $0 is DarkView }) != nil
    }
 
    fileprivate func showTooltip(viewToShow: UIView,
                                 height: CGFloat,
                                 width: CGFloat,
                                 direction: TooltipDirection,
                                 inView: UIView? = nil,
                                 pointView: UIView? = nil,
                                 onHide: (() -> Void)? = nil) {
        removeTooltipView()
        guard let superview = inView ?? superview else { return }
        guard let pointView = pointView else { return }

        DispatchQueue.main.async {
            let tooltipView = TooltipView()
            let tooltipDirection = tooltipView.updatePositionRegardingScreenSize(pointView, height, direction)
            tooltipView.removeCallback = onHide
            tooltipView.setupArrowView(tooltipDirection: tooltipDirection)
            superview.addSubview(tooltipView)
            tooltipView.applySizeConstraint(height: height, width: width)
            tooltipView.setupTooltipDirection(pointView: pointView, mainView: superview, tooltipDirection: tooltipDirection)
            tooltipView.setupViewToShow(viewToShow: viewToShow)
            tooltipView.show()
            
        }
    }
    
    fileprivate func removeTooltipView() {
        DispatchQueue.main.async {
            for subview in self.subviews {
                if let subview = subview as? TooltipView {
                    subview.removeFromSuperview()
                }
            }
        }
    }
}

class DarkView: UIView {
    
}

