//
//  ChekoutViewController.swift
//  Quick & Easy Photo ID
//
//  Created by Ronak Gondaliya on 13/12/19.
//  Copyright © 2019 Nirav Gondaliya. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import PassKit
import Stripe
class ShippingCell:UITableViewCell {
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var txtShippingType:UITextField!
}

class BasketSummaryCell:UITableViewCell {
    @IBOutlet var lblPrice:UILabel!
    @IBOutlet var lblShippingCharge:UILabel!
    @IBOutlet var lblTotal:UILabel!
}

class TextFieldCell:UITableViewCell {
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var txtField:UITextField!
}

protocol MyProtocol: class {
    func cardPaymentSuccess(transactionID: String, success: Bool)
}

class ChekoutViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, MyProtocol {
    func cardPaymentSuccess(transactionID: String, success: Bool) {
        self.callSendMailAPI(transactionID)
    }
    
    
    
    @IBOutlet var tblView:UITableView!
    var price:Float = 0.0
    var strShippingMethod = ""
    var shippingCharge:Float = 0.00
    var total:Float = 0.00
    var pickerShipping = UIPickerView()
    var selectedShipping = ""
    var firstName = "", lastName = "", strEmail = "", strAddress1 = "", strAdddress2 = "", strCity = "", strPostal = "", strPhoneNumber = "", strCountry = ""
    var cardPaymentSuccess:Bool = false
    var arrContactList:Results<AddContact>!
    var personImage = [Data]()
    
    var trayingTimes = 0
//    var applePayButton:PKPaymentButton!
    @IBOutlet var applePayView:UIView!
    let ApplePaySwagMerchantID = "merchant.com.passporthphotouk.applepay"
    
    let SupportedPaymentNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex]
    //var indicator:MaterialLoadingIndicator!
    @IBOutlet var cartButton:UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Customer's Details"
        self.tblView.estimatedRowHeight = 100.0
        self.tblView.rowHeight = UITableViewAutomaticDimension
        self.addNavBackBtn(withSelector: #selector(goBack))
        pickerShipping.delegate = self
        pickerShipping.dataSource = self
        
        cartButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        cartButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        cartButton.layer.shadowOpacity = 1.0
        cartButton.layer.shadowRadius = 0.0
        cartButton.layer.masksToBounds = false
        cartButton.layer.cornerRadius = 4.0
        
        //        if strShippingMethod == "post" || strShippingMethod == "both" {
        //            shippingCharge = 4.99
        //        }else {
        //            shippingCharge = 0.0
        //        }
        
        self.getAllContactFile()
//        var applePayButton:PKPaymentButton!
//        if #available(iOS 12.0, *) {
//            applePayButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
//        } else {
//            applePayButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
//        }
//        applePayButton.addTarget(self, action: #selector(ChekoutViewController.tappedOnClick(_:)), for: .touchUpInside)
//        let screen = UIScreen.main.bounds
//        applePayButton.frame = CGRect(x: 0, y: 0, width: (screen.width-16)/2, height: 50)
//        //        applePayButton.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
//        applePayView.addSubview(applePayButton)
        // Do any additional setup after loading the view.
    }
    
    func validateView()-> String{
        
        let erroMessge : String = ""
        if selectedShipping == "0" {
            if self.firstName.isEmpty{
                return "Please enter first name"
            }else if self.lastName.isEmpty{
                return "Please enter last name"
            }else if self.strEmail.isEmpty{
                return "Please enter email address"
            }else if self.strPhoneNumber.isEmpty{
                return "Please enter contact number"
            }
        }else {
            if self.firstName.isEmpty{
                return "Please enter first name"
            }else if self.lastName.isEmpty{
                return "Please enter last name"
            }else if self.strEmail.isEmpty{
                return "Please enter email address"
            }else if self.strPhoneNumber.isEmpty{
                return "Please enter contact number"
            }else if self.strCity.isEmpty{
                return "Please enter city / town"
            }else if self.strCountry.isEmpty{
                return "Please enter country"
            }else if self.strPostal.isEmpty{
                return "Please enter post code"
            }
        }
        
        return erroMessge
    }
    
    //MARK:- Button Click Event
    @IBAction func tappedOnClick(_ sender:UIButton) {
        let error = self.validateView()
        if !error.isEmpty  {
            let alert = UIAlertController (title: "Required", message: error, preferredStyle: .alert)
            let btnOK = UIAlertAction (title: "OK", style: .cancel, handler: nil)
            alert.addAction(btnOK)
            self.present(alert, animated: true, completion: nil)
        }else {
            //self.openPaypal()
            let request = PKPaymentRequest()
            request.merchantIdentifier = ApplePaySwagMerchantID
            request.supportedNetworks = SupportedPaymentNetworks
            request.merchantCapabilities = PKMerchantCapability.capability3DS
            request.countryCode = "GB"
            request.currencyCode = "GBP"
            
            request.paymentSummaryItems = [(PKPaymentSummaryItem(label: "Passport Photo UK", amount: NSDecimalNumber(value: total)))]
            request.requiredBillingContactFields = [PKContactField.emailAddress]
            
            let contact = PKContact()
            var name = PersonNameComponents()
            name.givenName = self.firstName
            name.familyName = self.lastName
            contact.name = name
            contact.emailAddress = self.strEmail
            
            request.shippingContact = contact
            
            let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
            applePayController?.delegate = self
            present(applePayController!, animated: true, completion: nil)
        }
    }
    
    let themeViewController = ThemeViewController()
    
    @IBAction func tappedOnAddCard(_ sender:UIButton) {
        let error = self.validateView()
        if !error.isEmpty  {
            let alert = UIAlertController (title: "Required", message: error, preferredStyle: .alert)
            let btnOK = UIAlertAction (title: "OK", style: .cancel, handler: nil)
            alert.addAction(btnOK)
            self.present(alert, animated: true, completion: nil)
        }else {
            let theme = themeViewController.theme.stpTheme
            let viewController = CardFieldViewController()
            viewController.theme = theme
            viewController.amount = "\(Int(round(self.total * 100)))"
            viewController.delegate = self
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.navigationBar.stp_theme = theme
            present(navigationController, animated: true, completion: nil)
        }
        
    }
    
    
    //MARK:- UITableViewDataSource, UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //        if strShippingMethod == "photocodeonly" {
        if section == 0 {
            return "Basket Summary"
        }else if section == 1 {
            return "Customer's Details"
        }
        return ""
        //        }else {
        //            if section == 0 {
        //                return "SHIPPING OPTION"
        //            }else if section == 1 {
        //                return "BASKET SUMMARY"
        //            }else if section == 2 {
        //                return "SHIPPING INFORMATION"
        //            }
        //            return ""
        //        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        //        if strShippingMethod == "photocodeonly" {
        return ""
        //        }else {
        //            if section == 0 {
        //                if selectedShipping == "Special Delivery" {
        //                    return "Note: Order must be placed before 12 PM"
        //                }else if selectedShipping == "Free Delivery" {
        //                    return "Note : 3-5 working Days"
        //                }else {
        //                    return ""
        //                }
        //            }else {
        //                return ""
        //            }
        //        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        if strShippingMethod == "photocodeonly" {
        if section == 0 {
            return 1
        }else if section == 1 {
            if selectedShipping == "0" {
                return 4
            }else {
                return 9
            }
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        if strShippingMethod == "photocodeonly" {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasketSummaryCell") as! BasketSummaryCell
            cell.lblPrice.text = String(format: "£ %.2f",price)
            //shippingCharge = 00.0;
            cell.lblShippingCharge.text = String(format: "£ %.2f",shippingCharge)
            
            cell.lblTotal.text = String(format: "£ %.2f", price + shippingCharge) //"£ \(price + shippingCharge)"
            total = price + shippingCharge
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell") as! TextFieldCell
            cell.txtField.delegate = self
            if indexPath.row == 0 {
                cell.lblTitle.text = "First Name"
                cell.txtField.tag = 111
            }else if indexPath.row == 1 {
                cell.lblTitle.text = "Last Name"
                cell.txtField.tag = 222
            }else if indexPath.row == 2 {
                cell.lblTitle.text = "Email"
                cell.txtField.tag = 333
                cell.txtField.keyboardType = UIKeyboardType.emailAddress
            }else if indexPath.row == 3 {
                cell.lblTitle.text = "Phone Number"
                cell.txtField.tag = 444
                cell.txtField.keyboardType = UIKeyboardType.phonePad
            }else if indexPath.row == 4 {
                cell.lblTitle.text = "Address Line 1"
                cell.txtField.tag = 555
            }else if indexPath.row == 5 {
                cell.lblTitle.text = "Address Line 2"
                cell.txtField.tag = 666
            }else if indexPath.row == 6 {
                cell.lblTitle.text = "City / Town"
                cell.txtField.tag = 777
            }else if indexPath.row == 7 {
                cell.lblTitle.text = "Country"
                cell.txtField.tag = 888
            }else if indexPath.row == 8 {
                cell.lblTitle.text = "Post code"
                cell.txtField.tag = 999
            }
            cell.selectionStyle = .none
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShippingCell") as! ShippingCell
            cell.selectionStyle = .none
            return cell
            
        }
        //        }else {
        //            if indexPath.section == 0 {
        //                let cell = tableView.dequeueReusableCell(withIdentifier: "ShippingCell") as! ShippingCell
        //                cell.lblTitle.text = "Shipping Option"
        //                cell.txtShippingType.text = selectedShipping
        //                cell.txtShippingType.delegate = self
        //                cell.selectionStyle = .none
        //                return cell
        //            }else if indexPath.section == 1 {
        //                let cell = tableView.dequeueReusableCell(withIdentifier: "BasketSummaryCell") as! BasketSummaryCell
        //                cell.lblPrice.text = "£ \(price)"
        //                if selectedShipping == "Free Delivery" {
        //                    shippingCharge = 0.0;
        //                    cell.lblShippingCharge.text = "£ 0.00"
        //                }else if selectedShipping == "Special Delivery" {
        //                    shippingCharge = 7.50;
        //                    cell.lblShippingCharge.text = "£ 7.50"
        //
        //                }
        //                cell.lblTotal.text = String(format: "£ %.2f", price + shippingCharge) //"£ \(price + shippingCharge)"
        //                total = price + shippingCharge
        //                cell.selectionStyle = .none
        //                return cell
        //            }else if indexPath.section == 2 {
        //                let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell") as! TextFieldCell
        //                cell.txtField.delegate = self
        //                if indexPath.row == 0 {
        //                    cell.lblTitle.text = "First Name"
        //                    cell.txtField.tag = 111
        //                }else if indexPath.row == 1 {
        //                    cell.lblTitle.text = "Last Name"
        //                    cell.txtField.tag = 222
        //                }else if indexPath.row == 2 {
        //                    cell.lblTitle.text = "Email"
        //                    cell.txtField.tag = 333
        //                    cell.txtField.keyboardType = UIKeyboardType.emailAddress
        //                }else if indexPath.row == 3 {
        //                    cell.lblTitle.text = "Phone Number"
        //                    cell.txtField.tag = 444
        //                    cell.txtField.keyboardType = UIKeyboardType.phonePad
        //                }else if indexPath.row == 4 {
        //                    cell.lblTitle.text = "Address Line 1"
        //                    cell.txtField.tag = 555
        //                }else if indexPath.row == 5 {
        //                    cell.lblTitle.text = "Address Line 2"
        //                    cell.txtField.tag = 666
        //                }else if indexPath.row == 6 {
        //                    cell.lblTitle.text = "City"
        //                    cell.txtField.tag = 777
        //                }else if indexPath.row == 7 {
        //                    cell.lblTitle.text = "Post code"
        //                    cell.txtField.tag = 888
        //                }
        //                cell.selectionStyle = .none
        //                return cell
        //            }else {
        //                let cell = tableView.dequeueReusableCell(withIdentifier: "ShippingCell") as! ShippingCell
        //                cell.selectionStyle = .none
        //                return cell
        //
        //            }
        //        }
        
        
    }
    
    //MARK:- UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 369 {
            textField.inputView = pickerShipping
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 111 {
            firstName = textField.text ?? ""
        }else if textField.tag == 222{
            lastName = textField.text ?? ""
        }else if textField.tag == 333{
            strEmail = textField.text ?? ""
        }else if textField.tag == 444{
            strPhoneNumber = textField.text ?? ""
        }else if textField.tag == 555{
            strAddress1 = textField.text ?? ""
        }else if textField.tag == 666{
            strAdddress2 = textField.text ?? ""
        }else if textField.tag == 777{
            strCity = textField.text ?? ""
        }else if textField.tag == 888{
            strCountry = textField.text ?? ""
        }else if textField.tag == 999{
            strPostal = textField.text ?? ""
        }
    }
    
    
    //MARK:- UIPickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "Free Delivery"
        }else if row == 1 {
            return "Special Delivery"
        }else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            selectedShipping = "Free Delivery"
        }else if row == 1 {
            selectedShipping = "Special Delivery"
        }
        //        if pickerView.superview is UITextField {
        //            let textField = pickerView.superview as! UITextField
        //            textField.text = selectedShipping
        //        }
        self.tblView.reloadData()
    }
    
    
    //MARK:- Global Methods
    func getAllContactFile() {
        let realm = try! Realm()
        //let predicate = NSPredicate(format: "spIdentifier == '\(stickerPackID)'")
        arrContactList = realm.objects(AddContact.self)//.filter(predicate)
        for person in arrContactList {
            personImage.append(person.imageData)
        }
        //self.contactCollectionView.reloadData()
    }
    
    
    func callSendMailAPI(_ paymentId:String) {
        trayingTimes = trayingTimes + 1
        let totalAmount = String(format: "%.2f", price)
        
        
        let user = "ppcukadmin"
        let password = "Admin123#"
        let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers = ["Authorization": "Basic \(base64Credentials)","Accept":"application/json",
                       "Content-Type": "multipart/form-data", "Connection":"keep-alive"]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let strURL = "http://passportphotocodeuk.com/backend/api/orders/sendMail"
        //let strURL = "https://www.passportphotocodeuk.com/ppuk/api/orders/sendMail"
        //        let strURL = "https://passportphotouk.co.uk/ppuk/api/orders/sendMail"
        var parameters = [String : String]()
        parameters["paypal_transaction_id"] = paymentId
        parameters["transaction_date"] = dateFormatter.string(from: Date())
        parameters["amount"] = totalAmount
        parameters["cst_firstname"] = firstName
        parameters["cst_lastname"] = lastName
        parameters["cst_mobilenumber"] = strPhoneNumber
        parameters["cst_email"] = strEmail
        parameters["plateform"] = "2"
        parameters["cst_address"] = "\(strAddress1), \(strAdddress2), \(strCity), \(strPostal)"
        parameters["cst_shipping_method"] = strShippingMethod
        parameters["cst_shipping_amount"] = "\(shippingCharge)"
        parameters["cst_shipping_type"] = "\(selectedShipping)"
        parameters["app_version"] = "2.0"
        
        print("Parameter:",parameters)
        print("Header:",headers)
        
        appDelegate.showHud()
        upload(multipartFormData: { (multipartFormData) in
            
            for imageData in self.personImage {
                //let image = UIImage(data: photo)
                //let imageData:Data = UIImageJPEGRepresentation(image!, 1.0)!
                multipartFormData.append(imageData, withName: "cst_image[]", fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
                let bcf = ByteCountFormatter()
                bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
                bcf.countStyle = .file
                let string = bcf.string(fromByteCount: Int64(imageData.count))
                print("MB:- \(string)")
            }
            
            for (key, value) in parameters {
                multipartFormData.append((value.data(using: String.Encoding.utf8, allowLossyConversion: false))!, withName: key)
                
                //multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: strURL, method: .post, headers: headers) { (encodingResult) in
            
            
            
            switch encodingResult {
            case .success(let upload, _, _):
                
                upload.validate(statusCode: 200..<600)
                //upload.authenticate(user: user, password: password)
                upload.responseJSON { response in
                    
                    appDelegate.hideHud()
                    if response.result.error != nil {
                        print(response.result.error!)
                        print("failure")
                        //                        self.alert(message: "Fail! Please retry again.", completion: {
                        //                            if self.trayingTimes >= 2 {
                        let messageVC = self.storyboard?.instantiateViewController(withIdentifier: "PaymentMessageVC") as! PaymentMessageVC
                        messageVC.strFlag = "fail"
                        messageVC.strTransaction = paymentId
                        self.navigationController?.pushViewController(messageVC, animated: true)
                        //                            }else {
                        //                                self.callSendMailAPI(paymentId)
                        //                            }
                        //                        })
                        //UIAlertView(title: "Fail", message: "Please retry again.", delegate: nil, cancelButtonTitle: "Ok").show()
                    }else {
                        print("success")
                        print("addProduct Result:\(response)")
                        if let dictResult:[String:Any] = response.result.value as! [String : Any]? {
                            if (dictResult["status"] as! String == "success"){
                                //let successMsg = dictResult["message"] as! String
                                let realm = try! Realm()
                                try! realm.write {
                                    realm.deleteAll()
                                }
                                let messageVC = self.storyboard?.instantiateViewController(withIdentifier: "PaymentMessageVC") as! PaymentMessageVC
                                messageVC.strFlag = "success"
                                messageVC.strTransaction = paymentId
                                self.navigationController?.pushViewController(messageVC, animated: true)
                            }else{
                                if self.trayingTimes >= 2 {
                                    let messageVC = self.storyboard?.instantiateViewController(withIdentifier: "PaymentMessageVC") as! PaymentMessageVC
                                    messageVC.strFlag = "fail"
                                    messageVC.strTransaction = paymentId
                                    self.navigationController?.pushViewController(messageVC, animated: true)
                                }else {
                                    self.callSendMailAPI(paymentId)
                                }
                            }
                        }
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
            //failure
            }
        }
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


extension ChekoutViewController : PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        Stripe.setDefaultPublishableKey("pk_live_51HywFbJmxHQ890tSYPm6kjivC3lMNpDPl3xyIeTaktngN1ChqT8NjcEED37CrsXAfq14OFhgkvEokjONXUOy4PEx00LJ2fqLZZ")
//        Stripe.setDefaultPublishableKey("pk_test_51HywFbJmxHQ890tSxAwz9N7Jsm6GV8grLJ7aitkgZ2XAol4MPEl9GqZOAPEK7pVFt9EJF2XNEWbbG8KwXxV4aEmk00sAILTMfu")
        
        // 3
//        STPAPIClient.shared.createToken(with: <#T##PKPayment#>, completion: <#T##STPTokenCompletionBlock##STPTokenCompletionBlock##(STPToken?, Error?) -> Void#>)
        STPAPIClient.shared.createToken(with: payment) {
            (token, error) -> Void in
            
            if (error != nil) {
                completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.failure, errors: nil))
                return
            }
            
            //            self.callSendMailAPI(token?.tokenId ?? "")
            
            // 4
            //            let shippingAddress = self.createShippingAddressFromRef(address: payment.shippingAddress)
            
            // 5
            let url = "http://passportphotocodeuk.com/backend/api/Stripepay/Pay"
            let user = "ppcukadmin"
            let password = "Admin123#"
            let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
            let base64Credentials = credentialData.base64EncodedString(options: [])
            
            //            let request = NSMutableURLRequest(url: url! as URL)
            //            request.httpMethod = "POST"
            //            request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
            //            request.setValue("application/json", forHTTPHeaderField: "Accept")
            //            request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
            //            request.setValue("keep-alive", forHTTPHeaderField: "Connection")
            
            let headers = ["Authorization": "Basic \(base64Credentials)","Accept":"application/json",
                           "Content-Type": "multipart/form-data", "Connection":"keep-alive"]
            
            let parameters = ["token": token?.tokenId ?? "",
                              "amount": "\(Int(round(self.total * 100)))",
                              "currency":"GBP",
                              "description": "\(self.firstName) PPCUK - IOS - ApplePay",
            ] as [String : String]
            
            print("BODY: \(parameters)")
            print("Header: \(headers)")
            
            //            Alamofire.request(url, method: .post, parameters: body, headers: headers).responseJSON { (response) in
            //                let str = String(decoding: response.data!, as: UTF8.self)
            //                print(str);
            //            }
            
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
                        
                        if response.result.error != nil {
                            print(response.result.error!)
                            print("failure")
                            completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.failure, errors: nil))
                        }else {
                            print("success")
                            
                            
//
                            if let dictResult:[String:Any] = response.result.value as! [String : Any]? {
                                let data = dictResult["data"] as! [String : Any]
                                if let status = data["status"] as? String, status == "succeeded"{
                                    self.callSendMailAPI(token?.tokenId ?? "")
                                    completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.success, errors: nil))
                                }else {
                                    completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.failure, errors: nil))
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
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
