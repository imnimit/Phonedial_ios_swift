//
//  ChatUploadImge.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 07/02/23.
//

import Foundation
import ProgressHUD
import Alamofire

extension String {

    //-------------------------------------------------------------------------------------------------------------------------------------------
    func url() -> URL {

        guard let url = URL(string: self) else {
            fatalError("URL error: \(self)")
        }
        return url
    }

    //-------------------------------------------------------------------------------------------------------------------------------------------
    func data() -> Data {

        return Data(self.utf8)
    }
}

class uploadImge: NSObject {
    
    static let sharUploadImge = uploadImge()
    
    
    func UploadImge(_ photo: UIImage?, _ video: URL?, _ audio: String?, _ document: URL?,pram:[String: String],_ completion: @escaping ([String: Any]?, String?, Error?) -> Void) {
        if let photo = photo {
            if let data = photo.jpegData(compressionQuality: 1.0) {
                uploadAuth(pram, data, "image/jpeg",completion)
            }
        }
        
        if let video = video {
            if let data = Data(path: video.path) {
                uploadAuth(pram, data, "video/mp4", completion)
            }
        }
        
        if let audio = audio {
            if let data = Data(path: audio) {
                uploadAuth(pram, data, "audio/mpeg",completion)
            }
        }
        
        if let document = document {
            if let data = Data(path: document.path) {
                uploadAuth(pram, data, "application/\( document.pathExtension)",completion)
            }
        }
        
        
        
        
        
    }
  
    func uploadAuth(_ auth: [String: String],_ data: Data, _ mimeType: String, _ completion: @escaping ([String: Any]?, String?, Error?) -> Void) {
        
     //   ProgressHUD.show(interaction: false)
//        let auth = ["user_id":appDelegate.Ch`atTimeUserUserID,"room_id":appDelegate.ChatGroupID,"msg_type":ChatConstanct.FileTypes.IMAGE_MESSAGE,"unique_id":"casdfasdf"]
        self.upload(auth, data, mimeType, completion)
    }
    
    func upload(_ auth: [String: String], _ data: Data, _ mimeType: String, _ completion: @escaping ([String: Any]?, String?, Error?) -> Void) {
        
        let base = ChatConstanct.URLChat.SocketURL
        let link = "\(base)upload_files"
        
        AF.upload(multipartFormData: { multipart in
            for (key, value) in auth {
                multipart.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
            var FileName = ""
            if mimeType == "video/mp4" {
                FileName = randomString(length: 8) + ".mp4"
            } else  if mimeType == "audio/mpeg" {
                FileName = randomString(length: 8) + ".mp3"
            } else if mimeType == "image/jpeg" {
                FileName = randomString(length: 8) + ".jpg"
            }else{
                let fullNameArr = mimeType.components(separatedBy: "/")
                FileName = randomString(length: 8) + "." + fullNameArr[1]
            }
            multipart.append(data, withName: "files", fileName: FileName, mimeType: mimeType)
            
        }, to: link.url(), method: .post).responseData { response in
            ProgressHUD.dismiss()
            switch response.result {
            case .success(let data):
                let values = self.convert(data)
                let arData : [String: Any] = (values)
                let data: [String: Any]  = (arData["Response"] as! [String: Any])
                let maindata:  [String: Any] = (data["data"] as! [String: Any])
                if let link = maindata["files"] as? String {
                    completion(maindata, link, nil)
                } else {
                    completion(nil, nil, NSError("Upload error.", code: 100))
                    print(values)
                }
            case .failure(let error):
                completion(nil, nil, error)
            }
        }
    }
}
 
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension uploadImge {

    //-------------------------------------------------------------------------------------------------------------------------------------------
    private func data(_ values: [String: Any]) -> Data {

        if let data = try? JSONSerialization.data(withJSONObject: values) {
            return data
        }
        fatalError("JSONSerialization error. \(values)")
    }

    //-------------------------------------------------------------------------------------------------------------------------------------------
    private func convert(_ data: Data?) -> [String: Any] {

        if let data = data {
            if let values = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                return values
            }
        }
        fatalError("JSONSerialization error.")
    }

    //-------------------------------------------------------------------------------------------------------------------------------------------
    private func check(_ data: Data?, _ error: Error?) -> Error? {

        if let error = error { return error }

        let response = convert(data)
        if let error = response["error"] as? [String: Any] {
            if let message = error["message"] as? String {
                return NSError(message, code: 100)
            }
        }
        return nil
    }
}
