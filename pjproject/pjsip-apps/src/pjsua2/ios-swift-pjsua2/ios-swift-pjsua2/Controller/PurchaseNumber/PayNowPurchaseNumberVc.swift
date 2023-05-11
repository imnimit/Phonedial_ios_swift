//
//  PayNowPurchaseNumberVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 28/02/23.
//

import UIKit

class PayNowPurchaseNumberVc: UIViewController {

    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var lblContryCodeOrName: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet var viewInfo: [UIView]!
    @IBOutlet weak var btnPayAmount: UIButton!
    @IBOutlet weak var lblExpiryDate: UILabel!
    var payemntData = [String:Any]()
    var CountyInfo = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgFlag.image = UIImage(named: CountyInfo["iso"] as? String ?? "")
        lblContryCodeOrName.text = "(\(CountyInfo["Code"] as? String ?? "") ) \((CountyInfo["name"] as? String ?? ""))"
        lblNumber.text = payemntData["friendlyName"] as? String ?? ""
        btnPayAmount.layer.cornerRadius = btnPayAmount.layer.bounds.height/2
        
        self.title = "Purchase Number"
        
        
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.day = 20
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
        lblExpiryDate.text =  futureDate?.getFormattedDate(format: "yyyy-MMM-d")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        userBalance(checkBalance: false)


    }
   
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    
    //MARK: - API Calling
    func userBalance(checkBalance: Bool) {
        let requestData : [String : String] = ["Token":User.sharedInstance.getUser_token()
                                               ,"request":"get_userbalance"
                                               ,"Device_id": appDelegate.diviceID]
        print(requestData)
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as? String ?? "" == "1" {
                let dataForResponce = (diddata["response"] as! [String: Any])
                print(dataForResponce)
                if checkBalance == true {
                    let balance = Float((dataForResponce["Balance"] as? String ?? "").replace(string: "USD", replacement: "").removeWhitespace())
                    
                    if balance ?? 0 > Float(payemntData["amount"] as? String ?? "0") ?? 0 {
                        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PurchaseNumberReceiptVc") as! PurchaseNumberReceiptVc
                        nextVC.payemntData = self.payemntData
                        nextVC.countryCode = CountyInfo["Code"] as? String ?? ""
                        navigationController?.pushViewController(nextVC, animated: true)
                    }else{
                        let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "AddFundsVctr") as! AddFundsVctr
                        nextVC.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
                        nextVC.dataForResponce = dataForResponce
                        self.navigationController?.pushViewController(nextVC, animated: false)
                    }
                }
            }
        })
    }
    
    //MARK: - Btn Click
    
    @IBAction func btnPayNow(_ sender: UIButton) {
        userBalance(checkBalance: true)
    }
    
  

}
