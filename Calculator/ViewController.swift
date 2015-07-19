//
//  ViewController.swift
//  A1 Calculator
//
//  Created by Matt Bond on 2015-02-01.
//  Copyright (c) 2015 Codefire. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var display: UILabel!

    let calculator = CalculatorModel()
    
    var numberEntryInProgress = false

    var displayValue: Double? {
        get {
            //numberFromString requires a string not an optional, so default to an empty string instead of nil.
            return NSNumberFormatter().numberFromString(display.text ?? "")?.doubleValue
        }
        set {
            if newValue == nil{
                display.text = " "
            } else {
                //if we have a real number unwrap it and discard any ".0" component
                display.text = (newValue! % 1 == 0 ? String(format: "%.0f", newValue!) : "\(newValue!)")
            }
            history.text = count(calculator.description) > 1 ? calculator.description + " =" : " "
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayValue = 0
        history.text = " "
    }
    
    @IBAction func enterDigit(sender: UIButton) {
        if !numberEntryInProgress {
            display.text = sender.currentTitle!
        } else {
            display.text! += sender.currentTitle!
        }
        numberEntryInProgress = true
    }
    
    @IBAction func enterConstant(sender: UIButton) {
        let constant = sender.currentTitle!
        calculator.pushOperand(constant)
        displayValue = calculator.getConstantValue(constant)
        numberEntryInProgress = false;
    }
    
    @IBAction func enterDecimal() {
        if (numberEntryInProgress){
            if display.text?.rangeOfString(".") == nil {
                // no decimal was found, so it's safe to add one
                display.text! += "."
            }
        } else {
            // This must be the first button pressed in the current number
            // So prepand a zero
            display.text = "0."
            numberEntryInProgress = true
        }
    }
    
    @IBAction func enter() {
        if numberEntryInProgress {
            if let number = displayValue {
                calculator.pushOperand(number)
            }
            numberEntryInProgress = false
        }
    }
    
    @IBAction func removeLastDisplayNumber() {
        if numberEntryInProgress {
            let entrylength = count(display.text!)
            if entrylength == 1 {
                displayValue = nil
                numberEntryInProgress = false
            } else if entrylength > 1 {
                display.text = dropLast(display.text!)
            }
            // else it's 0, so do nothing
        }
    }
    
    @IBAction func toggleSign() {
        if numberEntryInProgress{
            displayValue! *= -1
        }
    }
    
    @IBAction func clear() {
        calculator.resetOperands()
        calculator.variableValue.removeAll(keepCapacity: true)
        displayValue = nil
        numberEntryInProgress = false
    }

    @IBAction func enterOperation(sender: UIButton) {
        if numberEntryInProgress {
            enter()
        }

        let operation = sender.currentTitle!
        displayValue = calculator.performOperation(operation)
    }
    
    @IBAction func setMemory() {
        if let value = displayValue {
            calculator.variableValue["M"] = value
            numberEntryInProgress = false;
            displayValue = calculator.evaluate()
        }
    }
    
    @IBAction func getMemory() {
        let result = calculator.pushOperand("M")
        if result != nil {
            displayValue = result
        }
    }
    
}

