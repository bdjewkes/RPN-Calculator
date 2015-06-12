//
//  ViewController.swift
//  Caclulator
//
//  Created by Brian Jewkes on 5/24/15.
//  Copyright (c) 2015 Brian Jewkes. All rights reserved.
//

import UIKit

class ViewController: UIViewController
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
                
            } else {
                display.text = " "
            }
            usrTypingNum = false;
        }
    }
    
    @IBOutlet weak var opDisplay: UILabel!
    
    var opDisplayValue: String?{
        get{
            if let opDisplayValue = opDisplay.text{
                return opDisplayValue
            } else{
                return nil
            }
        }
        set{
            if let value = newValue{
                opDisplay.text = value
            } else {
                opDisplay.text = " "
            }
        }
    }
    
    func UpdateDisplayValues(operation: Bool = false){
        displayValue = brain.updateDisplay()
        var suffix = ""
        if operation {
            suffix = " ="
        }
        opDisplayValue = brain.description + suffix
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
                brain.performOperation(operation)
                UpdateDisplayValues(operation: true)
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
            brain.pushOperand(displayValue!)
            UpdateDisplayValues()
        }
    }
    @IBAction func clear() {
        brain.clearOpStack()
        brain.clearVariableValues()
        UpdateDisplayValues()
        displayValue = 0
    }
    
    @IBAction func undo() {
        if count(display.text!) > 1 && usrTypingNum {
            display.text = dropLast(display.text!)
        } else if count(display.text!) == 0 && usrTypingNum{
            displayValue = 0
            usrTypingNum = false
        } else{
            UpdateDisplayValues(operation: brain.undoLastOp())
        }
    }
    
    @IBAction func pushVar(sender: UIButton) {
        usrTypingNum = false
        let varName = "M"
        brain.pushOperand(varName)
        UpdateDisplayValues()
    }
    @IBAction func setVar(sender: UIButton) {
        usrTypingNum = false
        let varName = "M"
        if let displayNumberValue = displayValue {
            brain.variableValues["\(varName)"] = displayNumberValue
        }
        UpdateDisplayValues()
    }
}
