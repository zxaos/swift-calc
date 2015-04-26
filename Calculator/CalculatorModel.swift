//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Matt Bond on 2015-04-26.
//  Copyright (c) 2015 Codefire. All rights reserved.
//
import Foundation

public class CalculatorModel {
    
    private enum Op : Printable {
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Operand(Double)
        case Constant(String, Double)
        
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
    
    public func pushOperand(operand: Double){
        stack.append(Op.Operand(operand))
    }
    
    public func pushOperand(operand: String){
        if let constant = knownConstants[operand]{
            stack.append(constant)
        }
    }
    
    public func performOperation(operation: String){
        if let op = knownOperations[operation]{
            stack.append(op)
        }
    }
    public func evaluate() -> Double? {
        return evaluate(stack).result
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remaining: [Op]){
        if !ops.isEmpty {
            var remainingOps = ops
            let currentOp = remainingOps.removeLast()
            switch currentOp {
            case .Constant( _ , let value):
                return (value, remainingOps)
            case .Operand(let value):
                return (value, remainingOps)
            case .UnaryOperation( _ , let operation ):
                //get an operand from the stack
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remaining)
                }
            case .BinaryOperation( _, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let firstOperand = operandEvaluation.result {
                    let operand2Evaluation = evaluate(operandEvaluation.remaining)
                    if let secondOperand = operand2Evaluation.result {
                        return (operation(firstOperand, secondOperand), operand2Evaluation.remaining)
                    }
                }
            default:
                return(nil, ops)
            }
        }
        return (nil, ops)
    }
 }