//
//  CallLogDtlVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 26/12/22.
//

import UIKit

class CallLogDtlVc: UIViewController {

    @IBOutlet weak var LetterOrImgVW: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblFistLetter: UILabel!
    @IBOutlet weak var imgContact: UIImageView!
    
    var dicCall = [[String:Any]]()
    var findNumber = [String:Any]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCall()

        self.title = Constant.ViewControllerTitle.CallLogs
        if findNumber.count > 0 {
            lblName.text = findNumber["name"] as? String
            lblNumber.text = findNumber["phone"] as? String
            lblFistLetter.text = findNameFistORMiddleNameFistLetter(name: findNumber["name"] as? String ?? "")
            if findNumber["imageDataAvailable"] as? Bool == true {
                lblFistLetter.isHidden = true
                imgContact.image = UIImage(data: (findNumber["imageData"] as! Data))!
            }
        }else {
            lblName.text = dicCall[0]["contact_name"] as? String
            lblNumber.text = dicCall[0]["number"] as? String
            lblFistLetter.text = findNameFistORMiddleNameFistLetter(name: dicCall[0]["contact_name"] as? String ?? "")
        }
        
    
        
        let barButton = UIBarButtonItem(image: UIImage(named: "ic_back_arrow"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(revealBackClicked))
        barButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = barButton
        
    }
    
    @objc func revealBackClicked(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    func initCall() {
        LetterOrImgVW.layer.cornerRadius = LetterOrImgVW.layer.bounds.height/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        self.navigationController!.navigationBar.topItem!.title = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false

    }
    

    
    
    //MARK: btn Click
    @IBAction func btnCallForContact(_ sender: UIButton) {
        let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "InviteContactPopup") as! InviteContactPopup
        nextVC.delegate = self
        nextVC.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
        self.present(nextVC, animated: false,completion: {
            nextVC.view.superview?.isUserInteractionEnabled = true
            nextVC.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.dismiss(animated: false, completion: nil)
    }
    
    
}
//MARK: TableView ------------------------------------------------------------------------------
extension CallLogDtlVc: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dicCall.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CallDtShowCell", for: indexPath) as! CallDtShowCell
        let dicForCall = dicCall[indexPath.row]
        if dicForCall["type"] as? String == "Outgoing" {
            cell.imgCallType.image = #imageLiteral(resourceName: "ic_outgoing_call.png")
        }else if dicForCall["type"] as? String == "MissCall" {
            cell.imgCallType.image = #imageLiteral(resourceName: "ic_miss_call.png")
        }else{
            cell.imgCallType.image = #imageLiteral(resourceName: "ic_incoming_call.png")
        }
        let durationFind =  (dicForCall["call_length"] as? String ?? "").components(separatedBy: ":")
        if durationFind.count > 2 {
            cell.lblDuration.text = "\(durationFind[0])h:" + "\(durationFind[1])m:" + "\(durationFind[2])s"
        }
        if (dicForCall["created_date"] as? String ?? "") != "" {
            let df = DateFormatter()
            df.dateFormat = "MM-dd-yyyy h:mm a"
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "MM-dd-yyyy HH:mm:ss"
            let dataFind = dateFormatter1.date(from: (dicForCall["created_date"] as! String))
            cell.lblDataOrTime.text =  df.string(from: dataFind!)
        }
        return cell
    }
}
extension CallLogDtlVc:goToContactDetailScreen {
    func callApplyAction(contactNumber: String,contactName: String) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: { [self] in
            if let tabBarController = appDelegate.window?.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 2
                let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
                let dialPed = storyboard1.instantiateViewController(withIdentifier: "dialpadVc") as! dialpadVc
                dialPed.contectNumber = dicCall[0]["number"] as? String ?? ""
                dialPed.contectName = lblName.text ?? ""
                tabBarController.viewControllers![2]  = dialPed
            }
        })
    }
}
