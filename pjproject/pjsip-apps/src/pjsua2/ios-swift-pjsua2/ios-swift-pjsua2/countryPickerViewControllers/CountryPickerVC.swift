//
//  CountryPickerVC.swift
//  ios-swift-pjsua2
//
//  Created by TNCG - Mini2 on 13/07/23.
//

import UIKit
import PhoneNumberKit
import FlagKit

protocol getCountryCodeDelegate{
    func getCountryCode(countryShortName: String, countryCode: String)
}

class CountryPickerVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var arrOfCountries = [String]()
    var arrOfCountriesCode = [String]()
    var arrCountryFlag = [UIImage]()
    var dicForAllContry = [[String:Any]]()
    var tempdicForAllContry = [[String:Any]]()
    var searchActive = true
    var delegate: getCountryCodeDelegate?
    var indexFindToCountryCode = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(arrOfCountries)
        print(arrOfCountriesCode)
        
        let indexPath = IndexPath(row: dicForAllContry.count-1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [self] in
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        })
        tempdicForAllContry = dicForAllContry
        searchBar.tintColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
  
    //MARK: btn action
    
    @IBAction func btnClose(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
  
}

extension CountryPickerVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dicForAllContry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryPickerCell") as! countryPickerCell
        let dicDataforFlag = dicForAllContry[indexPath.row]
    
        cell.lblCountryName.text = dicDataforFlag["name"] as? String ?? ""
        cell.lblCountryCode.text = dicDataforFlag["dialcode"] as? String ?? ""
        DispatchQueue.main.async {
            cell.flagImageVW.image = UIImage(named: dicDataforFlag["code"] as? String ?? "" + ".png")
        }
        
        if indexFindToCountryCode == cell.lblCountryCode.text {
            cell.imgCheckMark.isHidden = false
            cell.lblCountryCode.textColor = #colorLiteral(red: 0.1033737585, green: 0.6896910071, blue: 0.8629385829, alpha: 1)
        } else {
            cell.imgCheckMark.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let countryShortName = dicForAllContry[indexPath.row]["code"] as? String ?? ""
        let countryCode = dicForAllContry[indexPath.row]["dialcode"] as? String ?? ""
        self.delegate?.getCountryCode(countryShortName: countryShortName, countryCode: countryCode)
        
    }
}


extension CountryPickerVC : UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        searchBar.showsCancelButton = false
        searchController.searchBar.becomeFirstResponder()
        searchController.searchBar.showsCancelButton = true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if tempdicForAllContry.count > 0 {
            dicForAllContry = tempdicForAllContry
        }
        
        dicForAllContry = dicForAllContry.filter({($0["name"] as! String).localizedCaseInsensitiveContains(searchBar.text!)})
        
        if searchBar.text == "" {
            dicForAllContry = tempdicForAllContry
            searchActive = false
        } else {
            searchActive = true
        }
        self.tableView.reloadData()
        
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
    }
    
}
