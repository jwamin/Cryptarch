//
//  AppDelegate.swift
//  BitcoinInvestmentMonitor
//
//  Created by Joss Manger on 12/7/17.
//  Copyright © 2017 Joss Manger. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {


    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if(WCSession.isSupported()){
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "BTCModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
      // MARK: - WatchConnectivity
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("deactivated wc session")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("activated wc session")
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(activationState==WCSessionActivationState.activated)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("got message \(message)")
        if(WCSession.default.isReachable){
            
            let context = self.persistentContainer.viewContext
            
            let buysFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Buy")
            var fetchedBuys:[Buy] = []
            
                    do {
                        
                            fetchedBuys = try context.fetch(buysFetch) as! [Buy]

                    } catch {
            
                        fatalError("Failed to fetch Buys: \(error)")
            
                    }
            
            let rates = BTCPriceModel()
            rates.getUpdateBitcoinPrice()
            if(message["method"] as! String=="refresh"){
                
                var replyBody:[String:Float] = [:]
                for items in fetchedBuys{
                    if(replyBody[items.cryptoCurrency!] != nil){
                        replyBody[items.cryptoCurrency!] = items.btcAmount + replyBody[items.cryptoCurrency!]!
                    } else {
                        replyBody[items.cryptoCurrency!] = items.btcAmount
                    }
                }
                
                print(rates.cryptoRates)
                for (key,value) in rates.cryptoRates{
                    if let fl = replyBody[key]{
                        replyBody[key] = fl * value
                    }
                }
                
                var reply = ["reply":replyBody];
                print(fetchedBuys)
                print("meesage on appdel")
                WCSession.default.sendMessage(reply, replyHandler: {(replyMessage) in
                    print(replyMessage,fetchedBuys)
                    print("meesage on appdel")
                }, errorHandler: nil)
                
            } else {
                print("not refresh?")
            }
        } else {
            print("not reachable")
        }
    }
    
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        print("got message \(message)")
//        if(WCSession.default.isReachable){
//            if(message["method"] as! String=="refresh"){
//                let reply = ["hello":"hello world from appd"]
//               WCSession.default.sendMessage(reply, replyHandler: {(replyMessage) in
//                print(replyMessage)
//                print("meesage on appdel")
//                }, errorHandler: nil)
//
//            } else {
//                print("not refresh?")
//            }
//        } else {
//            print("not reachable")
//        }
//    }
    

}

