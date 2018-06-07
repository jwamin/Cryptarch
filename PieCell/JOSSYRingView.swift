//
//  JOSSYRingView.swift
//  CellHelpers
//
//  Created by Joss Manger on 6/6/18.
//  Copyright © 2018 Joss Manger. All rights reserved.
//

import QuartzCore
import UIKit

class NewCell : UITableViewCell{
    @IBOutlet weak var priceAtBuy: UILabel!
    @IBOutlet weak var currentPrice: UILabel!
    @IBOutlet weak var pieView: PieView!
    
}


@IBDesignable
class PieView : UIView{
    
    @IBInspectable var percentage:Double = 0.5 {
        didSet{
            updateLayerProperties()
            
        }
    }
    @IBInspectable var lineWidth:Double = 10.0 {
        didSet{
            updateLayerProperties()
            
        }
    }
    
    
    var backgroundRingLayer: CAShapeLayer!
    var ringLayer:CAShapeLayer!
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        layoutSubviews()
    }
    
    func updateLayerProperties(){
        if(ringLayer != nil){
            
            let percentFloat = CGFloat(percentage)
            var strokeColor = UIColor.lightGray
            ringLayer.strokeEnd = percentFloat
            switch percentFloat {
            case let a where a <= 0.0:
                strokeColor = UIColor.red
                var bez = UIBezierPath(ovalIn: getInsetRect()).reversing()
                ringLayer.path = bez.cgPath
                ringLayer.strokeEnd = 0 - percentFloat
            case let a where a > 0.0:
                strokeColor = UIColor.green
            default:
                print("fall through")
            }
            
            ringLayer.strokeColor = strokeColor.cgColor
            
        }
        
    }
    
    func getInsetRect()->CGRect{
        var rect = bounds
        rect = rect.insetBy(dx: CGFloat(lineWidth) / 2.0, dy: CGFloat(lineWidth)/2.0)
        return rect
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !(backgroundRingLayer != nil){
            backgroundRingLayer = CAShapeLayer()
            layer.addSublayer(backgroundRingLayer)
            
            let rect = getInsetRect()
            let path = UIBezierPath(ovalIn: rect)
            
            backgroundRingLayer.fillColor = nil
            backgroundRingLayer.lineWidth = CGFloat(lineWidth)
            backgroundRingLayer.strokeColor = UIColor(white: 0.5, alpha: 0.3).cgColor
            
            backgroundRingLayer.path = path.cgPath
        }
        backgroundRingLayer.frame = layer.bounds
        
        if !(ringLayer != nil){
            ringLayer = CAShapeLayer()
            var rect = bounds
            rect = rect.insetBy(dx: CGFloat(lineWidth) / 2.0, dy: CGFloat(lineWidth)/2.0)
            let path = UIBezierPath(ovalIn: rect)
            
            
            ringLayer.fillColor = nil
            ringLayer.lineWidth = CGFloat(lineWidth)
            ringLayer.path = path.cgPath
            ringLayer.lineCap = "round"
            //transform for pie
            ringLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            //print(ringLayer.anchorPoint)
            ringLayer.transform = CATransform3DRotate(ringLayer.transform, -.pi/2, 0, 0, 1)
            
            
            
            layer.addSublayer(ringLayer)
        }
        
        ringLayer.frame = layer.bounds
        updateLayerProperties()
    }
}

