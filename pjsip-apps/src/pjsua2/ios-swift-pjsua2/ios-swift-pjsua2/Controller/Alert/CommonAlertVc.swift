//
//  CommonAlertVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 16/12/22.
//

import UIKit
protocol  CommonAlertVcDelegate:class  {
    func CommonAlertAccept()
}
class CommonAlertVc:  UIViewController {
    
    @IBOutlet weak var lblAlertMessage: UILabel!
    @IBOutlet weak var viewAcceptbtn: UIView!
    weak var delegate: CommonAlertVcDelegate?
    @IBOutlet weak var uiViewMain: UIView!
    @IBOutlet weak var lblTitile: UILabel!
    var nameTitle = ""
    var discretion = ""
    //MARK:- ViewLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        viewAcceptbtn.layer.cornerRadius = 20.0
        viewAcceptbtn.layer.borderWidth = 1.0
        viewAcceptbtn.layer.borderColor = #colorLiteral(red: 0.1058823529, green: 0.6903560162, blue: 0.8614253998, alpha: 1)
        
        uiViewMain.layer.cornerRadius = 10.0
         
        lblTitile.text = nameTitle
        lblAlertMessage.text = discretion
         
    }
    
//MARK: - cancleClick
    @IBAction func cancleClick(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
//MARK: - cancleClick
    @IBAction func OkClick(_ sender: UIButton) {
        delegate?.CommonAlertAccept()
        self.dismiss(animated: false, completion: nil)
    }
    
}
