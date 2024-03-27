//
//  CropUser.swift
//  Quick & Easy Photo ID
//
//  Created by Nirav Gondaliya on 09/05/18.
//  Copyright © 2018 Nirav Gondaliya. All rights reserved.
//

import Foundation
import UIKit

class CropUser {
    static let shared = CropUser()
    var image:UIImage!
    var ratio:String!
    var editedImage:UIImage!
    var saveImage:UIImage!
    var imageType:String!
    var countryName : String!
    var isRedictToCodeGen : Bool = false
    var isCaptureMultiplePic : Bool = false
    var isCountryUK : Bool = false
    var countryInfo : Dictionary<String,Any> = [:]
}
