//
//  ViewController.swift
//  Swift-Calc
//
//  Created by Matt Bond on 2016-12-02.
//  Copyright © 2016 Codefire. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let model = CalculatorModel()
    
    private var numberEntryInProgress = false;
    
    @IBOutlet private weak var display: UILabel!
    
    private var displayValue: Double {
        get { return Double(display.text!)! }
        set { display.text = String(newValue) }
    }
    
    @IBAction private func digitButtonTapped(_ button: UIButton) {
        let title = button.currentTitle!
        if numberEntryInProgress {
            display.text! += title
        } else {
            display.text! = title
            numberEntryInProgress = true
        }
    }
    
    @IBAction private func operationButtonTapped(_ button: UIButton) {
        guard let title = button.currentTitle else {return}
        if (numberEntryInProgress) {
            model.setOperand(displayValue)
            numberEntryInProgress = false
        }
        model.performOperation(title)
        displayValue = model.result
    }
}

