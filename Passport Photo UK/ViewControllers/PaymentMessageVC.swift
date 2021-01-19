//
//  PaymentMessageVC.swift
//  Quick & Easy Photo ID
//
//  Created by Hari Prabodhm on 28/03/19.
//  Copyright © 2019 Nirav Gondaliya. All rights reserved.
//

import UIKit

class PaymentMessageVC: BaseViewController {

    var strFlag = ""
    var strTransaction = ""
    @IBOutlet var imgResult:UIImageView!
    @IBOutlet var lblTitleMessage:UILabel!
    @IBOutlet var lblMessage:UILabel!
    @IBOutlet var lblEmail:UILabel!
    var isBack = false;
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addNavBackBtn(withSelector: #selector(onBtnOkClick(_:)))
        navigationItem.title = "Payment Status"
        if strFlag == "success" {
            lblTitleMessage.text = "Thanks for your Order!"
            lblMessage.text = "Your order will be with you within the specified time period.\n\nAny queries please contact us on"
            imgResult.image = UIImage(named: "imgConfirm")
        }else {
            lblTitleMessage.text = "Oops! Something went wrong."
            lblMessage.text = "Connection error \n\nUnable to connect with the server. Please note down your transaction ID:\n\(strTransaction)\n\nPlease send us your photo at"
            imgResult.image = UIImage(named: "imgFail")
        }
        
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "photocodeuk@gmail.com")
        attributeString.addAttribute(NSAttributedStringKey.underlineStyle, value: 1, range: NSMakeRange(0, attributeString.length))
        lblEmail.attributedText = attributeString
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onBtnOkClick(_ sender: UIButton) {
        for viewController in (self.navigationController?.viewControllers)! {
            if viewController is TakePhotoViewController {
                isBack = true;
                self.navigationController?.popToViewController(viewController, animated: true)
            }
        }
        if (!isBack){
            for viewController in (self.navigationController?.viewControllers)! {
                if viewController is GoodAndBadViewController {
                    self.navigationController?.popToViewController(viewController, animated: true)
                }
            }
        }
    }
    
    @IBAction func tappedOnMail(_ sender: UIButton) {
        let strLink = "mailto:photocodeuk@gmail.com"
        if let url = URL(string: strLink) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func tappedOnContact(_ sender: UIButton) {
        let strLink = "telprompt:07702396886"
        if let url = URL(string: strLink) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            } else {
                UIApplication.shared.openURL(url)
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
