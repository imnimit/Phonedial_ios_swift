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

#include <string>
#include <pjsua2.hpp>
#include <dispatch/dispatch.h>
#include <set>
#include <fstream>
#include <sstream>
/**
 Create a class to be able to use it from objective-c++
 */

class PJSua2 {
public:
    
    
    pj::OnCallMediaStateParam callditails;
    //Lib
    /**
     Create Lib with EpConfig
     */
    void createLib(int portID, int transportTag);
    
    /**
     Delete lib
     */
    void deleteLib();
    
    
    
    //Account
    /**
     Create Account via following config(string username, string password, string ip, string port)
     */
    void createAccount(std::string username, std::string password, std::string ip, std::string port);
    
    /**
     Unregister account
     */
    void unregisterAccount();
    
    
    
    //Register State Info
    /**
     Get register state true / false
     */
    bool registerStateInfo();
    
    
    
    //Call Info
    /**
     Get caller id for incoming call, checks account currently registered (ai.regIsActive)
     */
    std::string incomingCallInfo();

    /**
     Listener (When we have incoming call, this function pointer will notify swift.)
     */
    void incoming_call(void(*function)(int));

    /**
     Listener (When we have changes on the call state, this function pointer will notify swift.)
     */
    void call_listener(void(*function)(int));
    
    /**
     Answer incoming call
     */
    void answerCall();
    
    /**
     Hangup active call (Incoming/Outgoing/Active)
     */
    void hangupCall();

    /**
     Hold the call
     */
    void holdCall(int passid);
    
    /**
     unhold the call
     */
    void unholdCall(int passid);
    
    
    /**
     Make outgoing call (string dest_uri) -> e.g. makeCall(sip:<SIP_USERNAME@SIP_IP:SIP_PORT>)
     */
    void outgoingCall(std::string dest_uri,std::string isVideo);
    
    void callRecodingstart();
    
    void outgoingCall1(std::string dest_uri);
    
    void CallPhone2();
    
    void callmedia();
    
    void pjmedia();
    void callmargeWork(int id);
    void clareData();
    
    std::string allnumberGet();
    std::string allnumberGetConfiremed();
    std::string allnumberConfirmdGet();
    void pertiqulerhangupCall(std::string passid);
    bool checkCallPickup();
    bool callPickup();
    bool callEnd();
    void callTrasfer(std::string dest_uri);
   // void pjsua_vid_codec_set_param();
    void VideoMediaTrasfter();
    void StartPreview(int device_id, void* hwnd, int width, int height, int fps);
    void onTimer(const pj::OnTimerParam &prm);
    void videoConference(bool OneConnect);
    void videoCallmargeWork(int id);
    
    void unholdAllCall();
    void sigleValuePop();
    
    
    
    // Vidoe Call Funcation
    void previewStop();
    void CameraDirationChange(int type);
    void update_video(void (*funcpntr)(void *));
    void videoview_update_video(void (*funcpntr)(void *));
    
    // Block OR unBlock
    void callBlock(const std::string& contact);
    void uncallBlock(const std::string& contact);
    void lodeBolckNumber();
    
    
    void previewHide();
    void previewShow();
    
    // Test Perpous
    
    void acc_listener(void (*function)(bool));

    
};

class BlockedContactsManager {
public:
    static BlockedContactsManager& getInstance() {
        static BlockedContactsManager instance;
        return instance;
    }
    
    void blockContact(const std::string& contact);
    
    void unblockContact(const std::string& contact);
    
    bool isContactBlocked(const std::string& contact);
    
    void saveBlockedContacts();
    
    void loadBlockedContacts();
    
    std::set<std::string> blockedContacts;

    BlockedContactsManager() {
//        loadBlockedContacts();
    }
    BlockedContactsManager(const BlockedContactsManager&);
    BlockedContactsManager& operator=(const BlockedContactsManager&);
};
