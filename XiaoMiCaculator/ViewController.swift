//
//  ViewController.swift
//  XiaoMiCaculator
//
//  Created by 123 on 2019/5/2.
//  Copyright © 2019年 wave. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var displayLabel1: UILabel!
    @IBOutlet weak var displayLabel2: UILabel!
    @IBOutlet weak var displayLabel3: UILabel!
    @IBOutlet weak var displayLabel4: UILabel!
    @IBOutlet weak var displayLabel5: UILabel!
    @IBOutlet weak var displayLabel6: UILabel!
    
    var displayLabelArray = [UILabel]()
    var isUserInTheMiddleOfTypeing = false
//    var errorMessage = ""
    var currentOperation = ""
    var currentResult = 0.0
    var calculator = Calculator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayLabelArray.append(displayLabel1)
        displayLabelArray.append(displayLabel2)
        displayLabelArray.append(displayLabel3)
        displayLabelArray.append(displayLabel4)
        displayLabelArray.append(displayLabel5)
        displayLabelArray.append(displayLabel6)
        
        for displayLabel in displayLabelArray {
            displayLabel.text = ""
            displayLabel.textColor = UIColor.lightGray
        }
        displayLabel6.text = "0"
        displayLabel6.textColor = UIColor.darkGray
        
        currentOperation = "+"
    }
    
    var displayValue: Double {
        get {
            let (_,_,digitalText) = textHasOperation(text:displayLabel5.text)
            return NumberFormatter().number(from: digitalText!)!.doubleValue
        }
        set {
            displayLabel5.text = floatToString(data: newValue)
            isUserInTheMiddleOfTypeing = false
        }
    }
    
    func textHasOperation(text:String?) -> (Bool, String?, String?) {
        let subText = text!.split(separator: " ")
        var hasOperation = false
        var digitalText, operationText: String?
        if subText.count > 1 {
            hasOperation = true
            operationText = String(subText[0])
            digitalText = String(subText[1])
        } else if subText.count == 1 {
            let unknownText = String(subText[0])
            if unknownText.count > 0 {
                if unknownText[unknownText.startIndex] >= "0" && unknownText[unknownText.startIndex] <= "9" {
                    digitalText = unknownText
                } else {
                    hasOperation = true
                    operationText = unknownText
                }
            }
        }
        return (hasOperation, operationText, digitalText)
    }
    
    func changeBoldDisplayFrom6To5() {
        displayLabel5.font = UIFont.systemFont(ofSize: 32)
        displayLabel5.textColor = UIColor.darkGray
        displayLabel6.font = UIFont.systemFont(ofSize: 28)
        displayLabel6.textColor = UIColor.lightGray
    }
    
    func changeBoldDisplayFrom5To6() {
        displayLabel5.font = UIFont.systemFont(ofSize: 28)
        displayLabel5.textColor = UIColor.lightGray
        displayLabel6.font = UIFont.systemFont(ofSize: 32)
        displayLabel6.textColor = UIColor.darkGray
    }
    
    func floatToString(data:Double) -> String {
        let src = String(format:"%.9f", arguments:[data])
        for i in 0...src.count-1 {
            let c = src[src.index(src.startIndex, offsetBy: src.count-1-i)]
            if c != "0" {
                if c == "." {
                    return String(src.dropLast(i+1))
                } else {
                    return String(src.dropLast(i))
                }
            }
        }
        return src
    }
    
    func fillCalcDisplayLables() {
        let history = calculator.history()
        if history.count < 1 {
            return
        }
        var lastSeqNo = history.last!.seqNo
        var labelIdx = 3
        for i in 0...history.count-1 {
            let idx = history.count-1 - i
            if history[idx].seqNo == 0 {
                break
            }
            if history[idx].seqNo == lastSeqNo {
                continue
            }
            displayLabelArray[labelIdx].text = "\(history[idx].operation) \(floatToString(data:history[idx].data))"
            labelIdx -= 1
            if labelIdx < 0 {
                return
            }
            lastSeqNo = history[idx].seqNo
        }
        if labelIdx >= 0 {
            for i in 0...labelIdx {
                displayLabelArray[i].text = ""
            }
        }
    }
    
    func fillUndoDisplayLables(lastNodeSeqNo: Int) {
        var lastSeqNo = lastNodeSeqNo
        let history = calculator.history()
        if history.count < 1 {
            return
        }
        var labelIdx = 3
        for i in 0...history.count-1 {
            let idx = history.count-1 - i
            if history[idx].seqNo == 0 {
                break
            }
            if history[idx].seqNo == lastSeqNo {
                continue
            }
            displayLabelArray[labelIdx].text = "\(history[idx].operation) \(floatToString(data: history[idx].data))"
            labelIdx -= 1
            if labelIdx < 0 {
                return
            }
            lastSeqNo = history[idx].seqNo
        }
        if labelIdx >= 0 {
            for i in 0...labelIdx {
                displayLabelArray[i].text = ""
            }
        }
    }
    
    func clearAllDisplay() {
        for i in 0...displayLabelArray.count-1 {
            displayLabelArray[i].text = ""
        }
        displayLabelArray[displayLabelArray.count-1].text = "0"
        changeBoldDisplayFrom5To6()
        currentOperation = ""
    }
    
    @IBAction func digitalPressed(_ sender: UIButton) {
        let operation = sender.currentTitle!
        switch operation {
        case "÷", "×", "−", "+":
            calculator.incrSeqNo()
            currentOperation = operation
            calculator.append(node: calculator.newNode(operation: currentOperation, data: 0))
            displayLabel5.text = operation + " "
            isUserInTheMiddleOfTypeing = true
            fillCalcDisplayLables()
            changeBoldDisplayFrom6To5()
            break
        case "=":
            calculator.commit()
            fillCalcDisplayLables()
            changeBoldDisplayFrom5To6()
            break
        case "C":
            calculator.reset()
            currentOperation = "+"
            displayValue = 0
            currentResult = 0
            clearAllDisplay()
            break
        case "0"..."9":
            if isUserInTheMiddleOfTypeing {
                displayLabel5.text! += operation
            } else {
                if operation != "0" {
                    displayLabel5.text = operation
                    isUserInTheMiddleOfTypeing = true
                }
            }
            if currentOperation != "" {
                calculator.append(node: calculator.newNode(operation: currentOperation, data: displayValue))
                currentResult = calculator.eval(operation: currentOperation)
            } else {
                currentResult = displayValue
            }
            displayLabel6.text! = "= " + floatToString(data: currentResult)
            fillCalcDisplayLables()
            changeBoldDisplayFrom6To5()
            break
        case "␡":
            if let lastNode = calculator.rollback() {
                if lastNode.seqNo == 0 {
                    break
                }
                fillUndoDisplayLables(lastNodeSeqNo: lastNode.seqNo)
                if lastNode.data != 0 {
                    displayLabel5.text = "\(lastNode.operation) \(floatToString(data:lastNode.data))"
                } else {
                    displayLabel5.text = "\(lastNode.operation) "
                }
                displayLabel6.text = floatToString(data:lastNode.result)
            }
            break
        default:
            break
        }
    }
    
}
