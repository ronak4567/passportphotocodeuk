//
//  HomeViewController.swift
//  Quick & Easy Photo ID
//
//  Created by Nirav Gondaliya on 09/05/18.
//  Copyright © 2018 Nirav Gondaliya. All rights reserved.
//

import UIKit
import RealmSwift
import IGRPhotoTweaks
import Toast_Swift
import MessageUI
import Alamofire
//import FullMaterialLoader

let kValue : String = "value"

class HomeViewController: BaseViewController , MFMailComposeViewControllerDelegate  {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtFname: UITextField!
    @IBOutlet weak var txtSurname: UITextField!
    //@IBOutlet weak var txtStreetAddress: UITextField!
    //@IBOutlet weak var txtCity: UITextField!
    //@IBOutlet weak var txtpostalCode: UITextField!
    @IBOutlet weak var txtContactNumber: UITextField!
    
    
    @IBOutlet weak var imgUser: UIImageView!
    var img:UIImage?
    var selectedDeliveryOption : [String:Any]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addNavBackBtn(withSelector: #selector(goBack))
        // self.addRightBtnAdd(withSelector: #selector(save))
        
        self.imgUser.image = CropUser.shared.editedImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Customer’s Details"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: - Tapped Methods
    @IBAction func onBtnSaveClick(_ sender: UIButton) {
        self.saveImage(image: self.imgUser.image!)
    }
    
    @IBAction func onBtnNextClick(_ sender: UIButton) {
        let error = self.validateView()
        if !error.isEmpty  {
            let alert = UIAlertController (title: "Required", message: error, preferredStyle: .alert)
            let btnOK = UIAlertAction (title: "OK", style: .cancel, handler: nil)
            alert.addAction(btnOK)
            self.present(alert, animated: true, completion: nil)
        }else {
            
        }
    }
    
    //MARK: - Methods
    @objc func save() {
        let imageNames = self.loadImagesFromAlbum()
        if imageNames.count >= 5 {
            self.alert(message: kAddImage) {}
        } else {
            let name = imageNames.count == 0 ? "1" : String(imageNames.count + 1)
            self.saveImageToDirectory(image: self.imgUser.image!, imageName: name) {
                self.alert(message: kImageSave, completion: { [weak self] in
                    self?.backNav()
                })
            }
        }
    }
    
    func backNav() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 5], animated: true)
    }
    
    func validateView()-> String{
        
        let erroMessge : String = ""
        
        if self.txtFname.text!.isEmpty{
            return "Please enter first name"
        }else if self.txtSurname.text!.isEmpty{
            return "Please enter last name"
        }else if self.txtEmail.text!.isEmpty{
            return "Please enter email address"
        }else if self.txtContactNumber.text!.isEmpty{
            return "Please enter contact number"
        }
        return erroMessge
    }
    
    //    func showIndicator() {
    //        indicator = MaterialLoadingIndicator(frame: CGRect(x:0, y:0, width: 50, height: 50))
    //        indicator.center = self.view.center
    //        self.view.addSubview(indicator)
    //        indicator.startAnimating()
    //    }
    //
    //    func hideIndicator() {
    //        indicator.stopAnimating()
    //        self.indicator.removeFromSuperview()
    //    }
    
    //have cc ma to je user nu mail address hase ae j and also add bcc as : adphotolab@gmail.com
    func sendMailWithAttachment(_ paymentId:String){
        //if MFMailComposeViewController.canSendMail() {
        var strCodeGen = ""
        if CropUser.shared.isRedictToCodeGen {
            strCodeGen = "Yes"
        }else{
            strCodeGen = "No"
        }
        
        //let clientMessage = "<p>Name: \(self.txtFname.text!)</br>Email: \(self.txtEmail.text!)</br>Address: \(self.txtHouseNumber.text!),\(self.txtStreetAddress.text!),\(self.txtCity.text!),\(self.txtpostalCode.text!)</br>Contact Number: \(self.txtContactNumber.text!)</br>Generate ID: \(strCodeGen)</br>PaymentID: \(paymentId)</p>"
        
        let clientMessage = "<p>Name: \(self.txtFname.text!)<br />Email:&nbsp;<a href='mailto:\(self.txtEmail.text!)' target='_blank'>\(self.txtEmail.text!)</a><br />Contact Number: \(self.txtContactNumber.text!)<br />Generate ID: \(strCodeGen)<br />PaymentID: \(paymentId)</p>"
        
        //let userMessageGenerateCodeID = "<p>Dear customer,<br />Thank you for placing an order with Passport Photo Code UK. Your unique photo code will be with you within 6-24 hours.</p><p>Any queries please contact us on <a href='mailto:mailphotocodeuk@gmail.com'>photocodeuk</a></p><p>Thank you for your custom <br />Passport Photo code UK</p>"
        
        let userMessage = "<p>Dear customer,<br />Thank you for placing an order with Passport Photo Code UK.<br />Your photographs will be with you within the specified time period.</p><p>Any queries please contact us on <a href='mailto:photocodeuk@gmail.com'>photocodeuk</a></p><p>Thank you for your custom <br />Passport Photo code UK</p>"
        
        
        let imageData:Data = UIImageJPEGRepresentation(CropUser.shared.saveImage, 1.0)!  //UIImagePNGRepresentation()!
        let imageName = self.txtFname.text!
        
        appDelegate.showHud()
        //self.showIndicator()
        let address = try! Address(address: "info@passportphotocodeuk.com")
        let addressTo = try! Address(address: "photocodeuk@gmail.com")
        //let addressTo2 = try! Address(address: "gondaliyaronak4567@gmail.com")
        //let addressTo3 = try! Address(address: "makwana.urnish@gmail.com")
        let message = try! Message(from: address, to: [addressTo], subject: "Passport Photo code UK", body: .html("\(clientMessage)"), attachments: [.init(name: "\(imageName).jpg", mimeType: "image/jpeg", content: imageData)])
        
        
        let server:Server = Server.testServer()
        
        let request:URLRequest = server.requestForSendingMessage(message)
        
        let session = URLSession(configuration: .default)
        
        //let responseExpectation = expectation(description: "response")
        
        var messageID:String?
        let task = session.dataTask(with: request) { (dataOrNil, responseOrNil, errorOrNil) in
            appDelegate.hideHud()
            //self.hideIndicator()
            if let error = errorOrNil {
                print(error)
                self.alert(message: "Mail sending fail. Please note down payment ID: \(paymentId)", completion: {
                    
                })
                //XCTFail("network failure")
                return
            }
            guard let response = SendMessageResponse.messageResponse(urlResponse: responseOrNil, body: dataOrNil) else {
                //XCTFail("no valid response from server")
                self.alert(message: "Mail sending fail. Please note down payment ID: \(paymentId)", completion: {
                    
                })
                return
            }
            if let sendResponse:SendMessageResponse = response as? SendMessageResponse {
                messageID = sendResponse.messageID
                if let id = messageID {
                    print("Admin message id = \(id)")
                    DispatchQueue.main.async {
                        let messageVC = self.storyboard?.instantiateViewController(withIdentifier: "PaymentMessageVC") as! PaymentMessageVC
                        self.navigationController?.pushViewController(messageVC, animated: true)
                    }
                    
                }
                //responseExpectation.fulfill()
                
            } else {
                print(response)
                self.alert(message: "Mail sending fail. Please note down payment ID: \(paymentId)", completion: {
                    
                })
                //XCTFail("didn't get message response")
                return
            }
            
        }
        task.resume()
        
        
        
        let addressFrom = try! Address(address: "info@passportphotocodeuk.com")
        let addressToCustomer = try! Address(address: "\(txtEmail.text!)")
        
        let message2 = try! Message(from: addressFrom, to: [addressToCustomer], subject: "Passport Photo code UK", body: .html("\(userMessage)"))
        
        
        let server2:Server = Server.testServer()
        
        let request2:URLRequest = server2.requestForSendingMessage(message2)
        
        let session2 = URLSession(configuration: .default)
        
        //let responseExpectation = expectation(description: "response")
        
        var messageID2:String?
        let task2 = session2.dataTask(with: request2) { (dataOrNil, responseOrNil, errorOrNil) in
            //appDelegate.hideHud()
            if let error = errorOrNil {
                print(error)
                //XCTFail("network failure")
                return
            }
            guard let response = SendMessageResponse.messageResponse(urlResponse: responseOrNil, body: dataOrNil) else {
                //XCTFail("no valid response from server")
                return
            }
            if let sendResponse:SendMessageResponse = response as? SendMessageResponse {
                messageID2 = sendResponse.messageID
                if let id = messageID2 {
                    print("Customer message id = \(id)")
                    
                }
                //responseExpectation.fulfill()
                
            } else {
                print(response)
                //XCTFail("didn't get message response")
                return
            }
            
        }
        task2.resume()
        
        
        /*let dictImage = ["Name":"image.jpg","ContentType":"image/jpeg","Content":imageData.base64EncodedString()]
         let parameters = ["From":"info@passportphotocodeuk.com", "To":"\(txtEmail.text!)", "Subject":"Passport Photo code UK", "HtmlBody":"\(clientMessage)","Attachments":[dictImage]] as [String : Any]
         appDelegate.showHud()
         Alamofire.request("https://api.postmarkapp.com/email", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json","Accept":"application/json","X-Postmark-Server-Token":"251bc9af-6caa-41a0-ac10-7b07e7997449"]).responseJSON { (response) in
         
         appDelegate.hideHud()
         if response.result.isSuccess {
         if let dictResult:[String:Any] = response.result.value as! [String : Any]? {
         print("Email:\(dictResult)")
         }
         }else{
         
         if let error = response.result.error {
         self.alert(message: error.localizedDescription, completion: {
         
         })
         }
         }
         }*/
        
        
        
    }
    
    //MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true) {
            //let countryVC = CountryViewController.instantiate(fromAppStoryboard: .Main)
            //self.navigationController?.pushViewController(countryVC, animated: true)
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func callSendMailAPI(_ paymentId:String) {
        
        var totalAmount = 0.0
        
        if let deliveryOption = self.selectedDeliveryOption{
            
            if let value = Double(deliveryOption[kValue] as! String){
                totalAmount = totalAmount + value
            }
        }
        //http://passportphotocodeuk.com/backend/api/orders/sendMail
        let user = "ppcukadmin"
        let password = "Admin123#"
        let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers = ["Authorization": "Basic \(base64Credentials)","Content-Type":"application/json"]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let strURL = "http://passportphotocodeuk.com/backend/api/orders/sendMail"
        var parameters = [String : String]()
        parameters["paypal_transaction_id"] = paymentId
        parameters["transaction_date"] = dateFormatter.string(from: Date())
        parameters["amount"] = "\(totalAmount)"
        parameters["cst_firstname"] = txtFname.text!
        parameters["cst_lastname"] = txtSurname.text!
        parameters["cst_mobilenumber"] = txtContactNumber.text!
        parameters["cst_email"] = txtEmail.text!
        parameters["plateform"] = "2"
        parameters["cst_shipping_type"] = "2"
        
        print("Parameter:",parameters)
        print("Header:",headers)
        
        appDelegate.showHud()
        upload(multipartFormData: { (multipartFormData) in
            let imageData:Data = UIImageJPEGRepresentation(CropUser.shared.saveImage, 1.0)!  //UIImagePNGRepresentation()!
            multipartFormData.append(imageData, withName: "cst_image", fileName: "PassportPhoto.jpeg", mimeType: "image/jpeg")
            
            for (key, value) in parameters {
                multipartFormData.append((value.data(using: String.Encoding.utf8, allowLossyConversion: false))!, withName: key)
                
                //multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: strURL, method: .post, headers: headers) { (encodingResult) in
            
            
            
            switch encodingResult {
            case .success(let upload, _, _):
                
                
                upload.validate()
                //upload.authenticate(user: user, password: password)
                upload.responseJSON { response in
                    
                    appDelegate.hideHud()
                    if response.result.error != nil {
                        print(response.result.error!)
                        print("failure")
                        self.alert(message: "Fail! Please retry again.", completion: {
                            
                        })
                        //UIAlertView(title: "Fail", message: "Please retry again.", delegate: nil, cancelButtonTitle: "Ok").show()
                    } else {
                        print("success")
                        print("addProduct Result:\(response)")
                        if let dictResult:[String:Any] = response.result.value as! [String : Any]? {
                            if (dictResult["status"] as! String == "success"){
                                //let successMsg = dictResult["message"] as! String
                                
                                let messageVC = self.storyboard?.instantiateViewController(withIdentifier: "PaymentMessageVC") as! PaymentMessageVC
                                messageVC.strFlag = "success"
                                messageVC.strTransaction = paymentId
                                self.navigationController?.pushViewController(messageVC, animated: true)
                            }else{
                                let messageVC = self.storyboard?.instantiateViewController(withIdentifier: "PaymentMessageVC") as! PaymentMessageVC
                                messageVC.strFlag = "fail"
                                messageVC.strTransaction = paymentId
                                self.navigationController?.pushViewController(messageVC, animated: true)
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
    
    
}

extension HomeViewController {
    
    @objc func saveImage(image:UIImage) {
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            self.view.makeToast("Image saved to photos.", duration: 3.0, position: .bottom)
            
        }
    }
    
    @objc func addRightBtnAdd(withSelector selector:Selector){
        let btn = UIButton (frame: CGRect (x: 0, y: 0, width: 35, height: 35))
        btn.setTitle("Add", for: .normal)
        btn.addTarget(self, action: selector, for: .touchUpInside)
        let barBtn = UIBarButtonItem (customView: btn)
        
        self.navigationItem.rightBarButtonItems = [barBtn]
    }
    
    
}
