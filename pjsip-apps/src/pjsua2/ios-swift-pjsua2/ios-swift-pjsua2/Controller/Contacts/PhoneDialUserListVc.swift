//
//  PhoneDialUserListVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 02/03/23.
//

import UIKit
import KNContacts
import Contacts

class PhoneDialUserListVc: UIViewController {

    var store = CNContactStore()
    var contactBook = KNContactBook(id: "allContacts")
    var dataContectInfo = [[String : Any]]()
    var number = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
//
        
    
       // getSipContact()
    }
    
    
    // MARK: - API CAlling
    
    func getSipContact() {
        let isONN : Bool = APIsMain.apiCalling.isConnectedToNetwork()
        if(isONN == false) {
            let alert = UIAlertController(title: Constant.GlobalConstants.APPNAME, message: "No Internet connection", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:{ (UIAlertAction)in
            }))
            alert.present(animated: true, completion: nil)
            return
        }
        
        let requestData : [String : String] = ["Number":number
                                               ,"Token":User.sharedInstance.getUser_token()
                                               ,"Device_id":appDelegate.diviceID
                                               ,"request":"get_sip_contact"]
        print(requestData)
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as? String ?? "" == "2" {
                self.showToastMessage(message: diddata["message"] as? String)
            } else {
                let Data : [String: Any] = (diddata["response"] as! [String: Any])
                print(Data)
            }
        })
    }
    

}
extension PhoneDialUserListVc:  UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataContectInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhoneDialerUserListCell", for: indexPath) as! PhoneDialerUserListCell
      
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
