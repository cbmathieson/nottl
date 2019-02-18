//
//  UIImage.swift
//  nottl
//
//  Created by Craig Mathieson on 2019-01-04.
//  Copyright © 2019 Craig Mathieson. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    //resize avatar images on upload
    func imageWith(newSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let image = renderer.image { _ in
            self.draw(in: CGRect.init(origin: CGPoint.zero, size: newSize))
        }
        return image
    }
    
    //resize note images on upload
    //noteImage = 640.0*1136.0
    //profile image = 120*120
    func compressImage(maxHeight: CGFloat, maxWidth: CGFloat) -> Data? {
        // Reducing file size to a 10th
        var actualHeight: CGFloat = self.size.height
        var actualWidth: CGFloat = self.size.width
        var imgRatio: CGFloat = actualWidth/actualHeight
        let maxRatio: CGFloat = maxWidth/maxHeight
        var compressionQuality: CGFloat = 0.5
        
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            } else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            } else {
                actualHeight = maxHeight
                actualWidth = maxWidth
                compressionQuality = 1
            }
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
        UIGraphicsBeginImageContext(rect.size)
        self.draw(in: rect)
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        guard let imageData = img.jpegData(compressionQuality: compressionQuality) else {
            return nil
        }
        return imageData
    }
    
}
