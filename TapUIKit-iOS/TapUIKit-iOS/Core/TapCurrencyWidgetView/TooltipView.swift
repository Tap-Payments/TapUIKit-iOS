//
//  TooltipView.swift
//  TapUIKit-iOS
//
//  Created by MahmoudShaabanAllam on 31/05/2023.
//  Copyright © 2023 Tap Payments. All rights reserved.
//

import UIKit

class TooltipView: UIView {
    @IBOutlet weak var topIndicatorView: UIView!
    @IBOutlet weak var bottomIndicatorView: UIView!
    @IBOutlet weak var leftIndicatorView: UIView!
    @IBOutlet weak var rightIndicatorView: UIView!
    @IBOutlet weak var indicatorCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var verticalIndicatorCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var cardBlurView: CardVisualEffectView!
    @IBOutlet weak var container: UIView!
    
    
    var removeCallback: (() -> Void)?
    internal let themePath: String = "poweredByTap"

    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.container = setupXIB()
        //        applyTheme()
        
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
        
        let backgroundThemePath = "CurrencyWidget.currencyDropDown"
        contentView.backgroundColor = .clear
//        contentView.tap_theme_backgroundColor = .init(keyPath: "\(backgroundThemePath).backgroundColor")
        
        cardBlurView.scale = 1
        cardBlurView.blurRadius = 6
        //        cardBlurView.colorTint = TapThemeManager.colorValue(for: "\(themePath).blurColor")
        cardBlurView.colorTint = .white
//        cardBlurView.colorTintAlpha = CGFloat(TapThemeManager.numberValue(for: "\(themePath).blurAlpha")?.floatValue ?? 0)
        cardBlurView.colorTintAlpha = 0.73
        
        contentView.layer.tap_theme_cornerRadious = ThemeCGFloatSelector.init(keyPath: "\(backgroundThemePath).cornerRadius")
        contentView.layer.tap_theme_borderColor = .init(keyPath: "\(backgroundThemePath).borderColor")
        contentView.layer.masksToBounds = true
        contentView.clipsToBounds = false
        contentView.layer.shadowOpacity = 1
        contentView.layer.tap_theme_shadowRadius = .init(keyPath: "\(backgroundThemePath).shadowBlur")
        contentView.layer.tap_theme_shadowColor = .init(keyPath: "\(backgroundThemePath).shadowColor")
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    // Mark:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setupTimeout(_ timeout: TimeInterval) {
        //        timeoutTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] (_) in
        //            self?.hide()
        //        }
    }
    
    // MARK: - Animations
    
    func show() {
        fadeIn()
    }
    
    func hide() {
        removeCallback?()
        fadeOut {
            self.removeFromSuperview()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func dismiss(_ sender: Any) {
        hide()
    }
    
}


extension UIView {
    internal var globalFrame: CGRect? {
           let rootView = UIApplication.shared.keyWindow?.rootViewController?.view
           return self.convert(self.frame, to: rootView)
       }
    
    internal func showTooltip(viewToShow: UIView,
                     height: CGFloat,
                     width: CGFloat,
                     direction: TooltipDirection,
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
                //                let centerAnchor = tooltipView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0)
                //                centerAnchor.priority = .defaultHigh
                tooltipView.indicatorCenterConstraint.isActive = false
                //                NSLayoutConstraint.activate([centerAnchor])
                //
                NSLayoutConstraint.activate([
                    //                    tooltipView.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 5),
                    tooltipView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 10),
                    //                    tooltipView.topIndicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0)
                ])
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
            
            //            tooltipView.setupTimeout(timeout)
            
        }
    }
    
    internal func removeTooltipView() {
        DispatchQueue.main.async {
            for subview in self.subviews {
                if let subview = subview as? TooltipView {
                    subview.removeFromSuperview()
                }
            }
        }
    }
}


protocol Tooltip {
    var key: String {get}
    var view: UIView {get}
    var viewToShow: UIView {get}
    var height: CGFloat {get}
    var width: CGFloat {get}
    var direction: TooltipDirection {get}
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



class SnapshotView: UIImageView {
    
}

extension UIView {
    var snapshot: UIImage? {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let image = renderer.image { ctx in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
        }
        return image
    }
    
    func addSnapshot(of view: UIView) {
        guard let snapshot = view.snapshot else { return }
        let imageView = SnapshotView(image: snapshot)
        let globalPoint = convert(view.frame.origin, from: view.superview)
        imageView.frame = CGRect(origin: globalPoint, size: view.frame.size)
        imageView.fadeIn()
    }
    
    func removeSnapshots() {
        subviews.filter({ $0 is SnapshotView }).forEach { (view) in
            view.fadeOut {
                view.removeFromSuperview()
            }
        }
    }
}

class DarkView: UIView {
    
}

extension UIView {
    func addDarkView(completion: ((UIView) -> Void)? = nil) {
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
    
    func removeDarkView() {
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
    
    var showingDarkView: Bool {
        return subviews.first(where: { $0 is DarkView }) != nil
    }
}

class TriangleView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let color = TapThemeManager.colorValue(for: "CurrencyWidget.currencyDropDown.backgroundColor") ?? .white
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.minY))
        context.closePath()
        context.setFillColor(color.cgColor)
        context.fillPath()
    }
}

class InvertedTriangleView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let color = TapThemeManager.colorValue(for: "CurrencyWidget.currencyDropDown.backgroundColor") ?? .white
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.maxY))
        context.closePath()
        context.setFillColor(color.cgColor)
        context.fillPath()
    }
}

class LeftTriangleView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let color = TapThemeManager.colorValue(for: "CurrencyWidget.currencyDropDown.backgroundColor") ?? .white
        context.beginPath()
        context.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.minX, y: (rect.maxY / 2.0)))
        context.closePath()
        context.setFillColor(color.cgColor)
        context.fillPath()
    }
}

class RightTriangleView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let color = TapThemeManager.colorValue(for: "CurrencyWidget.currencyDropDown.backgroundColor") ?? .white
        
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: (rect.maxY / 2.0)))
        context.closePath()
        
        context.setFillColor(color.cgColor)
        context.fillPath()
    }
}

extension UIView {
    func fadeIn(completion: (() -> Void)? = nil) {
        alpha = 0
        isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1
        }) { (_) in
            completion?()
        }
    }
    
    func fadeOut(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { (_) in
            self.isHidden = true
            completion?()
        }
    }
}
