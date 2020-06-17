//
//  TapChipHorizontalList.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/14/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020

public class TapChipHorizontalList: UIView {

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var contentView:UIView!
    
    var viewModel:TapChipHorizontalListViewModel = .init() {
        didSet{
            viewModel.cellDelegate = self
        }
    }
    
    private let themePath:String = "horizontalList"
    // Mark:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    public func changeViewMode(with viewModel:TapChipHorizontalListViewModel) {
        self.viewModel = viewModel
    }
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.contentView = setupXIB()
        //handlerImageView.translatesAutoresizingMaskIntoConstraints = false
        applyTheme()
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        
        viewModel.registerAllXibs(for: collectionView)
        let itemSpacing:CGFloat = CGFloat(TapThemeManager.numberValue(for: "\(themePath).itemSpacing")?.floatValue ?? 0)
        
        /*if let flowLayout:UICollectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
            flowLayout.minimumInteritemSpacing = itemSpacing
            
        }*/
        
        
        let flowLayout: flippableCollectionLayout = flippableCollectionLayout()
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.minimumInteritemSpacing = itemSpacing
        flowLayout.scrollDirection = .horizontal
        
        collectionView.collectionViewLayout = flowLayout
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func reloadData() {
         collectionView.reloadSections([0])
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = bounds
    }
}


extension TapChipHorizontalList:UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfRows()
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = viewModel.viewModel(at: indexPath.row)
        let cell:GenericTapChip = viewModel.dequeuCell(in: collectionView, at: indexPath)
        cell.configureCell(with: model)
        return cell
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath.row)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        viewModel.didDeselectItem(at: indexPath.row)
    }
}

extension TapChipHorizontalList:TapChipHorizontalViewModelDelegate {
    func reload(new dataSource: [GenericTapChipViewModel]) {
        reloadData()
    }
    
    
}



// Mark:- Theme methods
extension TapChipHorizontalList {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        let sectionMargin:CGFloat = CGFloat(TapThemeManager.numberValue(for: "\(themePath).margin")?.floatValue ?? 0)
        collectionView.contentInset = .init(top: 0, left: sectionMargin, bottom: 0, right: sectionMargin)
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
