//
//  AddContacts.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 21/12/22.
//

import Foundation
import Contacts
import UIKit

func AddContacts(img:UIImage,imgAddOrNot:Bool,name:String,middleName:String,homeEmail:String,number:String,companyName:String,occupation:String){
     
    // Create a mutable object to add to the contact.
    let contact = CNMutableContact()
    
    if imgAddOrNot == true {
        contact.imageData = img.jpegData(compressionQuality: 1.0)
    }
    contact.givenName = name
    contact.familyName = middleName
    contact.organizationName = companyName
    contact.jobTitle = occupation

    let homeEmail = CNLabeledValue(label: CNLabelHome, value: homeEmail as NSString)
//    let workEmail = CNLabeledValue(label: CNLabelWork, value: workEmail as NSString)
    contact.emailAddresses = [homeEmail/*, workEmail*/]

    contact.phoneNumbers = [CNLabeledValue(
        label: CNLabelPhoneNumberiPhone,
        value: CNPhoneNumber(stringValue: number))] //"(408) 555-0126"


    // Save the newly created contact.
    let store = CNContactStore()
    let saveRequest = CNSaveRequest()
    saveRequest.add(contact, toContainerWithIdentifier: nil)

    do {
        try store.execute(saveRequest)
    } catch {
        print("Saving contact failed, error: \(error)")
        // Handle the error.
    }
}

func DeleteContact(name: String){
    let store = CNContactStore()
    
    let predicate = CNContact.predicateForContacts(matchingName: name)
    let toFetch = [CNKeyDescriptor]()

    do{
        let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: toFetch)
      guard contacts.count > 0 else{
        print("No contacts found")
        return
      }

      guard let contact = contacts.first else{
         return
      }

      let req = CNSaveRequest()
      let mutableContact = contact.mutableCopy() as! CNMutableContact
      req.delete(mutableContact)

      do{
          try store.execute(req)
        print("Success, You deleted the user")
      } catch let e{
        print("Error = \(e)")
      }
    } catch let err{
       print(err)
    }
}

class ViewController1: UIViewController {
    let store = CNContactStore()
    
    let keys = [CNContactGivenNameKey as CNKeyDescriptor]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        store.requestAccess(for: .contacts) {
            
            permissionGranted, error in
            
            let request = CNContactFetchRequest(keysToFetch: self.keys)
            
            print("enumerate contacts")
            
            do {
                
                try self.store.enumerateContacts(with: request) {
                    
                    contact, pointer in
                    
                    print(contact.givenName)
                    
                }
                
            } catch {
                
                print("error")
                print(error.localizedDescription)
                
            }
            
            print("unified contacts")
            
            do {
                
                let containers = try self.store.containers(matching: nil)
                
                if containers.count > 1 {
                    fatalError("More than one container!")
                }
                
                let predicate = CNContact.predicateForContactsInContainer(withIdentifier: self.store.defaultContainerIdentifier())
                let contacts = try self.store.unifiedContacts(matching: predicate, keysToFetch: self.keys)
                for contact in contacts {
                    print(contact.givenName)
                }
                
            } catch {
                
                print("error")
                print(error.localizedDescription)
            }
            
        }
        
    }    
}


