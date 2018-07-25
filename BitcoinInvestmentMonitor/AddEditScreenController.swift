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
    @IBOutlet weak var currencyLabel: UILabel!
    
    @IBOutlet weak var add: UIButton!
    var editObject:Buy?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get{
            if(tableViewParent?.darkMode)!{
                return .lightContent
            } else {
                return .default
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Add Crypto Buy"
        
        currencyPicker.removeAllSegments()
        
        var segments = 0
        for val in BTCPriceModel.polling{
            currencyPicker.insertSegment(withTitle: val.stringValue(), at: segments, animated: false)
                segments+=1
        }
        
        if let passedObject = editObject {
            currencyPicker.selectedSegmentIndex = CryptoTicker.ticker(ticker: passedObject.cryptoCurrency).rawValue
            btcAmountField.text = String(passedObject.btcAmount)
            rateAtPurchaseField.text = String(passedObject.btcRateAtPurchase)
            datePicker.date = passedObject.dateOfPurchase! as Date
        } else {
         currencyPicker.selectedSegmentIndex = 0
        }
        
        datePicker.maximumDate = Date()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        if(tableViewParent?.darkMode)!{
            let white = UIColor.white
            darkModeView(view: self.view)
            currencyPicker.tintColor = white
            btcAmountField.textColor = white
            rateAtPurchaseField.textColor = white
            add.tintColor = white
            datePicker.setValue(white, forKey: "textColor")
        }
        
        self.navigationController?.setNeedsStatusBarAppearanceUpdate()
        
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
    
    @IBAction func pickerChanged(_ sender: Any) {
        
       let picker = sender as! UISegmentedControl
   
        let str = "USD->%@ Rate at Purchase"
        let tickerString = CryptoTicker(rawValue: picker.selectedSegmentIndex)!.stringValue()
        currencyLabel.text = String(format: str, tickerString)
        
        
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
        if let passedObject = editObject {
            
            passedObject.cryptoCurrency = CryptoTicker(rawValue: currencyPicker.selectedSegmentIndex)?.stringValue()
            passedObject.btcAmount = Float(btcAmountField.text ?? "0.0") ?? 0.0
            passedObject.btcRateAtPurchase = Double(rateAtPurchaseField.text ?? "0.0") ?? 0.0
            passedObject.dateOfPurchase = datePicker.date 
            
            tableViewParent?.btcManager.updateToCore()
            navigationController?.popViewController(animated: true)
            return
        } else {
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
    
}

