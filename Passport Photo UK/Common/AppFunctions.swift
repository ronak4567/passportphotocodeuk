//
//  AppFunctions.swift
//  Quick & Easy Photo ID
//
//  Created by Nirav Gondaliya on 05/05/18.
//  Copyright © 2018 Nirav Gondaliya. All rights reserved.
//

import Foundation
import UIKit

class AppFunctions{
    enum  AppStoryBoard:String {
        case Main
        
        var instance:UIStoryboard{
            return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
        }
        
        func viewController<T:UIViewController>(viewControllerClass:T.Type) -> T{
            let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
            return instance.instantiateViewController(withIdentifier: storyboardID) as! T
        }
    }
}
