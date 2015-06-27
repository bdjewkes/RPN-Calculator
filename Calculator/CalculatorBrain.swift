//
//  CalculatorBrain.swift
//  Caclulator
//
//  Created by Brian Jewkes on 6/6/15.
//  Copyright (c) 2015 Brian Jewkes. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum Op: Printable {
        case Operand(Double)
        case Variable(String)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double,Double) -> Double, Int)
        case Constant(String, Double -> Double)
        
        var description: String{
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let variable):
                    return variable
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _, _):
                    return symbol
                case .Constant(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    var description: String {
        get{
            var description = " "
            var (result, remainder) = describeStack()
            if let statement = result {
                description = statement
            }
            while remainder.count > 0 {
                (result, remainder, _) = describeStack(remainder)
                if let statement = result {
                    description.splice("\(statement), ", atIndex: description.startIndex)
                }
            }
            return description
        }
    }
    
    private var knownOps = [String:Op]()

    init() {
        func learnOp(op: Op){
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×",*, 1))
        learnOp(Op.BinaryOperation("÷", {$1 / $0}, 1))
        learnOp(Op.BinaryOperation("−", {$1 - $0}, 0))
        learnOp(Op.BinaryOperation("+",+, 0))
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("±") {$0 * -1})
        learnOp(Op.Constant("π") {$0 * M_PI})
    }
    
    typealias PropertyList = AnyObject
    var program: PropertyList {// guaranteed to be a PropertyList
        get{
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol]{
                        newOpStack.append(op)
                    }
                    else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue{
                        newOpStack.append(.Operand(operand))
                    } else {
                        newOpStack.append(.Variable(opSymbol))
                    }
                    
                }
                opStack = newOpStack
            }
            
        }
        
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]){
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Variable(let variable):
                if let varValue = variableValues[variable] {
                    return (varValue, remainingOps)
                } else {
                    return (nil, remainingOps)
                }
            case .UnaryOperation(_, let operation):
                let operandEvaluation =  evaluate(remainingOps)
                if let operand = operandEvaluation.result{
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation, _):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result{
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result{
                        return (operation(operand1,operand2), op2Evaluation.remainingOps)
                    }
                }
            case .Constant(_, let constant):
                return (constant(1), remainingOps)
            }
        }
        return (nil, ops)
    }
    
    private func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
    //    println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    private func describeStack(ops: [Op]) -> (result: String?, remainingOps: [Op], precedence: Int) {
        if !ops.isEmpty{
            var remainingOps = ops //create a mutable array
            let op = remainingOps.removeLast() //pop the top element from the 'stack'
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainingOps, Int.max)
            case .Variable(let variable):
                return (variable, remainingOps, Int.max)
            case .UnaryOperation(let symbol, let operation):
                let operandDescription =  describeStack(remainingOps)
                if let operand = operandDescription.result{
                    return ("\(symbol)(\(operand))", operandDescription.remainingOps, Int.max)
                }
            case .BinaryOperation(let symbol, let operation, let precedence):
                let op1Description = describeStack(remainingOps)
                if let operand1 = op1Description.result{
                    var op1ReturnValue = operand1
                    var op2ReturnValue: String
                    let op2Description = describeStack(op1Description.remainingOps)
                    if let operand2 = op2Description.result{
                        op2ReturnValue = operand2
                    } else {
                        op2ReturnValue = "?"
                    }
                    if precedence > op2Description.precedence {
                        op2ReturnValue = "(\(op2ReturnValue))"
                    }
                    else if precedence > op1Description.precedence {
                        op1ReturnValue = "(\(op1ReturnValue))"
                    }
                    return ("\(op2ReturnValue) \(symbol) \(op1ReturnValue)", op2Description.remainingOps, precedence)
                }
            case .Constant(let symbol, let constant):
                return (symbol, remainingOps, Int.max)
            }
        }
        return (nil, ops, Int.max)
    }
    private func describeStack() -> (String?, [Op]){
        var (result, remainder, _) = describeStack(opStack)
        return (result, remainder)
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    var variableValues = [String:Double]()
    
    func pushOperand(symbol: String) -> Double? {
        variableValues[symbol] = nil
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func clearOpStack()
    {
        opStack = [Op]()
    }
    
    func clearVariableValues(){
        variableValues = [String:Double]()
    }
    
    func updateDisplay() -> Double?{
        return evaluate()
    }
    
    func undoLastOp() -> Bool
    {
        if opStack.count > 0{
            opStack.removeLast()
        }
        if let lastOp = opStack.last{
            switch lastOp{
            case .BinaryOperation(_,_,_):
                return true
            case .UnaryOperation(_,_):
                return true
            default:
                return false
            }
        } else{
        return false
        }
    }
}
