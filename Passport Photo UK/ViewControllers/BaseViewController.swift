//
//  BaseViewController.swift
//  Quick & Easy Photo ID
//
//  Created by Nirav Gondaliya on 04/05/18.
//  Copyright © 2018 Nirav Gondaliya. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    enum NavMenuIcons {
        case menu
        case back
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.setBackGroundImage()
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(red: 38.0/255.0, green: 51.0/255.0, blue: 132.0/255.0, alpha: 1.0)
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        
        let color = UIColor(red: 38.0/255.0, green: 51.0/255.0, blue: 132.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor =  color
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

//MARK: User Define Methods
extension BaseViewController {
    func setBackGroundImage() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = #imageLiteral(resourceName: "background")
        backgroundImage.contentMode =  UIViewContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
    }
    
    func addNavMenuBtn(withSelector selector:Selector)  {
        
    }
    
    func addNavBackBtn(withSelector selector:Selector){
        
        let btn = UIButton (frame: CGRect (x: 0, y: 0, width: 35, height: 35))
        btn.setImage(#imageLiteral(resourceName: "img_Back"), for: .normal)
        btn.addTarget(self, action: selector, for: .touchUpInside)
        let barBtn = UIBarButtonItem (customView: btn)
        
        self.navigationItem.leftBarButtonItems = [barBtn]
    }
    
    func addNavCloseBtn(withSelector selector:Selector){
        
        let btn = UIButton (frame: CGRect (x: 0, y: 0, width: 35, height: 35))
        btn.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        btn.addTarget(self, action: selector, for: .touchUpInside)
        let barBtn = UIBarButtonItem (customView: btn)
        
        self.navigationItem.leftBarButtonItems = [barBtn]
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func goClose() {
        self.dismiss(animated: true) {
            
        }
    }
    
    func addRightBtn(withSelector selector:Selector){
        
        let btn = UIButton (frame: CGRect (x: 0, y: 0, width: 35, height: 35))
        btn.setTitle("OK", for: .normal)
        btn.addTarget(self, action: selector, for: .touchUpInside)
        let barBtn = UIBarButtonItem (customView: btn)
        
        self.navigationItem.rightBarButtonItems = [barBtn]
    }
    
    //MARK: - store and get images
    
    func createDirectory () {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("Images")
        
        do {
            try FileManager.default.createDirectory(atPath: dataPath.absoluteString, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
    }
    
    
    func saveImageToDirectory (image: UIImage,imageName: String, completion: () -> Void){
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("Images")
        
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
        
        let fileName = "\(imageName).png"
        let fileURL = documentsDirectory.appendingPathComponent("Images").appendingPathComponent(fileName)
        if let data = UIImageJPEGRepresentation(image, 1.0),
            !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try data.write(to: fileURL)
                completion()
                print("file saved")
            } catch {
                print("error saving file:", error)
            }
        }
    }
    
    func loadImagesFromAlbum() -> [String]{
        
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        var theItems = [String]()
        if let dirPath          = paths.first
        {
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent("Images")
            
            do {
                theItems = try FileManager.default.contentsOfDirectory(atPath: imageURL.path)
                theItems.remove(at: 0)
                return theItems
            } catch let error as NSError {
                print(error.localizedDescription)
                return theItems
            }
        }
        return theItems
    }
    
    
    func getImage(ImageName: String) -> UIImage {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath          = paths.first
        {
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent("Images").appendingPathComponent(ImageName)
            let image    = UIImage(contentsOfFile: imageURL.path)
            return image!
        }
        
        return UIImage()
    }
    
    func alert(message: String, completion:@escaping () -> Void) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "OK", style: .default) { (ok) in
            completion()
        }
        alertController.addAction(okBtn)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
