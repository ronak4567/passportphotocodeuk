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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Preview"
        self.imgViewPreview.image = image
        
        self.addNavBackBtn(withSelector: #selector(goBack))
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Tapped Event
    @IBAction func tappedOnSave(_ sender:UIButton) {
        
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
        CropUser.shared.editedImage = image
        CropUser.shared.saveImage = image
        let homeVC = MultiplePersonVC.instantiate(fromAppStoryboard: .Main)
        //homeVC.selectedDeliveryOption = ["title": "None", "value": "4.99"]
        //homeVC.selectedDeliveryOption = ["title": "None", "value": "0.01"]
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    
    @IBAction func tappedOnCancel(_ sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
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

extension UIImage {
    var jpeg: Data? {
        return UIImageJPEGRepresentation(self, 0.5) // QUALITY min = 0 / max = 1
    }
    var png: Data? {
        return UIImagePNGRepresentation(self)
    }
}
