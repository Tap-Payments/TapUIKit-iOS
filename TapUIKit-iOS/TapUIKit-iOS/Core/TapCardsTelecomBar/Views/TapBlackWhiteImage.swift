//
//  TapBlackWhitemage.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/28/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import class UIKit.UIImage
import class UIKit.CIImage
import class UIKit.CIFilter
import class UIKit.CIContext
import class UIKit.CIColor
import struct UIKit.CGFloat

internal class TapBlackWhiteImage {
   
   /// The image to be filtered and to convert to black and white
    var inputImage: UIImage? {
        didSet {
            guard let image = inputImage else {
                return
            }
            ciImage = CIImage(image: image)
            setupFilter()
            reset()
        }
    }
    
    /*
     The output image after processing
     */
    private(set) var outputImage: UIImage?
    
    /*
    
     The filter brightness value (0.0 ... 1.0)
     Default is 0.5
     */
    var brightness: CGFloat = 0.5 {
        didSet {
            reset()
        }
    }
    
    /// MARK: - Private VARs
    /// The filter technicue to be used to apply the black and white filter
    private var filter: CIFilter?
    /// The core image extraced from the UIImage to apply the filter upon
    private var ciImage: CIImage?
    
    
    /**
     Applys the filter to the provided UIImage
     - Returns: Black and white version of the provdided image and nil if any error occured
     */
    func filterImage() -> UIImage? {
        // Check that the user provided a valid image first
        if let outputImageCI = filter?.outputImage {
            // Check if all went good and we extraced the CIImage properly
            if let outputImageCG = CIContext(options: nil).createCGImage(outputImageCI, from: outputImageCI.extent) {
                outputImage = UIImage(cgImage: outputImageCG)
                guard let image = outputImage else {
                    return nil
                }
                return image
            }
        }
        
        return nil
    }
    
    /// MARK: - Private
    
    private func setupFilter() {
        filter = CIFilter(name: "CIColorMonochrome")
        filter?.setValue(ciImage, forKey: "inputImage")
        filter?.setValue(1.0, forKey: "inputIntensity")
    }
    
    private func reset() {
        filter?.setValue(CIColor(red: brightness, green: brightness, blue: brightness), forKey: "inputColor")
    }
}
