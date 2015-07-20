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

class CalculatorModelSpec: QuickSpec {
    override func spec() {
        var c : CalculatorModel!
        
        beforeEach {
            c = CalculatorModel();
        }

        describe("getConstantValue"){
            it("gets the numeric value of a constant that exists"){
               expect(c.getConstantValue("π")).to(equal(M_PI))
            }

            it("returns nil for unknown constants"){
                expect(c.getConstantValue("q")).to(beNil())
            }
        }
        
        describe("allows variables"){
        
            it("applies variables when calculating"){
                //given y = 6 - x * 32 ;  x = -9 -> y = 294
                c.pushOperand(6)
                c.pushOperand("x")
                c.pushOperand(32)
                c.performOperation("×")
                c.performOperation("−")
                c.variableValue["x"] = -9
                expect(c.evaluate()).to(equal(294))
            }
            
            it("immediately evaluates the expression when a variable is used"){
                c.variableValue["x"] = -9
                var result = c.pushOperand("x")
                expect(result).to(equal(-9))
            }
            
            it("treats undefined variables as nil"){
                expect(c.pushOperand("u")).to(beNil())
            }
        }
        
        xit("clears all data upon request"){}
        
        
        it("applies operations backwards down the expression"){
            //   2 + 3 * 4 = 14
            // = 2 + (3 * 4) = 14
            c.pushOperand(2)
            c.pushOperand(3)
            c.pushOperand(4)
            c.performOperation("×")
            c.performOperation("+")
            expect(c.evaluate()).to(equal(14))
        }
        
        describe("the description"){
            it("shows unary operations with function notation"){
                c.pushOperand(10)
                c.performOperation("cos");
                expect(c.description).to(equal("cos(10)"))
            }
            
            it("shows binary operations with infix notation"){
                c.pushOperand(3)
                c.pushOperand(5)
                c.performOperation("−")
                expect(c.description).to(equal("3−5"))
            }
            
            it("shows operands unadorned"){
                c.pushOperand(23.5)
                expect(c.description).to(equal("23.5"))
            }
            
            it("shows constants using their symbols"){
                c.pushOperand("π")
                expect(c.description).to(equal("π"))
            }
            
            it("shows variables using their symbols"){
                c.pushOperand("x")
                expect(c.description).to(equal("x"))
            }
            
            describe("and combines operation styles properly"){
                it("combines unary and binary"){
                    c.pushOperand(10)
                    c.performOperation("√")
                    c.pushOperand(3)
                    c.performOperation("+")
                    expect(c.description).to(equal("√(10)+3"))
                }
                it("combines binary and unary"){
                    c.pushOperand(3)
                    c.pushOperand(5)
                    c.performOperation("+")
                    c.performOperation("√")
                    expect(c.description).to(equal("√(3+5)"))
                }
                it("combines binary and binary"){//don't apply unnecessary parens
                    c.pushOperand(3)
                    c.pushOperand(5)
                    c.pushOperand(4)
                    c.performOperation("+")
                    c.performOperation("+")
                    expect(c.description).to(equal("3+5+4"))
                }                   
                it("combines unary and binary and unary and binary"){
                    c.pushOperand(3)
                    c.pushOperand(5)
                    c.performOperation("√")
                    c.performOperation("+")
                    c.performOperation("√")
                    c.pushOperand(6)
                    c.performOperation("÷")
                    expect(c.description).to(equal("√(3+√(5))÷6"))
                }
            }
            
            it("displays a '?' in place of missing operands"){
                c.pushOperand(3)
                c.performOperation("+")
                expect(c.description).to(equal("?+3"))
            }
            
            it("separates multiple complete expressions with commas"){
                c.pushOperand(3)
                c.pushOperand(5)
                c.performOperation("+")
                c.performOperation("√")
                c.pushOperand("π")
                c.performOperation("cos")
                expect(c.description).to(equal("√(3+5),cos(π)"))
            }
            
            it ("separates individual numbers like they were complete expressions"){
                c.pushOperand(3)
                c.pushOperand(5)
                expect(c.evaluate()).to(equal(5))
                expect(c.description).to(equal("3,5"))
            }
            
            it("adds parenthesis to ensure expression matches output"){
                c.pushOperand(3)
                c.pushOperand(5)
                c.pushOperand(4)
                c.performOperation("+")
                c.performOperation("×")
                expect(c.description).to(equal("3×(5+4)"))
            }
            
            it("can undo stack entries"){
                c.pushOperand(3)
                c.pushOperand(5)
                c.performOperation("+")
                c.performOperation("√")
                c.undoOp()
                expect(c.evaluate()).to(equal(8))
            }
        }
    }
}
