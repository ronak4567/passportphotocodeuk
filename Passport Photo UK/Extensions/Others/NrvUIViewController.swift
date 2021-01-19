//
//  NrvUIViewController.swift
//  Quick & Easy Photo ID
//
//  Created by Nirav Gondaliya on 05/05/18.
//  Copyright © 2018 Nirav Gondaliya. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    class var storyboardID:String{
        return "\(self)"
    }
    
    //MARK:- Static Functions
    static func instantiate(fromAppStoryboard appStoryboard:AppFunctions.AppStoryBoard) -> Self{
        return appStoryboard.viewController(viewControllerClass: self)
    }
    
    static func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
    func isModal() -> Bool {
        if (self.presentingViewController != nil) {
            return true
        }else if (self.navigationController?.presentingViewController != nil) {
            return true
        }else if self.tabBarController?.presentingViewController != nil {
            return true
        }
        
        return false
    }
}
