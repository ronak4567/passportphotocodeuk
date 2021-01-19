//
//  NrvUINavigationController.swift
//  Quick & Easy Photo ID
//
//  Created by Nirav Gondaliya on 05/05/18.
//  Copyright © 2018 Nirav Gondaliya. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        self.themePrimary()
    }
    
    func themePrimary() {
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white,
                                                  NSAttributedStringKey.font:UIFont(name: "HelveticaNeue", size: 20.0)!]
        self.navigationBar.isTranslucent = false
        
    }
}

extension UINavigationBar {
    
    func setGradientBackground(colors: [UIColor]) {
        
        var updatedFrame = bounds
        updatedFrame.size.height += self.frame.origin.y
        let gradientLayer = CAGradientLayer(frame: updatedFrame, colors: colors)
        
        setBackgroundImage(gradientLayer.createGradientImage(), for: UIBarMetrics.default)
    }
}
