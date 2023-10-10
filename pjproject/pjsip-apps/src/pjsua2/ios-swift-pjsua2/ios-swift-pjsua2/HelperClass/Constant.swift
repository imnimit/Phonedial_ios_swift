
import UIKit


var appDelegate: AppDelegate {
   return UIApplication.shared.delegate as! AppDelegate
}

struct API_URL {
    //http://45.77.46.154:8089/
    static let LIVE_URL = "https://45.77.46.154:8089/Dialer_API_23717/api.php?"    //"https://switch.nyerhosmobile.com/Dialer_API_23717/api.php"
    static let BASEURL = LIVE_URL
    static let URLAUDIODOWNLOAD = "https://switch.nyerhosmobile.com/voicemail/"
    static let SoketAPIURL = "https://chat.voizcall.com:7000/" //"http://socket.nyerhosmobile.com:7000/"
}

struct APISoketName {
    static let  CreateUser = "create_user"
    static let  Login = "login"
    static let  CreateGroup = "create_group"
    static let  GetUser = "get_user"
    static let  GetGroup = "get_group"
    static let  AddUserInGroup = "add_user_in_group"
    static let  UploadFiles = "upload_files"
}

class Constant: NSObject {
    struct ScreenSize {
        static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
        static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
        static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
        static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    }
    
    struct DeviceType {
        static let IS_IPHONE_4_OR_LESS =  UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
        static let IS_IPHONE_5 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
        static let IS_IPHONE_6 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
        static let IS_IPHONE_6P = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    }
    
    struct GlobalConstants {
        static let APPNAME = "PhoneDial"
        static let POPUP_ALERT = "Alert"
        static let GOOGLE_API_KEY = "AIzaSyAOFFQ4jMVhXoAnam1hfzHLngCutNlbzY4"
        
        static let SERVERNAME =  "45.77.46.154:8089/" //"switch.nyerhosmobile.com"
        static let PORT = "8089" //5060"
        
        static let pushToken = "NXMPushToken"
        static let fromKeyPath = "nexmo.push_info.from_user.name"
        
        static let LinkApp =  "https://apps.apple.com/us/app/idxxxxxxxx?ls=1&mt=8"
        
        static let TERMS_CONDITION_URL  =    "http://phonedial.io/pages/terms_conditions.html"
        static let PRIVACY_POLICY_URL  =   "http://phonedial.io/pages/privacy.html"
    }
    
    struct SocialMedia {
        static let FACEBOOK_URL = "https://www.facebook.com/getphonedial"
        static let INSTAGRAM_URL = "https://www.instagram.com/getphonedial"
        static let TWITTER_URL = "https://twitter.com/getphonedial"
    }
    
    struct AlertDiscretion {
        static let DeleteAccountDis = "Are You Sure Want To Delete Account! Erase all Relevant data for account & not get back!"
        static let DeleteAccountTitle = "Alert!"
    }
    
    struct CallConfig {
          static var mute = false
          static var Specaker = false
      }
    
    struct ViewControllerTitle {
        static let MyAccount = "My Account"
        static let InviteFriends = "Invite Friends"
        static let Contacts = "Contacts"
        static let PromoCode = "Promo Code"
        static let PhoneDialRewards = "PhoneDial Rewards"
        static let BlockCall = "BLOCK CALLS"
        static let SuggestFeature = "Suggest Feature"
        static let Feedback = "Feedback"
        static let TermsofService = "Terms of Service"
        static let PrivacyPolicy = "Privacy Policy"
        static let MyPhoneNumber = "My Phone Number"
        static let CallLogs = "Call Logs"
        static let SpeedDial = "Speed Dial"
    }
    
    struct ErrorOFAddContacsNumber {
        static let EnterFistName = "Please enter fist name"
        static let EnterPhoneNumber = "Please enter phone number"
        static let EnterPhoneValidNumber = "Please enter phone valid number"
    }
    
    struct ErrorOFFeedBack {
        static let PleaseEnterTitle = "Please enter title"
        static let PleaseEnterEiscretion = "Please enter discretion"
    }
    
    static let PleaseEnterPromoCode = "Please enter promo code"
    
    struct ValueStoreName {
        static let ContactNumber = "ContactNumber"
    }
    
    struct InappPuchseId {
        static let FiveDollar = "com.phonedial.io.five"
        static let TenDollar = "com.phonedial.io.ten"
        static let FifteenDollar = "com.phonedial.io.fifteen"
    }
    
    static let ConfrenceCallConnectUserNumber = 10

}
