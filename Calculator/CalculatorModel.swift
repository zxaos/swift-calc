//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Matt Bond on 2015-04-26.
//  Copyright (c) 2015 Codefire. All rights reserved.
//

//TODO: Handle variable interpolation
import Foundation

public class CalculatorModel : Printable{
    
    private enum Op : Printable {
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Operand(Double)
        case Constant(String, Double)
        case Variable(String)
        
        var description: String {
            get {
                switch self{
                case .Constant(let symbol, _):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .Operand(let value):
                    return "\(value)"
                case .Variable(let symbol):
                    return symbol
                }
            }
        }
    }
    
    private var knownConstants = [String:Op]()
    private var knownOperations = [String:Op]()
    private var stack = [Op]()
    
    public init() {
        func learnOp(op: Op){
            switch op {
            case .UnaryOperation, .BinaryOperation:
                knownOperations[op.description] = op
            case .Constant:
                knownConstants[op.description] = op
            default:
                //this should never happen.
                assert(false, "can't learn operand")
            }
        }
        
        learnOp(Op.Constant("π", M_PI))
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−", { $1 - $0 } ))
        learnOp(Op.BinaryOperation("×", * ))
        learnOp(Op.BinaryOperation("÷", { $1 / $0 } ))
        learnOp(Op.UnaryOperation("√", sqrt ))
        learnOp(Op.UnaryOperation("sin", sin ))
        learnOp(Op.UnaryOperation("cos", cos ))
        
    }
    
    public var variableValue = [String:Double]() {
        didSet {
            evaluate(stack)
        }
    }
    
    public func pushOperand(operand: Double){
        stack.append(Op.Operand(operand))
    }
    
    public func pushOperand(operand: String){
        if let constant = knownConstants[operand]{
            stack.append(constant)
        } else {
            
        }
    }
    
    public func performOperation(operation: String) -> Double? {
        if let op = knownOperations[operation]{
            stack.append(op)
            return evaluate(stack).result
        }
        return nil
    }
    
    public func resetOperands(){
        stack.removeAll(keepCapacity: true)
    }
    
    public func evaluate() -> Double? {
        return evaluate(stack).result
    }
    
    public var description: String {
        get {
            return ""
        }
    }
    
    /* Recursively evaluate an op stack*/
    private func evaluate(ops: [Op]) -> (result: Double?, remaining: [Op]){
        println("Evaluating Stack: \(ops)")
        if !ops.isEmpty {
            var remainingOps = ops
            let currentOp = remainingOps.removeLast()
            
            switch currentOp {
            
            case .Constant( _ , let value):
                return (value, remainingOps)
            
            case .Operand(let value):
                return (value, remainingOps)
            
            case .Variable(let symbol):
                return (variableValue[symbol], remainingOps)
            
            case .UnaryOperation( _ , let operation ):
                //get an operand from the stack
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remaining)
                }
            
            case .BinaryOperation( _, let operation):
                //get an operand from the stack
                let operandEvaluation = evaluate(remainingOps)
                if let firstOperand = operandEvaluation.result {
                    // If we succeeded, get another operand with remaining stack from first evaluation
                    let operand2Evaluation = evaluate(operandEvaluation.remaining)
                    if let secondOperand = operand2Evaluation.result {
                        //we have two operands. Run the function and return.
                        return (operation(firstOperand, secondOperand), operand2Evaluation.remaining)
                    }
                }
                
            default:
                return(nil, remainingOps)
            }
        }
        return (nil, ops)
    }
 }
