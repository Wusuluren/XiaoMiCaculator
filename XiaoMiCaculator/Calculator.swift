//
//  Calculator.swift
//  XiaoMiCaculator
//
//  Created by 123 on 2019/5/3.
//  Copyright © 2019年 wave. All rights reserved.
//

import Foundation

class Calculator {
    
    private enum OpType {
        case UnaryOperator((Double)->Double)
        case BinaryOperator((Double,Double)->Double)
    }
    
    struct Node {
        var operation: String
        var data: Double
        var result: Double
        var batchNo: Int
        var seqNo: Int
    }
    
    private var commitedCount = 0
    private var historyStack = [Node]()
    private var knownOps = [String:OpType]()
    private var curBatchNo = 0
    private var curSeqNo = 0
    private var lastBatchIdx = -1
    private var lastSeqIdx = -1
    
    init() {
        knownOps["×"] = OpType.BinaryOperator(*)
        knownOps["÷"] = OpType.BinaryOperator({
            if $1 != 0 {
                return $0 / $1
            } else {
                return 0
            }
        })
        knownOps["−"] = OpType.BinaryOperator(-)
        knownOps["+"] = OpType.BinaryOperator(+)
        knownOps[""] = OpType.UnaryOperator({ $0 })
        
        reset()
    }
    
    func append(node: Node) {
        historyStack.append(node)
        debug()
    }
    
    func commit() {
        commitedCount = historyStack.count
    }
    
    func rollback() -> Node? {
        if historyStack.count > commitedCount {
            return historyStack.removeLast()
        }
        return nil
    }
    
    func reset() {
        historyStack.removeAll()
        commitedCount = 0
        curSeqNo = 0
        curBatchNo = 0
        lastSeqIdx = -1
        lastBatchIdx = -1
        append(node: newNode(operation: "", data: 0))
        incrSeqNo()
    }
    
    func newNode(operation: String, data: Double) -> Node {
        var result = 0.0
        if lastSeqIdx != -1 {
            result = historyStack[lastSeqIdx].result
        }
        return Node(operation: operation, data: data, result: result, batchNo: curBatchNo, seqNo: curSeqNo)
    }
    
//    func incrBatchNo() {
//        curBatchNo += 1
//        lastBatchIdx = historyStack.count-1
//    }
    
    func incrSeqNo() {
        curSeqNo += 1
        lastSeqIdx = historyStack.count-1
    }
    
    func history() -> [Node] {
        return [Node](historyStack[0..<historyStack.endIndex])
    }
    
    func eval(operation: String) -> Double {
        if let op = knownOps[operation] {
            switch op {
            case .BinaryOperator(let `operator`):
                if historyStack.count == 0 {
                    return 0
                }
                if historyStack.count == 1 || lastSeqIdx == -1 {
                    let result = historyStack.last!.data
                    historyStack[historyStack.count-1].result = result
                    return result
                }
                let operand1 = historyStack.last
                let operand2 = historyStack[lastSeqIdx]
                let result = `operator`(operand2.result, operand1!.data)
                historyStack[historyStack.count-1].result = result
                print(result, historyStack[historyStack.count-1])
                return result
            case .UnaryOperator(let `operator`):
//                if historyStack.count >= 1 {
//                    let operand1Idx = historyStack.index(historyStack.count-1, offsetBy: 0)
//                    let operand1 = historyStack[operand1Idx]
//                    return `operator`(operand1.data)
//                }
                return 0
            }
        }
        return 0
    }
    
    func debug() {
        print("@@@ ", historyStack)
    }
}
