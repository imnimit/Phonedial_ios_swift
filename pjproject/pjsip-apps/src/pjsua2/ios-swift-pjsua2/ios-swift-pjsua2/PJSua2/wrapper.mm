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
#import "pjsua.h"

#import <pjlib.h>
#import <pjsua.h>
#import <pj/log.h>
#include <pjsua-lib/pjsua.h>
#include <pjsua-lib/pjsua_internal.h>
#include <pj/types.h>
#include <pj/compat/string.h>

#include "/Users/magictech/Desktop/pjproject/pjsip-apps/src/pjsua/pjsua_app.h"
#include "/Users/magictech/Desktop/pjproject/pjsip-apps/src/pjsua/pjsua_app_config.h"


#define THIS_FILE    "ipjsuaAppDelegate.m"

#import <UIKit/UIKit.h>

pjsua_call_id currentCallID;

static pjsua_app_cfg_t  app_cfg;
static int              restartArgc;
static char           **restartArgv;
static bool             isShuttingDown;

/**
 Create a object from .hpp class & wrapper to be able to use it via Swift
 */
@implementation CPPWrapper
PJSua2 pjsua2;
//pjsua_call_id        current_call = PJSUA_INVALID_ID;


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
    
    currentCallID = PJSUA_INVALID_ID;
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

+(void)pjsuaDataClare{
    pjsua2.clareData();
}


/**
 Hold the call
 */
- (void) holdCallWrapper:(int) idCall {
    pjsua2.holdCall(idCall);
    
//    if (current_call != PJSUA_INVALID_ID) {
//        pjsua_call_set_hold(current_call, NULL);
//
//    } else {
//        PJ_LOG(3,(THIS_FILE, "No current call"));
//    }
}

/**
 unhold the call
 */
- (void) unholdCallWrapper:(int) idCall {
    pjsua2.unholdCall(idCall);
    
//    if (current_call != PJSUA_INVALID_ID) {
//        /*
//         * re-INVITE
//         */
//        call_opt.flag |= PJSUA_CALL_UNHOLD;
//        pjsua_call_reinvite2(current_call, &call_opt, NULL);
//
//    } else {
//        PJ_LOG(3,(THIS_FILE, "No current call"));
//    }
}


/**
 Make outgoing call (string dest_uri) -> e.g. makeCall(sip:<SIP_USERNAME@SIP_IP:SIP_PORT>)
 */
-(void) outgoingCallWrapper :(NSString*) dest_uriNS
{
    std::string dest_uri = std::string([[dest_uriNS componentsSeparatedByString:@"*"][0] UTF8String]);
    pjsua2.outgoingCall(dest_uri);
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    
}


-(void) callmute {
    pjsua_conf_adjust_rx_level(0 /* pjsua_conf_port_id slot*/, 0.0f);
}

-(void) callunmute {
    pjsua_conf_adjust_rx_level(0 /* pjsua_conf_port_id slot*/, 1.0f);
}

+(NSString *)callNumber {
    NSString *strPath = [NSString stringWithFormat:@"%s", pjsua2.allnumberGet().c_str()];
    return  strPath;
}
+(NSString *)startRecording:(int)callid userfilename:(NSString
                                                      *)filename
{
    pjsua_recorder_id recorder_id;
    
    pj_status_t status;
    
    NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    NSString *strPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,filename];
    //    NSLog(@"File Path->%@",strPath);
    pj_str_t fileName = pj_str((char *)[strPath UTF8String]);
    //    pj_str_t fileName = pj_str(index([strPath UTF8String], strPath.length));
    status = pjsua_recorder_create(&fileName, 0, NULL, -1, 0, &recorder_id);
    NSLog(@"status issss-->%d",status);
    
    [[NSUserDefaults standardUserDefaults] setInteger:recorder_id forKey:@"recording_id"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    pjsua_call_info call_info;
    
    NSLog(@"recordder id id--->%d",recorder_id);
    NSLog(@"recording is for start recording is--->%d",app_config.rec_id);
    
    //status = pjsua_recorder_create(&fileName, 0, NULL, -1, 0, &app_config.rec_id);
    //    isRecordingStarted = 1;
    if (status != PJ_SUCCESS)
    {
        pjsua_perror(THIS_FILE, "error dll_startAudioCapture from pjsua_recorder_create", status);
    }
    else
    {
        //        app_config.rec_port = pjsua_recorder_get_conf_port(app_config.rec_id);
        
        app_config.rec_port = pjsua_recorder_get_conf_port(recorder_id);
        PJ_LOG(5, (THIS_FILE, "dll_startAudioCapture recId=%d confPort=%d", app_config.rec_id, app_config.rec_port));
        /* connect sound port to recorder port */
        status = pjmedia_conf_connect_port(pjsua_var.mconf, 0, app_config.rec_port, 0);
        if (status != PJ_SUCCESS)
        {
            pjsua_perror(THIS_FILE, "error dll_startAudioCapture edia_conf_connect_port snd->recport", status);
        }
        /* connect caller's port to recorder port */
        pjsua_call_get_info(0, &call_info); //callid
        status = pjmedia_conf_connect_port(pjsua_var.mconf, call_info.conf_slot, app_config.rec_port, 0);
        if (status != PJ_SUCCESS)
        {
            //                pjsua_perror(THIS_FILE, @"error dll_startAudioCapture pjmedia_conf_connect_port caller->recport", status);
        }
        //boost callTaker's and caller audio levels as configured
        if ((status = pjmedia_conf_adjust_rx_level(pjsua_var.mconf, pjsua_var.recorder[app_config.rec_id].slot,0)) == PJ_SUCCESS)
        {
            //                PJ_LOG(5, (THIS_FILE, "dll_startAudioCapture pjmedia_conf_adjust_rx_level by %d", g_audCapClientBoost));
        }
        else
        {
            pjsua_perror(THIS_FILE, "Error dll_startAudioCapture pjmedia_conf_adjust_rx_level", status);
        }
        if ((status = pjmedia_conf_adjust_tx_level(pjsua_var.mconf,pjsua_var.recorder[app_config.rec_id].slot,0)) == PJ_SUCCESS)
        {
            //                PJ_LOG(5, (THIS_FILE, "dll_startAudioCapture pjmedia_conf_adjust_tx_level by %d", g_audCapServerBoost));
        }
        else
        {
            pjsua_perror(THIS_FILE, "Error dll_startAudioCapture pjmedia_conf_adjust_tx_level", status);
        }
    }
    
    NSLog(@"str path is====>%@",strPath);
    return strPath;
}

-(bool) checkCallConnected {
    return pjsua2.checkCallPickup();
}

-(bool) chekCallPickupOrNot {
    return pjsua2.callPickup();
}

-(bool) checkCallEnd {
    return pjsua2.callEnd();
}

+(void)stopRecording:(int)callid
{
    //    pjsua_call_info call_info;
    //    pjsua_call_get_info(callid, &call_info);
    
    NSInteger int_recording_id = [[NSUserDefaults standardUserDefaults] integerForKey:@"recording_id"];
    
    pjsua_recorder_id recorder_id = int_recording_id;
    
    //    if(recorder_id != 0)
    //    {
    
    pj_status_t status = pjsua_recorder_destroy(recorder_id);
    NSLog(@"sttaus iiisss ----> %d",status);
    NSLog(@"recording id is---->%d",recorder_id);
    //    isRecordingStarted = 0;
    
    
    //  }
}
+(void)passCallHangOut:(int)number {
    pjsua2.pertiqulerhangupCall(number);
}

+(void)clareAllData {
    pjsua2.clareData();
}



+(void)call_transfer:(BOOL)no_refersub :(const char*)call_transferNumber // Unattented
{
    
    pjsua2.callTrasfer(call_transferNumber);
//
//    current_call = 0;
//    if (current_call == -1) {
//        PJ_LOG(3,(THIS_FILE, "No current call"));
//    } else {
//        int call = current_call;
//        pjsip_generic_string_hdr refer_sub;
//        pj_str_t STR_REFER_SUB = { "Refer-Sub", 9 };
//        pj_str_t STR_FALSE = { "false", 5 };
//        pjsua_call_info ci;
//        pjsua_msg_data msg_data_;
//
//        pjsua_call_get_info(current_call, &ci);
//        printf("Transferring current call [%d] %.*s\n", current_call,
//               (int)ci.remote_info.slen, ci.remote_info.ptr);
//
//        pj_str_t transferNumber = (pj_str(strdup(call_transferNumber)));
//
//        /* Check if call is still there. */
//
//        if (call != current_call) {
//            puts("Call has been disconnected");
//            return;
//        }
//
//        pjsua_msg_data_init(&msg_data_);
//        if (no_refersub) {
//            /* Add Refer-Sub: false in outgoing REFER request */
//            pjsip_generic_string_hdr_init2(&refer_sub, &STR_REFER_SUB,
//                                           &STR_FALSE);
//            pj_list_push_back(&msg_data_.hdr_list, &refer_sub);
//        }
//        pjsua_call_xfer( current_call, &transferNumber, &msg_data_);
//    }
}


+(void)call_transfer_replaces:(BOOL)no_refersub // attented
{
    printf("call_transfer_replaces");
    if (current_call == -1) {
        PJ_LOG(3,(THIS_FILE, "No current call"));
    } else {
        int call = current_call;
        int dst_call;
        pjsip_generic_string_hdr refer_sub;
        pj_str_t STR_REFER_SUB = { "Refer-Sub", 9 };
        pj_str_t STR_FALSE = { "false", 5 };
        pjsua_call_id ids[PJSUA_MAX_CALLS];
        pjsua_call_info ci;
        pjsua_msg_data msg_data_;
        unsigned i, count;
        pjsua_call_id trasferId = -1;
        
        count = PJ_ARRAY_SIZE(ids);
        pjsua_enum_calls(ids, &count);
        
        if (count <= 1) {
            puts("There are no other calls");
            return;
        }
        pjsua_call_get_info(current_call, &ci);
        printf("Transfer call [%d] %.*s to one of the following:\n",
               current_call,
               (int)ci.remote_info.slen, ci.remote_info.ptr);
        for (i=0; i<count; ++i) {
            pjsua_call_info call_info;
            
            if (ids[i] == call)
                continue;
            
            pjsua_call_get_info(ids[i], &call_info);
            printf("%d  %.*s [%.*s]\n",
                   ids[i],
                   (int)call_info.remote_info.slen,
                   call_info.remote_info.ptr,
                   (int)call_info.state_text.slen,
                   call_info.state_text.ptr);
            trasferId = ids[i];
        }
        
        if(trasferId > -1)
            dst_call = trasferId;
        else
            return;
        
        /* Check if call is still there. */
        
        if (call != current_call) {
            puts("Call has been disconnected");
            return;
        }
        /* Check that destination call is valid. */
        if (dst_call == call) {
            puts("Destination call number must not be the same "
                 "as the call being transferred");
            return;
        }
        if (dst_call >= PJSUA_MAX_CALLS) {
            puts("Invalid destination call number");
            return;
        }
        if (!pjsua_call_is_active(dst_call)) {
            puts("Invalid destination call number");
            return;
        }
        pjsua_msg_data_init(&msg_data_);
        if (no_refersub) {
            /* Add Refer-Sub: false in outgoing REFER request */
            pjsip_generic_string_hdr_init2(&refer_sub, &STR_REFER_SUB,
                                           &STR_FALSE);
            pj_list_push_back(&msg_data_.hdr_list, &refer_sub);
        }
        pj_status_t staus = pjsua_call_xfer_replaces(call, dst_call,
                                                     PJSUA_XFER_NO_REQUIRE_REPLACES,
                                                     &msg_data_);
        printf("calltransfer status%d\n",staus);
    }
}

+(void)connectMedia {
    pjsua2.pjmedia();
}

+(void)addConfrenceAttendee:(NSString*)contactNum{
    
    pjsua2.holdCall(0);
    
    sleep(2);
    char *destUri = (char*)[ contactNum  UTF8String];
    pjsua2.outgoingCall1(destUri);
    
//    pj_status_t status;
//    pj_str_t uri = pj_str(destUri);
//    status = pjsua_call_make_call(current_acc, &uri, 0, NULL, NULL, NULL);
//    pjsua_call_setting_default(&call_opt);
    
    //    printf(" making call Status is %d",status);
    
    NSLog(@"make call executed");
}

+(void)showCodecs{
    pjsua_codec_info c[32];
    unsigned i, count = PJ_ARRAY_SIZE(c);
    
    printf("List of audio codecs:\n");
    pjsua_enum_codecs(c, &count);
    for (i=0; i<count; ++i) {
        printf("  %d\t%.*s\n", c[i].priority, (int)c[i].codec_id.slen,
               c[i].codec_id.ptr);
    }
    printf("List of video codecs:\n");
    pjsua_vid_enum_codecs(c, &count);
    for (i=0; i<count; ++i) {
        printf("  %d\t%.*s%s%.*s\n", c[i].priority,
               (int)c[i].codec_id.slen,
               c[i].codec_id.ptr,
               c[i].desc.slen? " - ":"",
               (int)c[i].desc.slen,
               c[i].desc.ptr);
    }
}

+(void)makeCall:(NSString *)callee{
    static pj_thread_desc a_thread_descrip;
    static pj_thread_t *a_thread;
    
    if (!pj_thread_is_registered()) {
        pj_bzero(a_thread_descrip, PJ_ARRAY_SIZE(a_thread_descrip));
        NSLog(@"registering thread using pjsip....%d\n",pj_thread_is_registered());
        NSLog(@"registering thread using pjsip....%d\n",!pj_thread_is_registered());
        
        pj_thread_register("ipjsua",a_thread_descrip,&a_thread);
    }
    
    printf("\n%s Callename make call ipsua \n",callee);
    
    pj_str_t tmp = pj_str((char *)[callee UTF8String]);
    pjsua_msg_data msg_data_;
    pj_status_t status;
    
    // Update call setting /
    pjsua_call_setting_default(&call_opt);
    call_opt.aud_cnt = app_config.aud_cnt;
    call_opt.vid_cnt = app_config.vid.vid_cnt;
    
    printf("\n%s %d Callename making call\n",tmp.ptr,current_acc);
    pjsua_msg_data_init(&msg_data_);
    TEST_MULTIPART(&msg_data_);
    //status=pjsua_call_make_call(current_acc, &tmp, &call_opt, NULL,
    //             &msg_data_, &current_call);
    status=pjsua_call_make_call(current_acc, &tmp, &call_opt, NULL,
                                NULL, NULL/*&current_call*/);
    printf(" making call Status is %d",status);
    NSLog(@"make call executed");
    
}

+(void)send_dtmf:(NSString *)digit{
    current_call = 0;
    if (current_call == -1) {
        PJ_LOG(3,(THIS_FILE, "No current call"));
    } else if (!pjsua_call_has_media(current_call)) {
        PJ_LOG(3,(THIS_FILE, "Media is not established yet!"));
    } else {
        pj_str_t digits;
        digits = pj_str((char *)[ digit  UTF8String]);
        pjsua_call_dial_dtmf(current_call, &digits);
    }
}





+ (void)pjsuaStart
{
    
    // TODO: read from config?
    const char **argv = pjsua_app_def_argv;
    int argc = PJ_ARRAY_SIZE(pjsua_app_def_argv) -1;
    pj_status_t status;
    
    isShuttingDown = false;
//    displayMsg("Starting..");
    
    pj_bzero(&app_cfg, sizeof(app_cfg));
    if (restartArgc) {
        app_cfg.argc = restartArgc;
        app_cfg.argv = restartArgv;
    } else {
        app_cfg.argc = argc;
        app_cfg.argv = (char**)argv;
    }
    app_cfg.on_started = &pjsuaOnStartedCb;
    app_cfg.on_stopped = &pjsuaOnStoppedCb;
    app_cfg.on_config_init = &pjsuaOnAppConfigCb;
    
    while (!isShuttingDown) {
        status = pjsua_app_init(&app_cfg);
        if (status != PJ_SUCCESS) {
            char errmsg[PJ_ERR_MSG_SIZE];
            pj_strerror(status, errmsg, sizeof(errmsg));
//            displayMsg(errmsg);
            pjsua_app_destroy();
            return;
        }
        
//        /* Setup device orientation change notification */
//        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//        [[NSNotificationCenter defaultCenter] addObserver:app
//                                                 selector:@selector(orientationChanged:)
//                                                     name:UIDeviceOrientationDidChangeNotification
//                                                   object:[UIDevice currentDevice]];
        
        status = pjsua_app_run(PJ_TRUE);
        if (status != PJ_SUCCESS) {
            char errmsg[PJ_ERR_MSG_SIZE];
            pj_strerror(status, errmsg, sizeof(errmsg));
//            displayMsg(errmsg);
        }
        
//        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
        
        pjsua_app_destroy();
    }
    
    restartArgv = NULL;
    restartArgc = 0;
}

static void pjsuaOnStartedCb(pj_status_t status, const char* msg)
{
    char errmsg[PJ_ERR_MSG_SIZE];
    
    if (status != PJ_SUCCESS && (!msg || !*msg)) {
        pj_strerror(status, errmsg, sizeof(errmsg));
        PJ_LOG(3,(THIS_FILE, "Error: %s", errmsg));
        msg = errmsg;
    } else {
        PJ_LOG(3,(THIS_FILE, "Started: %s", msg));
    }
    
//    displayMsg(msg);
}

static void pjsuaOnStoppedCb(pj_bool_t restart,
                             int argc, char** argv)
{
    PJ_LOG(3,("ipjsua", "CLI %s request", (restart? "restart" : "shutdown")));
    if (restart) {
//        displayMsg("Restarting..");
        pj_thread_sleep(100);
        app_cfg.argc = argc;
        app_cfg.argv = argv;
    } else {
//        displayMsg("Shutting down..");
        pj_thread_sleep(100);
        isShuttingDown = true;
    }
}

static void pjsuaOnAppConfigCb(pjsua_app_config *cfg)
{
    PJ_UNUSED_ARG(cfg);
}


@end

