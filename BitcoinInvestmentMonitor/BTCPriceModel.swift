//
//  BTCPriceModel.swift
//  BitcoinInvestmentMonitor
//
//  Created by Joss Manger on 12/7/17.
//  Copyright © 2017 Joss Manger. All rights reserved.
//

import UIKit

protocol BTCPriceDelegate {
    func updatedPrice()
    func displayError()
    func silentFail()
}

struct TaskRecord {
    var data:Data!
    var active:Bool!
    let id:Int!
    let ticker:CryptoTicker
    
    init(id:Int,ticker:CryptoTicker){
        self.id = id
        self.ticker = ticker
        active=true
        data=Data()
    }
    
}

class BTCPriceModel: NSObject,URLSessionDataDelegate {
    
    var btcRate:Float!
    var cryptoRates:Dictionary<String,Float> = [:]
    var delegate:BTCPriceDelegate?
    var backgroundID:String!
    
    var session:URLSession!
    
    //    var  dispatch_group: DispatchGroup? = DispatchGroup()
    
    static let polling:Array<CryptoTicker> = [.btc,.ltc,.eth]
    
    init(backgroundTaskIdentifier:String) {
        super.init()
        //seed initial value of zero
        //let queue = OperationQueue()
        backgroundID=backgroundTaskIdentifier
        btcRate = 0.0
        for cryp in BTCPriceModel.polling{
            cryptoRates[cryp.stringValue()] = 0.0
        }
    }
    
    func killAll(){
        print("got kill All, removing observer, shanking dispatch group")
        
        //        dispatch_group = nil
        self.delegate?.silentFail()
        
        
    }
    
    var tasks:[TaskRecord] = []
    
    func getUpdateBitcoinPrice(){
        
        tasks = []
        
        if(session == nil){
           session = URLSession(configuration: URLSessionConfiguration.background(withIdentifier: backgroundID), delegate: self, delegateQueue: nil)
        }
        
        for ticker in BTCPriceModel.polling{
            
            request(ticker:ticker)
            
        }
        
        
    }
    
    
    func request(ticker:CryptoTicker){
        
        let cburl = "https://api.coinbase.com/v2/prices/"+ticker.stringValue()+"-USD/spot"
        //"https://api.coindesk.com/v1/bpi/currentprice.json"
        if let url = URL(string:cburl){
            
            let task = session.dataTask(with: url)
            let taskItem =  TaskRecord(id: task.taskIdentifier, ticker: ticker)
            tasks.append(taskItem)
            task.resume()
        }
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print(dataTask.taskIdentifier)
        for (index,taskObj) in tasks.enumerated() {
            
            if(dataTask.taskIdentifier==taskObj.id){
                tasks[index].data.append(data)
            }
            
        }
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        self.session = nil
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        var finished = true;
        
        for (index,taskObj) in tasks.enumerated() {
            
            if(task.taskIdentifier==taskObj.id){
                tasks[index].active = false
            } else {
                if(taskObj.active==true){
                    finished = false
                }
            }
            
            
        }
        
        if(finished==false){
            print("not complete")
            return
        }
        
        for taskItem in tasks{
            
            do{
                let dict = try JSONSerialization.jsonObject(with: taskItem.data, options: .init(rawValue: 0)) as! Dictionary<String,Any>
                
                if let data = dict["data"] as? Dictionary<String,Any>{
                    
                    if let rate = data["amount"] as? NSString{
                        if(taskItem.ticker == .btc){
                            self.btcRate = rate.floatValue
                        }
                        
                        self.cryptoRates[taskItem.ticker.stringValue()] = rate.floatValue
                        
                    } else {
                        print("fail at rate")
                    }
                }
                
            } catch {
                print(tasks)
                fatalError()
            }
        }
        //finally
        print(cryptoRates, "cryptorates")
        self.session.finishTasksAndInvalidate()
        self.delegate?.updatedPrice()
    }
    
    func pauseAndInvalidate(){
        
        if(session != nil){
            tasks = []
              session.invalidateAndCancel()
            
        }
      
    }


func processInfo(buy:Buy) -> Dictionary<String,String>{
    
    //REFACTOR THE SHIT OUT OF THIS TO RETURN STRUCT
    
    
    //print(buy.btcAmount,buy.cryptoCurrency)
    var buyDict:Dictionary<String,String> = [:]
    let dateF = DateFormatter()
    dateF.dateFormat = "yyyy-MM-dd"
    let originalPrice = buy.btcAmount * Float(buy.btcRateAtPurchase)
    let currentPrice = buy.btcAmount * cryptoRates[buy.cryptoCurrency!]!;
    let appreciationDecimal = currentPrice / originalPrice;
    let actualDecimal = (appreciationDecimal>1) ? appreciationDecimal-1 : 1-appreciationDecimal
    buyDict["buy"] = String(buy.btcAmount)
    buyDict["date"] = dateF.string(from: buy.dateOfPurchase! as Date)
    buyDict["actualDecimal"] = String(actualDecimal)
    buyDict["rateAtBuy"] = String(buy.btcRateAtPurchase)
    buyDict["priceAtBuy"] = String(originalPrice)
    buyDict["currentRate"] = String(cryptoRates[buy.cryptoCurrency!]!)
    buyDict["currency"] = String(cryptoRates[buy.cryptoCurrency!]!)
    //print(buy.cryptoCurrency,CryptoTicker.ticker(ticker: buy.cryptoCurrency))
    buyDict["currentPrice"] = String(format: "%.2f", arguments: [currentPrice])
    buyDict["appreciation"] = String(format: "%.2f", arguments:[(actualDecimal * 100)])+"%";
    buyDict["direction"] = (appreciationDecimal>1) ? "up" : "down"
    
    return buyDict
}

}
