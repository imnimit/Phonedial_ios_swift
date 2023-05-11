//
//  AllCallNumberVC.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 09/12/22.
//

import UIKit

class AllCallNumberVC: UIViewController {

    @IBOutlet weak var tbl: UITableView!
    var numberarray = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        numberarray = CPPWrapper.callNumber().components(separatedBy: ",")
        
        // Do any additional setup after loading the view.
    }

}
extension AllCallNumberVC : UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate {
    
    //MARK: - Table View Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberarray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "callSwipCell") as! callSwipCell
        cell.btnClick.tag = indexPath.row
        cell.btnClick.addTarget(self, action: #selector(self.siwpCall(_:)), for: .touchUpInside)
        let newString = numberarray[indexPath.row].replacingOccurrences(of: "sip:", with: "", options: .literal, range: nil)
        let phonenumber = newString.components(separatedBy: "@")
        cell.lblNumber.text = phonenumber[0]
        return cell
    }
    
    @objc func siwpCall(_ sender: UIButton) {
        CPPWrapper.passCallHangOut(Int32(sender.tag))
        numberarray = CPPWrapper.callNumber().components(separatedBy: ",")
        if numberarray.count == 1 {
            self.dismiss(animated: false)
        }else{
            tbl.reloadData()
        }
        
    }
}
