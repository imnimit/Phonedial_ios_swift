//
//  PurchaseNumberReceiptVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 28/02/23.
//

import UIKit

class PurchaseNumberReceiptVc: UIViewController {

    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblPaymentType: UILabel!
    @IBOutlet weak var lblTotalPayment: UILabel!
    @IBOutlet weak var lblFee: UILabel!
    @IBOutlet weak var lblPayableAmount: UILabel!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var lblMainShowPayout: UILabel!
    var countryCode = ""
    var payemntData = [String:Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        lblUserName.text = User.sharedInstance.getFullName()
        btnSubmit.layer.cornerRadius = btnSubmit.layer.bounds.height/2
        lblNumber.text = payemntData["friendlyName"] as? String ?? ""
        lblTotalPayment.text = "$" + (payemntData["amount"] as? String ?? "")
        lblPayableAmount.text = "$" + (payemntData["amount"] as? String ?? "")
        lblMainShowPayout.text = "$" + (payemntData["amount"] as? String ?? "")
    }
    
    //MARK: - btnClick
    func paymentSubmit() {
        let number =  lblNumber.text?.replace(string: "+", replacement: "")
        let requestData : [String : String] = ["token":User.sharedInstance.getUser_token()
                                               ,"method":"charge"
                                               ,"number": number ?? ""
                                               ,"countrycode": countryCode.replace(string: "+", replacement: "")
                                               ,"amount": payemntData["amount"] as? String ?? ""
                                               ,"request": "purchase_number_using_wallet"]
        print(requestData)
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as? String ?? "" == "1" {
                let dataForResponce = (diddata["response"] as! [String: Any])
                print(dataForResponce)
                self.navigationController?.popToRootViewController(animated: true)
            }
        })
    }
    
    //MARK: - Btn Click
    @IBAction func btnSubmit(_ sender: UIButton) {
        paymentSubmit()
    }
    

}
