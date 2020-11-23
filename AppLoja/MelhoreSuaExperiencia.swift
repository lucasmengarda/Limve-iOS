//
//  MelhoreSuaExperiencia.swift
//  AppLoja
//
//  Created by Gabi Rutkoski on 20/11/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import Foundation
import UIKit
import Parse
import TransitionButton
import PopupDialog

protocol MelhoreSuaExperienciaDelegate{
    func onExitMelhoreSuaExperiencia(telefone: String, email: String)
}

class MelhoreSuaExperiencia: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var botaoOk: TransitionButton!
    @IBOutlet weak var botaoSem: TransitionButton!
    
    @IBOutlet weak var holderTelefone: UIView!
    @IBOutlet weak var holderEmail: UIView!
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var telefone: UITextField!
    
    
    var frameInicialViewHolder: CGRect!
    var delegate: MelhoreSuaExperienciaDelegate!
    
    static func inicializeMelhoreSuaExperiencia(delegate: MelhoreSuaExperienciaDelegate) -> MelhoreSuaExperiencia{
        let tela = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "MelhoreSuaExperiencia") as! MelhoreSuaExperiencia
        tela.delegate = delegate
        return tela
    }
    
    @IBAction func irSemDados(){
        
        self.dismiss(animated: true, completion: nil)
        self.delegate.onExitMelhoreSuaExperiencia(telefone: "", email: "")
        
    }
    
    @IBAction func irComDados(){
        
        if (telefone.text!.count < 10){
            let popup = PopupDialog(title: "Ops!", message: "Confira se você digitou seu celular corretamente!")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        if (email.text!.count < 3 || !email.text!.contains("@")){
            let popup = PopupDialog(title: "Ops!", message: "E-mail inválido. Confira se você digitou-o corretamente!")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        
        self.dismiss(animated: true, completion: nil)
        self.delegate.onExitMelhoreSuaExperiencia(telefone: telefone.text!, email: email.text!)
        
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
        telefone.delegate = self
        
        botaoOk.spinnerColor = UIColor.white
        botaoOk.cornerRadius = botaoOk.frame.height/2
        botaoOk.backgroundColor = hexStringToUIColor("#4BC562")
        botaoSem.spinnerColor = UIColor.white
        botaoSem.cornerRadius = botaoSem.frame.height/2
        botaoSem.backgroundColor = hexStringToUIColor("#f9813a")
        
        holderEmail.layer.cornerRadius = 8.0
        holderTelefone.layer.cornerRadius = 8.0
    
        atribuirPlaceholder(textField: telefone, name: "Telefone de quem irá receber")
        atribuirPlaceholder(textField: email, name: "E-mail")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func atribuirPlaceholder(textField: UITextField, name: String){
        var placeHolder = NSMutableAttributedString()
        placeHolder = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont(name: "CeraRoundPro-Regular", size: 18.0)!])
        placeHolder.addAttribute(NSAttributedString.Key.foregroundColor, value: hexStringToUIColor("#939393"), range: NSRange(location:0, length: name.count))
        textField.attributedPlaceholder = placeHolder
    }
    
    @IBAction func returnClicked(sender: UITextField){
        if ((sender.text?.count)! > 0){
            let tag = sender.tag
            if (tag == 1){
                self.view.endEditing(true)
            } else {
                //sender.resignFirstResponder()
                self.view.viewWithTag((tag+1))?.becomeFirstResponder()
            }
        }
    }
    
    @IBAction func fecharKeyboard(){
        self.view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.count == 0 && range.length > 0 {
            
            let valor1 = telefone.text!
            let valor2 = valor1.replacingOccurrences(of: " ", with: "")
            let valor3 = valor2.replacingOccurrences(of: "(", with: "")
            let valor4 = valor3.replacingOccurrences(of: ")", with: "")
            let valor5 = valor4.replacingOccurrences(of: "-", with: "")
            
            let valor6 = String(valor5[valor5.startIndex..<valor5.index(before: valor5.endIndex)])
            
            var valor6Copy = valor6
            
            if (valor6.count == 0){
                textField.text = ""
                return false
            }
            
            var montandoTEL = ""
            
            for x in 0 ... 10 {
                
                if (x == 0){
                    montandoTEL.append("(")
                }
                
                if (valor6.count > x){
                    let valorIndividual = valor6Copy[valor6Copy.startIndex]
                    valor6Copy = String(valor6Copy[valor6Copy.index(after: valor6Copy.startIndex)..<valor6Copy.endIndex])
                    montandoTEL.append(valorIndividual)
                } else {
                    if (x != 0){
                        montandoTEL.append(" ")
                    }
                }
                
                if (x == 1){
                    montandoTEL.append(")")
                }
                
                if (valor5.count == 10){
                    if (x == 5){
                        montandoTEL.append("-")
                    }
                } else {
                    if (x == 6){
                        montandoTEL.append("-")
                    }
                }
            }
            
            telefone.text = montandoTEL
            
            let split = montandoTEL.split(separator: " ")
            let newPosition = telefone.position(from: telefone.beginningOfDocument, offset: split[0].count)
            telefone.selectedTextRange = telefone.textRange(from: newPosition!, to: newPosition!)
            
            return false
            
        }
        
        return true
    }
    
    @IBAction func telefoneDidChanged(){
        let valor1 = telefone.text!
        let valor2 = valor1.replacingOccurrences(of: " ", with: "")
        let valor3 = valor2.replacingOccurrences(of: "(", with: "")
        let valor4 = valor3.replacingOccurrences(of: ")", with: "")
        let valor5 = valor4.replacingOccurrences(of: "-", with: "")
        var valor5Copy = valor5
        
        if (valor5.count == 0){
            telefone.text = ""
            return
        }
        
        var montandoTEL = ""
        
        for x in 0 ... 10 {
            
            if (x == 0){
                montandoTEL.append("(")
            }
            
            if (valor5.count > x){
                let valorIndividual = valor5Copy[valor5Copy.startIndex]
                valor5Copy = String(valor5Copy[valor5Copy.index(after: valor5Copy.startIndex)..<valor5Copy.endIndex])
                montandoTEL.append(valorIndividual)
            } else {
                if (x != 0){
                    montandoTEL.append(" ")
                }
            }
            
            if (x == 1){
                montandoTEL.append(")")
            }
            
            if (valor5.count == 10){
                if (x == 5){
                    montandoTEL.append("-")
                }
            } else {
                if (x == 6){
                    montandoTEL.append("-")
                }
            }
        }
        
        telefone.text = montandoTEL
        
        let split = montandoTEL.split(separator: " ")
        let newPosition = telefone.position(from: telefone.beginningOfDocument, offset: split[0].count)
        telefone.selectedTextRange = telefone.textRange(from: newPosition!, to: newPosition!)
        
        if (valor5.count == 11){
            returnClicked(sender: telefone)
        }
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
