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
    
    var taskNumber = 0
    var responses:Dictionary<String,Data> = [:]
    var map:Dictionary<String,Int>?
    
    func getUpdateBitcoinPrice(){
        
        map = [:]
        responses = [:]
        session = URLSession(configuration: URLSessionConfiguration.background(withIdentifier: backgroundID), delegate: self, delegateQueue: nil)
        for ticker in BTCPriceModel.polling{
            taskNumber+=1
            request(ticker:ticker)
            
        }
        
//        dispatch_group?.notify(queue: .main, execute: {
//            print("tasks done",self.cryptoRates)
//
//
//        })

        
        
        
    }
    
    
    func request(ticker:CryptoTicker){
//        if (dispatch_group === nil){
//            print("rebuilding dispatch group")
//            dispatch_group = DispatchGroup()
//        }
        //dispatch_group?.enter()
        let cburl = "https://api.coinbase.com/v2/prices/"+ticker.stringValue()+"-USD/spot"
        //"https://api.coindesk.com/v1/bpi/currentprice.json"
        if let url = URL(string:cburl){
            
            let task = session.dataTask(with: url)
            map?[ticker.stringValue()]=task.taskIdentifier
            responses[String(task.taskIdentifier)] = Data()
            task.resume()
        }
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print(dataTask.taskIdentifier)
        responses[String(dataTask.taskIdentifier)]?.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

        taskNumber-=1

        
        if(taskNumber==0){

            for (responsekey,responsedata) in responses{
                
                var ticker = CryptoTicker(rawValue: 0)
                
                if let gotMap = map{
                    for (key,id) in gotMap{
                        if(String(id)==responsekey){
                            ticker = CryptoTicker.ticker(ticker: key)
                        }
                        
                    }
                    
                } else {
                    fatalError()
                }
                
          
                do{
                    let dict = try JSONSerialization.jsonObject(with: responsedata, options: .init(rawValue: 0)) as! Dictionary<String,Any>
                    print(dict)
                    
                      if let data = dict["data"] as? Dictionary<String,Any>{

                                    if let rate = data["amount"] as? NSString{
                                        if(ticker == .btc){
                                            self.btcRate = rate.floatValue
                                        }
                                       
                                        self.cryptoRates[ticker!.stringValue()] = rate.floatValue
                                       
                                    } else {
                                        print("fail at rate")
                                    }
                                 }
                    
                } catch {
                    fatalError()
                }
            }
            //finally
            print(cryptoRates, "cryptorates")
            self.session.finishTasksAndInvalidate()
             self.delegate?.updatedPrice()
        } else {
            print("tasks remaining \(taskNumber)")
        }

    }

    func processInfo(buy:Buy) -> Dictionary<String,String>{
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
