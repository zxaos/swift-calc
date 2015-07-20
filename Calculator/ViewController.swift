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
                /* Set the display value here. If we do this there's two benefits:
                 * We drop any trailing .0 (so 5.0 enter shows '5'), and setting the
                 * display updates the history, making it far more useful. So yeah.
                 */
                displayValue = number
            }
            numberEntryInProgress = false
        }
    }
    
    @IBAction func undo() {
        if numberEntryInProgress {
            let entrylength = count(display.text!)
            if entrylength == 1 {
                displayValue = nil
                numberEntryInProgress = false
            } else if entrylength > 1 {
                display.text = dropLast(display.text!)
            }
        } else { // else drop the last stack item in the model
            displayValue = calculator.undoOp()
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

