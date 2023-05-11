//
//  dialpadVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 18/11/22.
//

import UIKit

class dialpadVc: UIViewController {

    @IBOutlet weak var txtnumber: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
// MARK: - btn Click
    @IBAction func btnNumber(_ sender: UIButton) {
        txtnumber.text = (txtnumber.text ?? "") + "\(sender.tag)"
    }
    
    @IBAction func btnRemoveNumber(_ sender: UIButton) {
        if  self.txtnumber.text?.count ?? 0 > 0 {
            txtnumber.text?.removeLast()
        }
    }
    
    @IBAction func btnCall(_ sender: UIButton) {
//        if(CPPWrapper().registerStateInfoWrapper() != false){
////            let vcToPresent = self.storyboard!.instantiateViewController(withIdentifier: "outgoingCallVC") as! OutgoingViewController
////            vcToPresent.outgoingCallId = sipDestinationUriTField.text ?? "<SIP-NUMBER>"
////            self.present(vcToPresent, animated: true, completion: nil)
//            
//            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallingDisplayVc") as! CallingDisplayVc
//            nextVC.number = txtnumber.text ?? "<SIP-NUMBER>"
//            nextVC.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
//            self.present(nextVC, animated: true)
//            
//        }else {
//            let alert = UIAlertController(title: "Outgoing Call Error", message: "Please register to be able to make call", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
//                switch action.style{
//                    case .default:
//                    print("default")
//                    
//                    case .cancel:
//                    print("cancel")
//                    
//                    case .destructive:
//                    print("destructive")
//                    
//                @unknown default:
//                    fatalError()
//                }
//            }))
//            self.present(alert, animated: true, completion: nil)
//        }
//        
//        
    }
    
    @IBAction func btnAddNewContect(_ sender: UIButton) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddNewContectVc") as! AddNewContectVc
        nextVC.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
        self.present(nextVC, animated: true)
    }
    
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    
    
}
