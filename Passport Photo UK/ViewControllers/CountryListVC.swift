//
//  CountryListVC.swift
//  Passport Photo UK
//
//  Created by Depixed on 04/07/21.
//  Copyright © 2021 Nirav Gondaliya. All rights reserved.
//

import UIKit
import SDWebImage
import RealmSwift
class CountryCell: UITableViewCell {
    @IBOutlet var lblName:UILabel!
    @IBOutlet var lblPassportService:UILabel!
    @IBOutlet var lblSize:UILabel!
    @IBOutlet var imgCountrView:UIImageView!
}

class CountryListVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    var arrCountryList:[Dictionary<String, Any>] = [];
    var arrPerson:Results<AddContact>!
    @IBOutlet var tblCountry:UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addNavBackBtn(withSelector: #selector(goBack))
        self.title = "Select Country"
        
        getAllCountryList();
        getAllContactFile()
        
        // Do any additional setup after loading the view.
    }
    
    func getAllCountryList() {
        if let path = Bundle.main.path(forResource: "country_dimensions", ofType: "json")
        {
            
            let jsonData = try! NSData(contentsOfFile: path, options: .dataReadingMapped)
            
            if let jsonResult: NSDictionary = try! JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary//(jsonData, options: JSONSerialization.ReadingOptions.mutableContainers, error: nil)
                {
                    if let countryList = jsonResult["country_list"] as? [Dictionary<String, Any>]
                    {
                        arrCountryList = countryList;
                        self.tblCountry.reloadData()
                    }
                }
            
        }
    }
    
    func getAllContactFile() {
        let realm = try! Realm()
        //let predicate = NSPredicate(format: "spIdentifier == '\(stickerPackID)'")
        arrPerson = realm.objects(AddContact.self)//.filter(predicate)
        
    }
    
    //UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrCountryList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell") as! CountryCell
        let dictCountry = self.arrCountryList[indexPath.row]
        cell.lblName.text = dictCountry["country_name"] as? String
        cell.lblPassportService.text = dictCountry["country_service_name"] as? String
        cell.lblSize.text = "\(dictCountry["country_dimension_mm"] as! String) \(dictCountry["country_dimension_cm"] as! String)"
        
        cell.imgCountrView.sd_setImage(with: URL(string: dictCountry["country_flag"] as? String ?? ""), completed: nil)
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        CropUser.shared.isCaptureMultiplePic = false
        if arrPerson.count > 3 {
            let alert = UIAlertController (title: "You have selected four photo Are you continue to Order?", message: "", preferredStyle: .alert)
            let btnProceed = UIAlertAction(title: "Proceed", style: .default, handler: { (alertAction) in
                CropUser.shared.countryInfo = self.arrCountryList[indexPath.row]
                let homeVC = MultiplePersonVC.instantiate(fromAppStoryboard: .Main)
                self.navigationController?.pushViewController(homeVC, animated: true)
            })
            alert.addAction(btnProceed)
            let btnCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(btnCancel)
            self.present(alert, animated: true, completion: nil)
        }else {
            let cropVC = PreviewViewController.instantiate(fromAppStoryboard: .Main)
            //cropVC.selectedRatio = CropUser.shared.ratio
            //cropVC.country = self.selectedCountry
            //cropVC.selectedType = self.selectedSize
            //cropVC.IDSize = self.IDSize
            //cropVC.aspectHeightHead = self.aspectHeightHead
            CropUser.shared.countryInfo = self.arrCountryList[indexPath.row]
            self.navigationController?.pushViewController(cropVC, animated: true)
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
