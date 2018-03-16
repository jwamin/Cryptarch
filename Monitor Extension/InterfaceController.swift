//
//  InterfaceController.swift
//  Monitor Extension
//
//  Created by Joss Manger on 3/11/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation

let polling:[CryptoTicker] = [.btc,.ltc,.eth]


class InterfaceController: WKInterfaceController, BTCPriceDelegate {
    
    let delegate = WKExtension.shared().delegate as! ExtensionDelegate
    @IBOutlet var total: WKInterfaceLabel!
    
    @IBOutlet var table: WKInterfaceTable!
    
    @IBOutlet var ago: WKInterfaceTimer!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        refresh()
        
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
      
        
    }
    
    
    override func willDisappear() {
        ago.stop()
        ago.setHidden(true)
    }
    
    override func didAppear() {
       print("visible")
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    

    
    func layoutTable(){
        
        
        if(delegate.values.count>0){
            table.setNumberOfRows(delegate.values.count, withRowType: "Main")
            var count = 0;
            var totalFl:Float = 0.0
            for (key,item) in delegate.values {
                print(key,item)
                let row = self.table.rowController(at: count) as! TableItem
                let labelText = key as! String
                row.currencyLabel.setText(labelText)
                let holding = item as! Float;
                let rate = delegate.cryptoPrice!.cryptoRates[labelText]!
                
                let calc = (holding * rate)
                totalFl+=calc
                //let calc = Float(item as! String)! * (delegate.cryptoPrice!.cryptoRates[key as! String] as! Float))
                
                //row.valueLabel.setText("$"+String(calc))
                row.valueLabel.setText(String(format: "$%.2f",calc))
                count+=1;
            }
            total.setText("$"+String(totalFl))
            ago.setHidden(false)
            ago.setDate(Date.init())
            ago.start()
        } else {
            table.setNumberOfRows(0, withRowType: "Main")
            total.setText("Buy Crypto!")
        }
        
        
    }
    
    @IBAction func refreshMenuItem() {
        refresh()
    }
    func updatedPrice() {
        print("got updated price, laying out table")
        layoutTable()
        
    }
    
    func silentFail() {
        
    }
    
    func displayError() {
        
    }
    
    func refresh(){
        total.setText("updating...")
        table.setNumberOfRows(0, withRowType: "Main")
        ago.stop()
        ago.setHidden(true)
        delegate.refresh(sender: self)
        
    }
    
    
}


class TableItem : NSObject {
    
    @IBOutlet var currencyLabel: WKInterfaceLabel!
    @IBOutlet var valueLabel: WKInterfaceLabel!
    
    
}
