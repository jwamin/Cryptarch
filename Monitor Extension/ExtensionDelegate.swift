//
//  ExtensionDelegate.swift
//  Monitor Extension
//
//  Created by Joss Manger on 3/11/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    var values:NSDictionary = NSDictionary()
    var interface:InterfaceController!
    var cryptoPrice:BTCPriceModel?
    var active:Bool = false
    func applicationDidFinishLaunching() {
        
        
        if(WCSession.isSupported()){
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        // Perform any final initialization of your application.
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        print("resigning active")
        if(self.cryptoPrice != nil){
            active = false
            print("cryptoprice is active, halting and resetting interface")
            cryptoPrice?.pauseAndInvalidate()
            interface.layoutTable()
        }
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}

extension ExtensionDelegate: WCSessionDelegate {
    
    func refresh(sender: InterfaceController){
        let message = ["method":"refresh"]
        print("refresh called on WKED")
        if(interface==nil){
            interface = sender
        }
        
        if(self.cryptoPrice==nil){
            self.cryptoPrice = BTCPriceModel(backgroundTaskIdentifier:"watchBackgroundTask")
             self.cryptoPrice?.delegate = sender
            
        }
        active = true;
       
        WCSession.default.sendMessage(message, replyHandler: { (thing) in
           print("replyhandler")
        }, errorHandler: { (err) in
            print("watch error")
        });
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activated \(activationState == WCSessionActivationState.activated)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("thingy")
        
        let reply = message["reply"] as! NSDictionary
        
        self.values = reply
        if(active){
            self.cryptoPrice?.getUpdateBitcoinPrice()
        }
        
    }
    
}
