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