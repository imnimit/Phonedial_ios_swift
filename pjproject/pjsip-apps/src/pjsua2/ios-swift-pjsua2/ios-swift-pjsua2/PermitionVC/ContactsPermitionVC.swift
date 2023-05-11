//
//  ContactsPermitionVC.swift
//  Truckline Mobile
//
//  Created by Sagar Pandya on 15/06/21.
//

import UIKit
import Contacts


protocol ContactsPermitionDelegate{
    func contectPermtion()
}
class ContactsPermitionVC: UIViewController {

    @IBOutlet weak var viewAllow: UIView!
    @IBOutlet weak var viewDontAllow: UIView!
    var timerRefresh: Timer!
    var delegate: ContactsPermitionDelegate?


    //MARK: - viewLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        viewAllow.layer.cornerRadius = 15
        viewOrderApply(viewName:  viewDontAllow,BorderWidth: 1.0,Colro: #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1),CornerRedius: 15.0)
        
        self.timerRefresh = Timer.scheduledTimer(timeInterval: 1.2, target: self, selector: #selector(self.checkPermition), userInfo: nil, repeats: true)

    }
    
    func requestAccess()-> Bool {
        var allow = false
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            allow = true
        case .denied:
            allow = false
        case .restricted, .notDetermined:
            allow = false
        }
        return allow
    }
    
    @objc func checkPermition() {
        
        if requestAccess() {
            timerRefresh.invalidate()
            timerRefresh = nil
            self.delegate?.contectPermtion()
        }
    }
    
    //MARK: - Btn Click
    @IBAction func btnAllowClick(_ sender: UIButton) {
        checkPermissionToDeviceContacts()
    }
    
    
    
    func checkPermissionToDeviceContacts() {

        let store = CNContactStore()
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        // 2
        if authorizationStatus == .notDetermined {
            // 3
            store.requestAccess(for: .contacts) { [weak self] didAuthorize,
                                                              error in
                if didAuthorize {
                    self?.retrieveContacts(from: store)
                }
            }
        } else if authorizationStatus == .authorized {
            retrieveContacts(from: store)
            self.delegate?.contectPermtion()
        }  else if authorizationStatus == .denied {
            let alert = UIAlertController(title: "Can't access contact", message: "Please go to Settings -> MyApp to enable contact permission", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                self.headToSettingsOfPermissions()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func retrieveContacts(from store: CNContactStore) {
        let containerId = store.defaultContainerIdentifier()
        let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
        // 4
        let keysToFetch = [CNContactGivenNameKey as CNKeyDescriptor,
                           CNContactFamilyNameKey as CNKeyDescriptor,
                           CNContactImageDataAvailableKey as
                           CNKeyDescriptor,
                           CNContactImageDataKey as CNKeyDescriptor]

        let contacts = try! store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
        
        
        // 5
//        PRINTLOG(contacts)
      }
    
    
    func headToSettingsOfPermissions() {
        if let bundleId = Bundle.main.bundleIdentifier,
           let url = URL(string: "\(UIApplication.openSettingsURLString)&path=APPNAME/\(bundleId)")
        {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        self.setupNotifications()
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func applicationDidBecomeActive() {
        if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            dismiss(animated: false, completion: nil)
        }
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @IBAction func btnDontAllowClick(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
}
