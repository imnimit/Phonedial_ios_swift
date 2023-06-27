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
Call *call1 = NULL;

vector<CallOpParam> callOp;
vector<Call *> Callarray;
vector<AudioMedia *> aud_med_store;

// Subclass to extend the Call and get notifications etc.
class MyCall : public Call
{
    Account *myAcc;

public:
    MyCall(Account &acc, int call_id = PJSUA_INVALID_ID) : Call(acc, call_id)
    { }
    ~MyCall()
    { }
    
    
    // Notification when call's state has changed.
    virtual void onCallState(OnCallStateParam &prm){
        CallInfo ci = getInfo();
        try {
            if (ci.state == PJSIP_INV_STATE_DISCONNECTED) {
                /* Delete the call */
                std::string numberrui = ci.remoteUri;
                int countcall = 0;
                if (Callarray.size() >0 ) {
                    for (unsigned i=0; i<Callarray.size(); ++i) {
                        if (Callarray[i] != NULL) {
                            CallInfo callinfo = Callarray[i]->getInfo();
                            std::cout << "===============" << std::endl;
                            std::cout << callinfo.remoteUri << std::endl;
                            if (callinfo.remoteUri == numberrui) {
                               // delete Callarray[i];
                                Callarray[i] = NULL;
                            }
                        }else {
                            countcall = countcall + 1;
                        }
                    }
                }
                
                if (Callarray.size() != 0) {
                    if (Callarray.size() - 1  == countcall) {
                       callStatusListenerPtr(0); // Change
                    }
                }
            }
            
            if (ci.state == PJSIP_INV_STATE_CONFIRMED) {
               callStatusListenerPtr(1); // Change
            }
            
            setCallerId(ci.remoteUri);
            
            //Notify caller ID:
            PJSua2 pjsua2;
            pjsua2.incomingCallInfo();
            
        } catch(Error& err) {
            std::cout << "error" << std::endl;
        }
    }
    
    // Notification when call's media state has changed.
    virtual void onCallMediaState(OnCallMediaStateParam &prm){
        for (unsigned i=0; i<Callarray.size(); ++i) {
            if (Callarray[i] != NULL) {
                CallInfo ci = Callarray[i]->getInfo();
                // Iterate all the call medias
                for (unsigned i = 0; i < ci.media.size(); i++) {
                    if (ci.media[i].type==PJMEDIA_TYPE_AUDIO && getMedia(i)) {
                        AudioMedia *aud_med = (AudioMedia *)getMedia(i);
                        // Connect the call audio media to sound device
                        AudDevManager& mgr = Endpoint::instance().audDevManager();
                        aud_med->startTransmit(mgr.getPlaybackDevMedia());
                        mgr.getCaptureDevMedia().startTransmit(*aud_med);
                    }
                }
            }
        }
    }
    
    virtual void onCallMediaEvent(OnCallMediaEventParam &prm)
    {
        if (prm.ev.type == PJMEDIA_EVENT_FMT_CHANGED) {
            try {
                MediaSize new_size;
                new_size.w = prm.ev.data.fmtChanged.newWidth;
                new_size.h = prm.ev.data.fmtChanged.newHeight;

                // Scale down the size if necessary
                if (new_size.w > 500 || new_size.h > 500) {
                    new_size.w /= 2;
                    new_size.h /= 2;
                }

                // Show and adjust the size of the video window
                CallInfo info = getInfo();
                VideoWindow window = info.media[prm.medIdx].videoWindow;
                window.Show(true);
                window.setSize(new_size);
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
    
  
    
//    virtual void onCallReplaceRequest(OnCallReplaceRequestParam &prm){
//        CallInfo ci = getInfo();
//        //        prm.newCall = new MyCall(*myAcc);
//    }
    
//    void onCallTransferRequest(OnCallTransferRequestParam &prm)
//    {
//        /* Create new Call for call transfer */
//        prm.newCall = new MyCall(*myAcc);
//    }
//
    
    void onCallTransferRequest(OnCallTransferRequestParam &prm)
    {
        /* Create new Call for call transfer */
        prm.newCall = new MyCall(*myAcc);
    }

    void onCallReplaceRequest(OnCallReplaceRequestParam &prm)
    {
        /* Create new Call for call replace */
        prm.newCall = new MyCall(*myAcc);
    }

    
    
    
    
};


// Subclass to extend the Account and get notifications etc.
class MyAccount : public Account {
public:
    MyAccount() {}
    ~MyAccount()
    {
        // Invoke shutdown() first..
        //    shutdown();
        std::cout << "======= Account is being deleted: No of calls = " << Callarray.size() << std::endl;
        
        for (vector<Call *>::iterator it = Callarray.begin(); it != Callarray.end(); )
        {
            delete (*it);
            it = Callarray.erase(it);
        }
        // ..before deleting any member objects.
    }
    
    
    // This is getting for register status!
    virtual void onRegState(OnRegStateParam &prm);
    
    // This is getting for incoming call (We can either answer or hangup the incoming call)
    virtual void onIncomingCall(OnIncomingCallParam &iprm);
    
    void removeCall(Call *call)
    {
        for (vector<Call *>::iterator it = Callarray.begin();
             it != Callarray.end(); ++it)
        {
            if (*it == call) {
                Callarray.erase(it);
                break;
            }
        }
    }
};


//Creating objects
Endpoint *ep = new Endpoint;
MyAccount *acc = new MyAccount;

void MyAccount::onRegState(OnRegStateParam &prm){
    AccountInfo ai = getInfo();
    std::cout << (ai.regIsActive? "*** Register: code=" : "*** Unregister: code=") << prm.code << std::endl;
    PJSua2 pjsua2;
    setRegisterState(ai.regIsActive);
    pjsua2.registerStateInfo();
    
}

void MyAccount::onIncomingCall(OnIncomingCallParam &iprm) {
    Call *call = NULL;
    Callarray.push_back(call);
    
    CallOpParam prm(true); // Use default call settings
    callOp.push_back(prm);
    
    
    incomingCallPtr();
    Callarray[Callarray.size() - 1 ] = new MyCall(*this, iprm.callId);
    
}
void pjsua_call_get_vid_stream_idx(){
    
}

void PJSua2::clareData() {
    callOp.clear();
    Callarray.clear();
    aud_med_store.clear();
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
    try {
        EpConfig ep_cfg;
        ep_cfg.medConfig.sndClockRate = 48000;
        ep_cfg.medConfig.ecTailLen = 0;
        try {
            ep->libInit( ep_cfg );
        } catch (pj::Error& e) {
            std::cerr << "Error caught: " <<std::endl;
            return;
        }
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
    acfg.callConfig.timerMinSESec = 90;
    acfg.callConfig.timerSessExpiresSec = 90;

//    acfg.videoConfig.autoShowIncoming = false;
//    acfg.videoConfig.autoTransmitOutgoing = false;
//    acfg.videoConfig.defaultCaptureDevice = PJMEDIA_VID_INVALID_DEV  // PJMEDIA_VID_DEFAULT_CAPTURE_DEV;
//    acfg.videoConfig.defaultRenderDevice = PJMEDIA_VID_INVALID_DEV  //PJMEDIA_VID_DEFAULT_RENDER_DEV;
        
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
bool PJSua2::registerStateInfo() {
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
void PJSua2::incoming_call(void (* funcpntr)()) {
    incomingCallPtr = funcpntr;
}


/**
 Listener (When we have changes on the call state, this function pointer will notify swift.)
 */
void PJSua2::call_listener(void (* funcpntr)(int)) {
    callStatusListenerPtr = funcpntr;
}
/**
 Answer incoming call
 */
void PJSua2::answerCall() {
//    try {
//        if (Callarray.size() > 0 ) {
//            if (Callarray[Callarray.size() - 1 ] != NULL) {
//                callOp[callOp.size() - 1 ].statusCode = PJSIP_SC_OK;
//                Callarray[Callarray.size() - 1 ]->answer(callOp[callOp.size() - 1 ]);
//            }
//        }
//    } catch (pj::Error& e) {
//       std::cerr << "Error caught: " <<std::endl;
//    }
//
    
    if (Callarray.size() > 0 ) {
        if (Callarray[Callarray.size() - 1 ] != NULL) {
            callOp[callOp.size() - 1 ].statusCode = PJSIP_SC_OK;
            Callarray[Callarray.size() - 1 ]->answer(callOp[callOp.size() - 1 ]);
        }
    }
        
}
/**
 Hangup active call (Incoming/Outgoing/Active)
 */
void PJSua2::hangupCall() {
    
    for (unsigned i = 0 ; i< Callarray.size() ; ++i) {
        if (Callarray[i] != NULL) {
            callOp[i].statusCode = PJSIP_SC_DECLINE;
            Callarray[i]->hangup(callOp[i]);
            delete  Callarray[i];
            Callarray[i] = NULL;
        }
    }
    
    //sleep(1);
    clareData();
}

void PJSua2::pertiqulerhangupCall(int passid) {
    if (Callarray[passid] != NULL) {
        callOp[passid].statusCode = PJSIP_SC_DECLINE;
        Callarray[passid]->hangup(callOp[passid]);
        delete  Callarray[passid];
        Callarray[passid] = NULL;
    }
}


/**
 Hold the call
 */
void PJSua2::holdCall(int passid) {
    if (Callarray[passid] != NULL) {
        if (Callarray.size() > 0) {
            CallOpParam op = callOp[passid];
            try {
                Callarray[passid]->setHold(op);
            } catch(Error& err) {
                std::cout << "Hold error: " << err.info() << std::endl;
            }
        }
    }
}
/**
 Unhold the call
 */

void PJSua2::unholdCall(int passid) {
    if (Callarray[passid] != NULL) {
        if (Callarray.size() > 0) {
            CallOpParam op = callOp[passid];
            //CallOpParam op(true);
            op.opt.flag=PJSUA_CALL_UNHOLD;
            try {
                Callarray[passid]->reinvite(op);
            } catch(Error& err) {
                std::cout << "Unhold/Reinvite error: " << err.info() << std::endl;
            }
        }
    }
}
/**
 Make outgoing call (string dest_uri) -> e.g. makeCall(sip:<SIP_USERNAME@SIP_IP:SIP_PORT>)
 */
void PJSua2::outgoingCall(std::string dest_uri) {
    Call *call1 = NULL;
    
    CallOpParam prm(true); // Use default call settings
    prm.opt.audioCount = 1;
    prm.opt.videoCount = 0;
    
    callOp.push_back(prm);
    Callarray.push_back(call1);
    try {
        Callarray[Callarray.size() - 1] = new MyCall(*acc);
        Callarray[Callarray.size() - 1]->makeCall(dest_uri, callOp[callOp.size()  - 1]);
    } catch(Error& err) {
        std::cout << err.info() << std::endl;
    }
    
    
    
        
//    pjsua_acc_config cfg;
//    pjsua_acc_config_default(&cfg);
//    cfg.vid_in_auto_show = PJ_TRUE;
//
//    int vid_idx;
//    pjsua_vid_win_id wid;
//
//    CallInfo c = Callarray[Callarray.size() - 1]->getInfo();
//
//    vid_idx = pjsua_call_get_vid_stream_idx(c.accId);
//    if (vid_idx >= 0) {
//        pjsua_call_info ci;
//
//        pjsua_call_get_info(ci.id, &ci);
//        wid = ci.media[vid_idx].stream.vid.win_in;
//     //   VideoWindow(ci.id);
//    }
}
void PJSua2:: pjsua_vid_codec_set_param() {
//    const pj_str_t codec_id = {"H264", 4};
//    pjmedia_vid_codec_param param;
//
//    pjsua_vid_codec_get_param(&codec_id, &param);
//
//
//    ::pjsua_vid_codec_set_param(&codec_id, &param);
//
//    
//    param.enc_fmt.det.vid.size.w = 1280;
//    param.enc_fmt.det.vid.size.h = 720;
}

void PJSua2::outgoingCall1(std::string dest_uri) {
    
    Call *call1 = NULL;
    
    Callarray.push_back(call1);
    CallOpParam prm(true); // Use default call settings
    prm.opt.audioCount = 1;
    prm.opt.videoCount = 1;
    callOp.push_back(prm);
    
    try {
        Callarray[Callarray.size() - 1] = new MyCall(*acc);
        Callarray[Callarray.size() - 1]->makeCall(dest_uri, callOp[callOp.size()  - 1]);
    } catch(Error& err) {
        std::cout << err.info() << std::endl;
    }
    
}
void PJSua2::pjmedia() {
    
    AudioMediaRecorder wav_writer;
    AudioMedia& mic_media = Endpoint::instance().audDevManager().getCaptureDevMedia();
    try {
        wav_writer.createRecorder("file.wav");
        mic_media.startTransmit(wav_writer);
    } catch(Error& err) {
    }
    
    AudioMediaPlayer player;
    AudioMedia& speaker_media = Endpoint::instance().audDevManager().getPlaybackDevMedia();
    try {
        player.createPlayer("file.wav");
        player.startTransmit(speaker_media);
    } catch(Error& err) {
    }
    
    aud_med_store.clear();
    
    for(unsigned j = 0 ; j< Callarray.size(); j++) {
        callmargeWork(j);
        if (aud_med_store.size() > 1) {
            aud_med_store[j - 1]->startTransmit(*aud_med_store[j]);
            aud_med_store[j]->startTransmit( *aud_med_store[j - 1]);
        }
    }
    
}

void PJSua2::callmargeWork(int id) {
    
    AudioMediaRecorder wav_writer;
    AudioMedia& mic_media = Endpoint::instance().audDevManager().getCaptureDevMedia();
    try {
        wav_writer.createRecorder("file.wav");
        mic_media.startTransmit(wav_writer);
    } catch(Error& err) {
    }
    
    AudioMediaPlayer player;
    AudioMedia& speaker_media = Endpoint::instance().audDevManager().getPlaybackDevMedia();
    try {
        player.createPlayer("file.wav");
        player.startTransmit(speaker_media);
    } catch(Error& err) {
    }
    
    CallInfo ci = Callarray[id]->getInfo();
    AudioMedia *aud_med = NULL;
    std::cout << ci.callIdString << std::endl;
    
    for (unsigned i=0; i<ci.media.size(); ++i) {
        if (ci.media[i].type == PJMEDIA_TYPE_AUDIO) {
            aud_med = (AudioMedia *)Callarray[id]->getMedia(i);
            break;
        }
    }
    
    if (aud_med) {
        mic_media.startTransmit(*aud_med);
        aud_med->startTransmit(speaker_media);
    }
    
    aud_med_store.push_back(aud_med);
    
}

std::string PJSua2::allnumberGet() {
    std::string  number = "";
    if (Callarray.size() > 0 ) {
        for (unsigned i=0; i<Callarray.size(); ++i) {
            if (Callarray[i] != NULL) {
                CallInfo ci = Callarray[i]->getInfo();
                if (ci.state == PJSIP_INV_STATE_CONFIRMED) {
                    if (number == "" ){
                        number  = ci.remoteUri;
                    }else {
                        number  = number + "," + ci.remoteUri;
                    }
                }
            }
            
        }
    }
    
    return  number;
}

bool PJSua2::checkCallPickup() {
    if (Callarray.size() > 0) {
        return  true;
    }
    return false;
}

bool PJSua2::callPickup(){
    if (Callarray.size() > 0) {
        if (Callarray[0] != NULL) {
            CallInfo ci = Callarray[0]->getInfo();
            if (ci.state == PJSIP_INV_STATE_CONFIRMED) {
                return  true;
            }
        }
    }
    
    return false;
}

bool PJSua2::callEnd() {
    if (Callarray.size() > 0) {
        if (Callarray[0] != NULL) {
            CallInfo ci = Callarray[0]->getInfo();
            if (ci.state == PJSIP_INV_STATE_DISCONNECTED) {
                return  true;
            }
        }else{
            return  true;
        }
    }
    return  false;
}

void PJSua2::callTrasfer(std::string dest_uri){
    if (Callarray.size() > 0) {
        if (Callarray[0] != NULL) {
            Callarray[0]->xfer(dest_uri, callOp[0]);
//            Callarray[0]->xferReplaces(Callarray[0]->xfer(dest_uri, callOp[0]), callOp[0]);
        }
    }
}
//void PJSua2::VideoMediaTrasfter(){
//    CallInfo ci = Callarray[0]->getInfo();
//    call_1_dec_port = pjsua_call_get_vid_conf_port(ci.id, PJMEDIA_DIR_DECODING);
//    call_1_enc_port = pjsua_call_get_vid_conf_port(call_1_id, PJMEDIA_DIR_ENCODING);
//
//    /* Get video ports of call 2 */
//    call_2_dec_port = pjsua_call_get_vid_conf_port(call_2_id, PJMEDIA_DIR_DECODING);
//    call_2_enc_port = pjsua_call_get_vid_conf_port(call_2_id, PJMEDIA_DIR_ENCODING);
//
//    /* Connect video ports of call 1 and call 2.
//     * Note that the source is the stream port in decoding direction,
//     * and the sink is the stream port in encoding direction.
//     */
//    status = pjsua_vid_conf_connect(call_1_dec_port, call_2_enc_port, NULL);
//    status = pjsua_vid_conf_connect(call_2_dec_port, call_1_enc_port, NULL);
//}
void PJSua2::StartPreview(int device_id, void* hwnd, int width, int height, int fps)
{
    try {
        // Set the video capture device format.
        VidDevManager &mgr = Endpoint::instance().vidDevManager();
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

        VideoPreview preview(device_id);
        preview.start(param);
    } catch(Error& err) {
    }
}
enum {
    TIMER_START_PREVIEW = 1,
};
struct MyTimerParam {
    int type;
    union {
        struct {
            int   dev_id;
            void *hwnd;
            int   w, h, fps;
        } start_preview;
    } data;
};
void PJSua2::onTimer(const OnTimerParam &prm)
{
    MyTimerParam *param = (MyTimerParam*) prm.userData;
    if (param->type == TIMER_START_PREVIEW) {
        int dev_id = param->data.start_preview.dev_id;
        void *hwnd = param->data.start_preview.hwnd;
        int w      = param->data.start_preview.w;
        int h      = param->data.start_preview.h;
        int fps    = param->data.start_preview.fps;
        StartPreview(dev_id, hwnd, w, h, fps);
    }

    // Finally delete the timer parameter.
    delete param;
}
void PJSua2::videoConference() {
    
//    MyTimerParam *tp = new MyTimerParam();
//    tp->type = TIMER_START_PREVIEW;
//    tp->data.start_preview.dev_id = 1; // colorbar virtual device
//    tp->data.start_preview.hwnd   = (void*)some_hwnd;
//    tp->data.start_preview.w      = 320;
//    tp->data.start_preview.h      = 240;
//    tp->data.start_preview.fps    = 15;
//
//    // Schedule the preview start to be executed immediately (zero milisecond delay).
//    Endpoint::instance().utilTimerSchedule(0, tp);
    
    
//    VideoMedia vid_enc_med1 = call1.getEncodingVideoMedia(-1);
//    VideoMedia vid_dec_med1 = call1.getDecodingVideoMedia(-1);
//
//    VideoMedia vid_enc_med2 = call2.getEncodingVideoMedia(-1);
//    VideoMedia vid_dec_med2 = call2.getDecodingVideoMedia(-1);
//
//    vid_dec_med1.startTransmit(vid_enc_med2);
//    vid_dec_med2.startTransmit(vid_enc_med1);
}
