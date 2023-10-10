//
//  FeedbackOrSuggestVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 20/12/22.
//

import UIKit

class FeedbackOrSuggestVc: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtTitleDesc: UITextField!
    @IBOutlet weak var txtDesc: UITextView!
    @IBOutlet weak var titileVW: UIView!
    var feedBackVeiwOrNot = false
    override func viewDidLoad() {
        super.viewDidLoad()
        initCall()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    func initCall(){
        txtDesc.delegate = self
        if feedBackVeiwOrNot == true {
            self.title = Constant.ViewControllerTitle.Feedback
        }else {
            self.title = Constant.ViewControllerTitle.SuggestFeature
        }
       

        titileVW.layer.cornerRadius = 5
        titileVW.layer.borderWidth = 1.0
        titileVW.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        txtDesc.layer.cornerRadius = 5
        txtDesc.layer.borderWidth = 1.0
        txtDesc.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        let SubmiteBarButtonItem = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(btnClickSubmite))
        self.navigationItem.rightBarButtonItem  = SubmiteBarButtonItem
    }
    
    @objc func btnClickSubmite(){
         print("clicked")
        if txtTitleDesc.text == "" {
            showToastMessage(message: Constant.ErrorOFFeedBack.PleaseEnterTitle)
            return
        }
        
        if txtDesc.text == "Enter title for feed back" {
            showToastMessage(message: Constant.ErrorOFFeedBack.PleaseEnterEiscretion)
            return
        }
        FeedBackOrSuggestPassAPI()
    }
    
    
    //MARK: - APi Action
    func FeedBackOrSuggestPassAPI() {
        let isONN : Bool = APIsMain.apiCalling.isConnectedToNetwork()
        if(isONN == false) {
            let alert = UIAlertController(title: Constant.GlobalConstants.APPNAME, message: "No Internet connection", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:{ (UIAlertAction)in
            }))
            alert.present(animated: true, completion: nil)
            return
        }
        
        let requestData : [String : String] = ["token":User.sharedInstance.getUser_token(),
                                               "title":txtTitleDesc.text ?? ""
                                               ,"description":txtDesc.text ?? ""
                                               ,"request":"send_suggestions"]
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
extension FeedbackOrSuggestVc: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if  textView.text == "Enter Description" {
            txtDesc.text = ""
        }
        print("print1")
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("print2")
        if  textView.text == "" {
            txtDesc.text = "Enter Description"
        }
    }
    
    
}
