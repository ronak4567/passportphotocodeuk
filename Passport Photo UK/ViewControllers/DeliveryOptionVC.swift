//
//  DeliveryOptionVC.swift
//  Passport Photo UK
//
//  Created by Ronak Gondaliya on 04/06/20.
//  Copyright © 2020 Nirav Gondaliya. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig
class DeliveryOptionVC: BaseViewController {

    @IBOutlet var btnFreeDelivery: UIButton!
    @IBOutlet var btnRecordDelivery: UIButton!
    @IBOutlet var btnSpecialDelivery: UIButton!
    
    @IBOutlet var lblStandardDelivery: UILabel!
    @IBOutlet var lblSpecialDelivery: UILabel!
    
    @IBOutlet var lblShipping: UILabel!
    @IBOutlet var lblTotalPrice: UILabel!
    
    var strDeliveryOption = ""
    var strShippingMethod = ""
    var price:Float = 0.0
    
    var shippingCharge:Float = 0.0;
    
    var remoteConfig:RemoteConfig!
    var chargeRecordedDelivery:Float = 0.0
    var standardDelivery:Float = 0.0
    var specialDelivery:Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.viewDidLoad()
        self.title = "Delivery Option"
        
        
        self.addNavBackBtn(withSelector: #selector(goBack))
        getRemoteConfigData()
        // Do any additional setup after loading the view.
    }
    
    func getRemoteConfigData() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        
        remoteConfig.fetch { (status, error) -> Void in
          if status == .success {
            print("Config fetched!")
              print(self.remoteConfig["charge_both_option"].stringValue ?? "")
              print(self.remoteConfig["charge_delivery_free"].stringValue ?? "")
              print(self.remoteConfig["charge_four_printed_photo"].stringValue ?? "")
              print(self.remoteConfig["charge_next_day_delivery"].stringValue ?? "")
              print(self.remoteConfig["charge_photo_code_only"].stringValue ?? "")
              print(self.remoteConfig["charge_recorded_delivery"].stringValue ?? "")
              print(self.remoteConfig["charge_standard_delivery"].stringValue ?? "")
              print(self.remoteConfig["google_pay_status"].stringValue ?? "")
              print(self.remoteConfig["stripe_final_status"].stringValue ?? "")
              
              
              self.chargeRecordedDelivery = Float(self.remoteConfig["charge_recorded_delivery"].stringValue ?? "0.00") ?? 0.0
              self.standardDelivery = Float(self.remoteConfig["charge_standard_delivery"].stringValue ?? "0.00") ?? 0.0
              self.specialDelivery = Float(self.remoteConfig["charge_next_day_delivery"].stringValue ?? "0.00") ?? 0.0
              
              self.lblStandardDelivery.text = String(format: "£%.2f",self.standardDelivery)
              self.lblSpecialDelivery.text = String(format: "£%.2f",self.specialDelivery)
              
            self.remoteConfig.activate { changed, error in
                print("remoteConfig.activate")
                print(changed)
            }
          } else {
            print("Config not fetched")
            print("Error: \(error?.localizedDescription ?? "No error available.")")
          }
//          self.displayWelcome()
        }
    }
    
    @IBAction func tappedOnDeliveryOption(_ sender:UIControl){
        shippingCharge = 0.0;
        if (sender.tag == 111){
            strDeliveryOption = "standard"
            shippingCharge = self.standardDelivery;
            btnFreeDelivery.isSelected = true
            btnRecordDelivery.isSelected = false
            btnSpecialDelivery.isSelected = false
            
        }else if (sender.tag == 222){
            strDeliveryOption = "recorded"
            shippingCharge = self.chargeRecordedDelivery;
            btnFreeDelivery.isSelected = false
            btnRecordDelivery.isSelected = true
            btnSpecialDelivery.isSelected = false
        }else if (sender.tag == 333){
            strDeliveryOption = "special"
            shippingCharge = self.specialDelivery;
            btnFreeDelivery.isSelected = false
            btnRecordDelivery.isSelected = false
            btnSpecialDelivery.isSelected = true
            
        }
        lblShipping.text = String(format: "Shipping: £%.2f",shippingCharge)
        lblTotalPrice.text = String(format: "Total Price: £%.2f", price + shippingCharge)
    }
    
    @IBAction func tappedOnNext(_ sender:UIControl) {
        if strDeliveryOption == "" {
           alert(message: "Please select delivery option.") {
               
           }
        }
        let chekoutVC = ChekoutViewController.instantiate(fromAppStoryboard: .Main)
        chekoutVC.strShippingMethod = self.strShippingMethod
        chekoutVC.price = price;
        chekoutVC.shippingCharge = shippingCharge;
        if (strDeliveryOption == "standard"){
            chekoutVC.selectedShipping = "1";
        }else if (strDeliveryOption == "recorded"){
            chekoutVC.selectedShipping = "2";
        }else if (strDeliveryOption == "special"){
            chekoutVC.selectedShipping = "3";
        }else{
            chekoutVC.selectedShipping = "0";
        }
            
        
        self.navigationController?.pushViewController(chekoutVC, animated: true)
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
