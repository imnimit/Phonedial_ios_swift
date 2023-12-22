//
//  CommonMethods.swift
//  AnyTimeHealthCare
//
//  Created by Emed_Imac on 9/14/17.
//
//

import UIKit
import Foundation
import Toast_Swift
import CoreLocation
//import Lottie

extension UIView{
    func roundCorners(corners: UIRectCorner, radius: CGFloat, rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

func viewOrderApply(viewName: UIView,BorderWidth: Float,Colro: UIColor,CornerRedius: Float)  {
    viewName.layer.borderColor = Colro.cgColor
    viewName.layer.borderWidth = CGFloat(BorderWidth)
    viewName.layer.cornerRadius = CGFloat(CornerRedius)
}

class CardView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 2
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 3
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.5

    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)

        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }

}

extension UIView {

    func addDashedBorder() {
     //   Create a CAShapeLayer
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [2,3]
        
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: 0, y: 0),
                                CGPoint(x: self.frame.width/2, y: 0)])
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)        
    }
    
    
    private static let lineDashPattern: [NSNumber] = [2, 2]
    private static let lineDashWidth: CGFloat = 1.0

    func makeDashedBorderLine() {
        let path = CGMutablePath()
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = UIView.lineDashWidth
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.lineDashPattern = UIView.lineDashPattern
        path.addLines(between: [CGPoint(x: bounds.minX, y: bounds.height/2),
                                CGPoint(x: bounds.maxX, y: bounds.height/2)])
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)
    }
    
}


extension UIViewController {
    func hideKeybordTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.view.endEditing(true)
    }
    
    func showAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

extension UIColor {
    
    class var customGreen: UIColor {
        let darkGreen = 0x008110
        return UIColor.rgb(fromHex: darkGreen)
    }
    
    class func rgb(fromHex: Int) -> UIColor {
        
        let red =   CGFloat((fromHex & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((fromHex & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(fromHex & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension UIViewController {
    func popupAlert(title: String?, message: String?, actionTitles:[String?], actions:[((UIAlertAction) -> Void)?]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: actions[index])
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func showToastMessage(message : String?) {
        // create a new style
        var style = ToastStyle()

        // this is just one of many style options
        style.messageColor = .white
        style.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        // present the toast with the new style
        self.view.makeToast(message, duration: 3.0, position: .bottom, style: style)

        // or perhaps you want to use this style for all toasts going forward?
        // just set the shared style and there's no need to provide the style again
        ToastManager.shared.style = style
//        self.view.makeToast(message) // now uses the shared style

        // toggle "tap to dismiss" functionality
        ToastManager.shared.isTapToDismissEnabled = false

        // toggle queueing behavior
        ToastManager.shared.isQueueEnabled = true
    }
    
    func showToastMessagebgWhite(message : String?) {
        // create a new style
        var style = ToastStyle()

        // this is just one of many style options
        style.messageColor = .black
        style.backgroundColor = .white
        // present the toast with the new style
        self.view.makeToast(message, duration: 3.0, position: .bottom, style: style)

        // or perhaps you want to use this style for all toasts going forward?
        // just set the shared style and there's no need to provide the style again
        ToastManager.shared.style = style
//        self.view.makeToast(message) // now uses the shared style

        // toggle "tap to dismiss" functionality
        ToastManager.shared.isTapToDismissEnabled = false

        // toggle queueing behavior
        ToastManager.shared.isQueueEnabled = true
    }
    
}
// function for show alert in Main View Controller
extension UIAlertController {
    
    func show() {
        present(animated: true, completion: nil)
    }
    
    func present(animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
             presentFromController(controller: rootVC, animated: animated, completion: completion)
        }
    }
    
    private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController {
            presentFromController(controller: visibleVC, animated: animated, completion: completion)
        }  else {
            controller.present(self, animated: animated, completion: completion);
        }
    }
}

func showAlertforNetworkFailure(alerttitle :String, alertmessage: String,ButtonTitle: String, viewController: UIViewController) {
    
    let alertController = UIAlertController(title: alerttitle, message: alertmessage, preferredStyle: .alert)
    let okButtonOnAlertAction = UIAlertAction(title: ButtonTitle, style: .default)
    { (action) -> Void in
        //what happens when "ok" is pressed
        
    }
    alertController.addAction(okButtonOnAlertAction)
    alertController.show()
    
    
}

enum DeviceLockState {
    case locked
    case unlocked
}

class Utility {
    
    class func checkDeviceLockState(completion: @escaping (DeviceLockState) -> Void) {
        
       DispatchQueue.main.async {
            if UIApplication.shared.isProtectedDataAvailable {
                completion(.unlocked)
            } else {
                completion(.locked)
            }
        }
    }
}
func drawShadow(view : UIView){

    let cornerRadius: CGFloat = 4
    let shadowOffsetWidth: Int = 2
    let shadowOffsetHeight: Int = 2
    let shadowColor: UIColor? = UIColor.lightGray
    let shadowOpacity: Float = 0.5
    
    view.layer.cornerRadius = cornerRadius
    let shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: cornerRadius)
    
    view.layer.masksToBounds = false
    view.layer.shadowColor = shadowColor?.cgColor
    view.layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
    view.layer.shadowOpacity = shadowOpacity
    view.layer.shadowPath = shadowPath.cgPath
}

func setViewColorandCorner(color : UIColor,view : UIView) {
    view.layer.cornerRadius = 4.00;
    view.backgroundColor = color
}

func userAlreadyExist(kUsernameKey: String) -> Bool {
    return UserDefaults.standard.object(forKey: kUsernameKey) != nil
}
func storeLastSyncTime(LastSyncTime: String) {
    UserDefaults.standard.setValue(LastSyncTime, forKey: "last_sync_time")
}
func getLastSyncTime(LastSyncTimeKey: String) -> String {
//    return "2019/12/13 04:14:16 PM"
    return UserDefaults.standard.string(forKey: LastSyncTimeKey) ?? "2019/12/13 04:14:16 PM"
}
func storeUserID(ChatUserId: String) {
    UserDefaults.standard.setValue(ChatUserId, forKey: "ChatUserId")
}
func getUserId(ChatUserId: String) -> String {
//    return "2019/12/13 04:14:16 PM"
    return UserDefaults.standard.string(forKey: ChatUserId) ?? ""
}


func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}

func printSecondsToHoursMinutesSeconds(_ seconds: Int) -> String {
  let (h, m, s) = secondsToHoursMinutesSeconds(seconds)
  return "\(h < 10 ? "0\(h)" : "\(h)"):\(m < 10 ? "0\(m)" : "\(m)"):\(s < 10 ? "0\(s)" : "\(s)")"
}

func ChoiseRoleName(id:Int) -> String {
    switch id {
    case 5:
        return "Company Driver or Indepent Contractor"
    case 4:
        return "Owner Operator"
    case 3:
        return  "Fleet Owner"
    case 10:
        return "Dispatcher's Owner Operator"
    default: break
    }
    return  ""
}
func payoutNumberFormatter(_ price: Double) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.groupingSeparator = ","
    numberFormatter.groupingSize = 3
    numberFormatter.usesGroupingSeparator = true
    numberFormatter.decimalSeparator = "."
    numberFormatter.numberStyle = .decimal
    numberFormatter.maximumFractionDigits = 2
    return numberFormatter.string(from: price as NSNumber)!
}

func pakagingType(type: String) -> String {
    switch Int(type) {
    case 0:
        return "Boxes"
    case 1:
        return "Drums"
    case 2:
        return "Cases"
    case 3:
        return "Totes"
    case 4:
        return "Gaylords"
    case 5:
        return "Creates"
    case 6:
        return "Other"
    default:
        return ""
    }
}

func DocImgeGet(extection: String) -> UIImage {
    switch extection {
    case "pdf":
          return #imageLiteral(resourceName: "ic_chaticon_Pdf.png")
    case "html":
          return #imageLiteral(resourceName: "ic_chaticon_Vector.png")
    case "ppt":
          return #imageLiteral(resourceName: "ic_chaticon_Ppt.png")
    case "pptx":
          return #imageLiteral(resourceName: "ic_chaticon_Ppt.png")
    case "txt" , "rft":
          return #imageLiteral(resourceName: "ic_chaticon_Txt.png")
    case "xls", "xlsx":
          return #imageLiteral(resourceName: "ic_chaticon_Xls.png")
    case "doc" , "docx":
        return #imageLiteral(resourceName: "ic_chaticon_Doc.png")
    case "csv" :
        return #imageLiteral(resourceName: "ic_chaticon_Csv.png")
    default:
        return #imageLiteral(resourceName: "_unknown_gray.png")
    }
}

func findNameFistORMiddleNameFistLetter(name: String) -> String {
    
    if name == "" {
        return ""
    }
    var nameLetter: String = ""
    let index = name.index(name.startIndex, offsetBy: 0)
    nameLetter.append(name[index].uppercased())
    
    let components = name.components(separatedBy: " ")
    
    if components.count > 1  {
        if components[1] != "" {
            let index1 = components[1].index(components[1].startIndex, offsetBy: 0)
            nameLetter.append(components[1][index1].uppercased())
        }
    }
    return nameLetter
}

func AllowOnalyNumber(str: String) -> Bool{
    if CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: str)) {
        return true
    }else {
        return false
    }
}
extension String {
    public func toPhoneNumber() -> String {
        let digits = self.digitsOnly
        if digits.count == 10 {
            return digits.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1)-$2-$3", options: .regularExpression, range: nil)
        }
        else if digits.count == 11 {
            return digits.replacingOccurrences(of: "(\\d{1})(\\d{3})(\\d{3})(\\d+)", with: "$1($2)-$3-$4", options: .regularExpression, range: nil)
        }
        else {
            return self
        }
    }
    
    func replace(string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "")
    }
    
    func attributedString(with style: [NSAttributedString.Key: Any]? = nil,
                          and highlightedText: String,
                          with highlightedTextStyle: [NSAttributedString.Key: Any]? = nil) -> NSAttributedString {

        let formattedString = NSMutableAttributedString(string: self, attributes: style)
        let highlightedTextRange: NSRange = (self as NSString).range(of: highlightedText as String)
        formattedString.setAttributes(highlightedTextStyle, range: highlightedTextRange)
        return formattedString
    }
}
extension StringProtocol {
    /// Returns the string with only [0-9], all other characters are filtered out
    var digitsOnly: String {
        return String(filter(("0"..."9").contains))
    }

}

func findLast(number: String) -> String{
    guard number != "" else {return ""}
    var firstNumber = ""
    for i in number.reversed(){
        if i.isNumber{
            firstNumber.append(i)
            if firstNumber.count == 10 {
                break
            }
        }else{
            return firstNumber
        }
    }
    return firstNumber
}
func todayYourDataFormat(dataformat: String) -> String {
    let now = Calendar.current.dateComponents(in: .current, from: Date())
    
    // Create the start of the day in `DateComponents` by leaving off the time.
    let today = DateComponents(year: now.year, month: now.month, day: now.day, hour: now.hour, minute: now.minute, second: now.second)
    let dateToday = Calendar.current.date(from: today)!
    let dateFormatter : DateFormatter = DateFormatter()
    dateFormatter.dateFormat = dataformat
    let dateString = dateFormatter.string(from: dateToday)
    
    return dateString
}

func findExpiryData(FindExData:String) -> String {
    
    let dateFormatter1 = DateFormatter()
    dateFormatter1.dateFormat = "MM-dd-yyyy HH:mm:ss"
    guard let dataFind = dateFormatter1.date(from: FindExData) else {
        return ""
    }
    let calendar = Calendar.current
    let currentDate = Date()
    
    let df = DateFormatter()
    df.dateFormat = "MM-dd-yyyy HH:mm:ss"
    let dateString = df.string(from: currentDate)
    
    let components = calendar.dateComponents([.day,.hour,.minute,.second], from: dataFind, to: currentDate)
    
    if components.day ?? 0 > 0{
        return "\(String(describing: components.day!)) day ago"
    }
    
    if components.hour ?? 0 > 0{
        return "\(String(describing: components.hour!)) hours ago"
    }
    
    if components.minute ?? 0 > 0{
        return "\(String(describing: components.minute!)) minute ago"
    }
    
    if components.second ?? 0 > 0{
        return "\(String(describing: components.second!)) second ago"
    }
    
    return "Timer not Found"
}

func DataFormateSet(yourDataFormate: String , getDataFormat:  String,data: String) -> String {
    if data.trim()!.count == 0 {
        return ""
    }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = yourDataFormate
    guard let dateObj = dateFormatter.date(from: data)else {
        return ""
    }
    
    
    let dateFormatter1 = DateFormatter()
    dateFormatter1.dateFormat = getDataFormat

    return dateFormatter1.string(from: dateObj)
}
extension String {
    
    func trim() -> String? {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
func randomString(length: Int) -> String {
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    
    var randomString = ""
    
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    randomString = String(format: "%@", randomString)
    return randomString
}
extension Date {
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
func generateThumbnailVideo(url: URL, saveTo path: URL, completion: @escaping (UIImage?) -> Void) {
    let downloadTask = URLSession.shared.downloadTask(with: url) { (location, response, error) in
           guard let location = location else {
               completion(nil)
               return
           }
           do {
               let fileManager = FileManager.default
               if fileManager.fileExists(atPath: path.path) {
                   try fileManager.removeItem(at: path)
               }
               try fileManager.copyItem(at: location, to: path)
               
               generateThumbnailVideo(path: path) { thumbnail in
                   if let thumbnail = thumbnail {
                       completion(thumbnail)
                   } else {
                       completion(nil)
                   }
               }
           } catch let error {
               completion(nil)
           }
       }
       downloadTask.resume()
    
    
//    do {
//        let asset = AVURLAsset(url: path, options: nil)
//        let imgGenerator = AVAssetImageGenerator(asset: asset)
//        imgGenerator.appliesPreferredTrackTransform = true
//        let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
//        let thumbnail = UIImage(cgImage: cgImage)
//        completion(thumbnail)
//    } catch let error {
//        print("*** Error generating thumbnail: \(error.localizedDescription)")
//        completion(nil)
//    }
}
func generateThumbnailVideo(path: URL, completion: @escaping (UIImage?) -> Void) {
    do {
        let asset = AVURLAsset(url: path, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 2, timescale: 1), actualTime: nil)
        let thumbnail = UIImage(cgImage: cgImage)
        completion(thumbnail)
    } catch let error {
        print("*** Error generating thumbnail: \(error.localizedDescription)")
        completion(nil)
    }
}


func downloadAndConvertToBase64(mp3URL: URL, completion: @escaping (String?) -> Void) {
    let task = URLSession.shared.dataTask(with: mp3URL) { (data, response, error) in
        if let error = error {
            print("Error downloading MP3 file: \(error)")
            completion(nil)
            return
        }

        if let data = data {
            let base64String = data.base64EncodedString()
            completion(base64String)
        } else {
            completion(nil)
        }
    }
    task.resume()
}



func downloadImageConvertToBase64(from url: URL, completion: @escaping (String?) -> Void) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        if error != nil {
            completion("error")
            return
        }
        
        guard let data = data else {
            completion("Data not found.")
            return
        }
        
        let base64EncodedString = data.base64EncodedString()
        completion(base64EncodedString)
    }.resume()
}
extension Date {
    static func getDates(forLastNDays nDays: Int) -> [String] {
        let cal = NSCalendar.current
        // start with today
        var date = cal.startOfDay(for: Date())

        var arrDates = [String]()

        for _ in 1 ... nDays {
            // move back in time by one day:
            date = cal.date(byAdding: Calendar.Component.day, value: -1, to: date)!

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            let dateString = dateFormatter.string(from: date)
            arrDates.append(dateString)
        }
        print(arrDates)
        return arrDates
    }
}


func textFildDataChek(TextFild: UITextField) -> Bool {
    if TextFild.text != "" {
        return true
    }
    return false
}
extension UITextField {
    func setBorder() {
        self.layer.cornerRadius = 4.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.masksToBounds = true
    }
}
func isValidEmail(testStr:String) -> Bool {
    let emailRegEx = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
            "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
            "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    let result = emailTest.evaluate(with: testStr)
    return result
}

extension UIBarButtonItem {
    class func itemWith(colorfulImage: UIImage?, target: AnyObject, action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.setImage(colorfulImage, for: .normal)
        button.frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.addTarget(target, action: action, for: .touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: button)
        return barButtonItem
    }
    
    class func itemWith(Title: String?, target: AnyObject, action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.setTitle(Title, for: .normal)
        button.frame = CGRect(x: 0.0, y: 0.0, width: -44.0, height: 44.0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.setTitleColor(#colorLiteral(red: 0, green: 0.365360923, blue: 1, alpha: 1), for:.normal)
        let barButtonItem = UIBarButtonItem(customView: button)
        return barButtonItem
    }
    
    class func itemWithRightSide(colorfulImage: UIImage?, target: AnyObject, action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.setImage(colorfulImage, for: .normal)
        button.frame = CGRect(x: 0.0, y: 0.0, width: -44.0, height: -44.0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.addTarget(target, action: action, for: .touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: button)
        return barButtonItem
    }
}
extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}

extension RangeReplaceableCollection where Self: StringProtocol {
    mutating func removeAllNonNumeric() {
        removeAll { !$0.isWholeNumber }
    }
}

extension RangeReplaceableCollection where Self: StringProtocol {
    var digits: Self { filter(\.isWholeNumber) }
}

extension Character {
    var isDecimalOrPeriod: Bool { "0"..."9" ~= self || self == "." }
}
extension RangeReplaceableCollection where Self: StringProtocol {
    var digitsAndPeriods: Self { filter(\.isDecimalOrPeriod) }
}


//extension UITabBarController {
//    func showTabBar(){
//        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: .curveEaseOut) {
//            if let tabBarFrame = self.tabBarController?.tabBar.frame {
//                self.tabBarController?.tabBar.frame.origin.y = self.navigationController!.view.frame.maxY - tabBarFrame.height
//            }
//            self.tabBarController?.tabBar.isHidden = false
//            self.navigationController!.view.layoutIfNeeded()
//        }
//    }
//    
//    func hideTabBar() {
//        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: .curveEaseOut) {
//            if let tabBarFrame = self.tabBarController?.tabBar.frame {
//                self.tabBarController?.tabBar.frame.origin.y = self.navigationController!.view.frame.maxY + tabBarFrame.height
//            }
//            self.navigationController?.view.layoutIfNeeded()
//        } completion: { _ in
//            self.tabBarController?.tabBar.isHidden = true
//        }
//    }
//}
