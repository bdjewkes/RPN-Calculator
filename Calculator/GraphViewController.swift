//
//  GraphViewController.swift
//  Calculator
//
//  Created by Brian Jewkes on 6/23/15.
//  Copyright (c) 2015 Brian Jewkes. All rights reserved.
//

import UIKit

@IBDesignable
class GraphViewController: UIViewController, GraphViewDataSource {

    typealias PropertyList = AnyObject
    var program: PropertyList?
    var independentVariable: String?
    
    
    private var brain = CalculatorBrain()
    
    
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            if let brainProgram:PropertyList = program {
                brain.program = brainProgram
                if let x = independentVariable {
                    brain.variableValues[x] = nil
                }
                println("The current brain description: \(brain.description)")
                self.title = brain.description
                
            }
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "scale:"))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "panOriginOffset:"))
            graphView.addGestureRecognizer(UITapGestureRecognizer(target: graphView, action: "tapOriginOffset:"))
        }
    }
    func fOfX(x: Double) -> Double? {
        brain.variableValues["M"] = x
        let returnValue = brain.updateDisplay()
        println("X value: \(x), y Value: \(returnValue)")
        if returnValue?.isNormal ?? true || returnValue?.isZero ?? true{
            return brain.updateDisplay()
        } else {
            return nil
        }
        
    }
}

