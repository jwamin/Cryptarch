//
//  MainViewController.swift
//  BitcoinInvestmentMonitor
//
//  Created by Joss Manger on 12/15/17.
//  Copyright © 2017 Joss Manger. All rights reserved.
//

import UIKit

class MainViewController: UIViewController,BTCPriceDelegate,BTCManagerDelegate,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    let btcPriceMonitor:BTCPriceModel = BTCPriceModel()
    let btcManager:CDBTCManager = CDBTCManager()
    var refresh:UIRefreshControl?
    var totalValue:Float! = 0.0 {
        didSet{
            totalLabel.text = String(format: "$%.2f", totalValue)
        }
    }
    
    @IBOutlet weak var totalSpendLabel: UILabel!
    var totalSpendValue:Float! = 0.0 {
        didSet{
            totalSpendLabel.text = String(format: "$%.2f", totalSpendValue)
        }
    }
    @IBOutlet weak var percentLabel: UILabel!
    
    var totalPercentValue:Float! = 0.0 {
        didSet{
            percentLabel.textColor = (totalPercentValue>1) ? UIColor.green : UIColor.red
            percentLabel.text = String(format: "%.2f%", totalPercentValue)
        }
    }
    
    
    var currentItems:[[Buy]] = []
    var formerItems:[[Buy]] = []
    
    @IBOutlet weak var totalLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        btcPriceMonitor.delegate = self
        btcManager.delegate = self
        //        tableView.delegate = self
        //        tableView.dataSource = self
        btcPriceMonitor.getUpdateBitcoinPrice()
        btcManager.initEntity()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        self.title = "Cryptarch"
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let point = CGPoint(x: tableView.frame.origin.x, y: tableView.frame.origin.y)
        refresh = UIRefreshControl(frame: CGRect(origin: point, size: CGSize(width: tableView.frame.width, height: 32.0)))
        
        refresh!.addTarget(self, action: #selector(handlePullToRefresh), for: UIControlEvents.valueChanged)
        tableView.refreshControl = refresh
    }
    
    @objc func handlePullToRefresh(_ sender:UIRefreshControl){
        sender.beginRefreshing()
        btcPriceMonitor.getUpdateBitcoinPrice()
    }
    
    
    
    func updatedPrice() {
        print("notified price update")
        print(btcPriceMonitor.btcRate)
        DispatchQueue.main.async {
            
            //reload data is fine, not adding or removing in this transaction
            self.tableView.reloadData()
            if let refresh = self.refresh {
                refresh.endRefreshing()
                self.updatedCore()
                self.calculateTotals()
            }
        }
    }
    
    func updateTableItems(){
        formerItems = currentItems
        currentItems = []
        var items:[[Buy]] = []
        
        //Process fetched buys into array of arrays
        print("updating table items")
        for value in BTCPriceModel.polling{
            var theseItems:[Buy] = []
            for buy in btcManager.fetchedBuys{
                print(buy.objectID)
                if(buy.cryptoCurrency==value.stringValue()){
                    theseItems.append(buy)
                } 
                
            }
                items.append(theseItems)
        }
        print("DONE updating table items")
        //print("about to print array:")
        //print(items,items.count)
        
        currentItems = items
        
        
        //this worked before multi-section updates
        if formerItems.count>0{
            
            var indexPaths:[IndexPath] = []
            for (index,items) in currentItems.enumerated(){
                print("inner loop")
                //Adding with empty index causes crash
                //print(items.count,formerItems[index])
                if(items.count>formerItems[index].count){
                    for value in formerItems[index].count..<items.count{
                        let indexpath = IndexPath(row: value, section: index)
                        indexPaths.append(indexpath)
                    }
                }
                
            }

            if indexPaths.count>0{
                print("got an indexpath")
                print(indexPaths)
                tableView.beginUpdates()
//                for path in indexPaths{
//                    if(!indexPathIsValid(indexPath: path)){
//                        
//                        let set = IndexSet(integer:path.section)
//                        print("path invalid, \(path)")
//                        print("going to add index?, \(set)")
//                        tableView.insertSections(set, with: .automatic)
//                        
//                    } else {
//                        print("path valid, \(path)")
//                    }
//                }
                    tableView.insertRows(at: indexPaths, with: .right)
                
                
                
                tableView.endUpdates()
                calculateTotals()
            }
            
        } else {
            tableView.reloadData()
        }
        
        
    }
    
    func indexPathIsValid(indexPath: IndexPath) -> Bool {
        if indexPath.section >= tableView.numberOfSections {
            return false
        }
        if indexPath.row >= tableView.numberOfRows(inSection: indexPath.section) {
            return false
        }
        return true
    }
    
    func calculateTotals(){

        
        print("calculating totals")
            print(currentItems.count,currentItems)
        totalValue = 0.0
        totalSpendValue = 0.0
        var outerTempValue:Float = 0.0
        var tempSpend:Float = 0.0
        var rate:Float
        for items in currentItems{
            if(items.count>0){
                
            
            var tempValue:Float = 0.0
            
            for buy in items{
                tempValue+=buy.btcAmount
                tempSpend+=(buy.btcAmount * Float(buy.btcRateAtPurchase))
            }
            if(btcPriceMonitor.cryptoRates.count>0){
                rate = Float(btcPriceMonitor.cryptoRates[items[0].cryptoCurrency!]!) // less force unwrapping, guard?
            } else {
                rate = 0
            }
            outerTempValue += (tempValue*rate)
            }
        }
        
        totalValue = outerTempValue
        totalSpendValue = tempSpend
        print("updated label value to: \(totalValue)")
            print("updated spend label value to: \(totalSpendValue)")
            
        let appreciationDecimal = totalValue - totalSpendValue;
        totalPercentValue = appreciationDecimal// (appreciationDecimal>1) ? appreciationDecimal-1 : 1-appreciationDecimal
        
    }
    
    
    
    func displayError() {
        let error = UIAlertController(title: "Error refreshing price", message: "Please try again later...", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        error.addAction(action)
        self.refresh?.endRefreshing()
        self.present(error, animated: true, completion: nil)
    }
    
    func updatedCore() {
        

        
        //old set vs new, bulk update
        if(btcPriceMonitor.cryptoRates.count>0){
            updateTableItems()
        }
        
        
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "addSegue":
            let vc = segue.destination as! ViewController
            vc.tableViewParent = self
        default:
            return
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        tableView.reloadData()
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
//        var numberOfSections = 0
//        // if section is now empty, remove it
//        for set in currentItems{
//            if(set.count>0){
//                numberOfSections+=1
//            }
//        }
        return BTCPriceModel.polling.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(currentItems.count != 0){
            return currentItems[section].count
        }
        return 0
    }
    

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // handle if first section is empty, second has title
        return BTCPriceModel.polling[section].stringValue()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "btcbuy", for: indexPath) as! BTCBuyTableCell
        
        print("new cell",indexPath.section,indexPath.row)
        
        let labelDict = btcPriceMonitor.processInfo(buy: currentItems[indexPath.section][indexPath.row])
        let isRising = (labelDict["direction"] == "up")
        cell.initialiseTickerView(isRising: isRising)
        cell.btcAmountLabel.text = labelDict["buy"]
        cell.dateLabel.text = labelDict["date"]
        cell.btcRateAtBuyLabel.text = labelDict["rateAtBuy"]
        cell.usdAtBuyLabel.text = "$"+(labelDict["priceAtBuy"] ?? "missing")
        cell.currentRateLabel.text = labelDict["currentRate"]
        
        cell.currentPriceLabel.text = "$"+(labelDict["currentPrice"] ?? "missing")
        cell.appreciationLabel.text = (labelDict["direction"] == "up") ? "+"+labelDict["appreciation"]! : "-"+labelDict["appreciation"]!
        cell.appreciationLabel.textColor = isRising ? UIColor.green : UIColor.red
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView.cellForRow(at: indexPath) != nil){
            return 218.0 // Arbitrary, refactor
        }
        return 218.0
    }
    
    
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source

            print("current items at start of update:\(currentItems.count)")
            print("getting id for cd model")
            let id = currentItems[indexPath.section][indexPath.row].objectID
            
            print("removing from local model,\(indexPath.section) \(indexPath.row)")
            print("was",currentItems[indexPath.section].count)
            currentItems[indexPath.section].remove(at: indexPath.row)
            print("now",currentItems[indexPath.section].count)
            
            print("starting table view updates (delete), \(indexPath)")
            tableView.beginUpdates()
            print(currentItems[indexPath.section].count)
            
                
     
            
            
            print("deleting row")
            tableView.deleteRows(at: [indexPath], with: .fade)

            
//            if(currentItems[indexPath.section].count==0){
//                print("deleting section")
//                tableView.deleteSections(IndexSet(integer:indexPath.section), with: .automatic)
//
//            }
            
            
            print("ending updates")
            tableView.endUpdates()
            
            
            print("removing from cd model")
            btcManager.clearCore(id: id)
            calculateTotals()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            btcManager.commitToCore(buyInfo: ViewController.defaultSettings())
            
        }
    }
    
    //    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    //        var strings:[String] = []
    //        for value in currentItems{
    //            if let crypto = value[0].cryptoCurrency{
    //                strings.append(crypto)
    //            }
    //
    //        }
    //        return strings
    //    }
    
    
}
