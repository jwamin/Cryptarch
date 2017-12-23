//
//  ViewController.swift
//  BitcoinInvestmentMonitor
//
//  Created by Joss Manger on 12/7/17.
//  Copyright © 2017 Joss Manger. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var tableViewParent:MainViewController?
    
    @IBOutlet weak var currencyPicker: UISegmentedControl!
    @IBOutlet weak var btcAmountField: UITextField!
    @IBOutlet weak var rateAtPurchaseField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Crypto Buy"
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        view.endEditing(false)
//    }
    
    @IBAction func endEditing(_ sender:Any){
        view.endEditing(false)
    }
    
    static func defaultSettings()->Dictionary<String,String>{
        
        let dateF = DateFormatter()
        dateF.dateFormat = "yyyy-MM-dd"
        
        var buyInfo:Dictionary<String,String> = [:]
        buyInfo["date"] = dateF.string(from: Date())
        buyInfo["btcAmount"] = "1.0"
        buyInfo["btcRate"] = "20"
        buyInfo["currency"] = CryptoTicker.btc.stringValue()
        return buyInfo
        
    }
    
    
    @IBAction func add(_ sender: Any) {
        
        let dateF = DateFormatter()
        dateF.dateFormat = "yyyy-MM-dd"
        
        var buyInfo:Dictionary<String,String> = [:]
        buyInfo["date"] = dateF.string(from: datePicker.date)
        //print(buyInfo["date"],datePicker.date)
        buyInfo["btcAmount"] = btcAmountField.text
        buyInfo["btcRate"] = rateAtPurchaseField.text
        buyInfo["currency"] = CryptoTicker(rawValue: currencyPicker.selectedSegmentIndex)?.stringValue()
        tableViewParent?.btcManager.commitToCore(buyInfo:buyInfo)
        navigationController?.popViewController(animated: true)
    }
    
}

