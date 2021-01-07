//
//  UIImage+Additions.swift
//  MLCardForm
//
//  Created by Eric Ertl on 02/12/2020.
//

import Foundation

internal extension UIImage {

    func grayscale() -> UIImage? {
        if let currentFilter = CIFilter(name: "CIPhotoEffectMono") {
            let context = CIContext(options: nil)
            currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
            if let output = currentFilter.outputImage,
                let cgimg = context.createCGImage(output, from: output.extent) {
                let processedImage = UIImage(cgImage: cgimg)
                return processedImage
            }
        }
        return nil
    }
}
