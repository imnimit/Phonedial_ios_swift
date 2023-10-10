//
//  VideoOrAudioCallInfoVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 21/12/22.
//

import UIKit
import PagingKit

class VideoOrAudioCallInfoVc: UIViewController {
    
    var menuViewController: PagingMenuViewController!
    var contentViewController: PagingContentViewController!
    
    let focusView = UnderlineFocusView()
    
    
    let dataSource: [(menu: String, content: UIViewController)] = ["AUDIO CALLING", "VIDEO CALLING"].map {
        let title = $0
        if title == "AUDIO CALLING" {
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "phoneDIalersListVc") as! phoneDIalersListVc
            nextVC.IsVideoLog = false
            return (menu: title, content: nextVC)
        }else{
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "phoneDIalersListVc") as! phoneDIalersListVc
            nextVC.IsVideoLog = true
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
    }
    

   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.backgroundColor = .white
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
    
    
}

extension VideoOrAudioCallInfoVc: PagingMenuViewControllerDataSource {
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "identifier", for: index)  as! TitleLabelMenuViewCell
        cell.focusColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cell.normalColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6)
        cell.titleLabel.text = dataSource[index].menu
        
        cell.backgroundColor = #colorLiteral(red: 0.1069028154, green: 0.6903560162, blue: 0.8614253998, alpha: 1)
        
        return cell
    }

    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        return viewController.view.bounds.width / CGFloat(dataSource.count)

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

extension VideoOrAudioCallInfoVc: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        return dataSource[index].content
    }
}

extension VideoOrAudioCallInfoVc: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        contentViewController.scroll(to: page, animated: true)
    }
    
    func menuViewController(viewController: PagingMenuViewController, willAnimateFocusViewTo index: Int, with coordinator: PagingMenuFocusViewAnimationCoordinator) {
        setFocusViewWidth(index: index)
        coordinator.animateFocusView { [weak self] coordinator in
            self?.focusView.layoutIfNeeded()
        } completion: { _ in }
    }
}

extension VideoOrAudioCallInfoVc: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
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

