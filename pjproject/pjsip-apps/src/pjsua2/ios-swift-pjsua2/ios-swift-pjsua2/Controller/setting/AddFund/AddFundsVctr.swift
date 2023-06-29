//
//  AddFundsVctr.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 15/12/22.
//

import UIKit
import Stripe

class AddFundsVctr: UIViewController {

    @IBOutlet weak var addVW: UIView!
    @IBOutlet weak var proccdVW: UIView!
    @IBOutlet weak var btnCreditCard: UIButton!
    @IBOutlet weak var btnCredit: UIButton!
    @IBOutlet weak var lblWalletBalance: UILabel!
    @IBOutlet weak var lblChargeValue: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var cardSelection = 0
    @IBOutlet weak var hightTableView: NSLayoutConstraint!
    
    var dataForResponce = [String:Any]()
    var IncreaseValue = 4
    
    var arrayCard = [[String:Any]]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCall()
        self.title = "Add Fund"
        NotificationCenter.default.addObserver(self, selector: #selector(crditcardDetail), name: Notification.Name("crditcardDetail"), object: nil)
    }
    
    @objc func crditcardDetail() {
        if UserDefaults.standard.object(forKey: "CardDetils") != nil {
            arrayCard =  UserDefaults.standard.object(forKey: "CardDetils") as! [[String:Any]]
        }
        if hightTableView.constant != 0 {
            proccdVW.alpha = 1.0
            if arrayCard.count == 0 {
                proccdVW.alpha = 0.5
            }
        }
        tableView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        crditcardDetail()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationController?.navigationBar.backgroundColor = .none
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    func initCall(){
        let leftButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_back_arrow"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.backArrow))
        navigationItem.leftBarButtonItem = leftButton
        
        btnCreditCard.layer.borderColor = #colorLiteral(red: 0.2361463308, green: 0.6436210275, blue: 0.7784664035, alpha: 1)
        btnCreditCard.layer.borderWidth = 1
        btnCreditCard.layer.cornerRadius = 5
        
        btnCredit.layer.borderColor = #colorLiteral(red: 0.2361463308, green: 0.6436210275, blue: 0.7784664035, alpha: 1)
        btnCredit.layer.borderWidth = 1
        btnCredit.layer.cornerRadius = 5
        
        addVW.layer.cornerRadius = addVW.layer.bounds.height/2
        addVW.layer.backgroundColor = #colorLiteral(red: 0.2361463308, green: 0.6436210275, blue: 0.7784664035, alpha: 1)
        addVW.layer.borderColor = #colorLiteral(red: 0.2361463308, green: 0.6436210275, blue: 0.7784664035, alpha: 1)
        addVW.layer.borderWidth = 1
        addVW.isHidden = true
        
        proccdVW.layer.cornerRadius = proccdVW.layer.bounds.height/2
        proccdVW.layer.backgroundColor = #colorLiteral(red: 0.2361463308, green: 0.6436210275, blue: 0.7784664035, alpha: 1)
        proccdVW.layer.borderColor = #colorLiteral(red: 0.2361463308, green: 0.6436210275, blue: 0.7784664035, alpha: 1)
        proccdVW.layer.borderWidth = 1
        
        btnCredit.backgroundColor = #colorLiteral(red: 0.2361463308, green: 0.6436210275, blue: 0.7784664035, alpha: 1)
        btnCredit.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        
        
        lblWalletBalance.text = "Wallet Balance: " + (dataForResponce["Balance"] as? String ?? "")
        lblChargeValue.text = "$ 4.99"
        
        hightTableView.constant = 0.0
        
        proccdVW.alpha = 1.0

    }
    
    @objc func backArrow() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK: - btn Click
    
    @IBAction func btnAddOrRemoveBalance(_ sender: UIButton) {
        if sender.tag == 1 {
            if IncreaseValue < 14 {
                IncreaseValue = IncreaseValue + 5
            }else {
                var dialogMessage = UIAlertController(title: "Alert", message: "Reached to maximum amount of recharge", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                 })
                dialogMessage.addAction(ok)
                self.present(dialogMessage, animated: true, completion: nil)
            }
        }
        else  if sender.tag == 2 {
            if IncreaseValue > 4 {
                IncreaseValue = IncreaseValue - 5
            } else {
                var dialogMessage = UIAlertController(title: "Alert", message: "Reached to minimum amount of recharge", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                 })
                dialogMessage.addAction(ok)
                self.present(dialogMessage, animated: true, completion: nil)
            }
        }
        lblChargeValue.text = "$ \(IncreaseValue).99"

    }
    
    
    
    @IBAction func btnClickToBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnClickPaymentType(_ sender: UIButton) {
        if sender.tag == 1 {
            hightTableView.constant = 350

            btnCreditCard.backgroundColor = #colorLiteral(red: 0.2361463308, green: 0.6436210275, blue: 0.7784664035, alpha: 1)
            btnCreditCard.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            btnCredit.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            btnCredit.setTitleColor(#colorLiteral(red: 0.2361463308, green: 0.6436210275, blue: 0.7784664035, alpha: 1), for: .normal)

            addVW.isHidden = false
            
            proccdVW.alpha = 1.0
            if arrayCard.count == 0 {
                proccdVW.alpha = 0.5
            }
            
        }else  {
            hightTableView.constant = 0
            btnCreditCard.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            btnCredit.backgroundColor = #colorLiteral(red: 0.2361463308, green: 0.6436210275, blue: 0.7784664035, alpha: 1)
            btnCredit.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            btnCreditCard.setTitleColor(#colorLiteral(red: 0.2361463308, green: 0.6436210275, blue: 0.7784664035, alpha: 1), for: .normal)
            addVW.isHidden = true
            
            proccdVW.alpha = 1.0
           
        }
    }
    
    
    @IBAction func btnCallAddCardDetails(_ sender: UIButton) {
        
        
        
        let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "AddNewCardVCtr") as! AddNewCardVCtr
        self.navigationController?.pushViewController(nextVC, animated: true)
       // nextVC.modalPresentationStyle = .overFullScreen
       // self.present(nextVC, animated: false)
    }
    
    
    @IBAction func btnProceed(_ sender: UIButton) {
        if proccdVW.alpha == 0.5 {
            return
        }
            
        if  hightTableView.constant == 0 {
            let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "CardPaymentConfirmationVc") as! CardPaymentConfirmationVc
            nextVC.price = lblChargeValue.text ?? ""
//            self.present(nextVC, animated: false)
            self.navigationController?.pushViewController(nextVC, animated: true)
        }else{
            if cardSelection != -1 {
                paymentTokanCreate(CardDetail: arrayCard[cardSelection])
            }else{
                showToastMessage(message: "Please select card first")
            }
        }
    }
    
    @objc func DeleteCardDetails(_ sender: UIButton) {
        let alert = UIAlertController(title: "Alert", message: "Are your sure want to Dlete this Card Details?" , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { [self]_ in
            arrayCard.remove(at: sender.tag)
            let temp = arrayCard
            UserDefaults.standard.removeObject(forKey: "CardDetils")
            UserDefaults.standard.setValue(temp, forKey: "CardDetils")
            if UserDefaults.standard.object(forKey: "CardDetils") != nil {
                arrayCard =  UserDefaults.standard.object(forKey: "CardDetils") as! [[String:Any]]
            }
            proccdVW.alpha = 1.0
            if arrayCard.count == 0 {
                proccdVW.alpha = 0.5
            }
            tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
       
    }
    
    @objc func RedioButtonSelection(_ sender: UIButton) {
        cardSelection = sender.tag
        tableView.reloadData()
    }
    
    
    func paymentTokanCreate(CardDetail: [String:Any]){
        
        let comps = (CardDetail["carddate"] as? String)?.components(separatedBy: "/")
        let f = UInt(comps!.first!)
        let l = UInt(comps!.last!)
//
        let cardParams = STPCardParams()
        cardParams.name = CardDetail["cardnumber"] as? String
        cardParams.number = User.sharedInstance.getContactNumber()
        cardParams.expMonth = f!
        cardParams.expYear =  l!
        cardParams.cvc = CardDetail["cvv"] as? String
        cardParams.address.postalCode = CardDetail["zipcode"] as? String

        HelperClassAnimaion.showProgressHud()
        STPAPIClient.shared.createToken(withCard: cardParams) { [self] (token: STPToken?, error: Error?) in
            print("Printing Strip response:\(String(describing: token?.allResponseFields))\n\n")
            print("Printing Strip Token:\(String(describing: token?.tokenId))")
            HelperClassAnimaion.hideProgressHud()
            if error != nil {
                print(error?.localizedDescription ?? "")
            }

            if token != nil{
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
//                    self.paymentDetaiUploadAPI(tokan: token?.tokenId ?? "")
                })
                print("Transaction success! \n\nHere is the Token: \(String(describing: token!.tokenId))\nCard Type: \(String(describing: token!.card!.funding))\n\nSend this token or detail to your backend server to complete this payment.")
            }
        }
    }
    
    
    
    // MARK: - API Calling
    func PaymnetStrip() {
        let requestData : [String : String] = ["Token":User.sharedInstance.getUser_token()
                                               ,"request":"stripe_payment"
                                               ,"Device_id": appDelegate.diviceID]
        print(requestData)
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            let diddata : [String: Any] = (result as! [String: Any])
            print(diddata)
        })
    }
        
    
    
}
extension AddFundsVctr: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCard.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardListCell", for: indexPath) as? CardListCell else { return UITableViewCell() }
        let dicForArray = arrayCard[indexPath.row]
        cell.btnDelete.tag = indexPath.row
        cell.btnRedio.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(self.DeleteCardDetails(_:)), for: .touchUpInside)
        cell.btnRedio.addTarget(self, action: #selector(self.RedioButtonSelection(_:)), for: .touchUpInside)
        if cardSelection == indexPath.row {
            cell.btnRedio.isSelected = true
        }else{
            cell.btnRedio.isSelected = false
        }
        cell.lblCardNumber.text = formatCreditCardNumber(dicForArray["cardnumber"] as? String ?? "")
        cell.lblCardType.text = dicForArray["cardtype"] as? String ?? ""
        return cell
    }
    
    func formatCreditCardNumber(_ cardNumber: String) -> String {
        let last4Digits = String(cardNumber.suffix(4))
        let first12Digits = String(cardNumber.prefix(14))
        let maskedDigits = String(repeating: "*", count: 4) + " " + String(repeating: "*", count: 4) + " " + String(repeating: "*", count: 4)
        return maskedDigits + last4Digits
    }
    
   
}

