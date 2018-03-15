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
    
    @IBOutlet weak var statContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var btcManager:CDBTCManager!
    var refresh:UIRefreshControl!
    
    var darkMode:Bool = false
    
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
    
//    override var preferredStatusBarStyle: UIStatusBarStyle{
//        print("updating status bar")
//        if(darkMode){
//            return .lightContent
//        } else {
//            return .default
//        }
//    }
    
    var totalPercentValue:Float! = 0.0 {
        didSet{
            updateTotalValue()
        }
    }
    
    func updateTotalValue(){
        
        let neutralLabel:UIColor = (darkMode) ? UIColor.white : UIColor.black
        let inTheGreen = (totalPercentValue==0) ? 2 : (totalPercentValue>1) ? 1 : 0;
        percentLabel.textColor = (inTheGreen==2) ? neutralLabel : (inTheGreen==1) ? UIColor.green : UIColor.red;
        let str = String(format: "$%.2f", totalPercentValue)
     
        percentLabel.text = (inTheGreen>0) ? str : "-"+str.replacingOccurrences(of: "-", with: "")
    }
    
    @IBOutlet weak var totalLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        btcManager = CDBTCManager(self)
        btcManager.delegate = self
        
        btcManager.btcPriceMonitor?.getUpdateBitcoinPrice()
        percentLabel.text = ""
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
    
    override func viewWillAppear(_ animated: Bool) {

        darkMode = UserDefaults.standard.bool(forKey: "dark_mode")
        
        if darkMode{
            self.view.backgroundColor = UIColor.black
            self.navigationController?.navigationBar.barTintColor = UIColor.black
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
            refresh.backgroundColor = UIColor.black
            tableView.backgroundColor = UIColor.black
            MainViewController.darkModeView(view: view)
            MainViewController.darkModeView(view: statContainer)
            UIApplication.shared.statusBarStyle = .lightContent
        }
        updateTotalValue()
    }
    
    static func darkModeView(view:UIView){
        view.backgroundColor = UIColor.black
        for thisView in view.subviews{
            //print(thisView)
            if thisView is UILabel{
                (thisView as! UILabel).textColor = UIColor.white
            }
        }
    }
    
    @objc func handlePullToRefresh(_ sender:UIRefreshControl){
        sender.beginRefreshing()
        //Dispatch queue multiple async tasks, finally return tuple
        NotificationCenter.default.addObserver(self, selector: #selector(callkillAll), name: .UIApplicationWillResignActive, object: nil)
        btcManager.btcPriceMonitor?.getUpdateBitcoinPrice()
    }
    
    @objc func callkillAll(){
        btcManager.btcPriceMonitor?.killAll()
    }
    
    
    func updatedPrice() {
        print("notified price update")
        
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)
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
    
    func calculateTotals(){


        //print("calculating totals")

        totalValue = 0.0
        totalSpendValue = 0.0
        var outerTempValue:Float = 0.0
        var tempSpend:Float = 0.0
        var rate:Float
        if let items = btcManager.fetchedResultsController.fetchedObjects{
            for buy in items{

                var tempValue:Float = 0.0

                tempValue+=buy.btcAmount
                tempSpend+=(buy.btcAmount * Float(buy.btcRateAtPurchase))

                if(btcManager.btcPriceMonitor.cryptoRates.count>0){
                    rate = Float(btcManager.btcPriceMonitor.cryptoRates[buy.cryptoCurrency!]!) // less force unwrapping, guard?
                } else {
                    rate = 0
                }

                outerTempValue += (tempValue*rate)

            }
        }


        totalValue = outerTempValue
        totalSpendValue = tempSpend
        //print("updated label value to: \(totalValue)")
        //print("updated spend label value to: \(totalSpendValue)")

        let appreciationDecimal = totalValue - totalSpendValue;
        totalPercentValue = appreciationDecimal// (appreciationDecimal>1) ? appreciationDecimal-1 : 1-appreciationDecimal

    }

    
    
    @objc func displayError() {
        let error = UIAlertController(title: "Error refreshing price", message: "Please try again later...", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        error.addAction(action)
        self.refresh?.endRefreshing()
        self.present(error, animated: true, completion: nil)
    }
    
    @objc func silentFail() {
        self.refresh?.endRefreshing()
        
        //shouldnt be in model... I guess.
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)
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
            if sender is Buy{
                vc.editObject = sender as? Buy
            }
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnView = UITableViewHeaderFooterView()
        
        if let section = btcManager.fetchedResultsController.sections?[section]{
            let buy = section.objects![0] as! Buy
             returnView.textLabel?.text = CryptoTicker.ticker(ticker: buy.cryptoCurrency).stringValue()
        }
       
        
        if darkMode {
             returnView.contentView.backgroundColor = UIColor.black
            returnView.textLabel?.textColor = UIColor.red
        }
        
       
        return returnView
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        // handle if first section is empty, second has title
//        if let section = btcManager.fetchedResultsController.sections?[section]{
//            let buy = section.objects![0] as! Buy
//            return CryptoTicker.ticker(ticker: buy.cryptoCurrency).stringValue()
//        }
//
//        return "header"
//    }
    
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "btcbuy") as! BTCBuyTableCell
        
        //print("new cell",indexPath.section,indexPath.row)
        
        let labelDict = btcManager.btcPriceMonitor!.processInfo(buy: self.btcManager.fetchedResultsController.object(at: indexPath))
        let isRising = (labelDict["direction"] == "up")
        
        if darkMode{
            MainViewController.darkModeView(view: cell.contentView)
        }
        
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let context = self.btcManager.fetchedResultsController.managedObjectContext
        
        let edit = UITableViewRowAction.init(style: .normal, title: "Edit", handler: {(action,path) in
            let object = self.btcManager.fetchedResultsController.object(at: path)
            self.performSegue(withIdentifier: "addSegue", sender: object)
        })
        
        let delete = UITableViewRowAction.init(style: .destructive, title: "Delete", handler: {(action,path) in
            
            context.delete(self.btcManager.fetchedResultsController.object(at: path))
            
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        })
        let options:[UITableViewRowAction] = [delete,edit]
        return options
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
    
    //'fixed' version
//    func calculateTotals(){
//
//
//        print("calculating totals")
//
//        totalValue = 0.0
//        totalSpendValue = 0.0
//        var outerTempValue:Float = 0.0
//        var tempSpend:Float = 0.0
//        var rate:Float
//        if let items = btcManager.fetchedResultsController.fetchedObjects{
//            for buy in items{
//
//                var tempValue:Float = 0.0
//
//                tempValue+=buy.btcAmount
//                tempSpend+=(buy.btcAmount * Float(buy.btcRateAtPurchase))
//
//                if(btcManager.btcPriceMonitor.cryptoRates.count>0){
//                    rate = Float(btcManager.btcPriceMonitor.cryptoRates[buy.cryptoCurrency!]!) // less force unwrapping, guard?
//                } else {
//                    rate = 0
//                }
//
//                outerTempValue += (tempValue*rate)
//
//            }
//        }
//
//
//        totalValue = outerTempValue
//        totalSpendValue = tempSpend
//        print("updated label value to: \(totalValue)")
//        print("updated spend label value to: \(totalSpendValue)")
//
//        let appreciationDecimal = totalValue - totalSpendValue;
//        totalPercentValue = appreciationDecimal// (appreciationDecimal>1) ? appreciationDecimal-1 : 1-appreciationDecimal
//
//        //updatedPrice()
//
//    }
    
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
        //print(indexPath)
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
        calculateTotals()
    }
    
    
    
    
}
