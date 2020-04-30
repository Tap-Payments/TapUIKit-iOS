//
//  TapRecentCollectionView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 30/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import SnapKit

@objc public class TapRecentCollectionView: UIView {

    
    private var viewModel:TapCardsCollectionViewModel = .init()
    private lazy var collectionView:UICollectionView = UICollectionView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc public func setup(with viewModel:TapCardsCollectionViewModel) {
        self.viewModel = viewModel
        setupViews()
    }
    
    
    internal func setupViews() {
        addViews()
        addConstrains()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    internal func addViews() {
        
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.estimatedItemSize =  UICollectionViewFlowLayout.automaticSize
        flowLayout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        addSubview(collectionView)
        viewModel.registerCells(on: collectionView)
        
        
    }
    
    internal func addConstrains() {
        collectionView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}


extension TapRecentCollectionView:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellConfig:CellConfigurator = viewModel.cellConfigurator(at: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: type(of: cellConfig).reuseId, for: indexPath)
        
        cellConfig.configure(cell: cell)
        
        cell.layoutIfNeeded()
        
        return cell
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath)
    }
}

