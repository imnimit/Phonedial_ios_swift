//
//  IncomeingCallScreenVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 01/12/22.
//

import UIKit

class IncomeingCallScreenVc: UIViewController {
    
    var incomingCallId : String = ""
    @IBOutlet weak var callTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callTitle.text = incomingCallId
        CPPWrapper().call_listener_wrapper(call_status_listener_swift)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        CPPWrapper().hangupCall();
    }
    
    
    @IBAction func hangupClick(_ sender: UIButton) {
        CPPWrapper().hangupCall();
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func answerClick(_ sender: UIButton) {
        CPPWrapper().answerCall();
    }

}
