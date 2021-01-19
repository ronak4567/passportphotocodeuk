//
//  TermsViewController.swift
//  Quick & Easy Photo ID
//
//  Created by bhavin on 06/06/18.
//  Copyright © 2018 Nirav Gondaliya. All rights reserved.
//

import UIKit

class TermsViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addNavBackBtn(withSelector: #selector(goBack))
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        //let colors = [UIColor(red: 136.0/255.0, green: 1.0/255.0, blue: 13.0/255.0, alpha: 1.0),UIColor(red: 44.0/255.0, green: 50.0/255.0, blue: 67.0/255.0, alpha: 1.0)]
        //self.navigationController?.navigationBar.setGradientBackground(colors: colors)
        
        //let color = UIColor(red: 121.0/255.0, green: 26.0/255.0, blue: 30.0/255.0, alpha: 1.0)
        //self.navigationController?.navigationBar.barTintColor =  color
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Action Methods
    @IBAction func btnNextTapped(_ sender : UIButton){
        let generalGuideLineVC = GeneralGuidelinesViewController.instantiate(fromAppStoryboard: .Main)
        self.navigationController?.pushViewController(generalGuideLineVC, animated: true)
    }

}
