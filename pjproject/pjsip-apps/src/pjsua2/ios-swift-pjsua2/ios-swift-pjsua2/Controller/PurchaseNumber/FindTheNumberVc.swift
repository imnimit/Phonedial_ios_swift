//
//  FindTheNumberVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 28/02/23.
//

import UIKit

class FindTheNumberVc: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var trailingOfSearchBar: NSLayoutConstraint!
    
    var isTollFree = false
    var CountyInfo = [String:Any]()
    var FindTheNumber = [[String:Any]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Search by area code"
        GetNumberByAreaCodeAPI()
        searchBar.placeholder = "Enter \(CountyInfo["name"] as? String ?? "") area code"
        btnSearch.layer.cornerRadius = 10
        searchBar.delegate = self
        trailingOfSearchBar.constant = 0
        self.hideKeybordTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
   
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    
    // MARK: - But Click
    @IBAction func btnClickSearch(_ sender: UIButton) {
        GetNumberByAreaCodeAPI()
    }
    
    
    // MARK: - API Calling
    func GetNumberByAreaCodeAPI() {
        let requestData : [String : String] = ["areacode": (searchBar.text == "") ? "all" : (searchBar.text ?? "")
                                               ,"countrycode":CountyInfo["Code"] as? String ?? ""
                                               ,"iso":CountyInfo["iso"] as? String ?? ""
                                               ,"request":"get_number_by_areacode"
                                               ,"token":User.sharedInstance.getUser_token()
                                               ,"tollfree":(isTollFree == true) ? "yes" : "no"
                                               ]
        print(requestData)
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as? String ?? "" == "2" {
                self.showToastMessage(message: diddata["message"] as? String)
            } else {
                let Data : [String: Any] = (diddata["response"] as! [String: Any])
                FindTheNumber = Data["areacode_number"] as! [[String:Any]]
                tableView.reloadData()
                print(Data)
            }
        })
    }
    
}
extension FindTheNumberVc:  UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FindTheNumber.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListOFPurchaseNumberCell", for: indexPath) as! ListOFPurchaseNumberCell
        let DicForData = FindTheNumber[indexPath.row]
        cell.lblFlag.text = CountyInfo["Img"] as? String ?? ""
        cell.lblNumber.text = DicForData["friendlyName"] as? String ?? ""
        cell.lblCountryName.text = DicForData["isoCountry"] as? String ?? ""
        cell.separatorVW.isHidden = false
//        if indexPath.row == FindTheNumber.count - 1 {
//            cell.separatorVW.isHidden = true
//        }

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let dicData = FindTheNumber[indexPath.row]
        
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PayNowPurchaseNumberVc") as! PayNowPurchaseNumberVc
        nextVC.payemntData = dicData
        nextVC.CountyInfo = self.CountyInfo
        navigationController?.pushViewController(nextVC, animated: true)
        
    }
}
extension FindTheNumberVc : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        btnSearch.isHidden = false
        trailingOfSearchBar.constant = 95
        if searchBar.text == "" {
            GetNumberByAreaCodeAPI()
            btnSearch.isHidden = true
            trailingOfSearchBar.constant = 0
            dismissKeyboard()
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
