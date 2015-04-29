//
//  CalculatorModelTests.swift
//  Calculator
//
//  Created by Matt Bond on 2015-04-26.
//  Copyright (c) 2015 Codefire. All rights reserved.
//

import Foundation
import XCTest
import Calculator

class CalculatorModelTests: XCTestCase {
    let c = CalculatorModel()
    
    func testThatBinaryOperationsGiveCorrectValueWithTwoOperands() {
        // given 10 - 15 = -5
        c.pushOperand(10)
        c.pushOperand(15)
        
        // when
        let result = c.performOperation("−")
        
        //then
        XCTAssertNotNil(result)
        if result != nil {
            XCTAssertEqual(result!, -5.0)
        }
    }
    
    func testThatItAppliesVariablesWhenEvaluating(){
        //given r = 6 - x * 32 ;  x = -9 -> y = 294
        c.pushOperand(6)
        c.pushOperand("x")
        c.pushOperand(32)
        c.performOperation("×")
        c.performOperation("−")
        
        //when
        c.variableValue["x"] = -9
        
        let result = c.evaluate()
        //then
        XCTAssertNotNil(result)
        if result != nil {
            XCTAssertEqual(result!, 294)
        }
    }
    
    func testAddMultiplyOperatorPrecedence(){
        // 1 + 2 * 3 = 7
        // NOT 9
        c.pushOperand(1)
        c.pushOperand(2)
        c.pushOperand(3)
        c.performOperation("×")
        c.performOperation("+")
        let result = c.evaluate()
        XCTAssertNotNil(result)
        if result != nil {
            XCTAssertEqual(result!, 7.0)
        }
    }
}