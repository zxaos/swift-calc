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
        case .binary:
            print("Binary operation")
        case .equals:
            print("Equals")
        }
    }
    
    private var accumulator = 0.0
    private var pendingBinaryOp : OperationType?
  
    private enum OperationType {
        case constant(Double)
        case unary( (Double) -> Double )
        case binary( (Double, Double) -> Double )
        case equals
//        if pending != nil {
//            accumulator = pendingBinary
//        }
    }
    
    private let operations: Dictionary<String,OperationType> = [
        "π" : .constant(M_PI),
        "e" : .constant(M_E),
        "√" : .unary(sqrt),
        "+" : .binary( + ),
        "−" : .binary( - ),
        "×" : .binary( * ),
        "÷" : .binary( { $1 / $0 } ),
        "=" : .equals
    ]
}
