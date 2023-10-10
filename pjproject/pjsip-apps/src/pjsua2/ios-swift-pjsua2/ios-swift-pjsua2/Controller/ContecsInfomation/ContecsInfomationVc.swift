//
//  ContecsInfomationVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 20/12/22.
//

import UIKit
import PagingKit

class ContecsInfomationVc: UIViewController {
    
    @IBOutlet weak var AddContectVW: UIView!
    var menuViewController: PagingMenuViewController!
    var contentViewController: PagingContentViewController!
    
    let focusView = UnderlineFocusView()
    
    
    let dataSource: [(menu: String, content: UIViewController)] = ["PERSONAL", "FAVORITE", "PHONEDIALERS"].map {
        let title = $0
        if title == "PERSONAL" {
            let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "ContactsVc") as! ContactsVc
            nextVC.navigationBarnotShow = true
            nextVC.isInvitedBtnShow = false
            nextVC.isFavoriteBtnShow = true
            nextVC.isContectNumberShow = false
            return (menu: title, content: nextVC)
        }else if title == "FAVORITE" {
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FavoriteListVc") as! FavoriteListVc
            return (menu: title, content: nextVC)
        }else if title == "PHONEDIALERS" {
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhoneDialUserListVc") as! PhoneDialUserListVc
            return (menu: title, content: nextVC)
        } else {
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FavoriteListVc") as! FavoriteListVc
            return (menu: title, content: nextVC)
        }
    }
    
    lazy var firstLoad: (() -> Void)? = { [weak self, menuViewController, contentViewController] in
        menuViewController?.reloadData()
        contentViewController?.reloadData { [weak self] in
            self?.adjustfocusViewWidth(index: 0, percent: 0)
        }
        self?.firstLoad = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuViewController.register(type: TitleLabelMenuViewCell.self, forCellWithReuseIdentifier: "identifier")
        menuViewController.registerFocusView(view: focusView)
        contentViewController.scrollView.bounces = true
        
        self.hideKeybordTappedAround()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
        //self.tabBarController?.tabBar.backgroundColor = .white
        self.tabBarController?.tabBar.backgroundColor = #colorLiteral(red: 0.9898476005, green: 0.9898476005, blue: 0.9898476005, alpha: 1)
        self.tabBarController!.tabBar.layer.borderWidth = 0.8
        appDelegate.sipRegistration()
        
        userBalance()
      
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        firstLoad?()    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PagingMenuViewController {
            menuViewController = vc
            menuViewController.dataSource = self
            menuViewController.delegate = self
        } else if let vc = segue.destination as? PagingContentViewController  {
            contentViewController = vc
            contentViewController?.dataSource = self
            contentViewController?.delegate = self
        }
    }
    
    // MARK: - btn Click
    @IBAction func btnClickAddContect(_ sender: UIButton) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddNewContectVc") as! AddNewContectVc
        nextVC.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
        self.present(nextVC, animated: true)
    }
    
    
    //MARK: - APi Action
    func userBalance() {
        let requestData : [String : String] = ["Token":User.sharedInstance.getUser_token()
                                               ,"request":"get_userbalance"
                                               ,"Device_id": appDelegate.diviceID]
        print(requestData)
        APIsMain.apiCalling.callDataWithoutLoader(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as? String ?? "" == "4" {
                let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "LogoutPopupVc") as! LogoutPopupVc
                nextVC.modalPresentationStyle = .overFullScreen
                self.present(nextVC, animated: false)
            }
        })
    }
    
    
}

extension ContecsInfomationVc: PagingMenuViewControllerDataSource {
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "identifier", for: index)  as! TitleLabelMenuViewCell
        cell.focusColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cell.normalColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6)
        cell.titleLabel.text = dataSource[index].menu
        
        cell.backgroundColor = #colorLiteral(red: 0.1069028154, green: 0.6903560162, blue: 0.8614253998, alpha: 1)
        
        return cell
    }

    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        if index == 2 {
            return 150
        }else {
            return 130

        }
    }

    var insets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return view.safeAreaInsets
        } else {
            return .zero
        }
    }
    
    func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return dataSource.count
    }
}

extension ContecsInfomationVc: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        return dataSource[index].content
    }
}

extension ContecsInfomationVc: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        contentViewController.scroll(to: page, animated: true)
    }
    
    func menuViewController(viewController: PagingMenuViewController, willAnimateFocusViewTo index: Int, with coordinator: PagingMenuFocusViewAnimationCoordinator) {
        setFocusViewWidth(index: index)
        if index == 2 {
            AddContectVW.isHidden = true
        }else {
            AddContectVW.isHidden = false
        }
        coordinator.animateFocusView { [weak self] coordinator in
            self?.focusView.layoutIfNeeded()
        } completion: { _ in }
    }
}

extension ContecsInfomationVc: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        if index == 2 {
            AddContectVW.isHidden = true
        }else {
            AddContectVW.isHidden = false
        }
        menuViewController.scroll(index: index, percent: percent, animated: false)
        adjustfocusViewWidth(index: index, percent: percent)
    }
    
    // TODO:- needs refactering
    func adjustfocusViewWidth(index: Int, percent: CGFloat) {
        let adjucentIdx = percent < 0 ? index - 1 : index + 1
        guard let currentCell = menuViewController.cellForItem(at: index) as? TitleLabelMenuViewCell,
            let adjucentCell = menuViewController.cellForItem(at: adjucentIdx) as? TitleLabelMenuViewCell else {
            return
        }
        focusView.underlineWidth = adjucentCell.calcIntermediateLabelSize(with: currentCell, percent: percent)
    }
    
    
    // TODO:- needs refactering
    func setFocusViewWidth(index: Int) {
        guard let cell = menuViewController.cellForItem(at: index) as? TitleLabelMenuViewCell else {
            return
        }
        focusView.underlineWidth = cell.labelWidth
    }
}

