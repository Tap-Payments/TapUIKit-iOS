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
    
    @IBOutlet weak var container: UIView!
    
    
    var removeCallback: (() -> Void)?
    private var timeoutTimer: Timer?
    
    static func newInstance() -> TooltipView {
        return Bundle(for: self).loadNibNamed("TooltipView", owner: self, options: nil)![0] as! TooltipView
    }
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.container = setupXIB()
//        applyTheme()
        
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
        
        let backgroundThemePath = "CurrencyWidget.currencyDropDown"
        contentView.tap_theme_backgroundColor = .init(keyPath: "\(backgroundThemePath).backgroundColor")
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
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] (_) in
            self?.hide()
        }
    }
    
    // MARK: - Animations
    
    func show() {
        fadeIn()
    }
    
    func hide() {
        timeoutTimer?.invalidate()
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
    func showTooltip(title: String? = nil,
                     message: String,
                     timeout: TimeInterval = 10,
                     action: String? = nil,
                     direction: TooltipDirection,
                     inView: UIView? = nil,
                     onHide: (() -> Void)? = nil) {
        removeTooltipView()
        
        guard let superview = inView ?? superview else { return }
        
        DispatchQueue.main.async {
            let tooltipView = TooltipView()
//            let currencyTableView = CurrencyTableView()
            tooltipView.removeCallback = onHide
            tooltipView.rightIndicatorView.isHidden = direction != .right
            tooltipView.leftIndicatorView.isHidden = direction != .left
            tooltipView.topIndicatorView.isHidden = direction != .up
            tooltipView.bottomIndicatorView.isHidden = direction != .down
 
            superview.addSubview(tooltipView)
       

//            currencyTableView.translatesAutoresizingMaskIntoConstraints  = false


            switch direction {
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
            
            if direction.isVertical {
                let centerAnchor = tooltipView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0)
                centerAnchor.priority = .defaultHigh
                tooltipView.indicatorCenterConstraint.isActive = false
                NSLayoutConstraint.activate([centerAnchor])
                
                NSLayoutConstraint.activate([
                    tooltipView.trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor, constant: -10),
                    tooltipView.leadingAnchor.constraint(greaterThanOrEqualTo: superview.leadingAnchor, constant: 10),
                    tooltipView.topIndicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0)
                ])
            } else if direction.isHorizontal {
                let centerAnchor = tooltipView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0)
                centerAnchor.priority = .defaultHigh
                NSLayoutConstraint.activate([centerAnchor])
            }
//            tooltipView.addSubview(currencyTableView)
//            tooltipView.bringSubviewToFront(currencyTableView)
//            let horizontalConstraint = currencyTableView.centerXAnchor.constraint(equalTo: tooltipView.centerXAnchor)
//              let verticalConstraint = currencyTableView.centerYAnchor.constraint(equalTo: tooltipView.centerYAnchor)
//            let widthConstraint = currencyTableView.widthAnchor.constraint(equalTo: tooltipView.widthAnchor, multiplier: 0.8)
//
//              let heightConstraint = currencyTableView.heightAnchor.constraint(equalTo: tooltipView.heightAnchor, multiplier: 0.8)
//              NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
            
            tooltipView.show()

            tooltipView.setupTimeout(timeout)
            
        }
    }
    
    public func removeTooltipView() {
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
    var didShow: Bool {get}
    var title: String? {get}
    var message: String {get}
    var direction: TooltipDirection {get}
    
    func setShown()
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
    private var tooltipsToShow: [Tooltip] = []
    var didSetupTooltips: Bool = false
    
    weak var delegate: ToolTipDelegate?
    
    func setup(tooltips: [Tooltip], darkView: UIView) {
        didSetupTooltips = true
        
        tooltipsToShow = tooltips
        parentView = darkView
        
        guard !tooltipsToShow.allSatisfy({ $0.didShow }) else {
            delegate?.toolTipDidComplete()
            return
        }
        
        parentView?.addDarkView { [weak self] in
            self?.showNext()
        }
    }
    
    private func showNext() {
        parentView?.removeTooltipView()
        
        guard let tooltip = tooltipsToShow.first else {
            parentView?.removeDarkView()
            if tooltipsToShow.isEmpty {
                delegate?.toolTipDidComplete()
            }
            return
        }
        
        tooltipsToShow.removeFirst()
        
        guard !tooltip.didShow else {
            showNext()
            return
        }
        
        let isLast = tooltipsToShow.count == 0
        
        let action = isLast ? "Done" : "Next"
        
        tooltip.addSnapshot(to: parentView)
        tooltip.view.showTooltip(title: tooltip.title,
                                 message: tooltip.message,
                                 action: action,
                                 direction: tooltip.direction,
                                 inView: parentView,
                                 onHide: { [weak self] in
            tooltip.setShown()
            self?.parentView?.removeSnapshots()
            self?.showNext()
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
        addSubview(imageView)
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
    func addDarkView(completion: (() -> Void)? = nil) {
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
                completion?()
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
