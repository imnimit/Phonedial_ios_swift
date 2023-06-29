/*
 * Copyright (C) 2012-2012 Teluu Inc. (http://www.teluu.com)
 * Contributed by Emre Tufekci (github.com/emretufekci)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

import UIKit



func topMostController() -> UIViewController {
    var topController: UIViewController = (UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController!)!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
    }


    func incoming_call_swift() {
        DispatchQueue.main.async () {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "viewController")
            let topVC = topMostController()
            let vcToPresent = vc.storyboard!.instantiateViewController(withIdentifier: "incomingCallVC") as! IncomingViewController
            vcToPresent.incomingCallId = CPPWrapper().incomingCallInfoWrapper()
            topVC.present(vcToPresent, animated: true, completion: nil)
        }
    }


    func call_status_listener_swift ( call_answer_code: Int32) {
        if (call_answer_code == 0){
                    DispatchQueue.main.async () {
                        UIApplication.shared.windows.first { $0.isKeyWindow}?.rootViewController?.dismiss(animated: true, completion: nil)
                    }
        }
        else if (call_answer_code == 1) {
                    DispatchQueue.main.async () {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "viewController")
                        let topVC = topMostController()
                        let vcToPresent = vc.storyboard!.instantiateViewController(withIdentifier: "activeCallVC") as! ActiveViewController
                        vcToPresent.activeCallId = CPPWrapper().incomingCallInfoWrapper()
                        topVC.present(vcToPresent, animated: true, completion: nil)
                    }
                }
        else {
                print("ERROR CODE:")
            }
        }
   

    func displayPreviewWindow(  call_answer_code: Int32, _vid_dev_index: pjmedia_vid_dev_index, Int32 : pj_bool_t , call_id: pjsua_call_id) {
        print("Value of static is \(call_answer_code)")
//        pjsua_vid_preview_param param;
//        pjsua_vid_preview_param_default(&param);
//        let param = pjsua_vid_preview_param()
//        pjsua_vid_preview_param_default(UnsafeMutablePointer<param>!)
        
//        param.wnd_flags = PJMEDIA_VID_DEV_WND_BORDER | PJMEDIA_VID_DEV_WND_RESIZABLE;
//
//        pjsua_vid_preview_start(_vid_dev_index,&param);
//
//        pjmedia_rect_size size;
//        size.h = 90;
//        size.w = 75;
//        pjmedia_coord pos;
//        pos.x = 10;
//        pos.y = 10;
//        pjsua_vid_win_id win_id;
//        win_id = pjsua_vid_preview_get_win(_vid_dev_index);
//        dispatch_async(dispatch_get_main_queue(), ^{pjsua_vid_win_set_size(win_id, &size); pjsua_vid_win_set_pos(win_id, &pos);});
//        displayWindow(win_id,isPreview,call_id);
    }
    func displayReceiverWindow() {
        print("Controller comes here")
    }

func checkwindowShow(id: UIView) {
    
}

