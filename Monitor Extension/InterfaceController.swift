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
        
        total.setText("loading...")

        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        
        
    }
    
    override func didAppear() {
        print("hello")
       refresh()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        print("\(table) select \(rowIndex)")
        refresh()
    }
    
    func layoutTable(){
        table.setNumberOfRows(polling.count, withRowType: "Main")
        
        if(delegate.values.count>0){
            var count = 0;
            var totalFl:Float = 0.0
            for (key,item) in delegate.values["reply"] as! NSDictionary {
                print(key,item)
                let row = self.table.rowController(at: count) as! TableItem
                row.currencyLabel.setText(key as! String)
                let holding = item as! Float;
                let rate = delegate.cryptoPrice!.cryptoRates[key as! String] as! Float
                
                let calc = (holding * rate)
                totalFl+=calc
                //let calc = Float(item as! String)! * (delegate.cryptoPrice!.cryptoRates[key as! String] as! Float))
                
                //row.valueLabel.setText("$"+String(calc))
                row.valueLabel.setText("$"+String(calc))
                count+=1;
            }
            total.setText("$"+String(totalFl))
            ago.setDate(Date.init())
            ago.start()
        } else {
            var count = 0;
            for item in polling {
                let row = self.table.rowController(at: count) as! TableItem
                row.currencyLabel.setText(item.stringValue())
                row.valueLabel.setText(item.stringValue())
                count+=1;
            }
        }
        

    }

    func updatedPrice() {
        let gotValue = delegate.values
        print("eee value")
        print(delegate.values["reply"])
        
       layoutTable()
        
    }

    func silentFail() {
        
    }
    
    func displayError() {
        
    }
    
    func refresh(){
        
       ago.stop()
        delegate.refresh(sender: self)
    }
    
    
}


class TableItem : NSObject {
    
    @IBOutlet var currencyLabel: WKInterfaceLabel!
    @IBOutlet var valueLabel: WKInterfaceLabel!
    
    
}
