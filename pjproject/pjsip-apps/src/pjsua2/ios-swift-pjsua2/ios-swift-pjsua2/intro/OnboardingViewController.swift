//
//  OnboardingViewController.swift
//  Onboarding
//
//  Created by Maheen on 06/06/2022.
//

import UIKit
import AdvancedPageControl
import AVFoundation
import AVKit
struct OnboardingSlide {
    let title: String
    let description: String
    let image: UIImage
    let Video: String
}

class OnboardingViewController: UIViewController {

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pageControl3: AdvancedPageControlView!
    @IBOutlet weak var heightOfPageControl: NSLayoutConstraint!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnCenterLetsGo: UIButton!
    @IBOutlet weak var videoVW: UIView!
    
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var paused: Bool = false
    
    var slides: [OnboardingSlide] = []
    
    var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            if currentPage == slides.count - 1 {
                videoVW.isHidden = false
                nextBtn.setTitle("LET'S GO", for: .normal)
                nextBtn.isHidden = true
                pageControl3.isHidden = true
                btnSkip.isHidden = true
                btnCenterLetsGo.isHidden = false
                avPlayer.play()
            } else {
                videoVW.isHidden = true
                nextBtn.setTitle("NEXT", for: .normal)
                nextBtn.isHidden = false
                pageControl3.isHidden = false
                btnSkip.isHidden = false
                btnCenterLetsGo.isHidden = true
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // view.addSubview(nextBtn)
        heightOfPageControl.constant = 0
        btnCenterLetsGo.isHidden = true
        print(currentPage)
        slides = [
            OnboardingSlide(title: "Unlimited Calling on VueTel", description: "Enjoy Unlimited Voice, Video calling with instant Messaging.", image: #imageLiteral(resourceName: "user_experiance"), Video: ""),
            OnboardingSlide(title: "Voicemail, Call recording and more!", description: "Never worry about missing a call or unable to capture a phone conversation.", image: #imageLiteral(resourceName: "voice_mail"), Video: ""),
            OnboardingSlide(title: "Add Funds", description: "Enjoy Local & International calls by reloading your Balance with Vuetel Coupon", image: #imageLiteral(resourceName: "recharge"), Video: ""),
            OnboardingSlide(title: "Add Funds", description: "Enjoy Local & International calls by reloading your Balance with Vuetel Coupon", image: #imageLiteral(resourceName: "recharge"), Video: ""),


        ]
        pageControl.numberOfPages = slides.count
        pageControl3.drawer = ExtendedDotDrawer(numberOfPages: 4,
                                                space: 16.0,
                                                indicatorColor: #colorLiteral(red: 0.3816709816, green: 0.5210908055, blue: 0.7934839129, alpha: 1),
                                                dotsColor: #colorLiteral(red: 0.8206127286, green: 0.8203557134, blue: 0.8394408822, alpha: 1),
                                                isBordered: false,
                                                borderWidth: 0.0,
                                                indicatorBorderColor: .clear,
                                                indicatorBorderWidth: 0.0)
        
        playVideo()
    }
    

    override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
        if currentPage == slides.count {
            avPlayer.play()
        }
     }
     
     override func viewDidDisappear(_ animated: Bool) {
         super.viewDidDisappear(animated)
         if currentPage == slides.count {
             avPlayer.pause()
         }
     }
    
    
    func playVideo() {
        let theURL = Bundle.main.url(forResource: "vuetel_logo_animation", withExtension: "mp4")
        avPlayer = AVPlayer(url: theURL!)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = .resizeAspectFill
        avPlayer.volume = 0
        avPlayer.actionAtItemEnd = .none
        
        avPlayerLayer.frame = view.layer.bounds
        videoVW.backgroundColor = .clear
        videoVW.layer.insertSublayer(avPlayerLayer, at: 0)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer.currentItem)
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
            let p: AVPlayerItem = notification.object as! AVPlayerItem
            p.seek(to: .zero)
        }
    
    
    @IBAction func nextBtnClicked(_ sender: Any) {
        if currentPage == slides.count - 1 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier:"ipjsuaLoginVc") as! ipjsuaLoginVc
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .flipHorizontal
            navigationController?.pushViewController(controller, animated: true)
        } else {
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    @IBAction func btnCenterLetsGO(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier:"ipjsuaLoginVc") as! ipjsuaLoginVc
        controller.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
    
    @IBAction func btnSkip(_ sender: UIButton) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let controller = storyboard.instantiateViewController(withIdentifier:"ipjsuaLoginVc") as! ipjsuaLoginVc
//        controller.modalPresentationStyle = .fullScreen
//        controller.modalTransitionStyle = .flipHorizontal
//        navigationController?.pushViewController(controller, animated: true)
        
        videoVW.isHidden = false
        nextBtn.setTitle("LET'S GO", for: .normal)
        nextBtn.isHidden = true
        pageControl3.isHidden = true
        btnSkip.isHidden = true
        btnCenterLetsGo.isHidden = false
        avPlayer.play()
        
        //present(controller, animated: true, completion: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.identifier, for: indexPath) as! OnboardingCollectionViewCell
        cell.setup(slides[indexPath.row])
//        if slides[indexPath.row].image == UIImage(named: "voizcall_logo") {
//            cell.slideTitleLbl.text = ""
//        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
        let indexPath = IndexPath(item: currentPage, section: 0)
        print(indexPath)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSet = scrollView.contentOffset.x
        let width = scrollView.frame.width
        pageControl3.setPageOffset(offSet / width)
    }
}

