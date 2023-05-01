//
//  InviteContactPopup.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 23/12/22.
//

import UIKit
import MessageUI

protocol  goToContactDetailScreen:class  {
    func callApplyAction(contactNumber: String,contactName: String)
}
class InviteContactPopup: UIViewController {

    @IBOutlet weak var callVW: UIView!
    @IBOutlet weak var inviteVW: UIView!
    @IBOutlet weak var mainVW: UIView!
    @IBOutlet weak var InfoImgeVW: UIView!
    
    var callData = [String:Any]()
    var nameContact = ""
    weak var delegate: goToContactDetailScreen?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCall()
    }
    func initCall(){
        InfoImgeVW.layer.cornerRadius = InfoImgeVW.layer.bounds.height/2
        mainVW.layer.cornerRadius = 5
        callVW.layer.cornerRadius = 5
        inviteVW.layer.cornerRadius = 5
    }
    
    //MARK: btn Click
    @IBAction func btnClickInviteCall(_ sender: UIButton) {
        let data = callData
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "test"
            controller.recipients = ["\(data["Info"] as! String)"]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnClickCall(_ sender: UIButton) {
        self.dismiss(animated: false,completion: { [self] in
            delegate?.callApplyAction(contactNumber: callData["Info"] as? String ?? "",contactName: nameContact)
        })
    }
    
}

extension InviteContactPopup: MFMessageComposeViewControllerDelegate{
    @objc func documentSlection(_ sender: UIButton) {
        let data = callData
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "test"
            controller.recipients = ["\(data["Info"] as! String)"]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func filterNumber(phoneNumber: String) -> String {
        let str = phoneNumber
        let filter0 = str.replacingOccurrences(of: ")", with: "")
        let filter = filter0.replacingOccurrences(of: "(", with: "")
        let filter1 = filter.replacingOccurrences(of: "-", with: "")
        let filter2 = filter1.replacingOccurrences(of: "+", with: "")
        let filter3 = filter2.replacingOccurrences(of: " ", with: "")
        let filter4 = filter3.replacingOccurrences(of: "*", with: "")
        let filter5 = filter4.replacingOccurrences(of: "#", with: "")
        let filter6 = filter5.replacingOccurrences(of: "&", with: "")

        if filter6.count > 10 {
            let last4 = String(filter6.suffix(10))
            print(last4)
            return last4
        }
        return filter6
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .sent:
            print("Message sent")
        case .cancelled:
            print("Message Cancelled")
        case .failed:
            print("Message Fail")
        default:
            print("Some issue Face")
        }
        self.dismiss(animated: true, completion: nil)
    }
}


