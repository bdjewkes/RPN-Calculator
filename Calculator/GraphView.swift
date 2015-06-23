//
//  GraphView.swift
//  Calculator
//
//  Created by Brian Jewkes on 6/23/15.
//  Copyright (c) 2015 Brian Jewkes. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
}
@IBDesignable
class GraphView: UIView {

    var origin: CGPoint{
        return convertPoint(center, fromView: superview)
    }
    
    @IBInspectable
    var scale: CGFloat = 1 { didSet {setNeedsDisplay()} }
    
    func scale(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1
            println(scale)
        }
    }
    
    weak var dataSource: GraphViewDataSource?
    
    var axesDrawer = AxesDrawer(color: UIColor.blueColor())
    
    override func drawRect(rect: CGRect) {
        axesDrawer.drawAxesInRect(rect, origin: origin, pointsPerUnit: scale)
    }
    
}
