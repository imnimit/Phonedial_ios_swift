//
//  CardPaymentConfirmationVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 16/12/22.
//

import UIKit

class CardPaymentConfirmationVc: UIViewController {

    @IBOutlet weak var BtnSubmit: UIView!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblRecipnetID: UILabel!
    @IBOutlet weak var lblcreaditCared: UILabel!
    @IBOutlet weak var lblTotoleAmount: UILabel!
    @IBOutlet weak var lblMainShowAmount: UILabel!
    
    var price = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCall()
    }
    
    func initCall(){
        self.title = "Confirmation"
        BtnSubmit.layer.cornerRadius = BtnSubmit.layer.bounds.height/2
        
        lblName.text = User.sharedInstance.getFullName()
        lblNumber.text = User.sharedInstance.getContactNumber()
        lblTotoleAmount.text = price
        lblMainShowAmount.text = price
    }
    
    // MARK: btn Click
    @IBAction func btnSubmit(_ sender: UIButton) {
        var Inappid = ""
        if (self.price == "$ 4.99") {
            Inappid = Constant.InappPuchseId.FiveDollar
        }else  if (self.price == "$ 9.99") {
            Inappid = Constant.InappPuchseId.TenDollar
        }else {
            Inappid = Constant.InappPuchseId.FifteenDollar
        }
        HelperClassAnimaion.showProgressHud()
        IAPHelper.shared.startPurchase(productId: Inappid, completion: { [self]result in
            if result == true {
                HelperClassAnimaion.hideProgressHud()
                receiptValidation()
            }else {
               // showToastMessage(message: "Payment Fail")
                HelperClassAnimaion.hideProgressHud()
                print("Fail Payment")
            }
        })
    }
    
    
    func receiptValidation() {
        let receiptPath = Bundle.main.appStoreReceiptURL?.path
        if FileManager.default.fileExists(atPath: receiptPath!) {
            var receiptData:NSData?
            do{
                receiptData = try NSData(contentsOf: Bundle.main.appStoreReceiptURL!, options: NSData.ReadingOptions.alwaysMapped)
            }
            catch{
                print("ERROR: " + error.localizedDescription)
            }
             //let receiptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let base64encodedReceipt = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithCarriageReturn)

            print(base64encodedReceipt!)
            
            createInappPurechase(json: base64encodedReceipt ?? "")
        }
    }
    
    // MARK: Api Calling
    func createInappPurechase(json: String) {
        let rmeoveotherString = price.replace(string: "$", replacement: "").removeWhitespace()
        let requestData : [String : String] = ["Token":User.sharedInstance.getUser_token()
                                               ,"request":"account_recharge_IAP"
                                               ,"device_id": appDelegate.diviceID
                                               ,"amount":rmeoveotherString
                                               ,"iap_receipt":json
                                               ,"method":"Apple IAP"
                                               ,"Device_id": appDelegate.diviceID]
        print(requestData)
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as? Bool == true {
                self.navigationController?.popToRootViewController(animated: true)
            }
            print(diddata)
        })
    }
    
    
    func CallGenrateReceipt(){
        let rmeoveotherString = price.replace(string: "$", replacement: "").removeWhitespace()

        let requestData : [String : String] = ["Token":User.sharedInstance.getUser_token()
                                               ,"request":"generate_receipt"
                                               ,"Device_id": appDelegate.diviceID
                                               ,"amount":rmeoveotherString
                                               ,"type":""
                                               ,"payment_method_nonce":""]
        print(requestData)
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as? Bool == true {
                self.dismiss(animated: false)
            }
            self.dismiss(animated: false)
            print(diddata)
        })
    }
}
