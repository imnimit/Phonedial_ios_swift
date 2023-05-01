//
//  MyPurchaseNumberVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 20/12/22.
//

import UIKit

class MyPurchaseNumberVc: UIViewController {

    @IBOutlet weak var btnPurchaseNumber: UIButton!
    @IBOutlet weak var topVW: UIView!
    @IBOutlet weak var tableView: UITableView!
    var dicPurchaseNumber = [[String:Any]]()
    
    @IBOutlet weak var hightPurchaseBtn: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InitCall()
    }
    
    func InitCall(){
        self.title = Constant.ViewControllerTitle.MyPhoneNumber
        btnPurchaseNumber.layer.cornerRadius = btnPurchaseNumber.layer.bounds.height/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        appDelegate.sipRegistration()
        
        DispatchQueue.main.async {
            self.listNumberAPI()
        }
        
        DispatchQueue.main.async {
            self.userBalance()
        }
    }
    
    func FindNumberOFDay(date: String) -> String{
        
        let date1 = Date()
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "MMMM-dd-yyyy HH:mm:ss"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM-dd-yyyy HH:mm:ss" // set the date format
        let dateFrom = dateFormatter.date(from: date)!
        let dateTo = dateFormatter.date(from: dateFormatter.string(from: date1))!

        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: dateFrom, to: dateTo)
        let days = components.day! + 20

        print("Number of days between the two dates: \(days)")
        
        return "\(days)"
    }
    
    @objc func purchaseNumberDelete(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Delete Purchase Number", message: "Are you sure you want to delete this Number?", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default, handler: { [self] action in
            let dicForData = dicPurchaseNumber[sender.tag]
            dleltePruchseNumber(number: dicForData["number"] as? String ?? "")
        })
        alert.addAction(ok)
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { action in
        })
        alert.addAction(cancel)
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
    
    
    //MARK: - btn Click
    @IBAction func btnClickPurchaseNumber(_ sender: UIButton) {
        self.tabBarController?.tabBar.isHidden = true
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectNumberTypeVc") as! SelectNumberTypeVc
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    //MARK: - APi Action
    func userBalance() {
        let requestData : [String : String] = ["Token":User.sharedInstance.getUser_token()
                                               ,"request":"get_userbalance"
                                               ,"Device_id": appDelegate.diviceID]
        print(requestData)
        APIsMain.apiCalling.callDataWithoutLoader(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as? String ?? "" == "4" {
                let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "LogoutPopupVc") as! LogoutPopupVc
                nextVC.modalPresentationStyle = .overFullScreen
                self.present(nextVC, animated: false)
            } 
        })
    }
    
    func listNumberAPI() {
        let requestData : [String : String] = ["Token":User.sharedInstance.getUser_token()
                                               ,"request":"did_list"
                                               ,"Device_id": appDelegate.diviceID]
        print(requestData)
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            let diddata : [String: Any] = (result as! [String: Any])
            print(diddata)
            if diddata["status"] as? String ?? "" == "1" {
                topVW.isHidden = true
                tableView.isHidden = false
                dicPurchaseNumber = diddata["response"] as! [[String:Any]]
                tableView.reloadData()
            }else{
                topVW.isHidden = false
                tableView.isHidden = true
            }
        })
    }
    
    func dleltePruchseNumber(number: String) {
        let requestData : [String : String] = ["number":number
                                               ,"request":"delete_purched_number"
                                               ,"token":User.sharedInstance.getUser_token()]
        print(requestData)
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            let diddata : [String: Any] = (result as! [String: Any])
            print(diddata)
            if diddata["status"] as? String ?? "" == "1" {
                listNumberAPI()
            }
        })
    }
    
    
 
}
extension MyPurchaseNumberVc: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dicPurchaseNumber.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PurchaseNumberListCell", for: indexPath) as? PurchaseNumberListCell else { return UITableViewCell() }
        let dicForData = dicPurchaseNumber[indexPath.row]
        cell.lblPhoneNumber.text = dicForData["number"] as? String ?? ""
        cell.lblPuchaseDate.text = "Purchase date : " +  (dicForData["assign_date"] as? String ?? "")
        cell.lblDayRemain.text = "(\(dicForData["remaining_days"] as? Int ?? 0) Days left)"
        cell.mainVW.layer.cornerRadius = 5
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(self.purchaseNumberDelete(_:)), for: .touchUpInside)

        return cell
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
