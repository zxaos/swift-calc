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
    
    func testSubtraction() {
        // 6 - 2 = 4
        c.pushOperand(3)
        c.pushOperand(5)
        c.performOperation("−")
        let result = c.evaluate()
        XCTAssertNotNil(result)
        if result != nil {
            XCTAssertEqual(result!, -2.0)
        }
    }
    
    func testAddMultiplyOperatorPrecedence(){
        // 2 + 3 * 4 = 14
        // (2 + 3) * 4 = 20
        c.pushOperand(2)
        c.pushOperand(3)
        c.pushOperand(4)
        c.performOperation("×")
        c.performOperation("+")
        let result = c.evaluate()
        XCTAssertNotNil(result)
        if result != nil {
            XCTAssertEqual(result!, 14.0)
        }
        // 1 * 2 + 3 = 5
        c.resetOperands()
        c.pushOperand(1)
        c.pushOperand(2)
        c.pushOperand(3)
        c.performOperation("+")
        c.performOperation("×")
        XCTAssertNotNil(result)
        if result != nil {
            XCTAssertEqual(result!, 5.0)
        }
    }
}