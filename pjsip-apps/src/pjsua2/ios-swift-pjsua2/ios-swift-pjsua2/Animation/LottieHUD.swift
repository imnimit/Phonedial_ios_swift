//
//  LottieHUD.swift
//  LottieHUD
//
//  Created by Ahmed Raad on 12/17/17.
//  Copyright © 2017 Ahmed Raad. All rights reserved.
//

import Foundation
import Lottie
import UIKit



public enum LottieHUDMaskType {
    case solid
}

public final class LottieHUD {
    
    public struct LottieHUDConfig {
        
        static var shadow: CGFloat = 0.7
        static var animationDuration: TimeInterval = 0.3
    }
    
    private var maskView: UIView = {
        let bg = UIView()
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.isUserInteractionEnabled = false
        bg.alpha = 0.0
        return bg
    }()
    
    
    // Not implemeted yet :)
    //    public var blurMaskType: UIBlurEffect = UIBlurEffect(style: .dark)
    
    private var _lottie: AnimationView!
    private var _lottieBackGround: UIView!
    
    public var contentMode: UIView.ContentMode = .scaleAspectFit {
        didSet {
            self._lottie.contentMode = contentMode
        }
    }
    
    public var maskType: LottieHUDMaskType = .solid

    public var size: CGSize = CGSize(width: 200, height: 200)
    
    
    init(_ name: String, loop: Bool = true) {
        self._lottie = AnimationView(name: name)
//        self._lottie.loopAnimation = loop
    }
    
    init(_ lottie: AnimationView) {
        self._lottie = lottie
    }
    
    public func showHUD(with delay: TimeInterval = 0.0, loop: Bool = true) {
//        _lottie.loopAnimation = loop
        createHUD(delay: delay)
    }
    
    public func stopHUD() {
        clearHUD()
    }
    
    private func createHUD(delay: TimeInterval = 0.0) {
        DispatchQueue.main.async {
//            UIApplication.shared.keyWindow!.isUserInteractionEnabled = false // Deprecated in iOS 13.0
            UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.isUserInteractionEnabled = false
            self.configureMask()
            self.configureConstraints()
            UIView.animate(withDuration: LottieHUDConfig.animationDuration, delay: delay, options: .curveEaseIn, animations: {
                self.maskView.alpha = 1.0
            }, completion: nil)
            self._lottie.loopMode = .loop
            self._lottie.play()
        }
    }
    
    private func configureMask() {
        if maskType == .solid {
            maskView.backgroundColor = UIColor.black.withAlphaComponent(LottieHUDConfig.shadow)
        } else {
            // Not implemented yet
        }
    }
    
    private func configureConstraints() {
        // Configure Backround View Constraints
//        self.keyWindow.view.addSubview(self.maskView) // Change
        appDelegate.window?.rootViewController?.view.addSubview(self.maskView)
        guard let keyWindowMargins = appDelegate.window?.rootViewController?.view else {return}
        
        maskView.leadingAnchor.constraint(equalTo: keyWindowMargins.leadingAnchor, constant: 0).isActive = true
        maskView.trailingAnchor.constraint(equalTo: keyWindowMargins.trailingAnchor, constant: 0).isActive = true
        maskView.topAnchor.constraint(equalTo: keyWindowMargins.topAnchor).isActive = true
        maskView.bottomAnchor.constraint(equalTo: keyWindowMargins.bottomAnchor).isActive = true
        maskView.addSubview(_lottie)
        
//        maskView.addSubview(_lottieBackGround)

        // Configure Lottie Constraints
        _lottie.translatesAutoresizingMaskIntoConstraints = false
        _lottie.centerXAnchor.constraint(equalTo: maskView.centerXAnchor, constant: 0).isActive = true
        _lottie.centerYAnchor.constraint(equalTo: maskView.centerYAnchor, constant: 0).isActive = true
        _lottie.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        _lottie.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        
//        _lottie.backgroundColor = UIColor.white
//        _lottie.layer.cornerRadius = 5.0
        
        
    }
    
    private func clearHUD() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: LottieHUDConfig.animationDuration, delay: 0, options: .curveEaseIn, animations: {
                self.maskView.alpha = 0.0
            }) { finished in
//              UIApplication.shared.keyWindow!.isUserInteractionEnabled = true
                UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.isUserInteractionEnabled = true
                self.maskView.removeFromSuperview()
                self._lottie.stop()
            }
        }
    }
    
    private var keyWindow: UIViewController {
        return UIApplication.topViewController()!
    }
    
}

extension UIApplication {
    
    class func topViewControllers(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(controller: nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(controller: presented)
        }
        
//        if let slide = viewController as? SlideMenuController {
//            return topViewController(controller: slide.mainViewController)
//        }
        return viewController
    }

        class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
            if let navigationController = controller as? UINavigationController {
                return topViewController(controller: navigationController.visibleViewController)
            }
            if let tabController = controller as? UITabBarController {
                if let selected = tabController.selectedViewController {
                    return topViewController(controller: selected)
                }
            }
            if let presented = controller?.presentedViewController {
                return topViewController(controller: presented)
            }
            return controller
        }

}
