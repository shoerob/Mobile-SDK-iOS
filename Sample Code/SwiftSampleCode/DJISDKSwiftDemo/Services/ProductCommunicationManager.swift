//
//  ProductCommunicationManager.swift
//  SDK Swift Sample
//
//  Created by Arnaud Thiercelin on 3/22/17.
//  Copyright © 2017 DJI. All rights reserved.
//

import UIKit
import DJISDK

class ProductCommunicationManager: NSObject {

    // Set this value to true to use the app with the Bridge and false to connect directly to the product
    let enableBridgeMode = false
    
    // When enableBridgeMode is set to true, set this value to the IP of your bridge app.
    let bridgeAppIP = "10.81.55.116"
    
    func registerWithSDK() {
        let appKey = Bundle.main.object(forInfoDictionaryKey: SDK_APP_KEY_INFO_PLIST_KEY) as? String
        
        guard appKey != nil && appKey!.isEmpty == false else {
            NSLog("Please enter your app key in the info.plist")
            return
        }
        
        //
        // MARK: LDM Enable Attempts
        //  Please enable one LDM method at a time per-run, to see if they work.
        //
        
//        self.AttemptToUseLDM_1()
//        self.AttemptToUseLDM_2()
        self.AttemptToUseLDM_3()
    }
    
    // Attempt #1
    //   This code attempts to enable LDM as described in the DJI documentation.
    //
    //   According to the DJI SDK documentation for:
    //   - (void)enableLDMWithCompletion:(void (^_Nonnull)(NSError *_Nullable error))completion;
    //   /**
    //   *  Enables LDM. Can only be enabled if `isLDMSupported` is `YES`. Please call
    //   *  `getIsLDMSupportedWithCompletion` methods firstly.  Call this method before
    //   *  calling the other methods of SDK (including `registerAppWithDelegate`) to
    //   *  restrict the internet access  of SDK (SDK registration is unrestricted).
    //   */
    //
    // Resulting Output:
    //   DEBUG -- getIsLDMSupported: false, The drone is not connect(code:-12000)
    //
    // Conclusion(s): Does NOT work. The observer for DJILDMManagerSupportedChanged is NEVER called. registerApp NEVER occurs.
    //
    // MARK: LDM Attempt #1
    func AttemptToUseLDM_1() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.DJILDMManagerSupportedChanged, object: nil, queue: nil) { [unowned self] (notification) in
            let isSupported = DJISDKManager.ldmManager().isLDMSupported
            let isEnabled = DJISDKManager.ldmManager().isLDMEnabled
            print("DEBUG -- DJILDMManagerSupportedChanged -- isSupported: \(isSupported) -- isEnabled: \(isEnabled)")
            
            if isSupported == true {
                if !DJISDKManager.hasSDKRegistered() {
                    DJISDKManager.registerApp(with: self)
                }
                
                if !DJISDKManager.ldmManager().isLDMEnabled {
                    DJISDKManager.ldmManager().enableLDM { (error) in
                        print("DEBUG -- enableLDM Result: \(error?.localizedDescription ?? "nil")")
                    }
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.DJILDMManagerEnabledChanged, object: nil, queue: nil) { (notification) in
            let isSupported = DJISDKManager.ldmManager().isLDMSupported
            let isEnabled = DJISDKManager.ldmManager().isLDMEnabled
            print("DEBUG -- DJILDMManagerEnabledChanged -- isSupported: \(isSupported) -- isEnabled: \(isEnabled)")
        }

        DJISDKManager.ldmManager().getIsLDMSupported { (isSupported, error) in
            print("DEBUG -- getIsLDMSupported: \(isSupported), \(error?.localizedDescription ?? "nil")")
        }
    }
    
    // MARK: LDM Attempt #2
    //   This code registers the app with DJI before attempting to enable LDM.
    //
    // Resulting Output:
    //   2020-11-02 12:40:02.415351-0600 DJISDKSwiftDemo[2087:808203] SDK Registered with error nil
    //   DEBUG -- getIsLDMSupported: false, The drone is not connect(code:-12000)
    //   DJILDMManagerSupportedChanged -- isSupported: false -- isEnabled: false
    //
    // Conclusion(s): Does NOT work. isSupported is always FALSE.
    //
    func AttemptToUseLDM_2() {
        DJISDKManager.registerApp(with: self)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.DJILDMManagerSupportedChanged, object: nil, queue: nil) { (notification) in
            let isSupported = DJISDKManager.ldmManager().isLDMSupported
            let isEnabled = DJISDKManager.ldmManager().isLDMEnabled
            print("DEBUG -- DJILDMManagerSupportedChanged -- isSupported: \(isSupported) -- isEnabled: \(isEnabled)")
            
            if isSupported == true {
                if !DJISDKManager.hasSDKRegistered() {
                    DJISDKManager.registerApp(with: self)
                }
                
                if !DJISDKManager.ldmManager().isLDMEnabled {
                    DJISDKManager.ldmManager().enableLDM { (error) in
                        print("DEBUG -- enableLDM Result: \(error?.localizedDescription ?? "nil")")
                    }
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.DJILDMManagerEnabledChanged, object: nil, queue: nil) { (notification) in
            let isSupported = DJISDKManager.ldmManager().isLDMSupported
            let isEnabled = DJISDKManager.ldmManager().isLDMEnabled
            print("DEBUG -- DJILDMManagerEnabledChanged -- isSupported: \(isSupported) -- isEnabled: \(isEnabled)")
        }

        DJISDKManager.ldmManager().getIsLDMSupported { (isSupported, error) in
            print("DEBUG -- getIsLDMSupported: \(isSupported), \(error?.localizedDescription ?? "nil")")
        }
    }
    
    // MARK: LDM Attempt #3
    //   This code registers the app with DJI before attempting to enable LDM. It also uses an async dispatch to execute the
    //   getIsLDMSupported call.
    //
    // Resulting Output:
    //   2020-11-02 12:40:02.415351-0600 DJISDKSwiftDemo[2087:808203] SDK Registered with error nil
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: false -- isEnabled: false
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: false -- isEnabled: false
    //   DEBUG -- getIsLDMSupported: false, The drone is not connect(code:-12000)
    //
    // Conclusion(s): Does NOT work. isSupported is always FALSE.
    //
    func AttemptToUseLDM_3() {
        DJISDKManager.registerApp(with: self)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.DJILDMManagerSupportedChanged, object: nil, queue: nil) { (notification) in
            let isSupported = DJISDKManager.ldmManager().isLDMSupported
            let isEnabled = DJISDKManager.ldmManager().isLDMEnabled
            print("DEBUG -- DJILDMManagerSupportedChanged -- isSupported: \(isSupported) -- isEnabled: \(isEnabled)")
            
            if isSupported == true {
                if !DJISDKManager.hasSDKRegistered() {
                    DJISDKManager.registerApp(with: self)
                }
                
                if !DJISDKManager.ldmManager().isLDMEnabled {
                    DJISDKManager.ldmManager().enableLDM { (error) in
                        print("DEBUG -- enableLDM Result: \(error?.localizedDescription ?? "nil")")
                    }
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.DJILDMManagerEnabledChanged, object: nil, queue: nil) { (notification) in
            let isSupported = DJISDKManager.ldmManager().isLDMSupported
            let isEnabled = DJISDKManager.ldmManager().isLDMEnabled
            print("DEBUG -- DJILDMManagerEnabledChanged -- isSupported: \(isSupported) -- isEnabled: \(isEnabled)")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            DJISDKManager.ldmManager().getIsLDMSupported { (isSupported, error) in
                print("DEBUG -- getIsLDMSupported: \(isSupported), \(error?.localizedDescription ?? "nil")")
            }
        }
    }
}

extension ProductCommunicationManager : DJISDKManagerDelegate {
    func didUpdateDatabaseDownloadProgress(_ progress: Progress) {
        NSLog("SDK downloading db file \(progress.completedUnitCount / progress.totalUnitCount)")
    }
    
    func appRegisteredWithError(_ error: Error?) {
        
        NSLog("SDK Registered with error \(error?.localizedDescription)")
        
        if enableBridgeMode {
            DJISDKManager.enableBridgeMode(withBridgeAppIP: bridgeAppIP)
        } else {
            DJISDKManager.startConnectionToProduct()
        }
        
    }
    
    func productConnected(_ product: DJIBaseProduct?) {
        
    }
    
    func productDisconnected() {
        
    }
    
    func componentConnected(withKey key: String?, andIndex index: Int) {
        
    }
    
    func componentDisconnected(withKey key: String?, andIndex index: Int) {
        
    }
}
