//
//  RedeemCouponVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 20/12/22.
//

import UIKit

class RedeemCouponVc: UIViewController {

    @IBOutlet weak var btnRedeemVW: UIButton!
    @IBOutlet weak var promoCodeTextVW: UIView!
    @IBOutlet weak var txtPromoCode: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        intiCall()
    }
    
    func intiCall(){
        self.title = Constant.ViewControllerTitle.PromoCode
        btnRedeemVW.layer.cornerRadius = btnRedeemVW.layer.bounds.height/2
        
        promoCodeTextVW.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        promoCodeTextVW.layer.borderWidth = 1
        promoCodeTextVW.layer.cornerRadius = 2
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: .curveEaseOut) {
            if let tabBarFrame = self.tabBarController?.tabBar.frame {
                self.tabBarController?.tabBar.frame.origin.y = self.navigationController!.view.frame.maxY + tabBarFrame.height
            }
            self.navigationController!.view.layoutIfNeeded()
        } completion: { _ in
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    
    // MARK: - Btn Click
    @IBAction func btnSubmitCode(_ sender: UIButton) {
        if txtPromoCode.text == "" {
            showToastMessage(message: Constant.PleaseEnterPromoCode)
            return
        }
        PromoCodeRedeem()
        
    }
    
    //MARK: - APi Action
    func PromoCodeRedeem() {
        let isONN : Bool = APIsMain.apiCalling.isConnectedToNetwork()
        if(isONN == false) {
            let alert = UIAlertController(title: Constant.GlobalConstants.APPNAME, message: "No Internet connection", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:{ (UIAlertAction)in
            }))
            alert.present(animated: true, completion: nil)
            return
        }
        
        let requestData : [String : String] = ["Token":User.sharedInstance.getUser_token(),
                                               "Refill_coupon_no":txtPromoCode.text ?? ""
                                               ,"Device_id":appDelegate.diviceID
                                               ,"request":"refill_coupon"]
        print(requestData)
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as! String == "1" {
                navigationController?.popViewController(animated: false)
            } else {
                self.showToastMessage(message: diddata["message"] as? String)
            }
        })
    }
    
    
}
