//
//  CDBTCManager.swift
//  BitcoinInvestmentMonitor
//
//  Created by Joss Manger on 12/7/17.
//  Copyright © 2017 Joss Manger. All rights reserved.
//

import UIKit
import CoreData

protocol BTCManagerDelegate {
    //func updatedCore()
    func establishedController()
}


class CDBTCManager: NSObject,BTCPriceDelegate {

    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var managedObjectContext: NSManagedObjectContext? = nil
    var fetchedBuys:[Buy] = []
    var delegate:BTCManagerDelegate?
    var btcPriceMonitor:BTCPriceModel!
    
    var parent:MainViewController!
    
    init(_ parent:MainViewController) {
        super.init()
        managedObjectContext = appDelegate.persistentContainer.viewContext
        btcPriceMonitor = BTCPriceModel(self)
        self.parent = parent
    }
    
    
    
    //delegation of price model
    
    func updatedPrice() {
        parent.updatedPrice()
    }
    
    func silentFail() {
        parent.silentFail()
    }
    
    func displayError() {
        parent.displayError()
    }
    
    
    func initEntity(){
        
        print("initialising entity")
        //print(fetchedResultsController.fetchedObjects)
//        let buysFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Buy")
//
//        do {
//            let context = fetchedResultsController.managedObjectContext
//            fetchedBuys = try context.fetch(buysFetch) as! [Buy]
//            delegate?.updatedCore()
//            //print(fetchedBuys,fetchedBuys.count)
//        } catch {
//
//            fatalError("Failed to fetch Buys: \(error)")
//
//        }
        
    }
    
    func updateToCore(){
        let context = fetchedResultsController.managedObjectContext
        do {
            print("doing core update")
            try context.save()
            
     
            
        } catch {
            print("core commit failed")
            fatalError()
            
        }
        
    }
    
    func commitToCore(buyInfo:Dictionary<String,String>){
        let context = fetchedResultsController.managedObjectContext
        let obj = Buy(context: context)
        
        //add buy info to object
        let dateF = DateFormatter()
        dateF.dateFormat = "yyyy-MM-dd"
        
        
        obj.dateOfPurchase = dateF.date(from: buyInfo["date"]!) ?? Date()
        obj.btcAmount = Float(buyInfo["btcAmount"] ?? "0.01") ?? 0.01
        obj.btcRateAtPurchase = Double(buyInfo["btcRate"] ?? "7800.120") ?? 7800.120
        obj.cryptoCurrency = buyInfo["currency"]
        
        do {
            print("doing core commit")
            try context.save()
            
            //local, use array
            //fetchedBuys.append(obj) // do i need this?
            //delegate?.updatedCore()
            
            //OR
            //Reload
            //initEntity()
            
        } catch {
            print("core commit failed")
            fatalError()
            
        }
        
    }
    
//    func clearCore(indexPath:IndexPath){
//        
//    }
//    
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<Buy> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Buy> = Buy.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "dateOfPurchase", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "cryptoCurrency", cacheName: "Master")
        aFetchedResultsController.delegate = self.delegate as? NSFetchedResultsControllerDelegate
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<Buy>? = nil

    
}
