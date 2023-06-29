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

#import "wrapper.h"
#import "CustomPJSUA2.hpp"

#import <pjlib.h>
#import <pjsua.h>
#import <pj/log.h>

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
/**
 Create a object from .hpp class & wrapper to be able to use it via Swift
 */
@implementation CPPWrapper
PJSua2 pjsua2;



//Lib
/**
 Create Lib with EpConfig
 */
-(void) createLibWrapper
{
    return pjsua2.createLib();
};

/**
 Delete lib
 */
-(void) deleteLibWrapper {
    pjsua2.deleteLib();
}





//Account
/**
 Create Account via following config(string username, string password, string ip, string port)
 */
-(void) createAccountWrapper :(NSString*) usernameNS :(NSString*) passwordNS :(NSString*) ipNS :(NSString*) portNS
{
    std::string username = std::string([[usernameNS componentsSeparatedByString:@"*"][0] UTF8String]);
    std::string password = std::string([[passwordNS componentsSeparatedByString:@"*"][0] UTF8String]);
    std::string ip = std::string([[ipNS componentsSeparatedByString:@"*"][0] UTF8String]);
    std::string port = std::string([[portNS componentsSeparatedByString:@"*"][0] UTF8String]);
    
    pjsua2.createAccount(username, password, ip, port);
}

/**
 Unregister account
 */
-(void) unregisterAccountWrapper {
    return pjsua2.unregisterAccount();
}



//Register State Info
/**
 Get register state true / false
 */
-(bool) registerStateInfoWrapper {
    return pjsua2.registerStateInfo();
}



// Factory method to create NSString from C++ string
/**
 Get caller id for incoming call, checks account currently registered (ai.regIsActive)
 */
- (NSString*) incomingCallInfoWrapper {
    NSString* result = [NSString stringWithUTF8String:pjsua2.incomingCallInfo().c_str()];
    return result;
}

/**
 Listener (When we have incoming call, this function pointer will notify swift.)
 */
- (void)incoming_call_wrapper: (void(*)())function {
    pjsua2.incoming_call(function);
}

/**
 Listener (When we have changes on the call state, this function pointer will notify swift.)
 */
- (void)call_listener_wrapper: (void(*)(int))function {
    pjsua2.call_listener(function);
}

/**
 Answer incoming call
 */
- (void) answerCallWrapper {
    pjsua2.answerCall();
}

/**
 Hangup active call (Incoming/Outgoing/Active)
 */
- (void) hangupCallWrapper {
    pjsua2.hangupCall();
}
-(void)showAllCodecList{
    pjsua2.codecList();
}
/**
 Hold the call
 */
- (void) holdCallWrapper{
    pjsua2.holdCall();
}

/**
 unhold the call
 */
- (void) unholdCallWrapper{
    pjsua2.unholdCall();
}

/**
 Make outgoing call (string dest_uri) -> e.g. makeCall(sip:<SIP_USERNAME@SIP_IP:SIP_PORT>)
 */
-(void) outgoingCallWrapper :(NSString*) dest_uriNS
{
    std::string dest_uri = std::string([[dest_uriNS componentsSeparatedByString:@"*"][0] UTF8String]);
    pjsua2.outgoingCall(dest_uri);
}


pj_bool_t showNotification(pjsua_call_id call_id,pj_str_t fromVal)
{
    // Create a new notification
    NSString* num=[NSString stringWithFormat:@"%s",fromVal];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"MissedCall" message:num preferredStyle:UIAlertControllerStyleAlert];
    
    //We add buttons to the alert controller by creating UIAlertActions:
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    //You can use a block here to handle a press on this button
    [alertController addAction:actionOk];
   // [app.viewController presentViewController:alertController animated:YES completion:nil];
    
    pjsua_call_hangup(pjsua2.registerStateInfo(), 486, NULL, NULL);
    return PJ_FALSE;
}

void displayPreviewWindow(pjmedia_vid_dev_index _vid_dev_index, pj_bool_t isPreview, pjsua_call_id call_id){
    NSLog(@"displayPreviewWindow called!\n");
    pjsua_vid_preview_param param;
    pjsua_vid_preview_param_default(&param);
    
    param.wnd_flags = PJMEDIA_VID_DEV_WND_BORDER | PJMEDIA_VID_DEV_WND_RESIZABLE;
    
    pjsua_vid_preview_start(_vid_dev_index,&param);
    
    pjmedia_rect_size size;
    size.h = 90;
    size.w = 75;
    pjmedia_coord pos;
    pos.x = 10;
    pos.y = 10;
    pjsua_vid_win_id win_id;
    win_id = pjsua_vid_preview_get_win(_vid_dev_index);
    dispatch_async(dispatch_get_main_queue(), ^{pjsua_vid_win_set_size(win_id, &size); pjsua_vid_win_set_pos(win_id, &pos);});
    displayWindow(win_id,isPreview,call_id);
}

// MARK: - Display window for video call
pj_bool_t displayWindow(pjsua_vid_win_id wid,pj_bool_t isPreview,pjsua_call_id call_id)
{
#if PJSUA_HAS_VIDEO
    NSLog(@"windows id : %d",wid);
    int i, last;

    i = (wid == PJSUA_INVALID_ID) ? 0 : wid;
    last = (wid == PJSUA_INVALID_ID) ? PJSUA_MAX_VID_WINS : wid+1;

    if(!isPreview)
    {
        if(wid == PJSUA_INVALID_ID)
        {
            printf("MyLogger: displayWindow failed\n");
            return PJ_FALSE;
        }else{
            printf("MyLogger: displayWindow success\n");
            pjsua_vid_win_set_show(wid, PJ_TRUE);
        }
    }


    for (;i < last; ++i) {
        pj_status_t  status;
        pjsua_vid_win_info _vid_win_info;
        status = pjsua_vid_win_get_info(i, &_vid_win_info);
        if(status != PJ_SUCCESS)
            NSLog(@"status ====== %d ",status);
        if (status == PJ_SUCCESS) {
            NSLog(@"\nDisplaying Window\n");
            UIView *view = (__bridge UIView *)_vid_win_info.hwnd.info.ios.window;
            if (view) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(isPreview){
                        NSLog(@"Display Preview window isPreview");
                        pjsua_vid_win_id win_id;
                        win_id = wid;
                       // [VideoContainerHelper.shared displayOwnVideoPreview:view];
                        /*[VideoContainerHelper.shared setNewSize:^(CGSize size){
                            pjmedia_rect_size rect_size;
                            rect_size.h = 100;
                            rect_size.w = 100;
                            pjsua_vid_win_set_size(wid, &rect_size);
                            
                        }];*/
                    }else{
                        NSLog(@"\nDisplaying Remote Window \n");
                        /* Add the video window as subview */
                       // [VideoContainerHelper.shared displayRemoteVideo:view];
                    }
                });
            }
        }
      }
    
    return PJ_TRUE;
#endif
}




@end

