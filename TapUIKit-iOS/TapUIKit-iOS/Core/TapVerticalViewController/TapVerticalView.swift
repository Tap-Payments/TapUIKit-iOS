//
//  TapVerticalView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/7/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit

public class TapVerticalView: UIView {
    
    @IBOutlet var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var stackView1: UIView!
    @IBOutlet weak var stackView2: UIView!
    
    @IBOutlet weak var containerView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        setupXib()
        setupStackScrollView()
    }
    
    
    private func setupStackScrollView() {
        scrollView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        scrollView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, keyPath == "contentSize" else { return }
        DispatchQueue.main.async {
            print("CONTENT \(self.scrollView.contentSize)")
        }
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.containerView.frame = bounds
    }
    
    func setupXib() {
        
        // 1. Load the nib
        guard let nibs = Bundle.init(for: TapVerticalView.self).loadNibNamed("TapVerticalView", owner: self, options: nil),
        nibs.count > 0,
            let loadedView:UIView = nibs[0] as? UIView else { return }
        
        self.containerView = loadedView
        
        // 2. Set the bounds for the container view
        self.containerView.frame = bounds
        self.containerView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        // 3. Add this container view as the subview
        addSubview(containerView)
}
}
