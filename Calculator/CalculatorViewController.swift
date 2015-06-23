//
//  ViewController.swift
//  Caclulator
//
//  Created by Brian Jewkes on 5/24/15.
//  Copyright (c) 2015 Brian Jewkes. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController
{
    
    @IBOutlet weak var display: UILabel!
    
    var displayValue: Double?{
        get {
            if let displayDouble = NSNumberFormatter().numberFromString(display.text!)?.doubleValue {
                return displayDouble
            } else {
                return nil
            }
        }
        set{
            if let value = newValue{
                display.text = "\(value)"
                opHistoryValue = "\(brain.description) ="
            } else {
                display.text = "0.0"
                opHistoryValue = " "
            }
            usrTypingNum = false;
            
        }
    }
 
    @IBOutlet weak var opHistory: UILabel!

    var opHistoryValue: String?{
        get{
            if let opHistoryValue = opHistory.text{
                return opHistoryValue
            } else{
                return nil
            }
        }
        set{
            if let value = newValue{
                opHistory.text = value
            } else {
                opHistory.text = " "
            }
        }
    }
    
    var brain = CalculatorBrain()
    
    var usrTypingNum = false

    @IBAction func operate(sender: UIButton) {
        
        if usrTypingNum && sender.currentTitle == "±" {
            displayValue! *= -1
        }else {
            if usrTypingNum {
                enter()
            }
            if let operation = sender.currentTitle {
                displayValue = brain.performOperation(operation)
            }
        }
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if digit != "." || display.text!.rangeOfString(".") == nil {
            if(usrTypingNum){
                display.text = display.text! + digit
            }else{
                display.text = digit
                usrTypingNum = true
            }
        }
    }
    
    @IBAction func enter() {
        usrTypingNum = false
        if let displayNumberValue = displayValue {
            displayValue = brain.pushOperand(displayValue!)
        }
    }
    @IBAction func clear() {
        brain.clearOpStack()
        brain.clearVariableValues()
        displayValue = nil
    }
    
    @IBAction func undo() {
        if count(display.text!) > 1 && usrTypingNum {
            display.text = dropLast(display.text!)
        } else if count(display.text!) == 0 && usrTypingNum{
            displayValue = 0
            usrTypingNum = false
        } else{
            brain.undoLastOp()
            displayValue = brain.updateDisplay()
        }
    }
    
    @IBAction func pushVar(sender: UIButton) {
        usrTypingNum = false
        displayValue = brain.pushOperand(sender.currentTitle!)
    }
    
    @IBAction func setVar(sender: UIButton) {
        usrTypingNum = false
        if let displayNumberValue = displayValue {
            brain.variableValues[String(sender.currentTitle![advance(sender.currentTitle!.startIndex, 1)])] = displayNumberValue
        }
        displayValue = brain.updateDisplay()
    }
}
