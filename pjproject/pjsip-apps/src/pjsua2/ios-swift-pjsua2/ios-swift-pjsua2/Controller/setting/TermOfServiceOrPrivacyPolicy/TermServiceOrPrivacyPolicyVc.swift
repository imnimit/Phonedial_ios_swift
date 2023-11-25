//
//  TermServiceOrPrivacyPolicyVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 20/12/22.
//

import UIKit
import WebKit

class TermServiceOrPrivacyPolicyVc: UIViewController,WKNavigationDelegate {
    
    var DocumentUrl: String  = ""
    var Title: String = ""
    var showinDispachOwnerTime = ""
    lazy var webView: WKWebView = {
        let wv = WKWebView()
        wv.translatesAutoresizingMaskIntoConstraints = false
        return wv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Title
        
        view.addSubview(webView)
        NSLayoutConstraint.activate([webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     webView.topAnchor.constraint(equalTo: view.topAnchor),
                                     webView.rightAnchor.constraint(equalTo: view.rightAnchor),
                                     webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        
        
        let link = URL(string:DocumentUrl)!
        webView.navigationDelegate = self
        webView.load(URLRequest(url: link))

      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
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
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        HelperClassAnimaion.showProgressHud()
        print("Strat to load")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        HelperClassAnimaion.hideProgressHud()
        print("finish to load")
    }    
}
