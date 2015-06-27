//
//  GraphView.swift
//  Calculator
//
//  Created by Brian Jewkes on 6/23/15.
//  Copyright (c) 2015 Brian Jewkes. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func fOfX(x: Double) -> Double?
}
@IBDesignable
class GraphView: UIView {

    var originOffset: (CGFloat, CGFloat) = (0,0) { didSet { setNeedsDisplay() }}
    
    var origin: CGPoint {
        let centerOfView = convertPoint(center, fromView: superview)
        return CGPoint(x: centerOfView.x + originOffset.0, y: centerOfView.y + originOffset.1)
    }

    
    @IBInspectable
    var scale: CGFloat = 1 { didSet { setNeedsDisplay()} }
    
    func scale(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1
        }
    }
    func panOriginOffset(gesture: UIPanGestureRecognizer) {
        if gesture.state == .Changed {
            let translatePoint = gesture.translationInView(self)
            originOffset.0 += translatePoint.x
            originOffset.1 += translatePoint.y
            gesture.setTranslation(CGPoint(x: 0,y:0), inView: self)
        }
    }
    func tapOriginOffset(gesture: UITapGestureRecognizer) {
        let tapPoint = gesture.locationOfTouch(0, inView: self)
        let centerOfView = convertPoint(center, fromView: superview)
        originOffset = (tapPoint.x - centerOfView.x, tapPoint.y - centerOfView.y)
    }

    weak var dataSource: GraphViewDataSource?
    
    var axesDrawer = AxesDrawer(color: UIColor.blueColor())
    
    override func drawRect(rect: CGRect) {
        axesDrawer.drawAxesInRect(rect, origin: origin, pointsPerUnit: scale)
        let path = UIBezierPath()
        var lastPoint:CGPoint?
        var lastGraphPointX: Double? = nil // the previous value of X in graph space
        for pixelX in 0...Int(bounds.size.width) {
            var currentPixelPoint:CGPoint?
            var graphPointX = (Double(pixelX) - Double(origin.x)) / Double(scale)
            if let lastGraphX = lastGraphPointX {
                // make sure that intger values of x aren't skipped over
                if ceil(lastGraphX) == floor(graphPointX) && lastGraphX%1 != 0{
                    graphPointX = floor(graphPointX)
                }
            }
            lastGraphPointX = graphPointX
            var yValue = dataSource?.fOfX(graphPointX)
            if let graphPointY = yValue{
                currentPixelPoint = CGPoint(x: CGFloat(pixelX), y: (origin.y + CGFloat(-graphPointY)*scale))
                path.moveToPoint(currentPixelPoint!)
                if let lastPixelPoint = lastPoint{
                    path.addLineToPoint(lastPixelPoint)
                    path.stroke()
                }
                lastPoint = currentPixelPoint
            } else {
               lastPoint = nil
            }
        }
    }
}
