//
//  DeliveryOptionVC.swift
//  Passport Photo UK
//
//  Created by Ronak Gondaliya on 04/06/20.
//  Copyright © 2020 Nirav Gondaliya. All rights reserved.
//

import UIKit

class DeliveryOptionVC: BaseViewController {

    @IBOutlet var btnFreeDelivery: UIButton!
    @IBOutlet var btnRecordDelivery: UIButton!
    @IBOutlet var btnSpecialDelivery: UIButton!
    
    @IBOutlet var lblShipping: UILabel!
    @IBOutlet var lblTotalPrice: UILabel!
    
    var strDeliveryOption = ""
    var strShippingMethod = ""
    var price:Float = 0.0
    
    var shippingCharge:Float = 0.0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.viewDidLoad()
        self.title = "Delivery Option"
        
        
        self.addNavBackBtn(withSelector: #selector(goBack))

        // Do any additional setup after loading the view.
    }
    
    @IBAction func tappedOnDeliveryOption(_ sender:UIControl){
        shippingCharge = 0.0;
        if (sender.tag == 111){
            strDeliveryOption = "free"
            shippingCharge = 0.0;
            btnFreeDelivery.isSelected = true
            btnRecordDelivery.isSelected = false
            btnSpecialDelivery.isSelected = false
        }else if (sender.tag == 222){
            strDeliveryOption = "recorded"
            shippingCharge = 4.99;
            btnFreeDelivery.isSelected = false
            btnRecordDelivery.isSelected = true
            btnSpecialDelivery.isSelected = false
        }else if (sender.tag == 333){
            strDeliveryOption = "special"
            shippingCharge = 9.50;
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
        if (strDeliveryOption == "free"){
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
