//
//  ViewController.swift
//  Calculator
//
//  Created by Ece Akcay on 9.08.2025.
//

import UIKit

final class ViewController: UIViewController {

    // MARK: - Outlet
    @IBOutlet weak var displayLabel: UILabel!

    // MARK: - State
    private var firstOperand: Double?
    private var pendingOperation: String?
    private var isTyping: Bool = false   // kullanıcı ekrana yeni sayı mı yazıyor?

    // MARK: - Helpers (virgül/nokta dönüştürme)
    private func textToDouble(_ text: String?) -> Double {
        Double((text ?? "0").replacingOccurrences(of: ",", with: ".")) ?? 0
    }
    private func doubleToText(_ value: Double) -> String {
        String(value).replacingOccurrences(of: ".", with: ",")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        displayLabel.text = "0"
    }

    // MARK: - Numbers (0–9, "," ve ".")
    @IBAction func numberButtonTapped(_ sender: UIButton) {
        guard let digit = sender.currentTitle else { return }

        // Ondalık işareti
        if digit == "," || digit == "." {
            let text = displayLabel.text ?? "0"
            let hasDecimal = text.contains(",") || text.contains(".")
            if hasDecimal { return }                 // ikinci ondalığa izin verme
            displayLabel.text = (isTyping ? text : (text == "0" ? "0" : text)) + ","
            isTyping = true
            return
        }

        // Rakamlar
        if !isTyping || displayLabel.text == "0" || displayLabel.text == nil {
            displayLabel.text = digit
            isTyping = true
        } else {
            displayLabel.text = (displayLabel.text ?? "") + digit
        }
    }

    // MARK: - Operations (+, -, x, ÷)
    @IBAction func operationButtonTapped(_ sender: UIButton) {
        let current = textToDouble(displayLabel.text)

        // İlk operandı yükle / zincirleme hesapla
        if firstOperand == nil {
            firstOperand = current
        } else if let op = pendingOperation {
            let result = perform(op, firstOperand ?? 0, current)
            firstOperand = result
            displayLabel.text = doubleToText(result)
        }

        // Sembolü normalize et
        let raw = sender.currentTitle ?? ""
        switch raw {
        case "x", "×": pendingOperation = "*"      // çarpma
        case "÷":     pendingOperation = "/"       // bölme
        default:      pendingOperation = raw       // + veya -
        }

        isTyping = false
    }

    // MARK: - Equals (=)
    @IBAction func equalsButtonTapped(_ sender: UIButton) {
        guard let op = pendingOperation, let first = firstOperand else {
            isTyping = false
            return
        }
        let second = textToDouble(displayLabel.text)
        let result = perform(op, first, second)
        displayLabel.text = doubleToText(result)

        // reset
        firstOperand = nil
        pendingOperation = nil
        isTyping = false
    }

    // MARK: - Single-key ops (C, ±, %)
    @IBAction func clearButtonTapped(_ sender: UIButton) {
        displayLabel.text = "0"
        firstOperand = nil
        pendingOperation = nil
        isTyping = false
    }

    @IBAction func toggleSignTapped(_ sender: UIButton) {
        let v = -textToDouble(displayLabel.text)
        displayLabel.text = doubleToText(v)
    }

    @IBAction func percentTapped(_ sender: UIButton) {
        let v = textToDouble(displayLabel.text) / 100.0
        displayLabel.text = doubleToText(v)
        isTyping = true // yüzde sonrası yazmaya devam edebil
    }

    // MARK: - Core math
    private func perform(_ symbol: String, _ a: Double, _ b: Double) -> Double {
        switch symbol {
        case "+":           return a + b
        case "-", "−":      return a - b
        case "*", "x", "×": return a * b
        case "/", "÷":      return b == 0 ? 0 : a / b
        default:            return b
        }
    }
}
