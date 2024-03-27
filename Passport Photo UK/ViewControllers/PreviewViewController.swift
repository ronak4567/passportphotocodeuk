//
//  PreviewViewController.swift
//  Quick & Easy Photo ID
//
//  Created by Ronak Gondaliya on 02/11/18.
//  Copyright © 2018 Nirav Gondaliya. All rights reserved.
//

import UIKit
import RealmSwift
class PreviewViewController: BaseViewController {

    var image:UIImage!
    @IBOutlet var imgViewPreview:UIImageView!
    
    var picker:UIImagePickerController? = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Preview"
        self.imgViewPreview.image = image
        picker?.delegate = self
        self.addNavBackBtn(withSelector: #selector(goBack))
        NotificationCenter.default.addObserver(self, selector: #selector(removeImage),
                         name: NSNotification.Name ("removeImage"),object: nil)
        // Do any additional setup after loading the view.
    }
    
    @objc func removeImage(){
        self.imgViewPreview.image = nil
        image = nil;
    }
    
    // MARK: - Tapped Event
    @IBAction func tappedOnSave(_ sender:UIButton) {
        if image != nil {
            let addContact = AddContact()
            addContact.FullName = "Person"
            if let data = image.jpeg {
                addContact.imageData = data
            }else {
                
            }
            let realm = try! Realm()
            try! realm.write {
                realm.add(addContact)
            }
            let homeVC = MultiplePersonVC.instantiate(fromAppStoryboard: .Main)
            self.navigationController?.pushViewController(homeVC, animated: true)
        }else{
            alert(message: "Please Select Or Capture Photo.") {
            }
        }
        
    }
    
    @IBAction func tappedOnCancel(_ sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnGalleryTapped(_ sender : UIButton){
        self.openLibrary()
    }
    
    @IBAction func btnCameraTapped(_ sender : UIButton){
        self.openCamera()
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

extension PreviewViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func openLibrary() {
        
        Utility.getPhotoLibraryAuthorizationStatus { (status, error) in
            if status {
                DispatchQueue.main.async {
                    self.picker?.sourceType = .photoLibrary
                    self.present(self.picker!, animated: true, completion: nil)
                }
            }
        }
    }
    
    func openCamera() {
        
        Utility.getCameraAuthorizationStatus(completionHandler: { status, error in
            if status {
                DispatchQueue.main.async {
                    self.picker?.sourceType = .camera
                    self.present(self.picker!, animated: true, completion: nil)
                }
            }
        })
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
//        if CropUser.shared.isCaptureMultiplePic {
//            picker.dismiss(animated: true) {
//                let addContact = AddContact()
//                addContact.FullName = "Person"
//                if let data = image?.jpeg {
//                    addContact.imageData = data
//                }else {
//
//                }
//
//                let realm = try! Realm()
//
//                try! realm.write {
//                    realm.add(addContact)
//                }
//                let homeVC = MultiplePersonVC.instantiate(fromAppStoryboard: .Main)
//                self.navigationController?.pushViewController(homeVC, animated: true)
//            }
//        }else {
            self.image = image;
            picker.dismiss(animated: true) {
                self.imgViewPreview.image = image
            }
//        }
        /*let image = info[UIImagePickerControllerOriginalImage] as! UIImage
         
         CropUser.shared.image = image
         CropUser.shared.ratio = self.selectedRatio
         let cropVC = CropViewController.instantiate(fromAppStoryboard: .Main)
         cropVC.image = image
         cropVC.country = self.country
         cropVC.selectedType = self.selectedType
         
         
         
         
         picker.dismiss(animated: true) {
         self.navigationController?.pushViewController(cropVC, animated: true)
         }*/
        
        
    }
}

extension UIImage {
    var jpeg: Data? {
        return UIImageJPEGRepresentation(self, 0.5) // QUALITY min = 0 / max = 1
    }
    var png: Data? {
        return UIImagePNGRepresentation(self)
    }
}
