//
//  CardFieldViewController.swift
//  UI Examples
//
//  Created by Ben Guo on 7/19/17.
//  Copyright © 2017 Stripe. All rights reserved.
//

import UIKit
import Stripe
import Alamofire
class CardFieldViewController: BaseViewController {

    let cardField = STPPaymentCardTextField()
    var theme = STPTheme.defaultTheme
    var amount:String = ""
    var delegate: MyProtocol?
    var firstName: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Payment Process"
        self.addNavCloseBtn(withSelector: #selector(goClose))
        
//        view.backgroundColor = UIColor.white
        view.addSubview(cardField)
        edgesForExtendedLayout = []
//        view.backgroundColor = theme.primaryBackgroundColor
        cardField.backgroundColor = theme.secondaryBackgroundColor
        cardField.textColor = theme.primaryForegroundColor
        cardField.placeholderColor = theme.secondaryForegroundColor
        cardField.borderColor = theme.accentColor
//        cardField.borderWidth = 1.0
        cardField.textErrorColor = theme.errorColor
        cardField.postalCodeEntryEnabled = false
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
//        navigationController?.navigationBar.stp_theme = theme
//        let color = UIColor(red: 38.0/255.0, green: 51.0/255.0, blue: 132.0/255.0, alpha: 1.0)
//        self.navigationController?.navigationBar.barTintColor =  color
    }

    @IBAction func tappedOnMakePayment() {
        let cardParams = STPCardParams()
            cardParams.number = cardField.cardNumber
        cardParams.expMonth = UInt(cardField.expirationMonth)
        cardParams.expYear = UInt(cardField.expirationYear)
            cardParams.cvc = cardField.cvc
        appDelegate.showHud()
        STPAPIClient.shared.createToken(withCard: cardParams) { token, error in
               guard let token = token else {
                   // Handle the error
                self.alert(message: error?.localizedDescription ?? "Some error occurred. Please try again") {
                    
                }
                appDelegate.hideHud()
                return
               }
               let tokenID = token.tokenId
            print(tokenID);
            self.createChargeAPI(token: tokenID)
               // Send the token identifier to your server...
           }
        //dismiss(animated: true, completion: nil)
    }
    
    
    func createChargeAPI(token:String) {
        let url = "https://passportphotocodeuk.com/backend/api/Stripepay/Pay"
        let user = "ppcukadmin"
        let password = "Admin123#"
        let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers = ["Authorization": "Basic \(base64Credentials)","Accept":"application/json",
                       "Content-Type": "multipart/form-data", "Connection":"keep-alive"]
        
        let parameters = ["token": token ?? "",
                          "amount": amount,
                          "currency":"GBP",
                          "description": "\(self.firstName) PPCUK - IOS - Card",
        ] as [String : String]
        
        print("BODY: \(parameters)")
        print("Header: \(headers)")
        
        upload(multipartFormData: { (multipartFormData) in
            
            
            for (key, value) in parameters {
                multipartFormData.append((value.data(using: String.Encoding.utf8, allowLossyConversion: false))!, withName: key)
                
                //multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: url, method: .post, headers: headers) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                
                upload.validate(statusCode: 200..<600)
                //upload.authenticate(user: user, password: password)
                upload.responseJSON { response in
                    appDelegate.hideHud()
                    if response.result.error != nil {
                        print(response.result.error!)
                        print("failure")
                        //completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.failure, errors: nil))
                    }else {
                        print("success")
                        
                        
//
                        if let dictResult:[String:Any] = response.result.value as! [String : Any]? {
                            if let data = dictResult["data"] as? [String : Any]{
                                if let status = data["status"] as? String, status == "succeeded"{
                                    self.delegate?.cardPaymentSuccess(transactionID: data["balance_transaction"] as? String ?? "", success: true);
                                    self.dismiss(animated: true) {
                                    }
                                }else {
                                    if let message = dictResult["Message"] as? String {
                                        self.alert(message: message) {
                                        }
                                    }
                                }
                            }else {
                                if let message = dictResult["Message"] as? String {
                                    self.alert(message: message) {
                                        
                                    }
                                }
                                
                            }
                            
                            print("Result:\(dictResult)")
                        }
                        
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
            //failure
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cardField.becomeFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let padding: CGFloat = 15
        cardField.frame = CGRect(x: padding,
                                 y: padding,
                                 width: view.bounds.width - (padding * 2),
                                 height: 50)
    }

}
