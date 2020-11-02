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
    
    var attemptToEnableLDMAfterRegistrationSucceeds: Bool = false
    var attemptToEnableLDMAfterProductConnects: Bool = false
    var attemptToEnableLDMWithAsyncAfterProductConnects: Bool = false
    
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
//        self.AttemptToUseLDM_3()
//        self.AttemptToUseLDM_4()
//        self.AttemptToUseLDM_5()
        self.AttemptToUseLDM_6() // This works, but has caveats.
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
    // Conclusion(s): FAILURE. Does NOT work. The observer for DJILDMManagerSupportedChanged is NEVER called. registerApp NEVER occurs.
    //
    // MARK: LDM Attempt #1 (FAILURE)
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
    
    // MARK: LDM Attempt #2 (FAILURE)
    //   This code registers the app with DJI before attempting to enable LDM.
    //
    // Resulting Output:
    //   2020-11-02 12:40:02.415351-0600 DJISDKSwiftDemo[2087:808203] SDK Registered with error nil
    //   DEBUG -- getIsLDMSupported: false, The drone is not connect(code:-12000)
    //   DJILDMManagerSupportedChanged -- isSupported: false -- isEnabled: false
    //
    // Conclusion(s): FAILURE. Does NOT work. isSupported is always FALSE.
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
    
    // MARK: LDM Attempt #3 (FAILURE)
    //   This code registers the app with DJI before attempting to enable LDM. It also uses an async dispatch to execute the
    //   getIsLDMSupported call.
    //
    // Resulting Output:
    //   2020-11-02 12:40:02.415351-0600 DJISDKSwiftDemo[2087:808203] SDK Registered with error nil
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: false -- isEnabled: false
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: false -- isEnabled: false
    //   DEBUG -- getIsLDMSupported: false, The drone is not connect(code:-12000)
    //
    // Conclusion(s): FAILURE. Does NOT work. isSupported is always FALSE.
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
    
    // MARK: LDM Attempt #4 (FAILURE)
    //   This code registers the app with DJI before attempting to enable LDM. Once app registration succeeds,
    //   getIsLDMSupported is called from the appRegisteredWithError delegate callback method.
    //
    //
    // Resulting Output:
    //   2020-11-02 13:07:38.562171-0600 DJISDKSwiftDemo[2135:817559] SDK Registered with error nil
    //   DEBUG -- getIsLDMSupported: false, The drone is not connect(code:-12000)
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: false -- isEnabled: false
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: false -- isEnabled: false
    //
    // Conclusion(s): FAILURE. Does NOT work. isSupported is always FALSE.
    //
    func AttemptToUseLDM_4() {
        self.attemptToEnableLDMAfterRegistrationSucceeds = true
        
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
    }
    
    // MARK: LDM Attempt #5 (FAILURE)
    //   This code registers the app with DJI before attempting to enable LDM. Once app registration succeeds,
    //   getIsLDMSupported is called from the productConnected delegate callback method.
    //
    //
    // Resulting Output:
    //
    //   Run #1 - Install application FROM SCRATCH. Start application. Plug in DJI controller to iPad after started. (SUCCESS)
    //
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: false -- isEnabled: false
    //   2020-11-02 13:21:41.453384-0600 DJISDKSwiftDemo[2187:824957] SDK Registered with error nil
    //   ----- NOTE: Plugged in Controller Here -----
    //   DEBUG -- getIsLDMSupported: true, nil
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: true -- isEnabled: false
    //   DEBUG -- enableLDM Result: nil
    //   DEBUG -- DJILDMManagerEnabledChanged -- isSupported: true -- isEnabled: true
    //
    // Conclusion(s): Works.
    //
    //   Run #2a - Re-start the ALREADY INSTALLED application. Plug in DJI controller to iPad after started. (FAILURE)
    //
    //   2020-11-02 13:25:08.305945-0600 DJISDKSwiftDemo[2196:826257] SDK Registered with error nil
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: true -- isEnabled: false
    //   DEBUG -- enableLDM Result: The drone is not connect(code:-12000)
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: true -- isEnabled: false
    //   DEBUG -- enableLDM Result: The drone is not connect(code:-12000)
    //   ----- NOTE: Plugged in Controller Here -----
    //   DEBUG -- getIsLDMSupported: true, nil
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: true -- isEnabled: false
    //   DEBUG -- enableLDM Result: nil
    //   DEBUG -- DJILDMManagerEnabledChanged -- isSupported: true -- isEnabled: true
    //
    //   Run #2b - Re-start the ALREADY INSTALLED application. Plug in DJI controller to iPad after started. (FAILURE)
    //
    //   2020-11-02 13:27:36.105117-0600 DJISDKSwiftDemo[2205:827358] SDK Registered with error nil
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: true -- isEnabled: false
    //   DEBUG -- enableLDM Result: The drone is not connect(code:-12000)
    //   ----- NOTE: Plugged in Controller Here -----
    //   DEBUG -- getIsLDMSupported: false, The drone is not connect(code:-12000)
    //
    //   Run #2c - Re-start the ALREADY INSTALLED application. Plug in DJI controller to iPad after started. (SUCCESS)
    //
    //   2020-11-02 13:30:22.534995-0600 DJISDKSwiftDemo[2214:828483] SDK Registered with error nil
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: true -- isEnabled: false
    //   DEBUG -- enableLDM Result: The drone is not connect(code:-12000)
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: true -- isEnabled: false
    //   DEBUG -- enableLDM Result: The drone is not connect(code:-12000)
    //   ----- NOTE: Plugged in Controller Here -----
    //   DEBUG -- getIsLDMSupported: true, nil
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: true -- isEnabled: false
    //   DEBUG -- enableLDM Result: nil
    //   DEBUG -- DJILDMManagerEnabledChanged -- isSupported: true -- isEnabled: true
    //
    //   Run #3 - Plugin the DJI controller BEFORE starting the app. Re-start the ALREADY INSTALLED application. (FAILURE)
    //
    //   2020-11-02 13:34:59.766597-0600 DJISDKSwiftDemo[2223:829916] SDK Registered with error nil
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: true -- isEnabled: false
    //   DEBUG -- enableLDM Result: The drone is not connect(code:-12000)
    //   DEBUG -- getIsLDMSupported: false, The drone is not connect(code:-12000)
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: true -- isEnabled: false
    //   DEBUG -- enableLDM Result: The drone is not connect(code:-12000)
    //
    //   Conclusion(s): FAILURE. Works sometimes. Does NOT work other times.
    //
    func AttemptToUseLDM_5() {
        self.attemptToEnableLDMAfterProductConnects = true
        
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
    }
    
    // MARK: LDM Attempt #6
    //   This code registers the app with DJI before attempting to enable LDM. Once app registration succeeds,
    //   getIsLDMSupported is called from the productConnected delegate callback method. Unlike attempt #5, an async delay
    //   is introduced BEFORE calling getIsLDMSupported to avert any race conditions that may have happened in the SDK.
    //
    // Resulting Output:
    //
    //   Run #1 - Install application FROM SCRATCH. Start application. Plug in DJI controller to iPad after started. (SUCCESS)
    //
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: false -- isEnabled: false
    //   2020-11-02 13:46:08.848980-0600 DJISDKSwiftDemo[2234:832159] SDK Registered with error nil
    //   ----- NOTE: Plugged in Controller Here -----
    //   DEBUG -- getIsLDMSupported: true, nil
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: true -- isEnabled: false
    //   DEBUG -- enableLDM Result: nil
    //   DEBUG -- DJILDMManagerEnabledChanged -- isSupported: true -- isEnabled: true
    //
    // Conclusion(s): Works.
    //
    //   Run #2a - Re-start the ALREADY INSTALLED application. Plug in DJI controller to iPad after started. (SUCCESS)
    //
    //   2020-11-02 13:49:03.786613-0600 DJISDKSwiftDemo[2243:833384] SDK Registered with error nil
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: true -- isEnabled: false
    //   DEBUG -- enableLDM Result: The drone is not connect(code:-12000)
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: true -- isEnabled: false
    //   DEBUG -- enableLDM Result: The drone is not connect(code:-12000)
    //   DEBUG -- getIsLDMSupported: true, nil
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: true -- isEnabled: false
    //   DEBUG -- enableLDM Result: nil
    //   DEBUG -- DJILDMManagerEnabledChanged -- isSupported: true -- isEnabled: true
    //
    //   Run #2b - Re-start the ALREADY INSTALLED application. Plug in DJI controller to iPad after started.
    //
    //   2020-11-02 13:50:47.116828-0600 DJISDKSwiftDemo[2251:834331] SDK Registered with error nil
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: true -- isEnabled: false
    //   DEBUG -- enableLDM Result: The drone is not connect(code:-12000)
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: true -- isEnabled: false
    //   DEBUG -- enableLDM Result: The drone is not connect(code:-12000)
    //   DEBUG -- getIsLDMSupported: true, nil
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: true -- isEnabled: false
    //   DEBUG -- enableLDM Result: nil
    //   DEBUG -- DJILDMManagerEnabledChanged -- isSupported: true -- isEnabled: true
    //
    //   Run #2c - Re-start the ALREADY INSTALLED application. Plug in DJI controller to iPad after started. (SUCCESS)
    //
    //   2020-11-02 13:52:11.191535-0600 DJISDKSwiftDemo[2260:835319] SDK Registered with error nil
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: true -- isEnabled: false
    //   DEBUG -- enableLDM Result: The drone is not connect(code:-12000)
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: true -- isEnabled: false
    //   DEBUG -- enableLDM Result: The drone is not connect(code:-12000)
    //   DEBUG -- getIsLDMSupported: true, nil
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: true -- isEnabled: false
    //   DEBUG -- enableLDM Result: nil
    //   DEBUG -- DJILDMManagerEnabledChanged -- isSupported: true -- isEnabled: true
    //
    //   Run #3 - Plugin the DJI controller BEFORE starting the app. Re-start the ALREADY INSTALLED application. (SUCCESS)
    //
    //   2020-11-02 13:53:45.472957-0600 DJISDKSwiftDemo[2268:836257] SDK Registered with error nil
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: true -- isEnabled: false
    //   DEBUG -- enableLDM Result: The drone is not connect(code:-12000)
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: true -- isEnabled: false
    //   DEBUG -- enableLDM Result: The drone is not connect(code:-12000)
    //   DEBUG -- getIsLDMSupported: true, nil
    //   DEBUG -- DJILDMManagerSupportedChanged -- isSupported: true -- isEnabled: false
    //   DEBUG -- enableLDM Result: nil
    //   DEBUG -- DJILDMManagerEnabledChanged -- isSupported: true -- isEnabled: true
    //
    //   Conclusion(s): SUCCESS. Works predictably, and consistently.
    //                  HOWEVER, does not enable before app registration, and requires a drone to be plugged in.
    //
    func AttemptToUseLDM_6() {
        self.attemptToEnableLDMWithAsyncAfterProductConnects = true
        
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
        
        if self.attemptToEnableLDMAfterRegistrationSucceeds {
            DJISDKManager.ldmManager().getIsLDMSupported { (isSupported, error) in
                print("DEBUG -- getIsLDMSupported: \(isSupported), \(error?.localizedDescription ?? "nil")")
            }
        }
    }
    
    func productConnected(_ product: DJIBaseProduct?) {
        if self.attemptToEnableLDMAfterProductConnects {
            DJISDKManager.ldmManager().getIsLDMSupported { (isSupported, error) in
                print("DEBUG -- getIsLDMSupported: \(isSupported), \(error?.localizedDescription ?? "nil")")
            }
        } else if self.attemptToEnableLDMWithAsyncAfterProductConnects {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                DJISDKManager.ldmManager().getIsLDMSupported { (isSupported, error) in
                    print("DEBUG -- getIsLDMSupported: \(isSupported), \(error?.localizedDescription ?? "nil")")
                }
            }
       }
    }
    
    func productDisconnected() {
        
    }
    
    func componentConnected(withKey key: String?, andIndex index: Int) {
        
    }
    
    func componentDisconnected(withKey key: String?, andIndex index: Int) {
        
    }
}
