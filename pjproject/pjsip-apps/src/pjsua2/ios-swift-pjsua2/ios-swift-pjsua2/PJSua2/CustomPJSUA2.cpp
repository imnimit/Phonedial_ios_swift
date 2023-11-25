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
#include <set>
#include <set>
#include <cstring>
using namespace std;

using namespace pj;

// Listen swift code via function pointers
void (*incomingCallPtr)(int) = 0;
void (*callStatusListenerPtr)(int) = 0;

void (*updateVideoPtr)(void *) = 0;
void (*videoViewupdateVideoPtr)(void *) = 0;
int priviewStart = 0;

/**
 Dispatch queue to manage ios thread serially or concurrently on app's main thread
 for more information please visit:
 https://developer.apple.com/documentation/dispatch/dispatchqueue
 */
dispatch_queue_t queue;

//Getter & Setter function
std::string callerId;
bool registerState = false;
int isVideoCall = false;
bool isVideoCallIncomeing = false;
VideoMedia *vid = NULL;

class MyEndpoint : public Endpoint
{
public:
    virtual void onTimer(const OnTimerParam &prm);
};

enum {
    MAKE_CALL = 1,
    ANSWER_CALL = 2,
    HOLD_CALL = 3,
    UNHOLD_CALL = 4,
    HANGUP_CALL = 5
};

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
vector<VideoMedia> vid_med;
vector<VideoMedia> vid_med_encoding;

bool callBlock = false;

// Subclass to extend the Account and get notifications etc.
class MyAccount : public Account {
public:
    std::string dest_uri;

    MyAccount() {}
    ~MyAccount()
    {
        // Invoke shutdown() first..
        //    shutdown();
//        std::cout << "======= Account is being deleted: No of calls = " << Callarray.size() << std::endl;
//
//        for (vector<Call *>::iterator it = Callarray.begin(); it != Callarray.end(); )
//        {
//            delete (*it);
//            it = Callarray.erase(it);
//        }
        // ..before deleting any member objects.
    }
    
    
    // This is getting for register status!
    virtual void onRegState(OnRegStateParam &prm);
    
    // This is getting for incoming call (We can either answer or hangup the incoming call)
    virtual void onIncomingCall(OnIncomingCallParam &iprm);
//
//    void removeCall(Call *call)
//    {
//        for (vector<Call *>::iterator it = Callarray.begin();
//             it != Callarray.end(); ++it)
//        {
//            if (*it == call) {
//                Callarray.erase(it);
//                break;
//            }
//        }
//    }
};


//Creating objects
Endpoint *ep = new Endpoint;
MyAccount *acc = new MyAccount;

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
    virtual void onCallState(OnCallStateParam &prm) {
        
        if (callBlock == true ){
            return;
        }
        CallInfo ci = getInfo();
        try {
            if (ci.state == PJSIP_INV_STATE_DISCONNECTED) {
                /* Delete the call */
                PJSua2 pj;
                if (isVideoCall == true) {
                    if (priviewStart == 1) {
                        if (Callarray.size() == 1) {
                            pj.CameraDirationChange(2);
                            pj.previewStop();
                        }
                        else {
                            pj.videoConference(true);
                        }
                    }
                }
                
                std::string numberrui = ci.remoteUri;
                int countcall = 0;
                if (Callarray.size() >0) {
                    for (unsigned i=0; i<Callarray.size(); ++i) {
                        if (Callarray[i] != NULL) {
                            CallInfo callinfo = Callarray[i]->getInfo();
                            std::cout << "===============" << std::endl;
                            std::cout << callinfo.remoteUri << std::endl;
                            if (callinfo.remoteUri == numberrui) {
                                // delete Callarray[i];
                                Callarray[i] = NULL;
                            }
                        } else {
                            countcall = countcall + 1;
                        }
                    }
                }

                if (Callarray.size() != 0) {
                    if (Callarray.size() - 1  == countcall) {
                        callStatusListenerPtr(0); // Cha
                    }
                }
            }

            
            if (ci.state == PJSIP_INV_STATE_CONFIRMED) {
                if (isVideoCall == false) {
 //                    callStatusListenerPtr(0); // Change
                } else {
                    if (Callarray.size()  > 1 ) {
                        PJSua2 p;
                        p.videoConference(false);
                    }
                }
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
    virtual void onCallMediaState(OnCallMediaStateParam &prm) {
        if (isVideoCall == true) {
             for (unsigned i=0; i<Callarray.size(); ++i) {
                 if (Callarray[i] != NULL && Callarray[i]->isActive() == true) {
                     CallInfo ci = Callarray[i]->getInfo();
                     
                     if (ci.media[i].status == PJSUA_CALL_MEDIA_ACTIVE ||
                         ci.media[i].status == PJSUA_CALL_MEDIA_REMOTE_HOLD)
                     {
                         if (ci.media[i].type==PJMEDIA_TYPE_AUDIO) {
                             // Iterate all the call medias
                             for (unsigned i = 0; i < ci.media.size(); i++) {
                                 if (ci.media[i].type==PJMEDIA_TYPE_AUDIO && getMedia(i)) {
                                     AudioMedia *aud_med = (AudioMedia *)getMedia(i);
                                     // Connect the call audio media to sound device
                                     AudDevManager& mgr = Endpoint::instance().audDevManager();
                                     aud_med->startTransmit(mgr.getPlaybackDevMedia());
                                     mgr.getCaptureDevMedia().startTransmit(*aud_med);
                                 }
                                 else if (ci.media[i].type==PJMEDIA_TYPE_VIDEO ) {
                                     
                                     if (isVideoCall == true && priviewStart == 0) {
                                         VideoWindow window(ci.media[i].videoIncomingWindowId);
                                         void *window1 = window.getInfo().winHandle.handle.window;
                                         updateVideoPtr(window1);
                                         
                                         VideoPreviewOpParam param;
                                         VideoPreview preview(ci.media[i].videoCapDev);
                                         param.windowFlags = PJMEDIA_VID_DEV_WND_BORDER | PJMEDIA_VID_DEV_WND_RESIZABLE | PJSUA_CALL_VID_STRM_CHANGE_DIR;
                                         param.show = true;
                                         preview.start(param);

                                         VideoWindow prev = preview.getVideoWindow();
                                         VideoWindowInfo window_info = prev.getInfo();

                                         if (!window_info.isNative) {
                                             prev.Show(true);
                                             updateVideoPtr(prev.getInfo().winHandle.handle.window);
                                         }
                                         priviewStart = 1;
                                     }
                                                                          
                                     if (Callarray.size()  > 1) {
                                         PJSua2 p;
                                         p.videoConference(false);
                                     }
                                 }
                             }
                         }
                     }
                 }
             }
        }
        else{
            for (unsigned i=0; i<Callarray.size(); ++i) {
                if (Callarray[i] != NULL && Callarray[i]->isActive() == true) {
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
    }
    
    virtual void onCallMediaEvent(OnCallMediaEventParam &prm)  {
        if (prm.ev.type == PJMEDIA_EVENT_FMT_CHANGED) {
            try {
                CallInfo info = getInfo();
                
                try {
                    MediaSize new_size;
                    new_size.w = 790;
                    new_size.h = 620;

                    //                 Show and adjust the size of the video window
                    CallInfo info = getInfo();
                    VideoWindow window = info.media[prm.medIdx].videoIncomingWindowId;
                    window.setSize(new_size);
                    window.Show(true);
                    window.setFullScreen2(PJMEDIA_VID_DEV_FULLSCREEN);
                    window.setFullScreen(true);
                } catch(Error& err) {
                }
                
            } catch(Error& err) {
            }
        }
    }

};

void MyEndpoint::onTimer(const OnTimerParam &prm)
{
    /* IMPORTANT:
     * We need to call PJSIP API from a separate thread since
     * PJSIP API can potentially block the main/GUI thread.
     * And make sure we don't use Apple's Dispatch / gcd since
     * it's incompatible with POSIX threads.
     * In this example, we take advantage of PJSUA2's timer thread
     * to perform call operations. For a more complex application,
     * it is recommended to create your own separate thread
     * instead for this purpose.
     */
    
    
    long code = (long) prm.userData;
    PJSua2 pj;
    if (code == MAKE_CALL) {
        Call *call1 = NULL;
        
        CallOpParam prm(true); // Use default call settings
        prm.opt.audioCount = 1;
        if(isVideoCall == true){
            prm.opt.videoCount = 1;
        }else{
            prm.opt.videoCount = 0;
        }
        callOp.push_back(prm);
        Callarray.push_back(call1);
        
        try {
            Callarray[Callarray.size() - 1] = new MyCall(*acc);
            Callarray[Callarray.size() - 1]->makeCall(acc->dest_uri, callOp[callOp.size()  - 1]);
        } catch(Error& err) {
            std::cout << err.info() << std::endl;
        }
    }else if (code == HANGUP_CALL) {
        callStatusListenerPtr(0); // Change

        if (isVideoCall == true) {
            pj.previewStop();
            for (unsigned i = 0 ; i< Callarray.size() ; ++i) {
                if (Callarray[i] != NULL) {
                    callOp[i].statusCode = PJSIP_SC_DECLINE;
                    Callarray[i]->hangup(callOp[i]);
                    delete  Callarray[i];
                    Callarray[i] = NULL;
                }
            }
        } else {
            for (unsigned i = 0 ; i< Callarray.size() ; ++i) {
                if (Callarray[i] != NULL) {
                    callOp[i].statusCode = PJSIP_SC_DECLINE;
                    Callarray[i]->hangup(callOp[i]);
                    delete  Callarray[i];
                    Callarray[i] = NULL;
                }
            }
        }
        
        //    sleep(1);
       pj.clareData();
    }
        
    
}

void MyAccount::onRegState(OnRegStateParam &prm) {
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
    
    
    Callarray[Callarray.size() - 1 ] = new MyCall(*this, iprm.callId);
    
    if (Callarray[Callarray.size() - 1 ] ->getInfo().remVideoCount == 1) {
        isVideoCall = true;
        prm.opt.audioCount = 1;
        prm.opt.videoCount = 1;
        callOp.push_back(prm);
        CallInfo ci = Callarray[Callarray.size() - 1 ]->getInfo();
        
        isVideoCallIncomeing = true;
        incomingCallPtr(1);
    }
    else{
        isVideoCall = false;
        prm.opt.audioCount = 1;
        prm.opt.videoCount = 0;
        callOp.push_back(prm);
        
        CallInfo ci = Callarray[Callarray.size() - 1 ]->getInfo();
        
        std::string input = ci.remoteUri;
        std::string delimiter1 = "sip:";
        std::string delimiter2 = "@";
        size_t start_pos = input.find(delimiter1);
        
        start_pos += delimiter1.length();
        size_t end_pos = input.find(delimiter2, start_pos);

        std::string extracted = input.substr(start_pos, end_pos - start_pos);
        
        isVideoCallIncomeing = false;
        incomingCallPtr(0);
    }
}

void pjsua_call_get_vid_stream_idx(){
    
}

void PJSua2::clareData() {
    callOp.clear();
    Callarray.clear();
    aud_med_store.clear();
    vid_med.clear();
    vid_med_encoding.clear();
    
    
    if (Callarray.size() > 0 ){
        for (unsigned i = 0 ; i< Callarray.size() ; ++i) {
            Callarray.pop_back();
        }
    }
    if (callOp.size() > 0 ){
        for (unsigned i = 0 ; i< callOp.size() ; ++i) {
            callOp.pop_back();
        }
    }
    if (aud_med_store.size() > 0 ){
        for (unsigned i = 0 ; i< aud_med_store.size() ; ++i) {
            aud_med_store.pop_back();
        }
    }
    
    if (vid_med.size() > 0 ){
        for (unsigned i = 0 ; i< vid_med.size() ; ++i) {
            vid_med.pop_back();
        }
    }
    
    if (vid_med_encoding.size() > 0 ){
        for (unsigned i = 0 ; i< vid_med_encoding.size() ; ++i) {
            vid_med_encoding.pop_back();
        }
    }
}

void PJSua2::sigleValuePop(){
    
    vector<Call *> temp;
    
    temp = Callarray;
    
    Callarray.clear();
    if (Callarray.size() > 0 ){
        for (unsigned i = 0 ; i< Callarray.size() ; i++) {
            Callarray.pop_back();
        }
    }

    if (temp.size() > 0 ){
        for (unsigned i = 0 ; i< temp.size() ; i++) {
            if (temp[i] != NULL && temp[i]->isActive() == true){
                Callarray.push_back(temp[i]);
            }
        }
    }
    temp.clear();
}
/**
 Create Lib with EpConfig
 */
void PJSua2::createLib(int portID, int transportTag) {
    try {
        ep->libCreate();
    } catch (Error& err){
        std::cout << "Startup error: " << err.info() << std::endl;
    }
    
    //LibInit
    try {
        EpConfig ep_cfg;

        ep_cfg.medConfig.vidPreviewEnableNative = false;

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
        std::cout << "port:" <<portID  << std::endl;
        std::cout << "transport Tag:" <<transportTag  << std::endl;
        tcfg.port = portID;
        TransportId tid;
        if (transportTag == 1) {
            tid = ep->transportCreate(PJSIP_TRANSPORT_UDP, tcfg);
        } else if (transportTag == 2) {
            tid = ep->transportCreate(PJSIP_TRANSPORT_TCP, tcfg);
        } else {
            tid = ep->transportCreate(PJSIP_TRANSPORT_TLS, tcfg);
        }
        
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
    pj_thread_sleep(500000);
    
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
    acfg.videoConfig.autoShowIncoming = true;
    acfg.videoConfig.autoTransmitOutgoing = true;
    acfg.videoConfig.windowFlags = PJMEDIA_VID_DEV_WND_BORDER | PJMEDIA_VID_DEV_WND_RESIZABLE | PJMEDIA_VID_DEV_FULLSCREEN;

    //  TODO:: GET ID -1 IS EXPERIMENTAL, NOT SURE THAT, IT IS GOOD WAY TO CHECK ACC IS CREATED. FIX IT!
    if (acc->getId() == -1) {
        // Create the account
        try {
            for (int i = ep->vidDevManager().getDevCount(); i>= 0; i--) {
                ep->vidDevManager().setCaptureOrient(i, PJMEDIA_ORIENT_ROTATE_90DEG);
                ep->vidDevManager().setOutputWindowFlags(i, PJMEDIA_VID_DEV_CAP_OUTPUT_FULLSCREEN, true);
            }
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
void PJSua2::incoming_call(void (* funcpntr)(int)) {
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
    
    if (Callarray.size() > 0) {
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
    
    if (isVideoCall == true) {
        if (Callarray.size() == 1){
            CameraDirationChange(2);
            previewStop();
        }
        for (unsigned i = 0 ; i< Callarray.size() ; ++i) {
            if (Callarray[i] != NULL && Callarray[i]->isActive() == true) {
                callOp[i].statusCode = PJSIP_SC_DECLINE;
                Callarray[i]->hangup(callOp[i]);
                delete  Callarray[i];
                Callarray[i] = NULL;
            }
        }
    }else{
        for (unsigned i = 0 ; i< Callarray.size() ; ++i) {
            if (Callarray[i] != NULL && Callarray[i]->isActive() == true) {
                if (callOp.size()  > i ){
                    callOp[i].statusCode = PJSIP_SC_DECLINE;
                    Callarray[i]->hangup(callOp[i]);
                    delete  Callarray[i];
                    Callarray[i] = NULL;
                }
            }
        }
    }

    //    sleep(1);
    clareData();
   
}
void PJSua2::pertiqulerhangupCall(std::string passid) {
    
    for (unsigned i = 0 ; i< Callarray.size() ; ++i) {
        if (Callarray[i] != NULL && Callarray[i]->isActive() == true) {
            CallInfo ci = Callarray[i]->getInfo();
            
            std::string input = ci.remoteUri;
            std::string delimiter1 = "sip:";
            std::string delimiter2 = "@";
            size_t start_pos = input.find(delimiter1);
            
            start_pos += delimiter1.length();
            size_t end_pos = input.find(delimiter2, start_pos);

            std::string extracted = input.substr(start_pos, end_pos - start_pos);
            if(extracted == passid) {
                callOp[i].statusCode = PJSIP_SC_DECLINE;
                Callarray[i]->hangup(callOp[i]);
                delete  Callarray[i];
                Callarray[i] = NULL;
            }
        }
    }
}


/**
 Hold the call
 */
void PJSua2::holdCall(long passid) {
    
    for (unsigned i = 0 ; i< Callarray.size() ; ++i) {
        if (Callarray[i] != NULL && Callarray[i]->isActive() == true) {
            CallInfo ci = Callarray[i]->getInfo();
            
            std::string input = ci.remoteUri;
            std::string delimiter1 = "sip:";
            std::string delimiter2 = "@";
            size_t start_pos = input.find(delimiter1);
            
            start_pos += delimiter1.length();
            size_t end_pos = input.find(delimiter2, start_pos);

            std::string extracted = input.substr(start_pos, end_pos - start_pos);
            if(extracted != std::to_string(passid) || passid == 1) {
                CallOpParam op = callOp[i];
                op.opt.flag=PJSUA_CALL_UNHOLD;
                try {
                    Callarray[i]->reinvite(op);
                } catch(Error& err) {
                    std::cout << "Unhold/Reinvite error: " << err.info() << std::endl;
                }
            } else {
                CallOpParam op = callOp[i];
                try {
                    Callarray[i]->setHold(op);
                } catch(Error& err) {
                    std::cout << "Hold error: " << err.info() << std::endl;
                }
            }
        }
    }
}
/**
 Unhold the call
 */
void PJSua2::unholdCall(long passid) {
    
    for (unsigned i = 0 ; i< Callarray.size() ; ++i) {
        if (Callarray[i] != NULL && Callarray[i]->isActive() == true) {
            CallInfo ci = Callarray[i]->getInfo();
            
            std::string input = ci.remoteUri;
            std::string delimiter1 = "sip:";
            std::string delimiter2 = "@";
            size_t start_pos = input.find(delimiter1);
            
            start_pos += delimiter1.length();
            size_t end_pos = input.find(delimiter2, start_pos);

            std::string extracted = input.substr(start_pos, end_pos - start_pos);
            if(extracted == std::to_string(passid)) {
                CallOpParam op = callOp[i];
                op.opt.flag=PJSUA_CALL_UNHOLD;
                try {
                    Callarray[i]->reinvite(op);
                } catch(Error& err) {
                    std::cout << "Unhold/Reinvite error: " << err.info() << std::endl;
                }
            } else {
                CallOpParam op = callOp[i];
                try {
                    Callarray[i]->setHold(op);
                } catch(Error& err) {
                    std::cout << "Hold error: " << err.info() << std::endl;
                }
            }
        }
    }
}

void PJSua2::unholdAllCall() {
    if (Callarray.size() > 0) {
        for (unsigned i=0; i<Callarray.size(); ++i) {
            if (Callarray[i] != NULL && Callarray[i]->isActive() == true) {
                CallOpParam op = callOp[i];
                op.opt.flag=PJSUA_CALL_UNHOLD;
                try {
                    Callarray[i]->reinvite(op);
                } catch(Error& err) {
                    std::cout << "Unhold/Reinvite error: " << err.info() << std::endl;
                }
            }
        }
    }
}
/**
 Make outgoing call (string dest_uri) -> e.g. makeCall(sip:<SIP_USERNAME@SIP_IP:SIP_PORT>)
 */
void PJSua2::outgoingCall(std::string dest_uri,std::string isVideo) {

    isVideoCallIncomeing = false;
    Call *call1 = NULL;

    CallOpParam prm(true); // Use default call settings
    prm.opt.audioCount = 1;
    if(isVideo == "1"){
        prm.opt.videoCount = 1;
        isVideoCall = true;
    }else{
        prm.opt.videoCount = 0;
        isVideoCall = false;
    }
    callOp.push_back(prm);
    Callarray.push_back(call1);

    try {
        Callarray[Callarray.size() - 1] = new MyCall(*acc);
        Callarray[Callarray.size() - 1]->makeCall(dest_uri, callOp[callOp.size()  - 1]);
    } catch(Error& err) {
        std::cout << err.info() << std::endl;
    }
}

void PJSua2::outgoingCall1(std::string dest_uri) {
    
    isVideoCallIncomeing = false;
    Call *call1 = NULL;
    
    Callarray.push_back(call1);
    CallOpParam prm(true); // Use default call settings
    prm.opt.audioCount = 1;
    prm.opt.videoCount = 0;
    callOp.push_back(prm);
    
    try {
        Callarray[Callarray.size() - 1] = new MyCall(*acc);
        Callarray[Callarray.size() - 1]->makeCall(dest_uri, callOp[callOp.size()  - 1]);
    } catch(Error& err) {
        std::cout << err.info() << std::endl;
    }
}

VideoWindow getCallVideoWindow(const Call *call) {
    CallInfo ci = call->getInfo();
    CallMediaInfoVector::iterator it;
    for (it = ci.media.begin(); it != ci.media.end(); ++it) {
        if (it->type == PJMEDIA_TYPE_VIDEO &&
            it->videoIncomingWindowId != PJSUA_INVALID_ID) {
            return it->videoWindow;
        }
    }
    return VideoWindow(PJSUA_INVALID_ID);
}

void PJSua2::videoConference(bool OneConnect) {
       
    vid_med.clear();
    vid_med_encoding.clear();
        
    int countConnectCall = 0;
    for(unsigned j = 0 ; j< Callarray.size(); j++) {
        if (Callarray[j] != NULL && Callarray[j]->isActive() == true) {
            countConnectCall = countConnectCall + 1;
            videoCallmargeWork(j);
            if (vid_med.size() > 1) {
                VideoMediaTransmitParam param;
                vid_med[j - 1].startTransmit(vid_med_encoding[j],param);
                vid_med[j].startTransmit(vid_med_encoding[j - 1],param);
            }
        }
    }
    
    if (OneConnect == true) {
        for(unsigned i = 0 ; i< vid_med.size(); i++) {
            for(unsigned j = 0 ; j< Callarray.size(); j++) {
                if (Callarray[j] != NULL && Callarray[j]->isActive() == true) {
                    VideoMediaTransmitParam param;
                    VideoWindow wid2 = getCallVideoWindow(Callarray[j]);
                    vid_med[i].startTransmit(wid2.getVideoMedia(), param);
                }
            }
        }
        std::cin.sync();
    } else {
        for(unsigned j = 0 ; j< vid_med.size(); j++) {
            VideoMediaTransmitParam param;
            VideoWindow wid2 = getCallVideoWindow(Callarray[countConnectCall - (j + 1)]);
            vid_med[j].startTransmit(wid2.getVideoMedia(), param);
        }
        std::cin.sync();
    }
  
    
//    VideoMedia call_1_dec_port = Callarray[0]->getDecodingVideoMedia(-1);
//    VideoMedia call_1_enc_port = Callarray[0]->getEncodingVideoMedia(-1);
//
//    /* Get video ports of call 2 */
//    VideoMedia call_2_dec_port = Callarray[1]->getDecodingVideoMedia(-1);
//    VideoMedia call_2_enc_port = Callarray[1]->getEncodingVideoMedia(-1);
//
//    /* Connect video ports of call 1 and call 2 */
//    VideoMediaTransmitParam transmit_param;
//    call_1_dec_port.startTransmit(call_2_enc_port, transmit_param);
//    call_2_dec_port.startTransmit(call_1_enc_port, transmit_param);
//
        
//    VideoMediaTransmitParam param;
//    VideoWindow wid2 = getCallVideoWindow(Callarray[1]);
//    call_1_dec_port.startTransmit(wid2.getVideoMedia(), param);
//
//    VideoWindow wid1 = getCallVideoWindow(Callarray[0]);
//    call_2_dec_port.startTransmit(wid1.getVideoMedia(), param);
}

void PJSua2::videoCallmargeWork(int id) {
    CallInfo ci = Callarray[id]->getInfo();
  //  std::cout << ci.callIdString << std::endl;
    
    vid_med.push_back(Callarray[id]->getDecodingVideoMedia(-1));
    vid_med_encoding.push_back(Callarray[id]->getEncodingVideoMedia(-1));
}
void PJSua2::previewHide() {    
    for (unsigned i=0; i<Callarray.size(); ++i) {
        if (Callarray[i] != NULL && Callarray[i]->isActive() == true) {
            CallInfo ci = Callarray[i]->getInfo();
            
            if (ci.media[i].status == PJSUA_CALL_MEDIA_ACTIVE ||
                ci.media[i].status == PJSUA_CALL_MEDIA_REMOTE_HOLD)
            {
                for (unsigned i = 0; i < ci.media.size(); i++) {
                    if (ci.media[i].type==PJMEDIA_TYPE_VIDEO ) {
                        VideoPreviewOpParam param;
                        VideoPreview preview(ci.media[i].videoCapDev);
                        param.windowFlags = PJMEDIA_VID_DEV_WND_BORDER | PJMEDIA_VID_DEV_WND_RESIZABLE | PJSUA_CALL_VID_STRM_CHANGE_DIR;
                        param.show = true;
                        preview.start(param);
                        
                        VideoWindow prev = preview.getVideoWindow();
                        VideoWindowInfo window_info = prev.getInfo();
                        
                        if (!window_info.isNative) {
                            prev.Show(false);
                        }
                    }
                }
            }
        }
    }
    
    CallVidSetStreamParam param;
    Callarray[0]->vidSetStream(PJSUA_CALL_VID_STRM_STOP_TRANSMIT, param);
    
}
void PJSua2::previewShow(){
    CallVidSetStreamParam param;
    Callarray[0]->vidSetStream(PJSUA_CALL_VID_STRM_START_TRANSMIT, param);
    
    for (unsigned i=0; i<Callarray.size(); ++i) {
        if (Callarray[i] != NULL && Callarray[i]->isActive() == true) {
            CallInfo ci = Callarray[i]->getInfo();
            
            if (ci.media[i].status == PJSUA_CALL_MEDIA_ACTIVE ||
                ci.media[i].status == PJSUA_CALL_MEDIA_REMOTE_HOLD)
            {
                for (unsigned i = 0; i < ci.media.size(); i++) {
                    if (ci.media[i].type==PJMEDIA_TYPE_VIDEO ) {
                        VideoPreviewOpParam param;
                        VideoPreview preview(ci.media[i].videoCapDev);
                        param.windowFlags = PJMEDIA_VID_DEV_WND_BORDER | PJMEDIA_VID_DEV_WND_RESIZABLE | PJSUA_CALL_VID_STRM_CHANGE_DIR;
                        param.show = true;
                        preview.start(param);
                        
                        VideoWindow prev = preview.getVideoWindow();
                        VideoWindowInfo window_info = prev.getInfo();
                        
                        if (!window_info.isNative) {
                            prev.Show(true);
                        }
                    }
                }
            }
        }
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
        if (Callarray[j] != NULL && Callarray[j]->isActive() == true) {
            callmargeWork(j);
            if (aud_med_store.size() > 1) {
                aud_med_store[j - 1]->startTransmit(*aud_med_store[j]);
                aud_med_store[j]->startTransmit( *aud_med_store[j - 1]);
            }
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
            if (Callarray[i] != NULL && Callarray[i]->isActive() == true) {
                CallInfo ci = Callarray[i]->getInfo();
                if (ci.state == PJSIP_INV_STATE_CONFIRMED || ci.state == PJSIP_INV_STATE_INCOMING || ci.state == PJSIP_INV_STATE_CALLING || ci.state == PJSIP_INV_STATE_EARLY || ci.state == PJSIP_INV_STATE_CONNECTING) {
                    if (number == "" ) {
                        number  = ci.remoteUri;
                    } else {
                        number  = number + "," + ci.remoteUri;
                    }
                }
            }
        }
    }
    return  number;
}

std::string PJSua2::allnumberGetConfiremed() {
    std::string  number = "";
    if (Callarray.size() > 0 ) {
        for (unsigned i=0; i<Callarray.size(); ++i) {
            if (Callarray[i] != NULL && Callarray[i]->isActive() == true) {
                CallInfo ci = Callarray[i]->getInfo();
                if (ci.state == PJSIP_INV_STATE_CONFIRMED && ci.media[i].status != PJSUA_CALL_MEDIA_NONE) {
                    if (number == "") {
                        number  = ci.remoteUri;
                    } else {
                        number  = number + "," + ci.remoteUri;
                    }
                }
            }
        }
    }
    return  number;
}
std::string PJSua2::allnumberConfirmdGet() {
    std::string  number = "";
    if (Callarray.size() > 0 ) {
        for (unsigned i=0; i<Callarray.size(); ++i) {
            if (Callarray[i] != NULL && Callarray[i]->isActive() == true) {
                CallInfo ci = Callarray[i]->getInfo();
                if (ci.state == PJSIP_INV_STATE_CONFIRMED) {
                    if (number == "" ) {
                        number  = ci.remoteUri;
                    } else {
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

bool PJSua2::callPickup() {
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
        } else {
            return  true;
        }
    }
    return  false;
}

void PJSua2::callTrasfer(std::string dest_uri){
    if (Callarray.size() > 0) {
        if (Callarray[0] != NULL) {
            Callarray[0]->xfer(dest_uri, callOp[0]);
        }
    }
}

// Vidoe Call
void PJSua2::previewStop(){
    PJSUA2_THROW(Error)
    if(priviewStart == 1){
        priviewStart = 0;
        VideoPreviewOpParam param;
        VideoPreview preview(-1);
        preview.stop();
    }
}

void PJSua2::CameraDirationChange(int type) {
    
    for (unsigned i=0; i<Callarray.size(); ++i) {
        if (Callarray[i] != NULL && Callarray[i]->isActive() == true) {
            // CameraFlip
            pjsua_call_vid_strm_op_param param1;
            pjsua_call_vid_strm_op_param_default(&param1);
            param1.cap_dev = type;// 3 Back 2 Front

            pjsua_call_set_vid_strm(Callarray[i]->getId(),
            PJSUA_CALL_VID_STRM_CHANGE_CAP_DEV,
            &param1);
        }
    }
    
}

void PJSua2::update_video(void (*funcpntr)(void *)){
    updateVideoPtr = funcpntr;
}

void PJSua2::videoview_update_video(void (*funcpntr)(void *)){
    videoViewupdateVideoPtr = funcpntr;
}

void PJSua2::callBlock(const std::string& contact){
    BlockedContactsManager::getInstance().blockContact(contact);
    BlockedContactsManager::getInstance().saveBlockedContacts();
}
void PJSua2::uncallBlock(const std::string& contact){
    BlockedContactsManager::getInstance().unblockContact(contact);
    BlockedContactsManager::getInstance().saveBlockedContacts();
}
void PJSua2::lodeBolckNumber() {
    BlockedContactsManager::getInstance().loadBlockedContacts();
}
void BlockedContactsManager:: blockContact(const std::string &contact) {
    blockedContacts.insert(contact);
}
void BlockedContactsManager::unblockContact(const std::string& contact) {
    blockedContacts.erase(contact);
}
bool BlockedContactsManager::isContactBlocked(const std::string& contact) {
    return blockedContacts.count(contact) > 0;
}

void BlockedContactsManager::saveBlockedContacts() {
    std::ofstream file("blocked_contacts.txt");
    if (static_cast<void>(file.is_open()), ios::in | ios::out) {
        for (const auto& contact : blockedContacts) {
            file << contact << '\n';
        }
        file.close();
    }
    
    ifstream fin;
    fin.open("index.txt", ios::app);
    if (!fin) {
        cout<<" Error while creating the file ";
    }
    else {
        cout<<"File created and data got written to file";
        fin.close();
    }
    
    
//    fstream file;
//    file.open("blocked_contacts.txt",ios::out);
//    for (const auto& contact : blockedContacts) {
//        file << contact << '\n';
//    }
//    file.close();

//    ofstream MyFile("test.txt");
//
//    // Write to the file
//    for (const auto& contact : blockedContacts) {
//        MyFile << contact << '\n';
//    }
//
//    // Close the file
//    MyFile.close();


    namespace fs = std::__fs::filesystem;
    fs::path f{ "my_file.txt" };
    if (fs::exists(f)) std::cout << "yes";
    else               std::cout << "nope";

    loadBlockedContacts();
}
void BlockedContactsManager::loadBlockedContacts() {
//    blockedContacts.clear();
    std::ifstream file("test.txt");
    if (static_cast<void>(file.is_open()), ios::in | ios::out) {
        std::string contact;
        while (std::getline(file, contact)) {
            blockedContacts.insert(contact);
        }
        file.close();
    }
}
