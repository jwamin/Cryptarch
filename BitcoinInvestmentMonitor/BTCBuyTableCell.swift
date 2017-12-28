//
//  BTCBuyTableCell.swift
//  BitcoinInvestmentMonitor
//
//  Created by Joss Manger on 12/7/17.
//  Copyright © 2017 Joss Manger. All rights reserved.
//

import UIKit

class BTCBuyTableCell: UITableViewCell {
    
    @IBOutlet weak var btcAmountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var appreciationLabel: UILabel!
    @IBOutlet weak var currentPriceLabel: UILabel!
    @IBOutlet weak var currentRateLabel: UILabel!
    @IBOutlet weak var usdAtBuyLabel: UILabel!
    @IBOutlet weak var btcRateAtBuyLabel: UILabel!
    
    var ticker:TickerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initialiseTickerView(isRising:Bool=true){
        ticker = TickerView(parent: self, isRising: isRising)
        ticker.backgroundColor = UIColor.clear
        self.addSubview(ticker)
    }
    
    override func prepareForReuse() {
        ticker.removeFromSuperview()
    }
    
}

class TickerView : UIView {
    
    var rising:Bool = true
    
    init(parent:UIView,isRising:Bool=true) {
        
        var rect = CGRect()
        
        let dimension:CGFloat = 10.0
        let constantMaybe:CGFloat = 1
        let xcoord = (parent.frame.width)-(dimension * constantMaybe)
        let ycoord = (parent.frame.height)-(dimension * constantMaybe)
        let offset:CGFloat = 3.0
        //let backup = CGRect(x: 0.0, y: 0.0, width: dimension, height: dimension)
        if (isRising){
            rect = CGRect(x: xcoord-offset, y: 0.0+offset, width: dimension, height: dimension)
        } else {
            rect = CGRect(x: xcoord-offset, y: ycoord-offset, width: dimension, height: dimension)
        }
        //rect = backup
        
        super.init(frame: rect)
        rising = isRising
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.clear.cgColor)
        let path = CGPath(rect: rect, transform: nil)
        context?.addPath(path)
        context?.fillPath()
        
        context?.beginPath()
        
        //Going UP
        if(rising){
            context?.setFillColor(UIColor.green.cgColor)
            context?.move(to: CGPoint(x: 0, y: 0))
            context?.addLine(to: CGPoint(x: self.frame.width, y: 0.0))
            context?.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
            context?.addLine(to: CGPoint(x: 0, y: 0))
        } else { //Going down
            context?.setFillColor(UIColor.red.cgColor)
            context?.move(to: CGPoint(x: self.frame.width, y: 0.0))
            context?.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
            context?.addLine(to: CGPoint(x: 0.0, y: self.frame.height))
        }
        
        context?.closePath()
        context?.fillPath()
        
        
    }
    
}
