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

#include "CustomPJSUA2.hpp"
#include <iostream>
#include <list>


#define current_acc    pjsua_acc_get_default()

using namespace pj;

// Listen swift code via function pointers
void (*incomingCallPtr)() = 0;
void (*callStatusListenerPtr)(int) = 0;

/**
 Dispatch queue to manage ios thread serially or concurrently on app's main thread
 for more information please visit:
 https://developer.apple.com/documentation/dispatch/dispatchqueue
 */
dispatch_queue_t queue;

//Getter & Setter function
std::string callerId;
bool registerState = false;

void setCallerId(std::string callerIdStr){
    callerId = callerIdStr;
}



std::string getCallerId(){
    return callerId;
}

void setRegisterState(bool registerStateBool){
    registerState = registerStateBool;
}

bool getRegisterState(){
    return registerState;
}



//Call object to manage call operations.
Call *call = NULL;



// Subclass to extend the Call and get notifications etc.
class MyCall : public Call
{
public:
    MyCall(Account &acc, int call_id = PJSUA_INVALID_ID) : Call(acc, call_id)
    { }
    ~MyCall()
    { }
    

    
    // Notification when call's state has changed.
    virtual void onCallState(OnCallStateParam &prm){
        CallInfo ci = getInfo();
        if (ci.state == PJSIP_INV_STATE_DISCONNECTED) {
            callStatusListenerPtr(0);
            
            /* Delete the call */
            delete call;
            call = NULL;
        }
        if (ci.state == PJSIP_INV_STATE_CONFIRMED) {
            callStatusListenerPtr(1);
        }
        
        setCallerId(ci.remoteUri);
        
        //Notify caller ID:
        PJSua2 pjsua2;
        pjsua2.incomingCallInfo();
        
    }

    virtual void onCallMediaEvent(OnCallMediaEventParam &prm)
    {
        if (prm.ev.type == PJMEDIA_EVENT_FMT_CHANGED) {
            try {
                VideoPreview preview(prm.medIdx);
                
                MediaSize new_size;
                new_size.w = prm.ev.data.fmtChanged.newWidth;
                new_size.h = prm.ev.data.fmtChanged.newHeight;
                
                // Scale down the size if necessary
                if (new_size.w > 500 || new_size.h > 500) {
                    new_size.w /= 2;
                    new_size.h /= 2;
                }
                //                VideoPreview preview(prm.medIdx);
                // Show and adjust the size of the video window
                CallInfo info = getInfo();
                VideoWindow window = info.media[prm.medIdx].videoWindow;
                window.Show(true);
                window.setSize(new_size);
                pjsua_vid_win_id win_id;
                win_id = pjsua_vid_preview_get_win(info.media[prm.medIdx].videoIncomingWindowId);
               // PJSua2 pjsua2;
             //   pjsua2.StartPreview(1, window.getInfo().winHandle.handle.window , 320, 240, 60);
                
                
                //For Important note about threading
//                MyTimerParam *tp = new MyTimerParam();
//                tp->type = TIMER_START_PREVIEW;
//                tp->data.start_preview.dev_id = 1; // colorbar virtual device
//                tp->data.start_preview.hwnd   = NULL;
//                tp->data.start_preview.w      = 320;
//                tp->data.start_preview.h      = 240;
//                tp->data.start_preview.fps    = 15;
//                Endpoint::instance().utilTimerSchedule(0, tp);
            } catch(Error& err) {
            }
        }
    }
    
    VideoWindow getCallVideoWindow(const Call *call) {
        CallInfo ci = call->getInfo();
        CallMediaInfoVector::iterator it;
        for (it = ci.media.begin(); it != ci.media.end(); ++it) {
        if (it->type == PJMEDIA_TYPE_VIDEO &&
            it->videoIncomingWindowId != PJSUA_INVALID_ID)
        {
            return it->videoWindow;
        }
        }
        return VideoWindow(PJSUA_INVALID_ID);
    }
    
    // Notification when call's media state has changed.
    virtual void onCallMediaState(OnCallMediaStateParam &prm) {
        
        CallInfo ci = getInfo();
      
        // Iterate all the call medias
//        pjsua_call_info call_info;
//        unsigned mi;
//        pj_bool_t has_error = PJ_FALSE;
        
//        for (mi=0; mi<ci.media.size(); ++mi) {
////        on_call_generic_media_state(&call_info, mi, &has_error);
//            switch (ci.media[mi].type) {
//            case PJMEDIA_TYPE_AUDIO:
//                printf("pjsua_app.c:: on_call_media_state:: PJMEDIA_TYPE_AUDIO\n");
//    //            on_call_audio_state(&call_info, mi, &has_error);
//                break;
//            case PJMEDIA_TYPE_VIDEO:
//                printf("pjsua_app.c:: on_call_media_state:: PJMEDIA_TYPE_VIDEO\n");
//                    // Window to show preview
//                on_call_video_state(ci, mi, &has_error);
////                    displayPreviewWindow(ci.media[mi].videoCapDev, PJ_TRUE, getCallerId());
//                break;
//            default:
//                /* Make gcc happy about enum not handled by switch/case */
//                break;
//            }
//        }
        
        
        
        for (unsigned i = 0; i < ci.media.size(); i++) {
            if (ci.media[i].type==PJMEDIA_TYPE_AUDIO) {
                AudioMedia *aud_med = (AudioMedia *)getMedia(i);

                // Connect the call audio media to sound device
                AudDevManager& mgr = Endpoint::instance().audDevManager();
                aud_med->startTransmit(mgr.getPlaybackDevMedia());
                mgr.getCaptureDevMedia().startTransmit(*aud_med);
            } else  if (ci.media[i].type==PJMEDIA_TYPE_VIDEO) {
                pjsua_vid_win_id wid = 0;
                VideoMedia *video_med = (VideoMedia *)getMedia(i);
                VidDevManager& mgr = Endpoint::instance().vidDevManager();

                VideoWindow *vidWin = new VideoWindow(ci.media[i].videoIncomingWindowId);
                VideoPreview *vidPrev = new VideoPreview(ci.media[i].videoCapDev);

                PJSua2 pjsua2;
//                int getid = stoi(getCallerId());
                pjsua2.StartPreview(ci.media[i].videoCapDev, vidWin, 320, 240, 60);
            
            
//            Endpoint::instance().utilTimerSchedule(0, NULL);
//
//                displayPreviewWindow(ci.media[i].videoCapDev, PJ_TRUE, getCallerId());
//
//
//                 video_med->startTransmit(call->getEncodingVideoMedia(-1),mgr.);
//                 aud_med->startTransmit(mgr.switchDev(aud_med->getPortId(),aud_med);
            }
        }
    }
    static void on_call_video_state(CallInfo ci, unsigned mi,
                                    pj_bool_t *has_error)
    {
        if(ci.media[mi].status != PJSUA_CALL_MEDIA_ACTIVE)
        return;

        pjsua_vid_win_id wid = 0;
        wid = ci.media[mi].videoWindow.getInfo().renderDeviceId;
        printf("pjsua_app.c::on_call_video_state. WID = %d",wid);
        pjsua_call_id callid = ci.id;
        printf("Now call Appdelegate method from here");
//        if( displayWindow(wid, PJ_FALSE, callid) ){
//            displayPreviewWindow(ci->media[mi].stream.vid.cap_dev, PJ_TRUE, callid);
//        }else{
//            pjsua_vid_preview_stop(ci->media[mi].stream.vid.cap_dev);
//        }
        PJ_UNUSED_ARG(has_error);
            
    }
};


// Subclass to extend the Account and get notifications etc.
class MyAccount : public Account {
public:
    MyAccount() {}
    ~MyAccount()
    {
        // Invoke shutdown() first..
        shutdown();
        // ..before deleting any member objects.
    }
    
    
    // This is getting for register status!
    virtual void onRegState(OnRegStateParam &prm);
    
    // This is getting for incoming call (We can either answer or hangup the incoming call)
    virtual void onIncomingCall(OnIncomingCallParam &iprm);
};



//Creating objects
Endpoint *ep = new Endpoint;
MyAccount *acc = new MyAccount;

//class Endpoint {
//
//    enum {
//        TIMER_START_PREVIEW = 1,
//    };
//    struct MyTimerParam {
//        int type;
//        union {
//            struct {
//                int   dev_id;
//                void *hwnd;
//                int   w, h, fps;
//            } start_preview;
//        } data;
//    };
//
//    void onTimer(const OnTimerParam &prm)
//    {
//        MyTimerParam *param = (MyTimerParam*) prm.userData;
//        if (param->type == TIMER_START_PREVIEW) {
//            int dev_id = param->data.start_preview.dev_id;
//            void *hwnd = param->data.start_preview.hwnd;
//            int w      = param->data.start_preview.w;
//            int h      = param->data.start_preview.h;
//            int fps    = param->data.start_preview.fps;
//            PJSua2 pjsua2;
//            pjsua2.StartPreview(dev_id, hwnd, w, h, fps);
//        }
//
//        delete param;
//    }
//    void startUserPreview(){
//        MyTimerParam *tp = new MyTimerParam();
//        tp->type = TIMER_START_PREVIEW;
//        tp->data.start_preview.dev_id = 1; // colorbar virtual device
////        tp->data.start_preview.hwnd   = (void*)some_hwnd;
//        tp->data.start_preview.w      = 320;
//        tp->data.start_preview.h      = 240;
//        tp->data.start_preview.fps    = 15;
//
//        // Schedule the preview start to be executed immediately (zero milisecond delay).
//        ep->utilTimerSchedule(0, tp);
//    }
//
//
//
//};


void MyAccount::onRegState(OnRegStateParam &prm){
    AccountInfo ai = getInfo();
    std::cout << (ai.regIsActive? "*** Register: code=" : "*** Unregister: code=") << prm.code << std::endl;
    PJSua2 pjsua2;
    setRegisterState(ai.regIsActive);
    pjsua2.registerStateInfo();
    
}

void MyAccount::onIncomingCall(OnIncomingCallParam &iprm) {
    incomingCallPtr();
    call = new MyCall(*this, iprm.callId);
    
   
}
/**
 Create Lib with EpConfig
 */
void PJSua2::createLib() {
    try {
        ep->libCreate();
    } catch (Error& err){
        std::cout << "Startup error: " << err.info() << std::endl;
    }
    
    //LibInit
    //LibInit
    try {
        EpConfig ep_cfg;
        ep->libInit( ep_cfg );
        
    } catch(Error& err) {
        std::cout << "Initialization error: " << err.info() << std::endl;
    }
    
    // Create SIP transport. Error handling sample is shown
    try {
        TransportConfig tcfg;
        tcfg.port = 5060;
        TransportId tid = ep->transportCreate(PJSIP_TRANSPORT_UDP, tcfg);
        
    } catch(Error& err) {
        std::cout << "Transport creation error: " << err.info() << std::endl;
    }
    
    // Start the library (worker threads etc)
    try { ep->libStart();
    } catch(Error& err) {
        std::cout << "Startup error: " << err.info() << std::endl;
    }
}


/**
 Delete lib
 */
void PJSua2::deleteLib() {
    
    // Here we don't have anything else to do..
    pj_thread_sleep(500);
    
    // Delete the account. This will unregister from server
    delete acc;
    
    ep->libDestroy();
    delete ep;
}


/**
 Create Account via following config(string username, string password, string ip, string port)
 */
void PJSua2::createAccount(std::string username, std::string password, std::string ip, std::string port) {
    
    // Configure an AccountConfig
    AccountConfig acfg;
    acfg.idUri = "sip:" + username + "@" + ip + ":" + port;
    acfg.regConfig.registrarUri = "sip:" + ip + ":" + port;
    AuthCredInfo cred("digest", "*", username, 0, password);
    acfg.sipConfig.authCreds.push_back(cred);
    
    
    //  TODO:: GET ID -1 IS EXPERIMENTAL, NOT SURE THAT, IT IS GOOD WAY TO CHECK ACC IS CREATED. FIX IT!
    if(acc->getId() == -1){
        // Create the account
        try {
            acc->create(acfg);
        } catch(Error& err) {
            std::cout << "Account creation error: " << err.info() << std::endl;
        }
    }else {
        // Modify the account
        try {
            //Update the registration
            acc->modify(acfg);
            acc->setRegistration(true);
        } catch(Error& err) {
            std::cout << "Account modify error: " << err.info() << std::endl;
        }
    }
    
}


/**
 Unregister account
 */
void PJSua2::unregisterAccount() {
    acc->setRegistration(false);
}


/**
 Get register state true / false
 */
bool PJSua2::registerStateInfo(){
    return getRegisterState();
}


/**
 Get caller id for incoming call, checks account currently registered (ai.regIsActive)
 */
std::string PJSua2::incomingCallInfo() {
    return getCallerId();
}


/**
 Listener (When we have incoming call, this function pointer will notify swift.)
 */
void PJSua2::incoming_call(void (* funcpntr)()){
    incomingCallPtr = funcpntr;
}


/**
 Listener (When we have changes on the call state, this function pointer will notify swift.)
 */
void PJSua2::call_listener(void (* funcpntr)(int)){
    callStatusListenerPtr = funcpntr;
}


/**
 Answer incoming call
 */
void PJSua2::answerCall(){
    CallOpParam op;
    op.statusCode = PJSIP_SC_OK;
    call->answer(op);
}


/**
 Hangup active call (Incoming/Outgoing/Active)
 */
void PJSua2::hangupCall(){
    
    if (call != NULL) {
        CallOpParam op;
        op.statusCode = PJSIP_SC_DECLINE;
        call->hangup(op);
        delete call;
        call = NULL;
    }
}

/**
 Hold the call
 */
void PJSua2::holdCall(){
    
    if (call != NULL) {
        CallOpParam op;
        
        try {
            call->setHold(op);
        } catch(Error& err) {
            std::cout << "Hold error: " << err.info() << std::endl;
        }
    }
    
}

/**
 Unhold the call
 */
void PJSua2::unholdCall(){
    
    if (call != NULL) {
        
        CallOpParam op;
        op.opt.flag=PJSUA_CALL_UNHOLD;
        
        try {
            call->reinvite(op);
        } catch(Error& err) {
            std::cout << "Unhold/Reinvite error: " << err.info() << std::endl;
        }
    }
    
}
/**
 Make outgoing call (string dest_uri) -> e.g. makeCall(sip:<SIP_USERNAME@SIP_IP:SIP_PORT>)
 */
void PJSua2::outgoingCall(std::string dest_uri) {
    CallOpParam prm(true); // Use default call settings
    try {
//        pjsua_call_setting  call_opt;
//        pjsua_call_setting_default(&call_opt);
//

        call = new MyCall(*acc);
        prm.opt.audioCount = 1;
        prm.opt.videoCount = 1;
        call->makeCall(dest_uri, prm);
    } catch(Error& err) {
        std::cout << err.info() << std::endl;
    }
}



void PJSua2::StartPreview(int device_id, void* hwnd, int width, int height, int fps)
{
    try {
        // Set the video capture device format.
        VidDevManager &mgr = ep->vidDevManager();
        MediaFormatVideo format = mgr.getFormat(device_id);
        format.width    = width;
        format.height   = height;
        format.fpsNum   = fps;
        format.fpsDenum = 1;
        mgr.setFormat(device_id, format, true);
        
        // Start the preview on a panel with window handle 'hwnd'.
        // Note that if hwnd is set to NULL, library will automatically create
        // a new floating window for the rendering.
        
        VideoPreviewOpParam param;
        param.window.handle.window = (void*) hwnd;
        
        //        VideoPreview preview(device_id);
        //        preview.start(param);
        
        VideoPreview preview(device_id);
        try {
            VideoPreview preview(device_id);
            VideoWindow window = preview.getVideoWindow();
            VideoWindowInfo window_info = window.getInfo();
            if (!window_info.isNative) {
                window.Show(true);  // show the window
            }
            window.setFullScreen(true);
        } catch(Error& err) {
            
        }
        //        preview.start(param);
        //
        //
        //
        //        ep->utilTimerSchedule(0, call->getUserData());
        
        
    } catch(Error& err) {
    }
}
//enum {
//    TIMER_START_PREVIEW = 1,
//};
//struct MyTimerParam {
//    int type;
//    union {
//        struct {
//            int   dev_id;
//            void *hwnd;
//            int   w, h, fps;
//        } start_preview;
//    } data;
//};
//void PJSua2::onTimer(const OnTimerParam &prm)
//{
//    MyTimerParam *param = (MyTimerParam*) prm.userData;
//    if (param->type == TIMER_START_PREVIEW) {
//        int dev_id = param->data.start_preview.dev_id;
//        void *hwnd = param->data.start_preview.hwnd;
//        int w      = param->data.start_preview.w;
//        int h      = param->data.start_preview.h;
//        int fps    = param->data.start_preview.fps;
//        StartPreview(dev_id, hwnd, w, h, fps);
//    }
//
//    // Finally delete the timer parameter.
//    delete param;
//}

void PJSua2:: codecList(){

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

