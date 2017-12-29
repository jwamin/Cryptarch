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
    func updatedCore()
}


class CDBTCManager: NSObject {

    let appDelegate:AppDelegate
    let managedObjectContext:NSManagedObjectContext
    var fetchedBuys:[Buy] = []
    var delegate:BTCManagerDelegate?
    
    override init() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistentContainer.newBackgroundContext()
    }
    
    func initEntity(){
        
        print("initialising entity")
        let buysFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Buy")
        
        do {
            
            fetchedBuys = try managedObjectContext.fetch(buysFetch) as! [Buy]
            delegate?.updatedCore()
            print(fetchedBuys,fetchedBuys.count)
        } catch {
            
            fatalError("Failed to fetch Buys: \(error)")
            
        }
        
    }
    
    func commitToCore(buyInfo:Dictionary<String,String>){
        let obj = NSEntityDescription.insertNewObject(forEntityName: "Buy", into: managedObjectContext) as! Buy
        
        //add buy info to object
        let dateF = DateFormatter()
        dateF.dateFormat = "yyyy-MM-dd"
        
        
        obj.dateOfPurchase = dateF.date(from: buyInfo["date"]!) ?? Date()
        obj.btcAmount = Float(buyInfo["btcAmount"] ?? "0.01") ?? 0.01
        obj.btcRateAtPurchase = Double(buyInfo["btcRate"] ?? "7800.120") ?? 7800.120
        obj.cryptoCurrency = buyInfo["currency"]
        
        do {
            
            try managedObjectContext.save()
            fetchedBuys.append(obj)
            delegate?.updatedCore()
            
        } catch {
            
            fatalError()
            
        }
        
    }
    
    func clearCore(id:NSManagedObjectID){
        
        do {
            let object = try managedObjectContext.existingObject(with: id)
            managedObjectContext.delete(object)
            try managedObjectContext.save()
            for (index,buy) in fetchedBuys.enumerated() {
                if(buy.objectID==id){
                    fetchedBuys.remove(at: index)
                }
            }
            //fetchedBuys.remove(at: index)
            delegate?.updatedCore()

        } catch {
            fatalError("Failed to fetch buys: \(error)")
        } 
    }
    
}
