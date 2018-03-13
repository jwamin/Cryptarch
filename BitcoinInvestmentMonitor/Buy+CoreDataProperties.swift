//
//  Buy+CoreDataProperties.swift
//  BitcoinInvestmentMonitor
//
//  Created by Joss Manger on 3/13/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//
//

import Foundation
import CoreData


extension Buy {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Buy> {
        return NSFetchRequest<Buy>(entityName: "Buy")
    }

    @NSManaged public var btcAmount: Float
    @NSManaged public var btcRateAtPurchase: Double
    @NSManaged public var cryptoCurrency: String?
    @NSManaged public var dateOfPurchase: NSDate?

}
