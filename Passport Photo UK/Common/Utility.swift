//
//  Utility.swift
//  Quick & Easy Photo ID
//
//  Created by Nirav Gondaliya on 09/05/18.
//  Copyright © 2018 Nirav Gondaliya. All rights reserved.
//

import Foundation
import Photos

class Utility {
    static func getPhotoLibraryAuthorizationStatus(completionHandler:@escaping ((Bool, String?)->())){
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                switch status {
                case .authorized:
                    completionHandler(true,nil)
                default:
                    completionHandler(false,"Storage Permission denied, can\'t go further")
                }
            })
        }else if status == .authorized{
            completionHandler(true,nil)
        }else{
            completionHandler(false,"Storage Permission denied, can\'t go further")
        }
    }
    
    static func getCameraAuthorizationStatus(completionHandler:@escaping ((Bool, String?)->())) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                switch status {
                case .authorized:
                    completionHandler(true,nil)
                default:
                    completionHandler(false,"Storage Permission denied, can\'t go further")
                }
            })
        }else if status == .authorized{
            completionHandler(true,nil)
        }else{
            completionHandler(false,"Storage Permission denied, can\'t go further")
        }
    }
}
