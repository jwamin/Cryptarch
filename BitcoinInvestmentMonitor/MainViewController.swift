//
//  MainViewController.swift
//  BitcoinInvestmentMonitor
//
//  Created by Joss Manger on 12/15/17.
//  Copyright © 2017 Joss Manger. All rights reserved.
//

import UIKit
import CoreData
import PieCell

class MainViewController: UIViewController, BTCPriceDelegate, BTCManagerDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    // MARK: - InterfaceBuilder Outlets
    
    @IBOutlet weak var statContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainPie: PieView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalSpendLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    
    
    // MARK: - Instance Variables
    
    var btcManager:CDBTCManager!
    var refresh:UIRefreshControl!
    
    
    // MARK: - Variables with property observers
    var darkMode:Bool = true {
        didSet{
            self.navigationController?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get{
            if(darkMode){
                return .lightContent
            } else {
                return .default
            }
        }
        
    }
    
    var totalValue:Float! = 0.0 {
        didSet{
            totalLabel.text = String(format: "$%.2f", totalValue)
        }
    }
    
    var totalSpendValue:Float! = 0.0 {
        didSet{
            totalSpendLabel.text = String(format: "$%.2f", totalSpendValue)
        }
    }
    
    var totalPercentValue:Float! = 0.0 {
        didSet{
            updateTotalValue()
        }
    }
    
    // MARK: - ViewController Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        let defaultsNumber = UserDefaults.standard.object(forKey: "dark_mode")
        
        if(defaultsNumber==nil){
            UserDefaults.standard.set(true, forKey: "dark_mode")
            darkMode = true
        } else {
            darkMode = UserDefaults.standard.bool(forKey: "dark_mode")
        }
        
        self.title = "Cryptarch"
        
        btcManager = CDBTCManager(self)
        btcManager.delegate = self
        btcManager.btcPriceMonitor?.getUpdateBitcoinPrice()
        percentLabel.text = ""
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let point = CGPoint(x: tableView.frame.origin.x, y: tableView.frame.origin.y)
        refresh = UIRefreshControl(frame: CGRect(origin: point, size: CGSize(width: tableView.frame.width, height: 32.0)))
        
        refresh!.addTarget(self, action: #selector(handlePullToRefresh), for: UIControlEvents.valueChanged)
        tableView.refreshControl = refresh
        
    }

    override func viewWillAppear(_ animated: Bool) {

        if darkMode{
            setDarkMode()
        }
        
    }

    // MARK: - View Updates
    
    private func setDarkMode(){
        self.view.backgroundColor = UIColor.black
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        refresh.backgroundColor = UIColor.black
        tableView.backgroundColor = UIColor.black
        darkModeView(view: view)
        darkModeView(view: statContainer)
    }
    
    
    @objc func handlePullToRefresh(_ sender:UIRefreshControl){
        sender.beginRefreshing()
        //Dispatch queue multiple async tasks, finally return tuple
        NotificationCenter.default.addObserver(self, selector: #selector(callkillAll), name: .UIApplicationWillResignActive, object: nil)
        btcManager.btcPriceMonitor?.getUpdateBitcoinPrice()
    }
    
    // MARK: - Data Processing for views
    
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
    
    func updateTotalValue(){
        
        let neutralLabel:UIColor = (darkMode) ? UIColor.white : UIColor.black
        let inTheGreen = (totalPercentValue==0) ? 2 : (totalPercentValue>1) ? 1 : 0;
        percentLabel.textColor = (inTheGreen==2) ? neutralLabel : (inTheGreen==1) ? UIColor.green : UIColor.red;
        var double = Double(totalValue/totalSpendValue)
        
        //PieView.percentage needs signed normal between -1 and 1
        double = (double<1) ? -(1-double) : double
        print("mainPie double:\(double)")
        mainPie.percentage = double
        
        print(mainPie.percentage)
        let str = String(format: "$%.2f", totalPercentValue)
        
        percentLabel.text = (inTheGreen>0) ? str : "-"+str.replacingOccurrences(of: "-", with: "")
    }
    
    func calculateTotals(){

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

     // MARK: - Call to refresh model
    
    @objc func displayError() {
        let error = UIAlertController(title: "Error refreshing price", message: "Please try again later...", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        error.addAction(action)
        self.refresh?.endRefreshing()
        self.present(error, animated: true, completion: nil)
    }
    
    @objc func callkillAll(){
        btcManager.btcPriceMonitor?.killAll()
    }
    
    @objc func silentFail() {
        self.refresh?.endRefreshing()
        
        //shouldnt be in model... I guess.
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)
    }
    
    // MARK: - Segue Handling
    
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
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {

        if(!btcManager.btcPriceMonitor.gotPrices){
            return 0
        } else {
            return self.btcManager.fetchedResultsController.sections?.count ?? 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //        if(currentItems.count != 0){
        //            return currentItems[section].count
        //        }
        //        return 0
        if(!btcManager.btcPriceMonitor.gotPrices){
            return 0
        } else {
            let sectionInfo = self.btcManager.fetchedResultsController.sections![section]
            return sectionInfo.numberOfObjects
        }
      
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
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle(for: NewCell.self).loadNibNamed("Cell", owner: self, options: nil)![0] as! NewCell
        
        let labelDict = btcManager.btcPriceMonitor!.processInfo(buy: self.btcManager.fetchedResultsController.object(at: indexPath))
        let isRising = (labelDict["direction"] == "up")
        
        if darkMode{
            darkModeView(view: cell.contentView)
        }
        cell.priceAtBuy.text = "$"+(labelDict["priceAtBuy"] ?? "missing")
        cell.currentPrice.text = "$"+(labelDict["currentPrice"] ?? "missing")
        cell.toplabel.text = "Current value"
        cell.bottomlabel.text = "Buy value"
        print(labelDict["direction"]!,labelDict["actualDecimal"]!)
        cell.pieView.percentage = (labelDict["direction"] == "up") ? Double(labelDict["actualDecimal"]!)! : -Double(labelDict["actualDecimal"]!)!
        cell.initialiseTickerView(isRising: isRising)

        return cell
        
    }

    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
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
        if cell is BTCBuyTableCell{
            let buycell = cell as! BTCBuyTableCell
            let rising = buycell.ticker.rising
            buycell.ticker.removeFromSuperview()
            buycell.initialiseTickerView(isRising: rising)
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(tableView.cellForRow(at: indexPath) is BTCBuyTableCell){
            return 218.0
        } else {
            return 85.0
        }
        
        
    }
    
    
   
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        tableReload()
    }
    
    func tableReload(){
        print("reloading table")
        tableView.reloadData()
    }
    

    // MARK: - Fetched results controller
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("will change content")
        tableView.beginUpdates()
    }
    
    func establishedController() {
        print("established link",self.btcManager.fetchedResultsController)
        self.btcManager.fetchedResultsController.delegate = self
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
    
    // MARK: - Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
