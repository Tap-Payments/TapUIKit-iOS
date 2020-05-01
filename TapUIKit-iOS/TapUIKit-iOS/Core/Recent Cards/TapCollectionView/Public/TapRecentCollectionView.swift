//
//  TapRecentCollectionView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 30/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import SnapKit
import TapThemeManager2020

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
        
        applyTheme()
        addViews()
        addConstrains()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    internal func applyTheme() {
        
        // Check if the file exists
        let bundle:Bundle = Bundle(for: type(of: self))
        // Based on the current display mode, we decide which default theme file we will use
        let themeFile:String = (self.traitCollection.userInterfaceStyle == .dark) ? "DefaultDarkTheme" : "DefaultLightTheme"
        // Defensive code to make sure all is loaded correctly
        guard let jsonPath = bundle.path(forResource: themeFile, ofType: "json") else {
            print("TapThemeManager WARNING: Can't find json 'DefaultTheme'")
            return
        }
        // Check if the file is correctly parsable
        guard
            let data = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)),
            let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed),
            let jsonDict = json as? NSDictionary else {
                print("TapThemeManager WARNING: Can't read json 'DefaultTheme' at: \(jsonPath)")
                return
        }
        TapThemeManager.setTapTheme(themeDict: jsonDict)
    }
    
    internal func addViews() {
        
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.estimatedItemSize =  UICollectionViewFlowLayout.automaticSize
        flowLayout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = false
        addSubview(collectionView)
        viewModel.registerCells(on: collectionView)
        
        
    }
    
    internal func addConstrains() {
        collectionView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
        }
    }
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
           super.traitCollectionDidChange(previousTraitCollection)
           applyTheme()
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
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        viewModel.didDeSelectItem(at: indexPath)
    }
    

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        // splace between two cell horizonatally
        return 8
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        // splace between two cell vertically
        return 7
    }
    
    
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        // give space top left bottom and right for cells
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
   
}

