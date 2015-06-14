//
//  CalculatorModelQuickTests.swift
//  Calculator
//
//  Created by Matt Bond on 2015-06-13.
//  Copyright (c) 2015 Codefire. All rights reserved.
//

import Quick
import Nimble
import Calculator

class CalculatorModelQuickTests: QuickSpec {
    override func spec() {
        var c : CalculatorModel!
        
        beforeEach {
            c = CalculatorModel();
        }
        
        describe("the Calculator Model"){
            
            it("applies variables when calculating"){
                //given r = 6 - x * 32 ;  x = -9 -> y = 294
                c.pushOperand(6)
                c.pushOperand("x")
                c.pushOperand(32)
                c.performOperation("×")
                c.performOperation("−")
                
                c.variableValue["x"] = -9
                
                expect(c.evaluate()).to(equal(294))
            }
            
            xit("clears all data upon request"){}
            
            xit("applies addition and multiplication with correct order of operations"){
                // 2 + 3 * 4 = 14
                // (2 + 3) * 4 = 20
                c.pushOperand(2)
                c.pushOperand(3)
                c.pushOperand(4)
                c.performOperation("×")
                c.performOperation("+")
                expect(c.evaluate()).to(equal(14))
                // 1 * 2 + 3 = 5
                c.resetOperands()
                c.pushOperand(1)
                c.pushOperand(2)
                c.pushOperand(3)
                c.performOperation("+")
                c.performOperation("×")
//                XCTAssertNotNil(result)
//                if result != nil {
//                    XCTAssertEqual(result!, 5.0)
//                }
            }
        }
    }
}
