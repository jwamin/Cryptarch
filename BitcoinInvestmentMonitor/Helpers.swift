//
//  Helpers.swift
//  BitcoinInvestmentMonitor
//
//  Created by Joss Manger on 12/23/17.
//  Copyright © 2017 Joss Manger. All rights reserved.
//

import Foundation

enum CryptoTicker:Int {
    
    case btc = 0
    case bch = 1
    case eth = 2
    case ltc = 3
    
    
    
    func stringValue() -> String {
        switch(self){
        case .btc:
            return "BTC"
        case .ltc:
            return "LTC"
        case .eth:
            return "ETH"
        case .bch:
            return "BCH"
        }
    }
    
    static func ticker(ticker:String?) -> CryptoTicker {
        if let validString = ticker {
            switch(validString){
            case "LTC":
                return .ltc
            case "BCH":
                return .bch
            case "ETH":
                return .eth
            default:
                return .btc
            }
        } else {
            return .btc
        }
    }
    
}
