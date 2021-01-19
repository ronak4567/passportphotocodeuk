//
//  NrvIcon.swift
//  Quick & Easy Photo ID
//
//  Created by Nirav Gondaliya on 05/05/18.
//  Copyright © 2018 Nirav Gondaliya. All rights reserved.
//

import Foundation
import UIKit

class NrvIcon{
    private var mutableAttributedStr = NSMutableAttributedString()
    
    var backgroundColor:UIColor = UIColor.clear
    
    required init() {
        
    }
    
    @discardableResult
    static func registerFont(fontUrl:URL) -> Bool{
        if let inData = NSData(contentsOf: fontUrl as URL) {
            var error: Unmanaged<CFError>?
            let cfdata = CFDataCreate(nil, inData.bytes.assumingMemoryBound(to: UInt8.self), inData.length)
            if let provider = CGDataProvider(data: cfdata!) {
                if let font = CGFont(provider) {
                    if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
                        return false
                    }
                    return true
                }
            }
        }
        return false
    }
    
    private func rangeMutableAttributedText() -> NSRange{
        return NSMakeRange(0, self.mutableAttributedStr.length)
    }
    
    private func fillBackground(forContext context:CGContext, backgroundSize:CGSize){
        self.backgroundColor.setFill()
        context.fill(CGRect(x: 0, y: 0, width: backgroundSize.width, height: backgroundSize.height))
    }
    
    private func drawingRectForImage(imageSize:CGSize) -> CGRect  {
        let iconSize = self.mutableAttributedStr.size()
        let xOffset = (imageSize.width - iconSize.width)/2
        let yOffset = (imageSize.height - iconSize.height)/2
        return CGRect(x: xOffset, y: yOffset, width: imageSize.width, height: imageSize.height)
    }
    
    func iconFont(withSize fontSize:CGFloat) -> UIFont? {
        return nil
    }
    
    static func iconWith(code:String, size:CGFloat) -> Self? {
        let icon = self.init()
        let font = icon.iconFont(withSize: size)!
        icon.mutableAttributedStr = NSMutableAttributedString(string: code, attributes: [NSAttributedStringKey(rawValue:NSAttributedStringKey.font.rawValue):font])
        return icon
    }
    
    func addAttribute(name:String,value:Any) {
        self.mutableAttributedStr.addAttribute(NSAttributedStringKey(rawValue: name), value: value, range: self.rangeMutableAttributedText())
    }
    
    func removeAttribute(name:String){
        self.mutableAttributedStr.removeAttribute(NSAttributedStringKey(rawValue: name), range: self.rangeMutableAttributedText())
    }
    
    func attributedString() -> NSAttributedString {
        return self.mutableAttributedStr
    }
    
    func image(withSize imageSize:CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        self.fillBackground(forContext: context, backgroundSize: imageSize)
        self.mutableAttributedStr.draw(in: self.drawingRectForImage(imageSize: imageSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
