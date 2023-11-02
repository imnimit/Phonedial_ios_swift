//
//  NumberPuchaseTimeListCountyVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 23/02/23.
//

import UIKit

class NumberPuchaseTimeListCountyVc: UIViewController {

  
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var hederTbl =  ["C","I","N","P","S","U"]
    var hederDetail = [[[String : Any]]]()
    var tempHederDetail = [[[String : Any]]]()
    var searchActive = true
    var tollFreeCity = false
    var isTollFree = false
     

    override func viewDidLoad() {
        super.viewDidLoad()
        if tollFreeCity == true {
            hederTbl.removeAll()
            hederDetail =  [[["name":"Canada","Img": flag(country: "CA"),"Code":"+1","iso":"CA"]]
                            ,[["name":"United States","Img": flag(country: "US"),"Code":"+1","iso":"US"]]]
            hederTbl  =  ["C","U"]
        }else {
            hederDetail =  [[["name":"Canada","Img": flag(country: "CA"),"Code":"+1","iso":"CA"]]
                                ,[["name":"Israel","Img": flag(country: "IL"),"Code":"+972","iso":"IL"]]
                                ,[["name":"New Zealand","Img": flag(country: "NZ"),"Code":"+64","iso":"NZ"]]
                                ,[["name":"Puerto Rico","Img": flag(country: "PR"),"Code":"+1","iso":"PR"]]
                            ,[["name":"Sweden","Img": flag(country: "SE"),"Code":"+46","iso":"SE"]]
                            ,[["name":"United Kingdom","Img": flag(country: "GB"),"Code":"+44","iso":"GB"],["name":"United States","Img": flag(country: "US"),"Code":"+1","iso":"US"]]]
        }
       
        
        tempHederDetail = hederDetail
        hideKeybordTappedAround()
        self.title = "Select Contry"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 15.0, *) {
           tableView.sectionHeaderTopPadding = 0
        }
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.isHidden = false

    }
   
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    
    
    func flag(country:String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }
    
    
}
extension NumberPuchaseTimeListCountyVc:  UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchBar.text?.count ?? 0 > 0 {
            return 1
        }else {
            return hederTbl.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        let label = UILabel()
        label.frame = CGRect.init(x: 25, y: 8, width: headerView.frame.width/2, height: headerView.frame.height/2)
        label.text = hederTbl[section]
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .white
        headerView.addSubview(label)
        headerView.backgroundColor = #colorLiteral(red: 0.4439517856, green: 0.5258321166, blue: 0.7032657862, alpha: 1)
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text?.count ?? 0 > 0 {
            return hederDetail.count
        }
        else {
            return hederDetail[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContryListCell", for: indexPath) as! ContryListCell
        let lbl = hederDetail[indexPath.section]
        cell.lblCountyName.text = lbl[indexPath.row]["name"] as? String ?? ""
        cell.imgFlag.text = lbl[indexPath.row]["Img"] as? String ?? ""
        cell.separatorVW.isHidden = false
        if indexPath.row == hederDetail[indexPath.section].count - 1 {
            cell.separatorVW.isHidden = true
        }
        return cell
    }
   
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchBar.text?.count ?? 0 > 0 {
            return  0
        }else{
            return  40
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        var  dic = [String:Any]()
        if searchBar.text?.count ?? 0 > 0 {
            dic =  hederDetail[0][indexPath.row]
            print(dic)
        } else {
            dic =  hederDetail[indexPath.section][indexPath.row]
            print(dic)
        }
        
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FindTheNumberVc") as! FindTheNumberVc
        nextVC.CountyInfo = dic
        nextVC.isTollFree = self.isTollFree
        navigationController?.pushViewController(nextVC, animated: true)
    }

}
extension NumberPuchaseTimeListCountyVc : UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if tempHederDetail.count > 0 {
            hederDetail = tempHederDetail
        }
        hederDetail = hederDetail.filter{ innerArray in
            guard let firstDict = innerArray.first else {
                return false
            }
            guard let name = firstDict["name"] as? String else {
                return false
            }
            return name.hasPrefix(searchBar.text ?? "")
        }

        if searchBar.text == "" {
            hederDetail = tempHederDetail
            searchActive = false
        } else {
            searchActive = true
        }
        tableView.reloadData()
    }
}
