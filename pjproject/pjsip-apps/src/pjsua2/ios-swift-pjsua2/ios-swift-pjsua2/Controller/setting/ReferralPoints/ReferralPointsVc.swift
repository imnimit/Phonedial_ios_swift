//
//  ReferralPointsVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 20/12/22.
//

import UIKit
import KDCircularProgress


class ReferralPointsVc: UIViewController {
    @IBOutlet weak var circleProgressBar: KDCircularProgress!
    @IBOutlet weak var progressUnlockSilver: GradientProgressView!
    
    @IBOutlet weak var lblForTotalRefPoint: UILabel!
    @IBOutlet weak var lblForSubTitleTotal: UILabel!
    @IBOutlet weak var lblForGenralInformation: UILabel!
    
    @IBOutlet weak var tierProgress1: GradientProgressView!
    @IBOutlet weak var tierProgress2: GradientProgressView!
    @IBOutlet weak var tierProgress3: GradientProgressView!
    @IBOutlet weak var tierProgress4: GradientProgressView!

    @IBOutlet weak var hightTableView: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblReferralPoint: UILabel!
    
    @IBOutlet weak var imgForSilverTier: UIImageView!
    @IBOutlet weak var imgForPlatinumTier: UIImageView!
    @IBOutlet weak var imgForDiamondTier: UIImageView!
    @IBOutlet weak var imgForBasicTier: UIImageView!
    
    @IBOutlet weak var lblForBasicTierInfo: UILabel!
    @IBOutlet weak var lblForSilverTierInfo:  UILabel!
    @IBOutlet weak var lblForPlatinumTierInfo:  UILabel!
    @IBOutlet weak var lblForDiamondTierInfo:  UILabel!
    
    @IBOutlet weak var lblForBasicTierRangeInfo: UILabel!
    @IBOutlet weak var lblForSilverTierRangeInfo: UILabel!
    @IBOutlet weak var lblForPlatinumTierRangeInfo: UILabel!
    @IBOutlet weak var lblForDiamondTierRangeInfo: UILabel!
    
    @IBOutlet weak var lblForBasicPointsRangeInfo: UILabel!
    @IBOutlet weak var lblForSilverPointsRangeInfo: UILabel!
    @IBOutlet weak var lblForPlatinumPointsRangeInfo: UILabel!
    @IBOutlet weak var lblForDiamondPointsRangeInfo: UILabel!
    @IBOutlet weak var lblForNextTierValue: UILabel!

  
    var basicCalculationPer = 1.0
    var silverCalculationPer = 1.0
    var platinumCalculationPer = 1.0
    var diamondCalculationPer = 1.0
    
    
    
    var strForGenralInfo = "Earn "
    var strForSubTitle = "of "
    var dataForResponce = [String:Any]()

    var indexShowInfo = -1
    var tblTitle = ["Vuetel Basic Member","Vuetel Silver Member","Vuetel Platinum Member","Vuetel Diamond Member"]
    var tblDescription = [["text1": "Earn 100 Vuetel reards points per referral.","text2":"You earn $5 Vuetel credit rewards within 15 days when your referral adds a minimum of $5 to their wallet."],
                          ["text1": "Earn 150 Vuetel reards points per referral.","text2":"You earn $6 Vuetel credit rewards within 15 days when your referral adds a minimum of $5 to their wallet."],
                          ["text1": "Earn 200 Vuetel reards points per referral.","text2":"You earn $8 Vuetel credit rewards within 15 days when your referral adds a minimum of $5 to their wallet."],
                          ["text1": "Earn 300 Vuetel reards points per referral.","text2":"You earn $10 Vuetel credit rewards within 15 days when your referral adds a minimum of $5 to their wallet."]]
    
    
    struct ReferlRewardPoint {
        static let TIERBASIC = 5000
        static let TIERSILVER = 9000
        static let TIERPLATINUM = 15000
        static let TIERDIAMOND = 50000
        static let DefultProgressBar = 0.0
    }
    
    var TotleEarn = 0
    var overViewPer = 0.0
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCall()
      

    }
    
    
    
    func initCall(){
        self.title = Constant.ViewControllerTitle.PhoneDialRewards
        
        TotleEarn = Int(dataForResponce["Referral_points"] as? String ?? "0") ?? 0
       
        circleProgressBar.startAngle = -90
        circleProgressBar.progressThickness = 0.4
        circleProgressBar.trackThickness = 0.5
        circleProgressBar.clockwise = true
        circleProgressBar.gradientRotateSpeed = 2
        circleProgressBar.roundedCorners = false
        circleProgressBar.glowMode = .noGlow
        circleProgressBar.glowAmount = 0
        
        self.lblForTotalRefPoint.text = "\(TotleEarn)";

        progressBarValueSet()
    }
    
    func progressBarValueSet(){
        
        self.imgForBasicTier.image = #imageLiteral(resourceName: "tick.png")
        self.imgForSilverTier.image = #imageLiteral(resourceName: "tick.png")
        self.imgForPlatinumTier.image = #imageLiteral(resourceName: "tick.png")
        self.imgForDiamondTier.image = #imageLiteral(resourceName: "tick.png")
        
        self.lblForBasicTierRangeInfo.text = "\(TotleEarn)" + " of " +  "\(ReferlRewardPoint.TIERBASIC)"
        self.lblForSilverTierRangeInfo.text = "\(TotleEarn)" + " of " +  "\(ReferlRewardPoint.TIERSILVER)"
        self.lblForPlatinumTierRangeInfo.text = "\(TotleEarn)" + " of " +  "\(ReferlRewardPoint.TIERPLATINUM)"
        self.lblForDiamondTierRangeInfo.text = "\(TotleEarn)" + " of " +  "\(ReferlRewardPoint.TIERDIAMOND)"
        
        
        self.lblForBasicPointsRangeInfo.text = "Points"
        self.lblForSilverPointsRangeInfo.text = "Points"
        self.lblForPlatinumPointsRangeInfo.text = "Points"
        self.lblForDiamondPointsRangeInfo.text = "Points"
        
        if TotleEarn < ReferlRewardPoint.TIERBASIC {
            strForSubTitle =  strForSubTitle + "\(ReferlRewardPoint.TIERBASIC)" + " pts"
            strForGenralInfo = strForGenralInfo + "\(ReferlRewardPoint.TIERBASIC - TotleEarn)"
            self.lblForNextTierValue.text = "\(ReferlRewardPoint.TIERBASIC)"
            basicCalculationPer =  (((Double(TotleEarn) * 100.0)) / (Double(ReferlRewardPoint.TIERBASIC)*100.0))
            self.overViewPer = self.basicCalculationPer;

            self.silverCalculationPer = ReferlRewardPoint.DefultProgressBar
            self.platinumCalculationPer = ReferlRewardPoint.DefultProgressBar
            self.diamondCalculationPer = ReferlRewardPoint.DefultProgressBar
            
            self.imgForBasicTier.image = #imageLiteral(resourceName: "lock.png")
            self.imgForSilverTier.image = #imageLiteral(resourceName: "lock.png")
            self.imgForPlatinumTier.image = #imageLiteral(resourceName: "lock.png")
            self.imgForDiamondTier.image = #imageLiteral(resourceName: "lock.png")
            
            
            progressUnlockSilver.progressColors = [#colorLiteral(red: 0.1529411765, green: 0.431372549, blue: 0.9568627451, alpha: 1)]
            progressUnlockSilver.animationDuration = 0.5
        }
        else if TotleEarn < ReferlRewardPoint.TIERSILVER {
            strForSubTitle = strForSubTitle +  "\(ReferlRewardPoint.TIERSILVER)" + " pts"
            strForGenralInfo = strForGenralInfo + "\(ReferlRewardPoint.TIERSILVER-self.TotleEarn)" + " more points to Unlock Platinum"
            self.lblForNextTierValue.text = "\(ReferlRewardPoint.TIERSILVER)"
            self.silverCalculationPer = (((Double(TotleEarn) * 100.0)) / (Double(ReferlRewardPoint.TIERSILVER)*100.0))
            self.overViewPer = self.silverCalculationPer;
            
            self.platinumCalculationPer = ReferlRewardPoint.DefultProgressBar
            self.diamondCalculationPer = ReferlRewardPoint.DefultProgressBar
            
            self.imgForSilverTier.image = #imageLiteral(resourceName: "lock.png")
            self.imgForPlatinumTier.image = #imageLiteral(resourceName: "lock.png")
            self.imgForDiamondTier.image = #imageLiteral(resourceName: "lock.png")
            
            self.lblForBasicTierInfo.text = "Basic";
            self.lblForBasicTierRangeInfo.text = "";
            self.lblForBasicPointsRangeInfo.text = "";
            
            progressUnlockSilver.progressColors = [#colorLiteral(red: 0.9764705882, green: 0.7647058824, blue: 0.2705882353, alpha: 1)]
            progressUnlockSilver.animationDuration = 0.5
        }
        else if TotleEarn < ReferlRewardPoint.TIERPLATINUM {
            strForSubTitle = strForSubTitle +  "\(ReferlRewardPoint.TIERPLATINUM)" + " pts"
            strForGenralInfo = strForGenralInfo + "\(ReferlRewardPoint.TIERPLATINUM-self.TotleEarn)"  +  "  more points to All  VIP Tier"
            self.lblForNextTierValue.text = "\(ReferlRewardPoint.TIERPLATINUM)"
            self.platinumCalculationPer = (((Double(TotleEarn) * 100.0)) / (Double(ReferlRewardPoint.TIERPLATINUM)*100.0))
            self.overViewPer = self.platinumCalculationPer;

            //reset load value
            self.diamondCalculationPer = ReferlRewardPoint.DefultProgressBar;
            //Reset Tick Mark
            self.imgForPlatinumTier.image = #imageLiteral(resourceName: "lock.png")
            self.imgForDiamondTier.image = #imageLiteral(resourceName: "lock.png")
            //Reset tier info text
            self.lblForBasicTierInfo.text = "Basic";
            self.lblForSilverTierInfo.text = "Silver";
            //Tier Color
            progressUnlockSilver.progressColors = [#colorLiteral(red: 0.5450980392, green: 0.5882352941, blue: 0.6196078431, alpha: 1)]
            progressUnlockSilver.animationDuration = 0.5
            //Tier Point Details
            self.lblForBasicTierRangeInfo.text = ""
            self.lblForSilverTierRangeInfo.text = ""
            
            self.lblForBasicPointsRangeInfo.text = ""
            self.lblForSilverPointsRangeInfo.text = ""
            
        }
        else if TotleEarn < ReferlRewardPoint.TIERDIAMOND {
            strForSubTitle = strForSubTitle +  "\(ReferlRewardPoint.TIERDIAMOND)" + " pts"
            strForGenralInfo = strForGenralInfo + "\(ReferlRewardPoint.TIERDIAMOND-self.TotleEarn)"  +  "  more points to Unlock Diamond"
            self.diamondCalculationPer = (((Double(TotleEarn) * 100.0)) / (Double(ReferlRewardPoint.TIERDIAMOND)*100.0))
            self.overViewPer = self.diamondCalculationPer;

            self.lblForNextTierValue.text = "\(ReferlRewardPoint.TIERDIAMOND)"
            self.diamondCalculationPer = (((Double(TotleEarn) * 100.0)) / (Double(ReferlRewardPoint.TIERDIAMOND)*100.0))
            self.overViewPer = self.diamondCalculationPer;
            //Reset Tick Mark
            self.imgForDiamondTier.image = #imageLiteral(resourceName: "lock.png")
            //Reset tier info text
            self.lblForBasicTierInfo.text = "Basic";
            self.lblForSilverTierInfo.text = "Silver";
            self.lblForPlatinumTierInfo.text = "Platinum";
            //Tier Color
//            self.strForSelectedTierColor = DIAMONDTIERCOLOR;
            //Tier Point Details
            self.lblForBasicTierRangeInfo.text = "";
            self.lblForSilverTierRangeInfo.text = "";
            self.lblForPlatinumTierRangeInfo.text = "";

            self.lblForBasicPointsRangeInfo.text = "";
            self.lblForSilverPointsRangeInfo.text = "";
            self.lblForPlatinumPointsRangeInfo.text = "";
            
            progressUnlockSilver.progressColors = [#colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.3019607843, alpha: 1)]
            progressUnlockSilver.animationDuration = 0.5
            
        }
        else {
            strForSubTitle = strForSubTitle +  "\(ReferlRewardPoint.TIERDIAMOND)" + " pts"
            strForGenralInfo = "Congratulations for All  VIP Tier completed"
            self.lblForNextTierValue.text = "\(ReferlRewardPoint.TIERDIAMOND)"
               self.basicCalculationPer = 1.0;
            self.silverCalculationPer = 1.0;
            self.platinumCalculationPer = 1.0;
            self.diamondCalculationPer = 1.0;
            self.overViewPer = 1.0;
             self.lblForBasicTierInfo.text = "Basic";
            self.lblForSilverTierInfo.text = "Silver";
             self.lblForPlatinumTierInfo.text = "Platinum";
            self.lblForDiamondTierInfo.text = "Diamond";
            //Tier Point Details
            self.lblForBasicTierRangeInfo.text = "";
            self.lblForSilverTierRangeInfo.text = "";
            self.lblForPlatinumTierRangeInfo.text = "";
            self.lblForDiamondTierRangeInfo.text = "";
            
            self.lblForBasicPointsRangeInfo.text = "";
            self.lblForSilverPointsRangeInfo.text = "";
            self.lblForPlatinumPointsRangeInfo.text = "";
            self.lblForDiamondPointsRangeInfo.text = "";
        }
        
        self.lblForSubTitleTotal.text = strForSubTitle;
        self.lblForGenralInformation.text = strForGenralInfo;
       
        
        let findAngle = Int((overViewPer * 360 ))
        
        circleProgressBar.animate(fromAngle: 0, toAngle: Double(findAngle), duration: 1.5) { completed in
            if completed {
                print("animation stopped, completed")
            } else {
                print("animation stopped, was interrupted")
            }
        }
        
        
        tierProgress1.progressColors = [#colorLiteral(red: 0.1529411765, green: 0.431372549, blue: 0.9568627451, alpha: 1)]
        tierProgress1.animationDuration = 0.5
        
        tierProgress2.progressColors = [#colorLiteral(red: 0.9764705882, green: 0.7647058824, blue: 0.2705882353, alpha: 1)]
        tierProgress2.animationDuration = 0.5
        
        tierProgress3.progressColors = [#colorLiteral(red: 0.5450980392, green: 0.5882352941, blue: 0.6196078431, alpha: 1)]
        tierProgress3.animationDuration = 0.5
        
        tierProgress4.progressColors = [#colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.3019607843, alpha: 1)]
        tierProgress4.animationDuration = 0.5
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [self] in
           
            progressUnlockSilver.setProgress(Float(overViewPer), animated: true)

            tierProgress1.setProgress(Float(basicCalculationPer), animated: true)
           
            tierProgress2.setProgress(Float(silverCalculationPer), animated: true)
            
            tierProgress3.setProgress(Float(platinumCalculationPer), animated: true)
            
            tierProgress4.setProgress(Float(diamondCalculationPer), animated: true)
        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: .curveEaseOut) {
            if let tabBarFrame = self.tabBarController?.tabBar.frame {
                self.tabBarController?.tabBar.frame.origin.y = self.navigationController!.view.frame.maxY + tabBarFrame.height
            }
            self.navigationController!.view.layoutIfNeeded()
        } completion: { _ in
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
   
}
extension ReferralPointsVc: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhoneDialBasicInfoCell", for: indexPath) as! PhoneDialBasicInfoCell
        cell.infoVW.isHidden = true
        cell.mainVW.layer.cornerRadius = 5
        cell.lblTitle.text = tblTitle[indexPath.row]
        cell.imgeSine.image =  #imageLiteral(resourceName: "add1.png")
                                             
        if indexShowInfo == indexPath.row {
            let dic = tblDescription[indexShowInfo]
            cell.lblEarnInfo.text = dic["text2"] ?? ""
            cell.lblReferralInfo.text = dic["text1"] ?? ""
            cell.infoVW.isHidden = false
            cell.imgeSine.image = #imageLiteral(resourceName: "minus1.png")
        }
        cell.bntHeder.tag = indexPath.row
        cell.bntHeder.addTarget(self, action: #selector(whichButtonPressed(sender:)), for: .touchUpInside)

        return cell
    }
    
   @objc func whichButtonPressed(sender: UIButton) {
       if indexShowInfo == sender.tag {
           indexShowInfo = -1
           hightTableView.constant = 220

       }else {
           indexShowInfo = sender.tag
           hightTableView.constant = 300
       }
       tableView.reloadData()
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == indexShowInfo {
            return 50+80
        }else {
            return 50
        }
    }
    
}
