//
//  MultiplePersonVC.swift
//  Quick & Easy Photo ID
//
//  Created by Ronak Gondaliya on 09/12/19.
//  Copyright © 2019 Nirav Gondaliya. All rights reserved.
//

import UIKit
import ContactsUI
import RealmSwift

import Foundation

class AddContact: Object {
    @objc dynamic var FullName = ""
    @objc dynamic var imageData = Data()
}

class ContactCell: UICollectionViewCell {
    @IBOutlet var imageFile: UIImageView!
    @IBOutlet var lblStickerNO: UILabel!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var btnDelete: UIButton!
}

class AddContactCell: UICollectionViewCell {
    @IBOutlet var imageFile: UIImageView!
}

class MultiplePersonVC: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var contactCollectionView: UICollectionView!
    
    //@IBOutlet var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet var lblSubTotal: UILabel!
    
    @IBOutlet var btnEmailOption: UIButton!
    @IBOutlet var btnHomeDeliveryOption: UIButton!
    @IBOutlet var btnBothOption: UIButton!
    @IBOutlet var btnInfo: UIButton!
    
    @IBOutlet var viewPhotocode: UIView!
    @IBOutlet var lblPhotoCodeSummery: UILabel!
    @IBOutlet var lblPhotoCodeSummery2: UILabel!
    @IBOutlet var viewPrintedPhoto: UIView!
    @IBOutlet var lblPhotoPrintSummery: UILabel!
    @IBOutlet var viewBoth: UIView!
    
    
    
    private let topMarginInset: CGFloat = 5.0
    private let marginInset: CGFloat = 22
    private let interimMargin: CGFloat = 16.0
    private var itemsPerRow: Int = 3
    
    var selectedContact:CNContact!
    
    var arrContactNumber:[CNLabeledValue<CNPhoneNumber>] = []
    
    var arrContactList:Results<AddContact>!
    var subTotal = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CropUser.shared.isCountryUK {
            btnInfo.isHidden = false
        }else {
            btnInfo.isHidden = true
        }
        self.title = "Select an Option"
        
        
        self.addNavBackBtn(withSelector: #selector(goBack))
        
        self.getAllContactFile()
        
        if CropUser.shared.isCountryUK {
            
        }else {
            btnEmailOption.setTitle("  Digital Photo", for: .normal)
            btnBothOption.setTitle("  Digital Photo + 4 Printed Photos", for: .normal)
        }
            
        // Do any additional setup after loading the view.
    }
    
    func getAllContactFile() {
        let realm = try! Realm()
        //let predicate = NSPredicate(format: "spIdentifier == '\(stickerPackID)'")
        arrContactList = realm.objects(AddContact.self)//.filter(predicate)
        self.contactCollectionView.reloadData()
    }
    
    @IBAction func tappedOnBack(_ sender:UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedOnRadio(_ sender:UIButton) {
        subTotal = 0.0;
        if sender == btnEmailOption {
            subTotal = 4.99 * Double(arrContactList.count)
            lblPhotoCodeSummery.textColor = UIColor.white
            lblPhotoCodeSummery2.textColor = UIColor.white
            lblPhotoPrintSummery.textColor = UIColor.darkGray
            viewPhotocode.backgroundColor = UIColor(red: 38.0/255.0, green: 51.0/255.0, blue: 132.0/255.0, alpha: 1.0)
            viewPrintedPhoto.backgroundColor = UIColor.white
            viewBoth.backgroundColor = UIColor.white
            btnBothOption.isSelected = false
            btnEmailOption.isSelected = true
            btnHomeDeliveryOption.isSelected = false
        }else if sender == btnHomeDeliveryOption {
            lblPhotoCodeSummery.textColor = UIColor.darkGray
            lblPhotoCodeSummery2.textColor = UIColor.darkGray
            lblPhotoPrintSummery.textColor = UIColor.white
            viewPhotocode.backgroundColor = UIColor.white
            viewPrintedPhoto.backgroundColor = UIColor(red: 38.0/255.0, green: 51.0/255.0, blue: 132.0/255.0, alpha: 1.0)
            viewBoth.backgroundColor = UIColor.white
            subTotal = 4.99 * Double(arrContactList.count);
            btnBothOption.isSelected = false
            btnEmailOption.isSelected = false
            btnHomeDeliveryOption.isSelected = true
        }else if sender == btnBothOption {
            lblPhotoCodeSummery.textColor = UIColor.darkGray
            lblPhotoCodeSummery2.textColor = UIColor.darkGray
            lblPhotoPrintSummery.textColor = UIColor.darkGray
            viewPhotocode.backgroundColor = UIColor.white
            viewPrintedPhoto.backgroundColor = UIColor.white
            viewBoth.backgroundColor = UIColor(red: 38.0/255.0, green: 51.0/255.0, blue: 132.0/255.0, alpha: 1.0)
            subTotal = 9.98 * Double(arrContactList.count);
            //subTotal = subTotal + 4.99
            btnBothOption.isSelected = true
            btnEmailOption.isSelected = false
            btnHomeDeliveryOption.isSelected = false
        }
        
        lblSubTotal.text = "£\(subTotal)"
    }
    
    @IBAction func tappedOnInfo(_ sender:UIButton) {
        let alert = UIAlertController (title: "Code will be delivered within 24 hours (if your photo meets the rules).", message: "", preferredStyle: .alert)
        
        let btnCancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(btnCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tappedOnNext(_ sender:UIButton) {
        var shipMethod = ""
        if btnEmailOption.isSelected {
           shipMethod = "email"
        }else if btnHomeDeliveryOption.isSelected {
            shipMethod = "post"
        }else if btnBothOption.isSelected {
            shipMethod = "both"
        }
        if shipMethod == "" {
            alert(message: "Please select option.") {
                
            }
        }else {
            if self.arrContactList.count == 0 {
                let alert = UIAlertController(title: "Warning!!!", message: "You have to at least 1 photo.!!!", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else if arrContactList.count > 4 {
                let alert = UIAlertController(title: "Warning!!!", message: "Maximum 4 photos can be added at a time.!!!", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else {
                if (shipMethod == "email"){
//                    let alert = UIAlertController (title: "Code will be delivered within 24 hours (if your photo meets the rules).", message: "", preferredStyle: .alert)
//                    let btnProceed = UIAlertAction(title: "Proceed", style: .default, handler: { (alertAction) in
                        let chekoutVC = ChekoutViewController.instantiate(fromAppStoryboard: .Main)
                        chekoutVC.strShippingMethod = "email"
                        chekoutVC.price = Float(self.subTotal);
                        chekoutVC.selectedShipping = "0";
                        chekoutVC.shippingCharge = 0.00;
                        self.navigationController?.pushViewController(chekoutVC, animated: true)
//                    })
//                    alert.addAction(btnProceed)
//                    
//                    let btnCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//                    alert.addAction(btnCancel)
//                    self.present(alert, animated: true, completion: nil)
                }else {
                    let deliveryVC = DeliveryOptionVC.instantiate(fromAppStoryboard: .Main)
                    deliveryVC.strShippingMethod = shipMethod
                    deliveryVC.price = Float(self.subTotal);
                    self.navigationController?.pushViewController(deliveryVC, animated: true)
                }
            }
        }
    }
    
    // MARK: - Collectionview
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interimMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: topMarginInset, left: marginInset, bottom: 60, right: marginInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let length = (collectionView.bounds.size.width - marginInset * 2 - interimMargin * CGFloat(itemsPerRow - 1)) / CGFloat(itemsPerRow)
        //self.widthTrayConstraint.constant = length
        //self.collectionViewHeight.constant = (length+20) * 2
        return CGSize(width: length, height: length)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrContactList.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddContactCell", for: indexPath) as! AddContactCell
            
            
            //cell.sticker = stickerPack.stickers[indexPath.row]
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactCell", for: indexPath) as! ContactCell
            //cell.sticker = stickerPack.stickers[indexPath.row]
            let dbContact = arrContactList[indexPath.row-1]
            cell.lblName.text = "" //dbContact.FullName
            if dbContact.imageData.count > 5 {
                cell.imageFile.image = UIImage(data: dbContact.imageData)
                //let length = (collectionView.bounds.size.width - marginInset * 2 - interimMargin * CGFloat(itemsPerRow - 1)) / CGFloat(itemsPerRow)
                cell.imageFile.layer.cornerRadius = 10.0
            }else {
//                cell.imageFile.setImage(string: dbContact.FullName, color: UIColor.red, circular: true, stroke: false, textAttributes: nil)
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.width))
                imageView.setImage(string: dbContact.FullName, color: UIColor.lightGray, circular: true, stroke: false, textAttributes: nil)
                cell.imageFile.image = imageView.image
                cell.imageFile.layer.cornerRadius = 10.0
            }
            
            cell.lblStickerNO.text = "\(indexPath.row)"
            cell.btnDelete.tag = indexPath.row - 1
            cell.btnDelete.addTarget(self, action: #selector(tappedOnDeleteStickerFile(_:)), for: .touchUpInside)
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let sticker: Sticker = stickerPack.stickers[indexPath.item]
        if indexPath.row == 0 {
            click_Contact()
        }else {
            //showActionSheet(withSticker: arrStickersFile[indexPath.row-1])
        }
    }
    
    @IBAction func tappedOnDeleteStickerFile(_ sender:UIButton) {
        
        let alert = UIAlertController(title: "Are you sure?", message: "Are you sure you want to delete this contact from shortcut?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            let dbSticker = self.arrContactList[sender.tag]
            let realm = try! Realm()
            realm.beginWrite()

            realm.delete(dbSticker)
            try! realm.commitWrite()
            
            self.getAllContactFile()
            //self.subTotal = 4.99 * Double(self.arrContactList.count);
            if self.btnEmailOption.isSelected {
                self.subTotal = 4.99 * Double(self.arrContactList.count)
            }else if self.btnHomeDeliveryOption.isSelected {
                self.subTotal = 4.99 * Double(self.arrContactList.count);
            }else if self.btnBothOption.isSelected {
                self.subTotal = 9.98 * Double(self.arrContactList.count);
            }
            self.lblSubTotal.text = "£\(self.subTotal)"
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler: { (UIAlertAction) in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //MARK:- CNContactPickerDelegate Method
    func click_Contact() {
        
        if arrContactList.count > 3 {
            let alert = UIAlertController(title: "Warning!!!", message: "Maximum four photos can be added at a time.", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else {
            var isRedirect = false;
            for viewController in self.navigationController!.viewControllers {
                if viewController is TakePhotoViewController {
                    isRedirect = true
                    CropUser.shared.isCaptureMultiplePic = true
                    self.navigationController?.popToViewController(viewController, animated: true);
                }
            }
            
            if !isRedirect {
                CropUser.shared.isCaptureMultiplePic = true
                let cropVC = TakePhotoViewController.instantiate(fromAppStoryboard: .Main)
                self.navigationController?.pushViewController(cropVC, animated: true);
            }
            
//            let cropVC = TakePhotoViewController.instantiate(fromAppStoryboard: .Main)
//            cropVC.isCaptureMultiplePic = true
//            let navigation = self.navigationController;
//            navigation
//            self.present(cropVC, animated: true) {
                
//            }
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
