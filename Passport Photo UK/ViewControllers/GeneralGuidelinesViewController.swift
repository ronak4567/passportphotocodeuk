//
//  GeneralGuidelinesViewController.swift
//  Quick & Easy Photo ID
//
//  Created by bhavin on 06/06/18.
//  Copyright © 2018 Nirav Gondaliya. All rights reserved.
//

import UIKit

class GeneralGuidelinesViewController: BaseViewController {

    var selectedSize:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addNavBackBtn(withSelector: #selector(goBack))
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        //let colors = [UIColor(red: 136.0/255.0, green: 1.0/255.0, blue: 13.0/255.0, alpha: 1.0),UIColor(red: 44.0/255.0, green: 50.0/255.0, blue: 67.0/255.0, alpha: 1.0)]
        //self.navigationController?.navigationBar.setGradientBackground(colors: colors)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Action Methods
    
    @IBAction func btnAgreeTapped(_ sender : UIButton){
        
        //let quickVC = QuickButtonViewController.instantiate(fromAppStoryboard: .Main)
        //self.navigationController?.pushViewController(quickVC, animated: true)
        
        CropUser.shared.ratio = "25:35"
        CropUser.shared.isRedictToCodeGen = true
        let countryChoose = SelectCountryVC.instantiate(fromAppStoryboard: .Main)
        self.navigationController?.pushViewController(countryChoose, animated: true)
//        let goodBadVc = GoodAndBadViewController.instantiate(fromAppStoryboard: .Main)
//        goodBadVc.selectedCountry = "UK"
//        goodBadVc.selectedType = self.selectedSize
//        goodBadVc.selectedSize = self.selectedSize
//        goodBadVc.isNavigateToAccuracy = false
//        goodBadVc.IDSize = 366
//        goodBadVc.aspectHeightHead = "17.5:24.5"
//        self.navigationController?.pushViewController(goodBadVc, animated: true)
        
        /*let alert = UIAlertController (title: "Code will be delivered within 2-24 hours (if your photo meets the rules).", message: "", preferredStyle: .alert)
        let btnProceed = UIAlertAction(title: "Proceed", style: .default, handler: { (alertAction) in
            /*CropUser.shared.ratio = "25:35"
             CropUser.shared.isRedictToCodeGen = true
             
             let cropVC = TakePhotoViewController.instantiate(fromAppStoryboard: .Main)
             cropVC.selectedRatio = CropUser.shared.ratio
             cropVC.country = "UK"
             cropVC.selectedType = self.selectedSize
             cropVC.IDSize = 366
             cropVC.aspectHeightHead = "17.5:24.5"
             cropVC.isRedictToCodeGen = true
             self.navigationController?.pushViewController(cropVC, animated: true)*/
            
            CropUser.shared.ratio = "25:35"
            CropUser.shared.isRedictToCodeGen = true
            let goodBadVc = GoodAndBadViewController.instantiate(fromAppStoryboard: .Main)
            goodBadVc.selectedCountry = "UK"
            goodBadVc.selectedType = self.selectedSize
            goodBadVc.selectedSize = self.selectedSize
            goodBadVc.isNavigateToAccuracy = false
            goodBadVc.IDSize = 366
            goodBadVc.aspectHeightHead = "17.5:24.5"
            self.navigationController?.pushViewController(goodBadVc, animated: true)
        })
        alert.addAction(btnProceed)
        let btnCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(btnCancel)
        self.present(alert, animated: true, completion: nil)
        */
        //let countryVC = CountryViewController.instantiate(fromAppStoryboard: .Main)
        //self.navigationController?.pushViewController(countryVC, animated: true)
    }

    

}
