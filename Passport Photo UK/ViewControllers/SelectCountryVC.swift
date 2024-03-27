//
//  SelectCountryVC.swift
//  Passport Photo UK
//
//  Created by Depixed on 03/07/21.
//  Copyright © 2021 Nirav Gondaliya. All rights reserved.
//

import UIKit

class SelectCountryVC: BaseViewController {
    
    @IBOutlet var ukView:UIView!
    @IBOutlet var globalView:UIView!
    @IBOutlet var lblEmail:UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addNavBackBtn(withSelector: #selector(goBack))
        self.title = "Select Country"
        let emailText: NSMutableAttributedString =  NSMutableAttributedString(string: "photocodeduk@gmail.com")
        emailText.addAttribute(NSAttributedStringKey.underlineStyle, value: 1, range: NSMakeRange(0, emailText.length))
        emailText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSMakeRange(0, emailText.length))
        lblEmail.attributedText = emailText
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.globalView.dropShadow(color: .lightGray, opacity: 1, offSet: CGSize(width: -5, height: -5), radius: 5, scale: true);
        let width = UIScreen.main.bounds.size.width - 20;
        
        let shadowSize : CGFloat = 5.0
            let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                       y: -shadowSize / 2,
                                                       width: width + shadowSize,
                                                       height: self.globalView.frame.size.height + shadowSize))
            self.globalView.layer.masksToBounds = false
            self.globalView.layer.shadowColor = UIColor.lightGray.cgColor
            self.globalView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            self.globalView.layer.shadowOpacity = 0.5
            self.globalView.layer.shadowPath = shadowPath.cgPath
        
        self.ukView.layer.masksToBounds = false
        self.ukView.layer.shadowColor = UIColor.lightGray.cgColor
        self.ukView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.ukView.layer.shadowOpacity = 0.5
        self.ukView.layer.shadowPath = shadowPath.cgPath
    }
    
    @IBAction func tappedOnAllCountry(_ sender:UIControl){
        CropUser.shared.isCountryUK = false
        CropUser.shared.countryInfo = [:]
        let countryList = CountryListVC.instantiate(fromAppStoryboard: .Main)
        self.navigationController?.pushViewController(countryList, animated: true)
    }
    
    @IBAction func tappedOnUKCountry(_ sender:UIControl){
        CropUser.shared.isCountryUK = true
        let goodBadVc = GoodAndBadViewController.instantiate(fromAppStoryboard: .Main)
        goodBadVc.selectedCountry = "UK"
        //goodBadVc.selectedType = self.selectedSize
        //goodBadVc.selectedSize = self.selectedSize
        goodBadVc.isNavigateToAccuracy = false
        goodBadVc.IDSize = 366
        goodBadVc.aspectHeightHead = "17.5:24.5"
        self.navigationController?.pushViewController(goodBadVc, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIView {

  // OUTPUT 1
  func dropShadow(scale: Bool = true) {
    layer.masksToBounds = false
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.5
    layer.shadowOffset = CGSize(width: -1, height: 1)
    layer.shadowRadius = 1

    layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    layer.shouldRasterize = true
    layer.rasterizationScale = scale ? UIScreen.main.scale : 1
  }

  // OUTPUT 2
  func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
    layer.masksToBounds = false
    layer.shadowColor = color.cgColor
    layer.shadowOpacity = opacity
    layer.shadowOffset = offSet
    layer.shadowRadius = radius

    layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    layer.shouldRasterize = true
    layer.rasterizationScale = scale ? UIScreen.main.scale : 1
  }
}
