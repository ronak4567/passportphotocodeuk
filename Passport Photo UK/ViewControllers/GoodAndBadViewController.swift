//
//  GoodAndBadViewController.swift
//  Quick & Easy Photo ID
//
//  Created by bhavin on 06/06/18.
//  Copyright © 2018 Nirav Gondaliya. All rights reserved.
//

import UIKit
import RealmSwift
class GoodAndBadViewController: BaseViewController {
    
    
    //MARK: - outlets
    var selectedCountry:String?
    var selectedAspectRatio:String = "35:45"
    var selectedSize:String?
    var isNavigateToAccuracy : Bool = false
    var selectedType:String?
    var IDSize : Int = 280
    var aspectHeightHead : String = ""
    var arrPerson:Results<AddContact>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addNavBackBtn(withSelector: #selector(goBack))
        getAllContactFile()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        //let colors = [UIColor(red: 136.0/255.0, green: 1.0/255.0, blue: 13.0/255.0, alpha: 1.0),UIColor(red: 44.0/255.0, green: 50.0/255.0, blue: 67.0/255.0, alpha: 1.0)]
        //self.navigationController?.navigationBar.setGradientBackground(colors: colors)
    }
    
    func getAllContactFile() {
        let realm = try! Realm()
        //let predicate = NSPredicate(format: "spIdentifier == '\(stickerPackID)'")
        arrPerson = realm.objects(AddContact.self)//.filter(predicate)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Action Methods
    
    @IBAction func tappedOnLink(_ sender : UIControl){
        let strLink = "https://www.gov.uk/photos-for-passports/rules-for-digital-photos"
        if let url = URL(string: strLink) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func btnNextTapped(_ sender : UIButton){
        CropUser.shared.isCaptureMultiplePic = false
        if arrPerson.count > 3 {
            let alert = UIAlertController (title: "You have selected four photo Are you continue to Order?", message: "", preferredStyle: .alert)
            let btnProceed = UIAlertAction(title: "Proceed", style: .default, handler: { (alertAction) in
                let homeVC = MultiplePersonVC.instantiate(fromAppStoryboard: .Main)
                self.navigationController?.pushViewController(homeVC, animated: true)
            })
            alert.addAction(btnProceed)
            let btnCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(btnCancel)
            self.present(alert, animated: true, completion: nil)
        }else {
            /*let cropVC = TakePhotoViewController.instantiate(fromAppStoryboard: .Main)
            cropVC.selectedRatio = CropUser.shared.ratio
            cropVC.country = self.selectedCountry
            cropVC.selectedType = self.selectedSize
            cropVC.IDSize = self.IDSize
            cropVC.aspectHeightHead = self.aspectHeightHead
            self.navigationController?.pushViewController(cropVC, animated: true);*/
            
            let cropVC = PreviewViewController.instantiate(fromAppStoryboard: .Main)
            self.navigationController?.pushViewController(cropVC, animated: true)
        }
        
        
    }
    
}
