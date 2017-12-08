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
}

class BTCPriceModel: NSObject {

    var btcRate:Float
    var delegate:BTCPriceDelegate?
    override init() {
        btcRate = 0.0
    }
    
    
    func getUpdateBitcoinPrice(){
        DispatchQueue.global(qos: .background).async {
            let cburl = "https://api.coinbase.com/v2/prices/spot?currency=USD"
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
                        //let str = String.init(data: data!, encoding: .utf8)
                        do{
                            let dict = try JSONSerialization.jsonObject(with: data!, options: .init(rawValue: 0)) as! Dictionary<String,Any>
                            print(dict)
                            
                            if let data = dict["data"] as? Dictionary<String,Any>{
                            
                                                                //print(usd)
                                    if let rate = data["amount"] as? NSString{
                                        self.btcRate = rate.floatValue
                                        self.delegate?.updatedPrice()
                                    } else {
                                        print("fail at rate")
                                    }
                            }
//                            if let bpi = dict["bpi"] as? Dictionary<String,Any>{
//                                //print(bpi)
//                                if let usd = bpi["USD"] as? Dictionary<String,Any> {
//
//                                    //print(usd)
//                                    if let rate = usd["rate_float"]{
//                                        self.btcRate = Float(rate as! Float)
////                                        DispatchQueue.main.async {
////                                            self.setBTCLabelString()
////                                        }
//                                        self.delegate?.updatedPrice()
//                                    } else {
//                                        print("fail at rate")
//                                    }
//
//
//                                } else {
//                                    print("fail at USD")
//                                }
//                            } else {
//                                print("fail at bpi")
//                            }
                        } catch {
                            fatalError()
                        }
                        
                    }
                })
                
                task.resume()
                //NSURLConnection.s
            }
        }
        
        
        
    }
    
    func processInfo(buy:Buy) -> Dictionary<String,String>{
        
        var buyDict:Dictionary<String,String> = [:]
        let dateF = DateFormatter()
        dateF.dateFormat = "yyyy-MM-dd"
        let originalPrice = buy.btcAmount * Float(buy.btcRateAtPurchase)
        let currentPrice = buy.btcAmount * btcRate;
        let appreciationDecimal = currentPrice / originalPrice;
        let actualDecimal = (appreciationDecimal>1) ? appreciationDecimal-1 : 1-appreciationDecimal
        buyDict["buy"] = String(buy.btcAmount)
        buyDict["date"] = dateF.string(from: buy.dateOfPurchase!)

        buyDict["rateAtBuy"] = String(buy.btcRateAtPurchase)
        buyDict["priceAtBuy"] = String(originalPrice)
        buyDict["currentRate"] = String(btcRate)
        
        buyDict["currentPrice"] = String(format: "%.2f", arguments: [currentPrice])
        buyDict["appreciation"] = String(format: "%.2f", arguments:[(actualDecimal * 100)])+"%";
        buyDict["direction"] = (appreciationDecimal>1) ? "up" : "down"
        
        return buyDict
    }
    
}
