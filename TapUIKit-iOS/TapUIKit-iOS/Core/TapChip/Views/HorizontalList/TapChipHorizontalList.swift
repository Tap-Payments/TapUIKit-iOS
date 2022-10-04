//
//  TapChipHorizontalList.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/14/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020
// import SimpleAnimation
import LocalisationManagerKit_iOS

/// Represents Tap representation of Chip horizontal list view
@objc public class TapChipHorizontalList: UIView {
    
    // Mark:- Variables
    
    /// The reference to the backbone uicollectionview used to display the horizontal items
    @IBOutlet weak var collectionView: UICollectionView!
    /// The content view that holds all inner views inside the view
    @IBOutlet weak var contentView:UIView!
    /// Reference to the header view if we need to show it
    @IBOutlet weak var headerView: TapHorizontalHeaderView! {
        didSet{
            headerView.delegate = self
        }
    }
    /// Refernce to the header height, to animate it in hide and showing if needed
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewToHederConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewToHeaderConstraintLowPriority: NSLayoutConstraint!
    //@IBOutlet weak var collectionViewCenterConstraint: NSLayoutConstraint!
    
    /// Keeps track of the last applied theme value
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    private var shouldShowHeader:Bool = true
    
    /// The view model that controls the data to be displayed and the events to be fired
    @objc public var viewModel:TapChipHorizontalListViewModel = .init()
    
    /// Represents the theme path to look for to UI this list
    private let themePath:String = "horizontalList"
    
    private var myHeightAnchor:NSLayoutConstraint?
    
    // Mark:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // Mark:- Public methods
    
    /**
     This instructs the view that we need to assign a new view model
     - Parameter viewModel: The view model you want to attach to the vie
     */
    @objc public func changeViewMode(with viewModel:TapChipHorizontalListViewModel) {
        self.viewModel = viewModel
    }
    
    @objc override func shouldShowTapView() -> Bool {
        return viewModel.shouldShow
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = bounds
    }
    
    // Mark:- Private methods
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        // First thing we load the XIB file and attach it to the curren view
        self.contentView = setupXIB()
        translatesAutoresizingMaskIntoConstraints = false
        myHeightAnchor = heightAnchor.constraint(equalToConstant: 85)
        self.addConstraint(myHeightAnchor!)
        // Second, theme it please!
        applyTheme()
        // Third, we do all the configurations needed as one time setup to our collection view
        configureCollectionView()
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// All the configurations needed as one time setup to our collection view
    private func configureCollectionView() {
        
        // Attach and register all created generic chip cells to the collection view
        viewModel.registerAllXibs(for: collectionView)
        
        // Define theming attributes for the collection view
        assignFlowLaout()
        
        // Declare ourself as the data source and delegae for the collection view
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    
    /// This method assigns the correct flippable layout with the scrolling direction + the item sizing
    private func assignFlowLaout() {
        collectionView.semanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight
        let itemSpacing:CGFloat = CGFloat(TapThemeManager.numberValue(for: "\(themePath).itemSpacing")?.floatValue ?? 0)
        //let sectionMargins:CGFloat = CGFloat(TapThemeManager.numberValue(for: "\(themePath).margin")?.floatValue ?? 0)
        let flowLayout: flippableCollectionLayout = flippableCollectionLayout()
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.minimumLineSpacing = itemSpacing
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.setCollectionViewLayout(flowLayout, animated: false)
        // Give it a chance to breath and layout to correctly render the new assigned flow layout
        var delay = 2500
        if #available(iOS 13, *) {
            delay = 300
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay)) {
            self.adjustArabicLayout(delay: delay)
            if #available(iOS 13, *) {
                if TapLocalisationManager.shared.localisationLocale ?? "en" == "ar" {
                    self.adjustArabicLayout(delay: 500)
                    self.adjustArabicLayout(delay: 900)
                }
            }
        }
    }
    
    private func adjustArabicLayout(delay:Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay)) {
            self.collectionView.layoutIfNeeded()
            var selectedIndex:Int = -1
            if let selectedIndecies = self.collectionView.indexPathsForSelectedItems, selectedIndecies.count > 0 {
                selectedIndex = selectedIndecies[0].row
            }
            self.collectionView.reloadData()
            if TapLocalisationManager.shared.localisationLocale ?? "en" == "ar" && selectedIndex != -1 {
                self.collectionView.selectItem(at: .init(row: selectedIndex, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            }
        }
    }
    
    /// The method handles the logic needed to update the displayed items and their statuses upon request
    private func reloadData() {
        collectionView.reloadSections([0])
    }
    
    /**
     Handles the logic for showing/hiding the header view for the given type
     - Parameter type: The header type to be shown
     */
    internal func handleHeaderView(with type: TapHorizontalHeaderType) {
        // Instruct the header view to render itself based on the type
        headerView.showHeader(with: type)
        
        // Determin and animate showing or hiding the header based on the given type
        guard type != .NoHeader else {
            shouldShowHeader = false
            hideHeaderView()
            return
        }
        shouldShowHeader = true
        showHeaderView()
    }
    
    
    /// Animate hiding the header view
    internal func hideHeaderView() {
        headerView.fadeOut{ (_) in
            DispatchQueue.main.async { [weak self] in
                UIView.animate(withDuration: 0.2, animations: {
                    self?.headerViewHeightConstraint.constant = 0
                    if #available(iOS 13, *) {
                        self?.collectionViewToHederConstraint.priority = .defaultLow
                        self?.collectionViewToHeaderConstraintLowPriority.isActive = false
                    } else {
                        self?.collectionViewToHederConstraint.isActive = false
                    }
                    self?.translatesAutoresizingMaskIntoConstraints = false
                    self?.myHeightAnchor?.constant = 80
                    self?.layoutIfNeeded()
                },completion: { _ in
                    //self?.assignFlowLaout()
                })
            }
        }
    }
    
    /// Animate showing the header view
    internal func showHeaderView() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.headerViewHeightConstraint.constant = 30
            self?.collectionViewToHederConstraint.priority = .required
            self?.translatesAutoresizingMaskIntoConstraints = false
            self?.myHeightAnchor?.constant = 85
            self?.layoutIfNeeded()
        },completion: { [weak self] _ in
            if self?.shouldShowHeader ?? false {
                self?.headerView.fadeIn()
                //self?.assignFlowLaout()
            }
        })
    }
    
}

/// Here we map the collection view methods to read from the view model data
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
    
    func shouldShowRightButton(show: Bool) {
        headerView.shouldShowRightButton(show: show)
    }
    
    func deleteCell(at index: Int) {
        // perform the deletion by a simple animation
        let indexPath = IndexPath(item: index, section: 0)
        self.collectionView.deleteItems(at:[indexPath])
        // Fade out the needed cell then delete it
        /*collectionView.cellForItem(at: indexPath)?.fadeOut(duration: 0.25, delay: 0, completion: { (_) in
         DispatchQueue.main.async { [weak self] in
         self?.collectionView.deleteItems(at:[indexPath])
         }
         })*/
        
    }
    
    func changeHeaderEditingStatus(to: Bool) {
        if viewModel.headerType == .GoPayListHeader || viewModel.headerType == .GatewayListHeader {
            headerView.changeEditingState(to: to)
        }
    }
    
    func refreshLayout() {
        assignFlowLaout()
    }
    
    func showHeader(with type: TapHorizontalHeaderType) {
        handleHeaderView(with: type)
        headerView.showHeader(with: type)
    }
    
    func reload(new dataSource: [GenericTapChipViewModel]) {
        reloadData()
    }
    
    func deselectAll() {
        collectionView.indexPathsForSelectedItems?.forEach{ collectionView.deselectItem(at: $0, animated: true) }
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
        self.tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        let sectionMargin:CGFloat = CGFloat(TapThemeManager.numberValue(for: "\(themePath).margin")?.floatValue ?? 0)
        collectionView.contentInset = .init(top: 0, left: sectionMargin, bottom: 0, right: sectionMargin)
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        
        guard lastUserInterfaceStyle != self.traitCollection.userInterfaceStyle else {
            return
        }
        lastUserInterfaceStyle = self.traitCollection.userInterfaceStyle
        applyTheme()
    }
}


extension TapChipHorizontalList: TapHorizontalHeaderDelegate {
    func endEditButtonClicked(with type: TapHorizontalHeaderView) {
        viewModel.closeEditButtonClicked(for: type)
        //type.changeEditingState(to: false)
        //viewModel.editMode(changed: false)
    }
    
    func rightAccessoryClicked(with type: TapHorizontalHeaderView) {
        viewModel.rightButtonClicked(for: type)
        //type.changeEditingState(to: true)
        //viewModel.editMode(changed: true)
    }
    
    func leftAccessoryClicked(with type: TapHorizontalHeaderView) {
        viewModel.leftButtonClicked(for: type)
    }
}
