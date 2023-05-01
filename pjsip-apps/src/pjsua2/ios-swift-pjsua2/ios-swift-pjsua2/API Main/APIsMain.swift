//
//  APIsMain.swift
//  AnyTimeHealthCare
//
//  Created by Emed_Imac on 10/4/17.
//

import UIKit
import Alamofire
import SystemConfiguration
import ImageIO


extension String {
    func getPathExtension() -> String {
        return (self as NSString).pathExtension
    }
}
//import JGProgressHUD
 struct JSONStringArrayEncoding: ParameterEncoding {
     private let myString: String

     init(string: String) {
         self.myString = string
     }

     func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
         var urlRequest = urlRequest.urlRequest

         let data = myString.data(using: .utf8)!

         if urlRequest?.value(forHTTPHeaderField: "Content-Type") == nil {
             urlRequest?.setValue("application/json", forHTTPHeaderField: "Content-Type")
         }

         urlRequest?.httpBody = data

         return urlRequest!
     }
 }

class APIsMain: NSObject {
    static let apiCalling = APIsMain()
        
    override init() {
    }
    
    
    func callData(credentials:[String: Any] ,requstTag:String, withCompletionHandler:@escaping (_ result: Any) -> Void) {
        
        let isONN : Bool = self.isConnectedToNetwork()
        if(isONN == true) {
            print("URL ::>> \(API_URL.BASEURL)\(requstTag)")
            HelperClassAnimaion.showProgressHud()
            AF.request("\(API_URL.BASEURL)\(requstTag)", method: .post, parameters: credentials,encoding: URLEncoding.default, headers: ["Content-type":"application/x-www-form-urlencoded","Authorization":"Basic bWFnaWN0ZWNoOnRydWNrbGluZQ==Content-Type:application/json"]).responseJSON {
                response in
                do {
                    switch response.result {
                    case .success:
                        print(response.value!)
                        HelperClassAnimaion.hideProgressHud()
                        let arForValues = response.value as? [[String: Any]]
                        if arForValues != nil {
                            withCompletionHandler(arForValues!)
                        }
                        guard let value = response.value as? [String: Any] else {
                            return
                        }
                        withCompletionHandler(value)
                        break
                    case .failure(let error):
                        HelperClassAnimaion.hideProgressHud()
                        print(error)
                        print("Something went Wrong.....")
                       // withCompletionHandler(error)
                    }
                }catch let error{
                    print(error)
                    DispatchQueue.main.async {
                        HelperClassAnimaion.hideProgressHud()
                        print("Something went Wrong.....")
                    }
                }
            }
        } else {
            HelperClassAnimaion.hideProgressHud()
            let alert = UIAlertController(title: Constant.GlobalConstants.APPNAME, message: "No Internet connection", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:{ (UIAlertAction)in
            }))
            alert.present(animated: true, completion: nil)
        }
    }
    
    func callDataWithoutLoader(credentials:[String: Any] ,requstTag:String, withCompletionHandler:@escaping (_ result: Any) -> Void) {
        
        let isONN : Bool = self.isConnectedToNetwork()
        if(isONN == true) {
            print("URL ::>> \(API_URL.BASEURL)\(requstTag)")
            AF.request("\(API_URL.BASEURL)\(requstTag)", method: .post, parameters: credentials,encoding: URLEncoding.default, headers: ["Content-type":"application/x-www-form-urlencoded","Authorization":"Basic bWFnaWN0ZWNoOnRydWNrbGluZQ==Content-Type:application/json"]).responseJSON {
                response in
                do {
                    switch response.result {
                    case .success:
                        print(response.value!)
                        let arForValues = response.value as? [[String: Any]]
                        if arForValues != nil {
                            withCompletionHandler(arForValues!)
                        }
                        guard let value = response.value as? [String: Any] else {
                            return
                        }
                        withCompletionHandler(value)
                        break
                    case .failure(let error):
                        print(error)
                        HelperClassAnimaion.hideProgressHud()

                        print("Something went Wrong.....")
                       // withCompletionHandler(error)
                    }
                }catch let error{
                    print(error)
                    HelperClassAnimaion.hideProgressHud()
                    DispatchQueue.main.async {
                        print("Something went Wrong.....")
                    }
                }
            }
        } else {
            HelperClassAnimaion.hideProgressHud()
            let alert = UIAlertController(title: Constant.GlobalConstants.APPNAME, message: "No Internet connection", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:{ (UIAlertAction)in
            }))
            alert.present(animated: true, completion: nil)
        }
    }
    
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection)
    }
    
    
    func callDataWithoutLoaderSoket(credentials:[String: Any] ,requstTag:String, withCompletionHandler:@escaping (_ result: Any) -> Void) {
        
        let isONN : Bool = self.isConnectedToNetwork()
        if(isONN == true) {
            AF.request("\(requstTag)", method: .post, parameters: credentials,encoding: URLEncoding.default).responseJSON {
                response in
                do {
                    switch response.result {
                    case .success:
//                        print(response.value!)
                        let arForValues = response.value as? [[String: Any]]
                        if arForValues != nil {
                            withCompletionHandler(arForValues!)
                        }
                        guard let value = response.value as? [String: Any] else {
                            return
                        }
                        withCompletionHandler(value)
                        break
                    case .failure(let error):
                        print(error)
                        HelperClassAnimaion.hideProgressHud()

                        print("Something went Wrong.....")
                       // withCompletionHandler(error)
                    }
                }catch let error{
                    print(error)
                    HelperClassAnimaion.hideProgressHud()

                    DispatchQueue.main.async {
                        print("Something went Wrong.....")
                    }
                }
            }
        } else {
//            HelperClass.hideProgressHud()
            let alert = UIAlertController(title: Constant.GlobalConstants.APPNAME, message: "No Internet connection", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:{ (UIAlertAction)in
            }))
            alert.present(animated: true, completion: nil)
        }
    }
    
        
}

