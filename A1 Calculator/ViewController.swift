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
    
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            if newValue == 0 {
                display.text = "0"
            } else {
                display.text = "\(newValue)"
            }
        }
    }
    
    var numberEntryInProgress = false
    var stack = Array<Double>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        display.text = "0"
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
        var constantValue: Double = 0.0
        switch constant {
        case "π": constantValue = M_PI;
        default:
            break;
        }
        stack.append(constantValue)
        history.text! += " \(constant)"
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
            stack.append(displayValue)
            if let equalPosition = history.text!.rangeOfString(" =") {
                history.text!.removeRange(equalPosition)
            }
            history.text! += " " + display.text!
            numberEntryInProgress = false
        }
        println(stack)
    }
    
    @IBAction func removeLastDisplayNumber() {
        if numberEntryInProgress {
            let entrylength = countElements(display.text!)
            if entrylength == 1 {
                display.text = "0"
                numberEntryInProgress = false
            } else if entrylength > 1 {
                display.text = dropLast(display.text!)
            }
            // else it's 0, so do nothing
        }
    }
    
    @IBAction func toggleSign() {
        if numberEntryInProgress{
            if let negString =  display.text!.rangeOfString("-"){
                display.text!.removeRange(negString)
            } else {
                display.text! = "-\(display.text!)"
            }
        }
    }
    
    @IBAction func clear() {
        history.text = " "
        displayValue = 0
        stack.removeAll(keepCapacity: true)
        numberEntryInProgress = false
    }

    @IBAction func enterOperation(sender: UIButton) {
        if numberEntryInProgress {
            println("Implicit enter")
            enter()
        }

        let operation = sender.currentTitle!
        var op_result = false
        let wrapped_plus: (Double,Double) -> Double = (+)
        switch operation {
        case "+": op_result = performOperation { $0 + $1 }
        case "−": op_result = performOperation { $0 - $1 }
        case "×": op_result = performOperation( * )
        case "÷": op_result = performOperation( / )
        case "√": op_result = performOperation( sqrt )
        case "sin": op_result = performOperation( sin )
        case "cos": op_result = performOperation( cos )
        default:
            break
        }
        if op_result {
            history.text! += " \(operation) ="
        }
    }
    
    func performOperation (op: (Double, Double) -> Double) -> Bool {
        if stack.count >= 2 {
            // swap the order of the last two operands so minus and divide make sense
            // plus and multiply are commutative so we don't care
            let last = stack.removeLast()
            displayValue = op(stack.removeLast(), last)
            //Set this here or else enter will not do anything
            numberEntryInProgress = true
            enter()
            return true
        }
        return false
    }
    
    func performOperation (op: (Double) -> Double) -> Bool {
        if stack.count >= 1 {
            displayValue = op(stack.removeLast())
            numberEntryInProgress = true
            enter()
            return true
        }
        return false
    }
}