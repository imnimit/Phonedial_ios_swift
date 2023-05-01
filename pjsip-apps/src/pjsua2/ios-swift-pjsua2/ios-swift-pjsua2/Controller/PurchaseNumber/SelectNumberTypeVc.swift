//
//  SelectNumberTypeVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 20/12/22.
//

import UIKit

class SelectNumberTypeVc: UIViewController {

    @IBOutlet weak var loclCitySelectionVW: UIView!
    @IBOutlet weak var tolFreeCitySelectionVW: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initCall()
    }
    
    func initCall(){
        self.title = "Select Type"
        
        loclCitySelectionVW.layer.cornerRadius = 5
        loclCitySelectionVW.layer.borderColor = #colorLiteral(red: 0.1069028154, green: 0.6903560162, blue: 0.8614253998, alpha: 1)
        loclCitySelectionVW.layer.borderWidth = 1
        
        tolFreeCitySelectionVW.layer.cornerRadius = 5
        tolFreeCitySelectionVW.layer.borderColor = #colorLiteral(red: 0.1069028154, green: 0.6903560162, blue: 0.8614253998, alpha: 1)
        tolFreeCitySelectionVW.layer.borderWidth = 1
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = false

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    
    //MARK: - btn click
    @IBAction func btnSelectionCountry(_ sender: UIButton) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NumberPuchaseTimeListCountyVc") as! NumberPuchaseTimeListCountyVc
        if sender.tag == 1 {
            nextVC.tollFreeCity = false
            nextVC.isTollFree = false
        } else {
            nextVC.tollFreeCity = true
            nextVC.isTollFree = true
        }
        navigationController?.pushViewController(nextVC, animated: true)
    }
}
