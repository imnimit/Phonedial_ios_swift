//
//  MediaDownload.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 03/02/23.
//

import Foundation
import Alamofire
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
class MediaDownload: NSObject {

    static var loading: [String] = []

    //-------------------------------------------------------------------------------------------------------------------------------------------
    class func anim(_ link: String, _ completion: @escaping (String, Error?) -> Void) {

        let path = Media.xpath(anim: link)
        checkManual(link, path, completion)
    }

    //-------------------------------------------------------------------------------------------------------------------------------------------
    class func photo(_ link: String, _ completion: @escaping (String, Error?) -> Void) {

        let path = Media.xpath(photo: link)
        checkManual(link, path, completion)
    }

    //-------------------------------------------------------------------------------------------------------------------------------------------
    class func video(_ link: String, _ completion: @escaping (String, Error?) -> Void) {

        let path = Media.xpath(video: link)
        checkManual(link, path, completion)
    }

    //-------------------------------------------------------------------------------------------------------------------------------------------
    class func audio(_ link: String, _ completion: @escaping (String, Error?) -> Void) {

        let path = Media.xpath(audio: link)
        checkManual(link, path, completion)
    }

    //-------------------------------------------------------------------------------------------------------------------------------------------
    private class func checkManual(_ link: String, _ path: String, _ completion: @escaping (String, Error?) -> Void) {

        let manual = path + ".manual"
        if (File.exist(manual)) {
            completion(path, xerror("Manual download."))
            return
        }
        try? "manual".write(toFile: manual, atomically: false, encoding: .utf8)

        media(link, path, completion)
    }

    //-------------------------------------------------------------------------------------------------------------------------------------------
    private class func media(_ link: String, _ path: String, _ completion: @escaping (String, Error?) -> Void) {

        guard let url = URL(string: "") else {
            fatalError("Backend url error.")
        }

        start(url, path) { error, later in
            completion(path, error)
        }
    }
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension MediaDownload {

    //-------------------------------------------------------------------------------------------------------------------------------------------
    class func sticker(_ sticker: String, _ completion: @escaping (String, Error?) -> Void) {

        let path = Media.xpath(sticker: sticker)

        guard let url = URL(string: "") else {
            fatalError("Backend url error.")
        }

        start(url, path) { error, later in
            completion(path, error)
        }
    }
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension MediaDownload {

    //-------------------------------------------------------------------------------------------------------------------------------------------
    class func user(_ link: String, _ completion: @escaping (UIImage?, Bool) -> Void) {

        let path = Media.xpath(user: link)

        if (File.exist(path)) {
            let image = UIImage(path: path)
            completion(image, false); return
        }

        guard let url = URL(string: "") else {
            completion(nil, false); return
        }

        start(url, path) { error, later in
            if (error == nil) {
                let image = UIImage(path: path)
                completion(image, false)
            } else {
                completion(nil, later)
            }
        }
    }
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension MediaDownload {

    //-------------------------------------------------------------------------------------------------------------------------------------------
    private class func start(_ url: URL, _ path: String, _ completion: @escaping (Error?, Bool) -> Void) {

        if (GQLNetwork.notReachable()) {
            completion(xerror("Network connection."), false); return
        }

        if (loading.count > 5) {
            completion(xerror("Too many processes."), true); return
        }

        if (loading.contains(path)) {
            completion(xerror("Already downloading."), true); return
        }

        loading.append(path)
        AF.request(url, method: .get).responseData { response in
            loading.remove(path)

            switch response.result {
            case .success(let data):
                Media.save(path, data)
                completion(nil, false)
            case .failure(let error):
                completion(error, false)
            }
        }
    }
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension MediaDownload {

    //-------------------------------------------------------------------------------------------------------------------------------------------
    private class func xerror(_ text: String) -> NSError {

        return NSError(text, code: 100)
    }
}
extension UIImage {

    //-------------------------------------------------------------------------------------------------------------------------------------------
    convenience init?(path: String) {

        if let data = Data(path: path) {
            self.init(data: data)
            return
        }
        return nil
    }

    //-------------------------------------------------------------------------------------------------------------------------------------------
    class func image(_ path: String, size: CGFloat) -> UIImage? {

        let image = UIImage(path: path)

        return image?.square(to: size)
    }
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension UIImage {

    //-------------------------------------------------------------------------------------------------------------------------------------------
    func resize(width: Int, height: Int) -> UIImage {

        let size = CGSize(width: width, height: height)

        return resize(size: size)
    }

    //-------------------------------------------------------------------------------------------------------------------------------------------
    func resize(width: CGFloat, height: CGFloat) -> UIImage {

        let size = CGSize(width: width, height: height)

        return resize(size: size)
    }

    //-------------------------------------------------------------------------------------------------------------------------------------------
    func resize(size: CGSize) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resized ?? UIImage()
    }
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension UIImage {

    //-------------------------------------------------------------------------------------------------------------------------------------------
    func square(to extent: Int) -> UIImage {

        let size = CGSize(width: extent, height: extent)

        return square().resize(size: size)
    }

    //-------------------------------------------------------------------------------------------------------------------------------------------
    func square(to extent: CGFloat) -> UIImage {

        let size = CGSize(width: extent, height: extent)

        return square().resize(size: size)
    }

    //-------------------------------------------------------------------------------------------------------------------------------------------
    func square() -> UIImage {

        if (size.width > size.height) {
            let xpos = (size.width - size.height) / 2
            return crop(x: xpos, y: 0, width: size.height, height: size.height)
        }

        if (size.height > size.width) {
            let ypos = (size.height - size.width) / 2
            return crop(x: 0, y: ypos, width: size.width, height: size.width)
        }

        return self
    }

    //-------------------------------------------------------------------------------------------------------------------------------------------
    func crop(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> UIImage {

        if let cgImage = cgImage {
            let rect = CGRect(x: x, y: y, width: width, height: height)
            if let cropped = cgImage.cropping(to: rect) {
                return UIImage(cgImage: cropped, scale: scale, orientation: imageOrientation)
            }
        }
        return UIImage()
    }
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension UIImage {

    //-------------------------------------------------------------------------------------------------------------------------------------------
    func rotateLeft() -> UIImage? {

        let new = CGSize(width: size.height, height: size.width)

        UIGraphicsBeginImageContextWithOptions(new, false, scale)
        let context = UIGraphicsGetCurrentContext()!

        context.translateBy(x: new.width/2, y: new.height/2)
        context.rotate(by: CGFloat(-0.5 * .pi))

        self.draw(in: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Array where Element: Hashable {

    //-------------------------------------------------------------------------------------------------------------------------------------------
    mutating func appendUnique(_ element: Element) {

        var array = self

        if !array.contains(element) {
            array.append(element)
        }

        self = array
    }

    //-------------------------------------------------------------------------------------------------------------------------------------------
    mutating func removeDuplicates() {

        var array: [Element] = []

        for element in self {
            if !array.contains(element) {
                array.append(element)
            }
        }

        self = array
    }

    //-------------------------------------------------------------------------------------------------------------------------------------------
    mutating func remove(_ element: Element) {

        var array = self

        while let index = array.firstIndex(of: element) {
            array.remove(at: index)
        }

        self = array
    }
}
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension NSError {

    //-------------------------------------------------------------------------------------------------------------------------------------------
    convenience init(_ description: String, code: Int) {

        let domain = Bundle.main.bundleIdentifier ?? ""
        let userInfo = [NSLocalizedDescriptionKey: description]

        self.init(domain: domain, code: code, userInfo: userInfo)
    }
}
