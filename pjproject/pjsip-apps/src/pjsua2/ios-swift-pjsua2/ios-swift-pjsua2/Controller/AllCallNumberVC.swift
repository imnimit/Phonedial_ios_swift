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
    var name = [String]()
    var confrenceTimeMange = [[String:Any]]()


    override func viewDidLoad() {
        super.viewDidLoad()
        numberarray = CPPWrapper.confirmCallNumber().components(separatedBy: ",")
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
        cell.imgBack.layer.cornerRadius = 10
        cell.imgBack.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cell.imgBack.layer.borderWidth = 1
        let phonenumber = newString.components(separatedBy: "@")
        cell.lblNumber.text = phonenumber[0]
        cell.lblName.text = "Unknown"
        let index = confrenceTimeMange.firstIndex(where: {($0["number"] as! String).suffix(10) == (cell.lblNumber.text ?? "").suffix(10)})
        if index != nil {
            cell.lblName.text = confrenceTimeMange[index!]["name"] as? String ?? "Unknown"
        }
        return cell
    }
    
    @objc func siwpCall(_ sender: UIButton) {
        let newString = numberarray[sender.tag].replacingOccurrences(of: "sip:", with: "", options: .literal, range: nil)
        let phonenumber = newString.components(separatedBy: "@")
        CPPWrapper.passCallHangOut(phonenumber[0])
        numberarray = CPPWrapper.callNumber().components(separatedBy: ",")
      //  CPPWrapper().valuePop()
        if numberarray.count == 1 {
            self.dismiss(animated: false)
        }else{
            tbl.reloadData()
        }
    }
}
