//
//  StartViewController.swift
//  Quick & Easy Photo ID
//
//  Created by Nirav Gondaliya on 05/05/18.
//  Copyright © 2018 Nirav Gondaliya. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig
class StartViewController: BaseViewController {
    
    var remoteConfig:RemoteConfig!

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.setUpPaypal()
        getRemoteConfigData()
    }
    
//    var environment:String = PayPalEnvironmentNoNetwork {
//        willSet(newEnvironment) {
//            if (newEnvironment != environment) {
//                PayPalMobile.preconnect(withEnvironment: newEnvironment)
//            }
//        }
//    }
    
//    var payPalConfig = PayPalConfiguration() // default
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
              
//              self.digitalPhotoAmount = Double(self.remoteConfig["charge_digital_photo"].stringValue ?? "0.00") ?? 0.0
//              self.printedPhotoAmount = Double(self.remoteConfig["charge_printed_photo"].stringValue ?? "0.00") ?? 0.0
//              self.bothPhotoAmount = Double(self.remoteConfig["charge_both_photo"].stringValue ?? "0.00") ?? 0.0
//              self.chargeDelivery = Float(self.remoteConfig["charge_delivery"].stringValue ?? "0.00") ?? 0.0
            self.remoteConfig.activate { changed, error in
                print("remoteConfig.activate")
                print(changed)
                print(error)
            }
          } else {
            print("Config not fetched")
            print("Error: \(error?.localizedDescription ?? "No error available.")")
          }
//          self.displayWelcome()
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onBtnStartClick(_ sender: UIButton) {
//        let messageVC = self.storyboard?.instantiateViewController(withIdentifier: "PaymentMessageVC") as! PaymentMessageVC
//        messageVC.strFlag = "fail"
//        messageVC.strTransaction = "AatXaCciihKnHISPK7d"
//        self.navigationController?.pushViewController(messageVC, animated: true)
        let termsVC = TermsViewController.instantiate(fromAppStoryboard: .Main)
        self.navigationController?.pushViewController(termsVC, animated: true)
    }
}

//extension StartViewController : PayPalPaymentDelegate{
//    
//    
//    func setUpPaypal() {
//        
//        let sandBox = "AatXaCciihKnHISPK7dliHXhNMgLNUnzBQHN2hB7tK19gpRfaP8sU2C_O0ZHdyF3H1A2jV0JvymHOR8G"
//        let production = "ARa9wLES8gG3ZZIXoonI3hTQz1WA0ZU1kYioT1dj5uOWG27LeTLdIxc7Q45D3FX7QWsXXJStGAo-8hXK"
//        
//        /*@{PayPalEnvironmentProduction : @"my-client-id-for-Production",
//         ///    PayPalEnvironmentSandbox : @"my-client-id-for-Sandbox"}*/
//        let dict : [AnyHashable : Any] = [PayPalEnvironmentProduction : production , PayPalEnvironmentSandbox : sandBox]
//        
//        PayPalMobile.initializeWithClientIds(forEnvironments: dict)
//        //self.environment = PayPalEnvironmentNoNetwork
//        self.environment =  PayPalEnvironmentProduction
//        //self.environment =  PayPalEnvironmentSandbox
//        payPalConfig.acceptCreditCards = false
//        payPalConfig.merchantName = "Passport photo code UK"
//        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
//        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
//        
//        
//        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
//        
//        
//        payPalConfig.payPalShippingAddressOption = .payPal;
//        
//        print("PayPal iOS SDK Version: \(PayPalMobile.libraryVersion())")
//    }
//    
//    func openPaypal() {
//        
//        
//        
//        var totalAmount = 0.01
//        
//        
//        let item1 = PayPalItem(name: "photo", withQuantity: 1, withPrice: NSDecimalNumber(string: "\(totalAmount)"), withCurrency: "GBP", withSku: "\(Date.timeIntervalBetween1970AndReferenceDate)")
//        
//        let items = [item1]
//        let subtotal = PayPalItem.totalPrice(forItems: items)
//        
//        let payment = PayPalPayment(amount: NSDecimalNumber(string:"\(totalAmount)"), currencyCode: "GBP" , shortDescription: "photo", intent: .sale)
//        //        let paymentDetails = PayPalPaymentDetails(subtotal: NSDecimalNumber("\(0)"), withShipping: NSDecimalNumber("\(0)"), withTax: NSDecimalNumber("\(0)"))
//        payment.items = items
//        //        payment.paymentDetails = paymentDetails
//        
//        if (payment.processable) {
//            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
//            present(paymentViewController!, animated: true, completion: nil)
//        }
//        else {
//            
//            // This particular payment will always be processable. If, for
//            // example, the amount was negative or the shortDescription was
//            // empty, this payment wouldn't be processable, and you'd want
//            // to handle that here.
//            print("Payment not processalbe: \(payment)")
//            
//            self.openPaypal()
//        }
//    }
//    
//    
//    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
//        paymentViewController.dismiss(animated: true, completion: nil)
//    }
//    
//    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
//        print("PayPal Payment Success !")
//        paymentViewController.dismiss(animated: true, completion: { () -> Void in
//            // send completed confirmaion to your server
//            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
//            
//            let resultText = completedPayment.description
//            print(resultText)
//            
//            if let data = completedPayment.confirmation["response"] as? AnyHashable{
//                
//                if let tr_id = (data as? Dictionary<String , Any>)?["id"] as? String {
//                    print(tr_id)
////                    self.sendMailWithAttachment()
//                }
//                
//            }
//            //            self.showSuccess()
//        })
//    }
//
//    
//    
//}
