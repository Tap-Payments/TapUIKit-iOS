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
    
    public func remove(view:UIView) {
        handleDeletion(for: view)
    }
    
    public func remove(view:UIView, at index:Int) {
        let subViews = stackView.arrangedSubviews
        guard subViews.count > index else { return }

        handleDeletion(for: subViews[index])
    }
    
    private func handleDeletion(for view:UIView) {
        stackView.removeArrangedSubview(view)
    }
    
    
    public func add(view:UIView, at index:Int? = nil) {
        handleAddition(of: view, at: index)
    }
    
    private func handleAddition(of view:UIView, at index:Int? = nil) {
        
        if let index = index {
            stackView.insertArrangedSubview(view, at: index)
        }else{
            stackView.addArrangedSubview(view)
        }
    }
    
    public func updateSubViews(with newViews:[UIView]) {
        
        var toBeRemovedViews:[UIView] = []
        var toBeAddedViews:[UIView] = []
        
        // Check which views we will delete, which doesn't exist in the new views list
        stackView.arrangedSubviews.forEach { currentSubview in
            if !newViews.contains(currentSubview) {
                toBeRemovedViews.append(currentSubview)
            }
        }
        
        // Check which views we will add, which exists only in the new views list
        newViews.forEach { newSubview in
            if !stackView.arrangedSubviews.contains(newSubview) {
                toBeAddedViews.append(newSubview)
            }
        }
        
        // Delete and add the calculated views
        toBeRemovedViews.forEach{stackView.removeArrangedSubview($0)}
        toBeAddedViews.forEach{stackView.addArrangedSubview($0)}
        
        // Make sure they are of the same order now!
        for (newIndex, newView) in newViews.enumerated() {
            
            let oldIndex = stackView.arrangedSubviews.firstIndex(of: newView)
            if oldIndex != newIndex {
                stackView.removeArrangedSubview(newView)
                stackView.insertArrangedSubview(newView, at: newIndex)
            }
        }
    }
    
    private func setupXib() {
        
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
