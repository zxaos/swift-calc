//
//  CalculatorModel.swift
//  Swift-Calc
//
//  Created by Matt Bond on 2016-12-02.
//  Copyright © 2016 Codefire. All rights reserved.
//

import Foundation

class CalculatorModel {
    
    public var result : Double {
        get { return accumulator }
    }
    
    public func setOperand(_ operand: Double) {
        accumulator = operand
    }
    
    public func performOperation(_ symbol: String) {
        guard let operation = self.operations[symbol] else { return }
        switch operation {
        case .constant(let value):
            accumulator = value
        case .unary(let function):
            accumulator = function(accumulator)
        case .binary(let function):
            runPendingBinaryOperation()
            pendingBinaryOp = PendingBinaryOperation(binaryFunction: function, operand: accumulator)
        case .equals:
            runPendingBinaryOperation()
        }
    }
    
    private var accumulator = 0.0
    private var pendingBinaryOp : PendingBinaryOperation?
    
    private func runPendingBinaryOperation() {
        if pendingBinaryOp != nil {
            accumulator = pendingBinaryOp!.binaryFunction(pendingBinaryOp!.operand, accumulator)
            pendingBinaryOp = nil
        }
    }
    
    private struct PendingBinaryOperation {
        var binaryFunction: (Double, Double) -> Double
        var operand: Double
    }
  
    private enum OperationType {
        case constant(Double)
        case unary( (Double) -> Double )
        case binary( (Double, Double) -> Double )
        case equals
    }
    
    private let operations: Dictionary<String,OperationType> = [
        "π" : .constant(M_PI),
        "e" : .constant(M_E),
        "√" : .unary(sqrt),
        "±" : .unary({ -$0}),
        // These could just be the plain operator (e.g. +) but it makes xcode
        // unhappy because it has to examine too many options to resolve the type?
        "+" : .binary( { $0 + $1} ), 
        "−" : .binary( { $0 - $1} ),
        "×" : .binary( { $0 * $1} ),
        "÷" : .binary( { $0 / $1} ),
        "=" : .equals
    ]
}
