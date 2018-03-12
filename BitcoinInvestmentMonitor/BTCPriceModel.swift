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

class BTCPriceModel: NSObject {

    var btcRate:Float
    var cryptoRates:Dictionary<String,Float> = [:]
    var delegate:BTCPriceDelegate?
    var  dispatch_group: DispatchGroup? = DispatchGroup()
    
    static let polling:[CryptoTicker] = [.btc,.ltc,.eth]
    
    override init() {
        //seed initial value of zero
        btcRate = 0.0
        for cryp in BTCPriceModel.polling{
            cryptoRates[cryp.stringValue()] = 0.0
        }
    }
    
    @objc func killAll(){
        print("got kill All, removing observer, shanking dispatch group")
    
        dispatch_group = nil
        self.delegate?.silentFail()
        
        
        //shouldnt be in model... I guess.
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)
    }
    
    func getUpdateBitcoinPrice(){
        
        //Dispatch queue multiple async tasks, finally return tuple
        NotificationCenter.default.addObserver(self, selector: #selector(killAll), name: .UIApplicationWillResignActive, object: nil)
        
        for ticker in BTCPriceModel.polling{
            
            request(ticker:ticker)
            
        }
        
        dispatch_group?.notify(queue: .main, execute: {
            print("tasks done",self.cryptoRates)
            NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)
            self.delegate?.updatedPrice()
        })

        
        
        
    }
    
    
    func request(ticker:CryptoTicker){
        if (dispatch_group === nil){
            print("rebuilding dispatch group")
            dispatch_group = DispatchGroup()
        }
        dispatch_group?.enter()
        let cburl = "https://api.coinbase.com/v2/prices/"+ticker.stringValue()+"-USD/spot"
        //"https://api.coindesk.com/v1/bpi/currentprice.json"
        if let url = URL(string:cburl){
            var errorPointer:Error?
            let task = URLSession.shared.dataTask(with: url, completionHandler: {
                (data, response, error) in
                if let gotError = error{
                    errorPointer = gotError
                    print(errorPointer as Any)
                    self.delegate?.displayError()
                } else {
                    
                    do{
                        let dict = try JSONSerialization.jsonObject(with: data!, options: .init(rawValue: 0)) as! Dictionary<String,Any>
                        print(dict)
                        
                        if let data = dict["data"] as? Dictionary<String,Any>{
                            
                            //print(usd)
                            if let rate = data["amount"] as? NSString{
                                if(ticker == .btc){
                                    self.btcRate = rate.floatValue
                                }
                                self.cryptoRates[ticker.stringValue()] = rate.floatValue
                                self.dispatch_group?.leave()
                            } else {
                                print("fail at rate")
                            }
                        }
                        
                    } catch {
                        fatalError()
                    }
                    
                }
            })
            
            task.resume()
        }
    }
    
    
    func processInfo(buy:Buy) -> Dictionary<String,String>{
        print(buy.btcAmount,buy.cryptoCurrency)
        var buyDict:Dictionary<String,String> = [:]
        let dateF = DateFormatter()
        dateF.dateFormat = "yyyy-MM-dd"
        let originalPrice = buy.btcAmount * Float(buy.btcRateAtPurchase)
        let currentPrice = buy.btcAmount * cryptoRates[buy.cryptoCurrency!]!;
        let appreciationDecimal = currentPrice / originalPrice;
        let actualDecimal = (appreciationDecimal>1) ? appreciationDecimal-1 : 1-appreciationDecimal
        buyDict["buy"] = String(buy.btcAmount)
        buyDict["date"] = dateF.string(from: buy.dateOfPurchase!)

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
