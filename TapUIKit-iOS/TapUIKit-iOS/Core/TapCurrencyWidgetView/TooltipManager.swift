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
                                       direction: tooltipToShow.direction, language: tooltipToShow.language,
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
    
    fileprivate var globalFrame: CGRect? {
        let rootView = UIApplication.shared.keyWindow?.rootViewController?.view
        return self.convert(self.frame, to: rootView)
    }
    
    fileprivate func showTooltip(viewToShow: UIView,
                                 height: CGFloat,
                                 width: CGFloat,
                                 direction: TooltipDirection,
                                 language: String,
                                 inView: UIView? = nil,
                                 pointView: UIView? = nil,
                                 onHide: (() -> Void)? = nil) {
        removeTooltipView()
        var tooltipDirection = direction
        guard let superview = inView ?? superview else { return }
        
        let frameRelativeToScreen = pointView?.globalFrame
        
        if (frameRelativeToScreen?.origin.y ?? 0) + height + 20 > UIScreen.main.bounds.height, tooltipDirection == .up {
            tooltipDirection = .down
        }
        
        if (frameRelativeToScreen?.origin.y ?? 0) - height - 20 < 0, tooltipDirection == .down {
            tooltipDirection = .up
        }
        
        DispatchQueue.main.async {
            let tooltipView = TooltipView()
            tooltipView.removeCallback = onHide
            tooltipView.rightIndicatorView.isHidden = tooltipDirection != .right
            tooltipView.leftIndicatorView.isHidden = tooltipDirection != .left
            tooltipView.topIndicatorView.isHidden = tooltipDirection != .up
            tooltipView.bottomIndicatorView.isHidden = tooltipDirection != .down
            
            superview.addSubview(tooltipView)
            
            
            viewToShow.translatesAutoresizingMaskIntoConstraints  = false
            
            NSLayoutConstraint.activate([tooltipView.widthAnchor.constraint(equalToConstant: width)])
            NSLayoutConstraint.activate([tooltipView.heightAnchor.constraint(equalToConstant: height)])
            
            switch tooltipDirection {
            case .up:
                NSLayoutConstraint.activate([tooltipView.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)])
            case .down:
                NSLayoutConstraint.activate([tooltipView.bottomAnchor.constraint(equalTo: self.topAnchor, constant: 0)])
            case .right:
                NSLayoutConstraint.activate([tooltipView.rightAnchor.constraint(equalTo: self.leftAnchor, constant: 0)])
            case .left:
                NSLayoutConstraint.activate([tooltipView.leftAnchor.constraint(equalTo: self.rightAnchor, constant: 0)])
            case .center:
                NSLayoutConstraint.activate([
                    tooltipView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
                    tooltipView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
                    tooltipView.leadingAnchor.constraint(greaterThanOrEqualTo: superview.leadingAnchor, constant: 37),
                    tooltipView.trailingAnchor.constraint(greaterThanOrEqualTo: superview.trailingAnchor, constant: 37)
                ])
            }
            
            if tooltipDirection.isVertical {
                let leadingConstraintConstant: CGFloat = 20
                if language == "ar" {
                    let triangleConstraintConstant: CGFloat = (pointView?.frame.origin.x ?? 0) + leadingConstraintConstant + 5
                    NSLayoutConstraint.activate([
                        tooltipView.topIndicatorView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: triangleConstraintConstant),
                        tooltipView.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -1 * leadingConstraintConstant),
                    ])
                } else {
                    let triangleConstraintConstant: CGFloat = (pointView?.frame.origin.x ?? 0) + leadingConstraintConstant + 5
                    NSLayoutConstraint.activate([
                        tooltipView.topIndicatorView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: triangleConstraintConstant),
                        tooltipView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: leadingConstraintConstant),
                    ])
                }
                
            } else if tooltipDirection.isHorizontal {
                let centerAnchor = tooltipView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0)
                centerAnchor.priority = .defaultHigh
                NSLayoutConstraint.activate([centerAnchor])
            }
            tooltipView.addSubview(viewToShow)
            tooltipView.bringSubviewToFront(viewToShow)
            let horizontalConstraint = viewToShow.centerXAnchor.constraint(equalTo: tooltipView.centerXAnchor)
            let verticalConstraint = viewToShow.centerYAnchor.constraint(equalTo: tooltipView.centerYAnchor)
            let widthConstraint = viewToShow.widthAnchor.constraint(equalTo: tooltipView.widthAnchor, multiplier: 0.8)
            let heightConstraint = viewToShow.heightAnchor.constraint(equalTo: tooltipView.heightAnchor, multiplier: 0.8)
            NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
            
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

