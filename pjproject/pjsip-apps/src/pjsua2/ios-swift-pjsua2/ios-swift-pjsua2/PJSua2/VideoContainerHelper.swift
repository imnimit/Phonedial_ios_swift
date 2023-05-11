//
//  VideoContainerHelper.swift
//  ipjsua
//
//  Created by Nandhakumar on 17/06/19.
//  Copyright © 2019 Teluu. All rights reserved.
//

import Foundation
import AudioToolbox
import AVFoundation

@objc class VideoContainerHelper: NSObject, AVAudioPlayerDelegate{
    @objc static let shared = VideoContainerHelper()
    private var remoteVideoView: UIView?
    private var ownVideoPreview: UIView?
    private var window: UIWindow?
    private var smallScreenButton: UIButton?
    
    private var swapCamButton: UIButton?
    private var endCallButton: UIButton?
    private var videoOnOffButton: UIButton?
    private var muteButton: UIButton?
    private var speakerButton: UIButton?

    private var isCallMute: Bool = false
    private var isSpeakerOn: Bool = false
    
    public var FullScreen: CGRect! = nil

    private var remoteview:UIView?
    private var remoteVideoFullScreen: CGRect! = nil
    private var remoteVideoSmallScreen: CGRect! = nil
    private var ownVideoFullScreen: CGRect! = nil
    private let ownVideoSmallScreen: CGRect!
    private var isFullScreen: Bool = true
    private var isVideoOn: Bool = true
    @objc var newSize: ((CGSize)->Void)?
    @objc var videoContainerHelperHandler:((Int)->Void)?
    @objc var videoContainerAddedHandle: ((UIView)->Void)?
    @objc var videoContainerIsFullScreenHandle: ((Bool)->Void)?
    //let screenSize: CGRect = UIScreen.main.bounds

    private override init() {
        FullScreen = CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height)-10)
        remoteVideoFullScreen = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height)-20)
        remoteVideoSmallScreen = CGRect(x: 0, y:20, width: UIScreen.main.bounds.width*0.4, height: (UIScreen.main.bounds.width*0.4)*1.2)
        ownVideoFullScreen = CGRect(x: 30, y: 30, width: remoteVideoFullScreen.size.width*0.4, height: (remoteVideoFullScreen.size.width*0.4)*1.2 )
        ownVideoSmallScreen = CGRect(x: 0, y: 20, width: remoteVideoSmallScreen.size.width*0.4, height:(remoteVideoSmallScreen.size.width*0.4)*1.2)
    }
    
/*
    @objc func flipPreviewViewView() {
        self.ownVideoPreview?.transform = CGAffineTransform(translationX: 0.8, y: 0.8)
        UIView.transition(with: self.ownVideoPreview!, duration: 0.5, options: [.transitionFlipFromLeft], animations: {
                self.ownVideoPreview?.transform = CGAffineTransform(translationX: 1, y: 1)
                print("Flipping")
        }) { (fin) in
            print("Flipped")
        }
    }

    private func updateVideoViewFrame(complition:(()->Void)?) {
        let remoteViewFrame = remoteVideoFullScreen
        let ownViewFrame = ownVideoFullScreen
        UIView.animate(withDuration: 0.3, animations: {
            self.remoteVideoView?.frame = remoteViewFrame!
            self.ownVideoPreview?.frame = ownViewFrame!
        }) { (finished) in
            complition!()
        }
    }
*/
    @objc func getFullScreen()->CGRect{
     return FullScreen
    }
    
    @objc func displayRemoteVideo(_ remoteVideo: UIView) {
        print("displayRemoteVideo \(remoteVideoFullScreen.size.width) \n")
        print("displayRemoteVideo \(remoteVideoFullScreen.size.height) \n")
        self.window = UIApplication.shared.windows.first;
        //remoteVideo.frame = remoteVideoFullScreen
        //let archive = NSKeyedArchiver.archivedData(withRootObject: remoteVideo)
        //remoteVideoView = NSKeyedUnarchiver.unarchiveObject(with: archive) as? UIView

        remoteVideoView = remoteVideo
        //remoteVideoView?.sizeToFit()
        
        remoteVideoView?.bounds = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height)-20)
        remoteVideoView?.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height)-20)
        self.window?.addSubview(remoteVideoView!)
        addButtonsForCalls(remoteVideoView!)

        //addRemoteVideo()
        //addTapGestureOnRemoteVideoView()
        //tapAction()
        //addButtonForSmallScreenAction()
        //addPanGestureOnRemoteVideoPreview()
        //videoContainerAddedHandle?(remoteVideo)
    }
    
    @objc func displayOwnVideoPreview(_ preview: UIView) {
        ownVideoPreview = preview
        addOwnVideoPreview()
        addPanGestureOnOwnVideoPreview()
    }
    
    private func addRemoteVideo() {
        //remoteVideoView?.frame = CGRect(x: 0, y: 10, width: remoteVideoFullScreen.size.width, height: remoteVideoFullScreen.size.height - 10)
        remoteVideoView?.frame = remoteVideoFullScreen
        self.window?.addSubview(remoteVideoView!)
        
    }
    
    private func addOwnVideoPreview() {
        ownVideoPreview?.frame = CGRect(x: 30, y: 30, width: remoteVideoFullScreen.size.width*0.4, height:(remoteVideoFullScreen.size.width*0.4)*1.2 )
        ownVideoPreview?.layer.masksToBounds = true
        ownVideoPreview?.layer.cornerRadius = 5.0
        self.remoteVideoView?.addSubview(ownVideoPreview!)
        //let size = self.ownVideoFullScreen?.size
        //self.newSize?(size!)
    }
    
    private func addPanGestureOnRemoteVideoPreview() {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action:
            #selector(handlePan))
        remoteVideoView?.addGestureRecognizer(gestureRecognizer)
    }
    
    private func addPanGestureOnOwnVideoPreview(){
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        ownVideoPreview?.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer){
        let translation = gestureRecognizer.translation(in: window!)
        dragOnPanGesture(gestureRecognizer, translation)
    }
    
    private func dragOnPanGesture(_ gestureRecognizer: UIPanGestureRecognizer,
                                  _ translation: CGPoint) {
        if !isFullScreen { if gestureRecognizer.view == ownVideoPreview{ return }}
        if isFullScreen { if gestureRecognizer.view == remoteVideoView{ return }}
        
        let yPosition = gestureRecognizer.view!.center.y + translation.y
        let xPosition = gestureRecognizer.view!.center.x + translation.x
        
        gestureRecognizer.view!.center.x=xPosition
        gestureRecognizer.view!.center.y=yPosition
        gestureRecognizer.setTranslation(CGPoint.zero, in: window!)
    }
    
    func addButtonsForCalls(_ remoteVideo: UIView) {
        swapCamButton = UIButton(frame: CGRect(x:(remoteVideo.center.x)+(((remoteVideo.center.x)/3)*2),y:remoteVideo.bounds.size.height-70,width:30,height: 30))
        //swapCamButton?.setImage(UIImage(named: "Swap"), for: .normal)
        swapCamButton?.setTitle("S", for: .normal)
        swapCamButton?.alpha = 0.5
        swapCamButton?.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        swapCamButton?.layer.cornerRadius = 15
        swapCamButton?.layer.masksToBounds = true
        swapCamButton?.setTitleColor(UIColor.red, for: .normal)
        swapCamButton?.addTarget(self, action: #selector(swapOwnCameraAction), for: .touchUpInside)
        remoteVideo.addSubview(swapCamButton!)
        
        speakerButton = UIButton(frame: CGRect(x:(remoteVideo.center.x)+((remoteVideo.center.x)/3),y:remoteVideo.bounds.height-70,width:30,height: 30))
        //speakerButton?.setImage(UIImage(named: "video"), for: .normal)
        speakerButton?.setTitle("L", for: .normal)
        speakerButton?.alpha = 0.5
        speakerButton?.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        speakerButton?.layer.cornerRadius = 15
        speakerButton?.layer.masksToBounds = true
        speakerButton?.setTitleColor(UIColor.red, for: .normal)
        speakerButton?.addTarget(self, action: #selector(speakerButtonAction), for: .touchUpInside)
        remoteVideo.addSubview(speakerButton!)
        
        endCallButton = UIButton(frame: CGRect(x:(remoteVideo.center.x),y:remoteVideo.bounds.size.height-70,width:30,height: 30))
        //endCallButton?.setImage(UIImage(named: "End"), for: .normal)
        endCallButton?.setTitle("X", for: .normal)
        endCallButton?.alpha = 0.5
        endCallButton?.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        endCallButton?.layer.cornerRadius = 15
        endCallButton?.layer.masksToBounds = true
        endCallButton?.setTitleColor(UIColor.red, for: .normal)
        endCallButton?.addTarget(self, action: #selector(endCallAction), for: .touchUpInside)
        remoteVideo.addSubview(endCallButton!)
        
        videoOnOffButton = UIButton(frame: CGRect(x:((remoteVideo.center.x)/3)*2,y:remoteVideo.bounds.height-70,width:30,height: 30))
        //videoOnOffButton?.setImage(UIImage(named: "video"), for: .normal)
        videoOnOffButton?.setTitle("V", for: .normal)
        videoOnOffButton?.alpha = 0.5
        videoOnOffButton?.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        videoOnOffButton?.layer.cornerRadius = 15
        videoOnOffButton?.layer.masksToBounds = true
        videoOnOffButton?.setTitleColor(UIColor.red, for: .normal)
        videoOnOffButton?.addTarget(self, action: #selector(videoOnOffAction), for: .touchUpInside)
        remoteVideo.addSubview(videoOnOffButton!)
        
        muteButton = UIButton(frame: CGRect(x:(remoteVideo.center.x)/3,y:remoteVideo.bounds.height-70,width:30,height: 30))
        //muteButton?.setImage(UIImage(named: "video"), for: .normal)
        muteButton?.setTitle("M", for: .normal)
        muteButton?.alpha = 0.5
        muteButton?.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        muteButton?.layer.cornerRadius = 15
        muteButton?.layer.masksToBounds = true
        muteButton?.setTitleColor(UIColor.red, for: .normal)
        muteButton?.addTarget(self, action: #selector(muteButtonAction), for: .touchUpInside)
        remoteVideo.addSubview(muteButton!)
    }
    
    @objc func swapOwnCameraAction() {
     // ipjsuaAppDelegate.swapCamera(); //for camera swap
    }
    
    @objc func endCallAction() {
       // ipjsuaAppDelegate.hangup_Call(); //for end call
    }
    
    @objc func videoOnOffAction(){       //for video on/off
        if(self.isVideoOn){
       //     ipjsuaAppDelegate.disableVideo();
            self.isVideoOn = false;
        }else{
            self.isVideoOn = true;
          //  ipjsuaAppDelegate.enableVideo();
        }
    }
    
    @objc func muteButtonAction(){
        if(!isCallMute){
        //    ipjsuaAppDelegate.mutethecall();
            isCallMute=true;
        }else{
         //   ipjsuaAppDelegate.unmutethecall();
            isCallMute=false;
        }
    }
    
    @objc func speakerButtonAction(){
        if(!isSpeakerOn){
            speakerOn()
            isSpeakerOn = true;
        }else{
            speakerOff()
            isSpeakerOn = false;
        }
    }
    
    func speakerOn() {
        print("speaker on")
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        do{
            try session.setCategory(AVAudioSession.Category.playAndRecord, options: AVAudioSession.CategoryOptions.mixWithOthers)
        }
        catch{ print("audio session error ",error) }
        do{
            try session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        }
        catch
        {
            print("overrideOutputAudioPort",error)
        }
    }
    
    func speakerOff() {
        print("speaker disabled")
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        do{
            try session.setCategory(AVAudioSession.Category.playAndRecord, options: AVAudioSession.CategoryOptions.mixWithOthers)
        }
        catch{ print(error) }
        do{
            try session.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
        }
        catch{ print(error)  }
        
    }
/*
     func addButtonForSmallScreenAction() {
         smallScreenButton = UIButton(frame: CGRect(x:
         (remoteVideoView?.bounds.width)! - 60, y: 20, width: 40, height: 40))
         smallScreenButton?.setImage(UIImage(named: "Exit"), for: .normal)
         smallScreenButton?.alpha = 0.5
         smallScreenButton?.backgroundColor = UIColor.white.withAlphaComponent(0.8)
         smallScreenButton?.layer.cornerRadius = 20
         smallScreenButton?.layer.masksToBounds = true
         smallScreenButton?.setTitleColor(UIColor.red, for: .normal)
         smallScreenButton?.addTarget(self, action:#selector(smallScreenButtonAction), for: .touchUpInside)
         remoteVideoView?.addSubview(smallScreenButton!)
     }
     
     @objc func smallScreenButtonAction() {
         isFullScreen = false
         videoContainerIsFullScreenHandle?(isFullScreen)
         self.smallScreenButton?.isHidden = true
         updateVideoViewFrame {
         let size = self.ownVideoSmallScreen?.size
         self.newSize?(size!)
         }
     }

    private func addTapGestureOnRemoteVideoView() {
        let doubleTap = UITapGestureRecognizer(target: self, action:
            #selector(tapAction))
        doubleTap.numberOfTapsRequired = 1
        remoteVideoView?.addGestureRecognizer(doubleTap)
    }
     
    @objc private func tapAction() {
        videoContainerIsFullScreenHandle?(isFullScreen)
        if !isFullScreen {
            self.isFullScreen = true
            
            updateVideoViewFrame {
                self.smallScreenButton?.isHidden = false
                self.isFullScreen = true
                let size = self.ownVideoFullScreen?.size
                self.newSize?(size!)
            }
        }
    }
     
    func onPanGestureTouchEnd(_ gestureRecognizer: UIPanGestureRecognizer, _ translation: CGPoint) {
        if !isFullScreen { if gestureRecognizer.view == ownVideoPreview{ return }}
        if isFullScreen { if gestureRecognizer.view == remoteVideoView{ return }}
        let yposition = gestureRecognizer.view!.center.y + translation.y
        let xposition = gestureRecognizer.view!.center.x + translation.x
        let y = yposition-yposition-((gestureRecognizer.view?.frame.height)!/2)
        let x = xposition-xposition-((gestureRecognizer.view?.frame.width)!/2)

        if x<0 {
            UIView.animate(withDuration: 0.3) {
                gestureRecognizer.view?.frame.origin.x=0
            }
        } else if
        (x+(gestureRecognizer.view?.frame.width)!)>UIScreen.main.bounds.width {
            UIView.animate(withDuration: 0.3) {
                gestureRecognizer.view?.frame.origin.x = UIScreen.main.bounds.width-(gestureRecognizer.view?.frame.width)!
            }
        }
        
        if y<0 {
            UIView.animate(withDuration: 0.3) {
                gestureRecognizer.view?.frame.origin.y = 0
            }
        }else if
        (y+(gestureRecognizer.view?.frame.height)!)>UIScreen.main.bounds.height {
            UIView.animate(withDuration: 0.3) {
                gestureRecognizer.view?.frame.origin.y = UIScreen.main.bounds.height-(gestureRecognizer.view?.frame.height)!
            }
        }
    }
*/

}

