//
//  TapCardScannerView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/12/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapCardScanner_iOS

@objc public class TapCardScannerView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet var previewView: UIView!
    lazy var tapInlineScanner:TapInlineCardScanner = .init()
    @objc public var delegate:TapInlineScannerProtocl?
    // Mark:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.contentView = setupXIB()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = bounds
        previewView.updateConstraints()
        previewView.layoutIfNeeded()
    }
    
    
    @objc public func configureScanner() {
        do{
            tapInlineScanner.pauseScanner(stopCamera: true)
            try tapInlineScanner.startScanning(in: previewView,blurBackground: true,showTapCorners: true)
            tapInlineScanner.delegate = self.delegate
        }catch{}
    }

    @objc public func killScanner() {
        tapInlineScanner.pauseScanner(stopCamera: true)
    }
}
