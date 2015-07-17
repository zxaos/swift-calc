//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Matt Bond on 2015-04-26.
//  Copyright (c) 2015 Codefire. All rights reserved.
//

import Foundation

public class CalculatorModel : Printable{
    
    private enum Op : Printable {
        //(symbol, function, precedence)
        case UnaryOperation(String, Double -> Double, Int)
        case BinaryOperation(String, (Double, Double) -> Double, Int)
        case Operand(Double)
        case Constant(String, Double)
        case Variable(String)
        
        var description: String {
            get {
                switch self{
                case .Constant(let symbol, _):
                    return symbol
                case .UnaryOperation(let symbol, _, _):
                    return symbol
                case .BinaryOperation(let symbol, _, _):
                    return symbol
                case .Operand(let value):
                    //Strip the trailing .0 if it's a round number
                    return value % 1 == 0 ? String(format: "%.0f", value) : "\(value)"
                case .Variable(let symbol):
                    return symbol
                }
            }
        }
    }
    
    private var knownConstants = [String:Op]()
    private var knownOperations = [String:Op]()
    private var stack = [Op]()
    //B-$ E-3 DM-2 AS-1
    private let highestPrecedence = 5
    
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
        learnOp(Op.BinaryOperation("+", +, 1))
        learnOp(Op.BinaryOperation("−", { $1 - $0 }, 1))
        learnOp(Op.BinaryOperation("×", *, 2))
        learnOp(Op.BinaryOperation("÷", { $1 / $0 }, 2))
        learnOp(Op.UnaryOperation("√", sqrt, 4))
        learnOp(Op.UnaryOperation("sin", sin, 4))
        learnOp(Op.UnaryOperation("cos", cos, 4 ))
        
    }
    
    public var variableValue = [String:Double]() {
        didSet {
            evaluate(stack)
        }
    }
    
    public func pushOperand(operand: Double) -> Double? {
        stack.append(Op.Operand(operand))
        return evaluate()
    }
    
    public func pushOperand(symbol: String) -> Double? {
        /* It's never specifically mentioned in the spec, so the assumption here is that
         * any variables pushed that have the same name as constants will be masked by those
         * constants, and will just not work (i.e. will use the constant value not the variable).
        */
        if let constant = knownConstants[symbol]{
            stack.append(constant)
        } else {
            stack.append(Op.Variable(symbol))
        }
        return evaluate()
    }
    
    public func performOperation(operation: String) -> Double? {
        if let op = knownOperations[operation]{
            stack.append(op)
            return evaluate()
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
            var current : (description: String?, remaining: [Op], precedence: Int) = ("", stack, highestPrecedence)
            var results : [String?] = []
            do {
                current = evaluateDescription(current.remaining)
                results.append(current.description)
            } while current.remaining.count > 1
            //Drop nils, reverse the array, and stick a comma between every element.
            return ",".join(results.filter({$0 != nil}).map({$0!}).reverse())
        }
    }
    
    // Recursively evaluate an op stack
    private func evaluate(ops: [Op]) -> (result: Double?, remaining: [Op]){
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
            
            case .UnaryOperation( _ , let operation, _):
                //get an operand from the stack
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remaining)
                }
            
            case .BinaryOperation( _, let operation, _):
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
    
    private func evaluateDescription(ops: [Op]) -> (description: String?, remaining: [Op], precedence: Int) {
        if !ops.isEmpty {
            var remainingOps = ops
            let currentOp = remainingOps.removeLast()
            
            switch currentOp {
            
            case .Operand, .Constant, .Variable:
                return (currentOp.description, remainingOps, highestPrecedence)
            
            case .UnaryOperation (let description, _, let precedence):
                //get operand for this
                let operandEvaluation = evaluateDescription(remainingOps);
                if let result = operandEvaluation.description {
                    //No serious precedence processing here since we are always wrapping with parens.
                    return ("\(description)(\(result))", operandEvaluation.remaining, precedence)
                }
                return (nil, remainingOps, highestPrecedence)
                
            case .BinaryOperation (let description, _, let currentPrecedence):
                /* The simplest case is when there is no result to the first evaluation - nil.
                 * Otherwise, we do a separate evaluation and build our string, falling back to
                 * a literal ? if the second evaluation fails.
                 * For both evaluations, wrap with extra parenthesis if the precedence of evaluation is lower
                 * than this to preserve proper order of operations in the output.
                 */
                
                // second result, operation, first result
                var result = ["?", description, ""]
                
                let firstEvaluation = evaluateDescription(remainingOps)
                if let firstDescription = firstEvaluation.description {
                    result[2] = firstEvaluation.precedence < currentPrecedence ? "(\(firstDescription))" : firstDescription
                    let secondEvaluation = evaluateDescription(firstEvaluation.remaining)
                    if let secondDescription = secondEvaluation.description {
                        result[0] = secondEvaluation.precedence < currentPrecedence ? "(\(secondDescription))" : secondDescription
                    }
                    return ("".join(result), secondEvaluation.remaining, currentPrecedence)
                }
                return (nil, remainingOps, currentPrecedence)
            }
        }
        // send back nil if there's no operations to process.
        return (nil, ops, highestPrecedence)
    }
 }
