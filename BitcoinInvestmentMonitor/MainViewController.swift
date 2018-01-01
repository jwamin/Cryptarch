//
//  MainViewController.swift
//  BitcoinInvestmentMonitor
//
//  Created by Joss Manger on 12/15/17.
//  Copyright © 2017 Joss Manger. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController,BTCPriceDelegate,BTCManagerDelegate,UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate {
    
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

    @IBOutlet weak var totalLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        btcPriceMonitor.delegate = self
        btcManager.delegate = self

        btcPriceMonitor.getUpdateBitcoinPrice()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        self.title = "Cryptarch"
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //tableView.register(BTCBuyTableCell, forCellReuseIdentifier: "btcbuy")
        
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
                self.tableReload()
                if let refresh = self.refresh {
                    refresh.endRefreshing()
                    //self.updatedCore()
                    self.calculateTotals()
                }
            
            
            

        }
    }
    
//    func updateTableItems(){
//        formerItems = currentItems
//        currentItems = []
//        var items:[[Buy]] = []
//
//        //Process fetched buys into array of arrays
//        print("updating table items")
//        for value in BTCPriceModel.polling{
//            var theseItems:[Buy] = []
//            for buy in btcManager.fetchedBuys{
//                print(buy.objectID)
//                if(buy.cryptoCurrency==value.stringValue()){
//                    theseItems.append(buy)
//                }
//
//            }
//                items.append(theseItems)
//        }
//        print("DONE updating table items")
//        //print("about to print array:")
//        //print(items,items.count)
//
//        currentItems = items
//
//
//        //this worked before multi-section updates
//        if formerItems.count>0{
//
//            var indexPaths:[IndexPath] = []
//            for (index,items) in currentItems.enumerated(){
//                print("inner loop")
//                //Adding with empty index causes crash
//                //print(items.count,formerItems[index])
//                if(items.count>formerItems[index].count){
//                    for value in formerItems[index].count..<items.count{
//                        let indexpath = IndexPath(row: value, section: index)
//                        indexPaths.append(indexpath)
//                    }
//                }
//
//            }
//
//            if indexPaths.count>0{
//                print("got an indexpath")
//                print(indexPaths)
//                tableView.beginUpdates()
//
//                    tableView.insertRows(at: indexPaths, with: .right)
//
//
//
//                tableView.endUpdates()
//                calculateTotals()
//            }
//
//        } else {
//            tableReload()
//        }
//
//
//    }
    
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

        totalValue = 0.0
        totalSpendValue = 0.0
        var outerTempValue:Float = 0.0
        var tempSpend:Float = 0.0
        var rate:Float
        if let items = btcManager.fetchedResultsController.fetchedObjects{
            for item in items{
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
    
//    func updatedCore() {
//
//        print("updated core called")
//
//        //old set vs new, bulk update
//        if(btcPriceMonitor.cryptoRates.count>0){
//            updateTableItems()
//        }
//
//
//    }
    
    
    
    
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
        tableReload()
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
        //return BTCPriceModel.polling.count
        return self.btcManager.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        if(currentItems.count != 0){
//            return currentItems[section].count
//        }
//        return 0
        let sectionInfo = self.btcManager.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    

    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // handle if first section is empty, second has title
        if let section = btcManager.fetchedResultsController.sections?[section]{
            let buy = section.objects![0] as! Buy
            return CryptoTicker.ticker(ticker: buy.cryptoCurrency).stringValue()
        }
    
        return "header"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "btcbuy") as! BTCBuyTableCell
        
        //print("new cell",indexPath.section,indexPath.row)
        
        let labelDict = btcPriceMonitor.processInfo(buy: self.btcManager.fetchedResultsController.object(at: indexPath))
        let isRising = (labelDict["direction"] == "up")
        
        cell.btcAmountLabel.text = labelDict["buy"]
        cell.dateLabel.text = labelDict["date"]
        cell.btcRateAtBuyLabel.text = labelDict["rateAtBuy"]
        cell.usdAtBuyLabel.text = "$"+(labelDict["priceAtBuy"] ?? "missing")
        cell.currentRateLabel.text = labelDict["currentRate"]
        
        cell.currentPriceLabel.text = "$"+(labelDict["currentPrice"] ?? "missing")
        cell.appreciationLabel.text = (labelDict["direction"] == "up") ? "+"+labelDict["appreciation"]! : "-"+labelDict["appreciation"]!
        cell.appreciationLabel.textColor = isRising ? UIColor.green : UIColor.red
        
        //print("labeldict",indexPath,labelDict,cell)
        cell.initialiseTickerView(isRising: isRising)
        return cell
    }
    
    //reload / reposition ticker view when about to appears
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let buycell = cell as! BTCBuyTableCell
        let rising = buycell.ticker.rising
        buycell.ticker.removeFromSuperview()
        buycell.initialiseTickerView(isRising: rising)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

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
            do {
                let context = self.btcManager.fetchedResultsController.managedObjectContext
                context.delete(self.btcManager.fetchedResultsController.object(at: indexPath))
                
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
    
    func tableReload(){
        print("reloading table")
        tableView.reloadData()
    }
    
    func establishedController() {
        print("established link",self.btcManager.fetchedResultsController)
        self.btcManager.fetchedResultsController.delegate = self
    }
    
// MARK: - Fetched results controller
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("will change content")
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            print("got insert sections")
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            print("got remove sections")
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print(indexPath)
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            print("got insert")
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            print("got delete")
        case .update:
            print("got update")
        case .move:
            print("got move")
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("did change content")
        tableView.endUpdates()
        tableView.reloadData()
    }

    
    
    
}
