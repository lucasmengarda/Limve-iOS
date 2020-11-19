//
//  DocumentoFiscal.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 10/03/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import Foundation
import UIKit
import Parse
import TransitionButton
import PopupDialog
import NVActivityIndicatorView
import DynamicBlurView

protocol DocumentoFiscalDelegate {
    func onExitDocumentoFiscal(sucesseful: Bool, cpfCnpj: String?, nome: String?, isFinalizacao: Bool)
}

class DocumentoFiscal: UIViewController {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var botaoSelecionar: TransitionButton!
    @IBOutlet weak var botaoFechar: TransitionButton!
    @IBOutlet weak var cpfCnpj: UITextField!
    @IBOutlet weak var nome: UITextField!
    
    var delegate: DocumentoFiscalDelegate!
    var cpfCnpjStr: String!
    var nomeStr: String!
    var frameInicialViewHolder: CGRect!
    var isFinalizacao = false
    
    static func inicializeDocumentoFiscal(cpfCnpj: String, nome: String, delegate: DocumentoFiscalDelegate) -> DocumentoFiscal{
        let tela = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "DocumentoFiscal") as! DocumentoFiscal
        tela.delegate = delegate
        tela.cpfCnpjStr = cpfCnpj
        tela.nomeStr = nome
        return tela
    }
    
    @IBAction func fechar(){
        self.dismiss(animated: true, completion: nil)
        self.delegate.onExitDocumentoFiscal(sucesseful: false, cpfCnpj: nil, nome: nil, isFinalizacao: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        holder.layer.cornerRadius = 16.0
        holder.clipsToBounds = true
        self.view.backgroundColor = UIColor.clear
        holder.layer.shadowColor = hexStringToUIColor("#00224B").cgColor
        holder.layer.shadowOpacity = 6
        holder.layer.shadowOffset = .zero
        holder.layer.shadowRadius = 10
        frameInicialViewHolder = holder.frame
        
        botaoSelecionar.spinnerColor = UIColor.white
        botaoSelecionar.cornerRadius = botaoSelecionar.frame.height/2
        botaoSelecionar.backgroundColor = hexStringToUIColor("#4BC562")
        botaoFechar.spinnerColor = UIColor.white
        botaoFechar.cornerRadius = botaoFechar.frame.height/2
        botaoFechar.backgroundColor = hexStringToUIColor("#EF343A")
        
        if (isFinalizacao){
            botaoSelecionar.setTitle("Finalizar compra", for: [])
        }
        
        cpfCnpj.text = cpfCnpjStr
        nome.text = nomeStr
        
        atribuirPlaceholder(textField: cpfCnpj, name: "Digite seu CPF ou CNPJ")
        atribuirPlaceholder(textField: nome, name: "Digite seu nome")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func atribuirPlaceholder(textField: UITextField, name: String){
        var placeHolder = NSMutableAttributedString()
        placeHolder = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont(name: "CeraRoundPro-Regular", size: 18.0)!])
        placeHolder.addAttribute(NSAttributedString.Key.foregroundColor, value: hexStringToUIColor("#939393"), range: NSRange(location:0, length: name.count))
        textField.attributedPlaceholder = placeHolder
    }
    
    @IBAction func prosseguir(){
        
        if (cpfCnpj.text!.count < 14 || !validaCPF()){
            if (cpfCnpj.text!.isValidCNPJ){
                
            } else {
                let popup = PopupDialog(title: "Ops!", message: "CPF/CNPJ inválido. Confira se você digitou-o corretamente!")
                popup.buttonAlignment = .horizontal
                popup.transitionStyle = .bounceUp
                let button = CancelButton(title: "Ok", action: {
                })
                popup.addButton(button)
                // Present dialog
                self.present(popup, animated: true, completion: nil)
                return
            }
        }
        
        if (nome.text!.count < 2){
            let popup = PopupDialog(title: "Ops!", message: "Confira se você digitou seu nome corretamente!")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        
        PFUser.current()!["cpf"] = cpfCnpj.text!
        PFUser.current()!["nome"] = nome.text!
        PFUser.current()!.saveInBackground()
        
        self.dismiss(animated: true, completion: nil)
        self.delegate.onExitDocumentoFiscal(sucesseful: true, cpfCnpj: cpfCnpj.text!, nome: nome.text!, isFinalizacao: isFinalizacao)
    }
    
    @IBAction func returnClicked(sender: UITextField){
        if ((sender.text?.count)! > 0){
            self.view.endEditing(true)
        }
    }
    
    @IBAction func cpfChanged(){
        
        let valor1 = cpfCnpj.text!
        let valor2 = valor1.replacingOccurrences(of: " ", with: "")
        let valor3 = valor2.replacingOccurrences(of: ".", with: "")
        let valor4 = valor3.replacingOccurrences(of: "-", with: "")
        let valor5 = valor4.replacingOccurrences(of: "/", with: "")
        var valor5Copy = valor5
        
        if (valor5.count == 0){
            cpfCnpj.text = ""
            return
        }
        
        var montandoCPF = ""
        
        if (valor5.count < 12){
            for x in 0 ... 10 {
                if (valor5.count > x){
                    let valorIndividual = valor5Copy[valor5Copy.startIndex]
                    valor5Copy = String(valor5Copy[valor5Copy.index(after: valor5Copy.startIndex)..<valor5Copy.endIndex])
                    montandoCPF.append(valorIndividual)
                } else {
                    //if (x != 0){
                      //  montandoCPF.append(" ")
                    //}
                }
                
                if (valor5.count > 3){
                    if (x == 2){
                        montandoCPF.append(".")
                    }
                }
                
                if (valor5.count > 6){
                    if (x == 5){
                        montandoCPF.append(".")
                    }
                }
                
                if (valor5.count > 9){
                    if (x == 8){
                        montandoCPF.append("-")
                    }
                }
                
            }
        } else {
            for x in 0 ... 14 {
                if (valor5.count > x){
                    let valorIndividual = valor5Copy[valor5Copy.startIndex]
                    valor5Copy = String(valor5Copy[valor5Copy.index(after: valor5Copy.startIndex)..<valor5Copy.endIndex])
                    montandoCPF.append(valorIndividual)
                } else {
                    //if (x != 0){
                      //  montandoCPF.append(" ")
                    //}
                }
                
                if (valor5.count > 2){
                    if (x == 1){
                        montandoCPF.append(".")
                    }
                }
                
                if (valor5.count > 5){
                    if (x == 4){
                        montandoCPF.append(".")
                    }
                }
                
                if (valor5.count > 8){
                    if (x == 7){
                        montandoCPF.append("/")
                    }
                }
                
                if (valor5.count > 13){
                    if (x == 11){
                        montandoCPF.append("-")
                    }
                }
            }
        }
        
        cpfCnpj.text = montandoCPF
        
        let newPosition = cpfCnpj.position(from: cpfCnpj.beginningOfDocument, offset: montandoCPF.count)
        cpfCnpj.selectedTextRange = cpfCnpj.textRange(from: newPosition!, to: newPosition!)
        
        if (valor5.count == 14){
            returnClicked(sender: cpfCnpj)
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.count == 0 && range.length > 0 {
            
            let newLength = (textField.text ?? "").count + string.count - range.length
            return newLength <= 14
        }
        
        return true
    }
    
    func validaCPF() -> Bool{
        
        let valor1 = cpfCnpj.text!
        let valor2 = valor1.replacingOccurrences(of: " ", with: "")
        let valor3 = valor2.replacingOccurrences(of: ".", with: "")
        let strCPF = valor3.replacingOccurrences(of: "-", with: "")
        
        var Soma = 0
        var Resto = Int()
        
        if (strCPF == "00000000000") {
            return false
        }
        
        for x in 0 ... 8 {
            let range = strCPF.index(strCPF.startIndex, offsetBy: x)..<strCPF.index(strCPF.startIndex, offsetBy: x+1)
            let numero = String(strCPF[range])
            Soma += (NSString(string: numero).integerValue * (10-x))
        }
        
        Resto = ((Soma * 10) % 11)
        print("primeiroResto: \(Resto)")
        
        
        if (Resto == 10){
            Resto = 0
        }
        
        if (Resto == 11){
            Resto = 0
        }
        
        let indexFinais = strCPF.index(strCPF.endIndex, offsetBy: -2)..<strCPF.index(strCPF.endIndex, offsetBy: -1)
        let primeiroDigito = String(strCPF[indexFinais])
        print("primeiroDigito: \(primeiroDigito)")
        if (Resto != NSString(string: primeiroDigito).integerValue){
            return false
        }
        
        Soma = 0
        Resto = Int()
        
        for x in 0 ... 9 {
            let range = strCPF.index(strCPF.startIndex, offsetBy: x)..<strCPF.index(strCPF.startIndex, offsetBy: x+1)
            let numero = String(strCPF[range])
            Soma += (NSString(string: numero).integerValue * (11-x))
        }
        
        Resto = ((Soma * 10) % 11)
        
        
        if (Resto == 10){
            Resto = 0
        }
        
        if (Resto == 11){
            Resto = 0
        }
        
        let indexFinais2 = strCPF.index(strCPF.endIndex, offsetBy: -1)..<strCPF.endIndex
        
        if (Resto != NSString(string: String(strCPF[indexFinais2])).integerValue){
            return false
        }
        
        return true;
    }
    
    //KEYBOARD OBSERVERS
    @objc func keyboardWillHide(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let _ = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                UIView.animate(withDuration: 0.25, animations: {
                    self.holder.frame = self.frameInicialViewHolder!
                })
            }
        }
    }
    @objc func keyboardWillShow(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let keyboardHeight2 = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                //This is keyboard Height
                UIView.animate(withDuration: 0.25, animations: {
                    self.holder.frame = CGRect(x: (self.frameInicialViewHolder?.origin.x)!, y: (self.frameInicialViewHolder?.origin.y)! - (keyboardHeight2/3), width: (self.frameInicialViewHolder?.width)!, height: (self.frameInicialViewHolder?.height)!)
                })
            }
        }
    }
    //
}

extension StringProtocol {
    var isValidCNPJ: Bool {
        let numbers = compactMap({ $0.wholeNumberValue })
        guard numbers.count == 14 && Set(numbers).count != 1 else { return false }
        func digitCalculator(_ slice: ArraySlice<Int>) -> Int {
            var number = 1
            let digit = 11 - slice.reversed().reduce(into: 0) {
                number += 1
                $0 += $1 * number
                if number == 9 { number = 1 }
            } % 11
            return digit % 10
        }
        let dv1 = digitCalculator(numbers.prefix(12))
        let dv2 = digitCalculator(numbers.prefix(13))
        return dv1 == numbers[12] && dv2 == numbers[13]
    }
}
