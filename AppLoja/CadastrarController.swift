//
//  CadastrarController.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 01/03/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import Foundation
import Parse
import UIKit
import TransitionButton
import PopupDialog

protocol LoginCadastrarDelegate {
    func onExit(sussecefull: Bool)
}

class CadastrarController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var botaoCadastrar: TransitionButton!
    @IBOutlet weak var botaoFechar: TransitionButton!
    @IBOutlet weak var holderCPF: UIView!
    @IBOutlet weak var holderNome: UIView!
    @IBOutlet weak var holderEmail: UIView!
    @IBOutlet weak var holderTelefone: UIView!
    @IBOutlet weak var holderSenha: UIView!
    @IBOutlet weak var holderRepeteSenha: UIView!
    @IBOutlet weak var cpf: UITextField!
    @IBOutlet weak var nome: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var telefone: UITextField!
    @IBOutlet weak var senha: UITextField!
    @IBOutlet weak var repeteSenha: UITextField!
    @IBOutlet weak var aceitaEMAIL: UISwitch!
    @IBOutlet weak var aceitaSMS: UISwitch!
    
    var frameInicialViewHolder: CGRect!
    var delegate: LoginCadastrarDelegate!
    
    static func inicializeCadastrarController(delegate: LoginCadastrarDelegate) -> CadastrarController{
        let tela = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "CadastrarController") as! CadastrarController
        tela.delegate = delegate
        return tela
    }
    
    var identificador: String!
    var emailStr: String?
    var nomeStr: String?
    
    static func inicializeCadastrarControllerAsLoginApple(identificador: String, email: String?, nome: String?, delegate: LoginCadastrarDelegate) -> CadastrarController{
        let tela = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "CadastrarController") as! CadastrarController
        tela.delegate = delegate
        tela.identificador = identificador
        tela.emailStr = email
        tela.nomeStr = nome
        return tela
    }
    
    @IBAction func fechar(){
        self.dismiss(animated: true, completion: nil)
        self.delegate.onExit(sussecefull: false)
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
        
        botaoCadastrar.spinnerColor = UIColor.white
        botaoCadastrar.cornerRadius = botaoCadastrar.frame.height/2
        botaoCadastrar.backgroundColor = hexStringToUIColor("#4BC562")
        botaoFechar.spinnerColor = UIColor.white
        botaoFechar.cornerRadius = botaoFechar.frame.height/2
        botaoFechar.backgroundColor = hexStringToUIColor("#EF343A")
        
        cpf.delegate = self
        telefone.delegate = self
        
        holderCPF.layer.cornerRadius = 8.0
        holderNome.layer.cornerRadius = 8.0
        holderEmail.layer.cornerRadius = 8.0
        holderTelefone.layer.cornerRadius = 8.0
        holderSenha.layer.cornerRadius = 8.0
        holderRepeteSenha.layer.cornerRadius = 8.0
    
        atribuirPlaceholder(textField: cpf, name: "Digite seu CPF")
        atribuirPlaceholder(textField: nome, name: "Digite seu nome")
        atribuirPlaceholder(textField: email, name: "Digite seu e-mail")
        atribuirPlaceholder(textField: telefone, name: "Digite seu celular")
        atribuirPlaceholder(textField: senha, name: "Digite sua senha")
        atribuirPlaceholder(textField: repeteSenha, name: "Confirme sua senha")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        senha.disableAutoFill()
        repeteSenha.disableAutoFill()
        
        if (identificador != nil){
            //administrando login apple
            atribuirPlaceholder(textField: senha, name: "Administrado pela Apple")
            atribuirPlaceholder(textField: repeteSenha, name: "Administrado pela Apple")
            senha.isEnabled = false
            repeteSenha.isEnabled = false
            
            holderSenha.alpha = 0.5
            holderRepeteSenha.alpha = 0.5
            
            if (emailStr != nil){
                atribuirPlaceholder(textField: email, name: "Administrado pela Apple")
                email.isEnabled = false
                holderEmail.alpha = 0.5
            }
            
            nome.text = nomeStr
        }
        
    }
    
    @IBAction func fecharKeyboard(){
        self.view.endEditing(true)
    }
    
    func atribuirPlaceholder(textField: UITextField, name: String){
        var placeHolder = NSMutableAttributedString()
        placeHolder = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont(name: "CeraRoundPro-Regular", size: 18.0)!])
        placeHolder.addAttribute(NSAttributedString.Key.foregroundColor, value: hexStringToUIColor("#939393"), range: NSRange(location:0, length: name.count))
        textField.attributedPlaceholder = placeHolder
    }
    
    @IBAction func cadastrar(){
        
        if (nome.text!.count == 0){
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
        
        if (cpf.text!.count == 0){
            let popup = PopupDialog(title: "Ops!", message: "Confira se você digitou seu CPF!")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
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
        if (cpf.text!.count < 14 || !validaCPF()){
            let popup = PopupDialog(title: "Ops!", message: "CPF inválido. Confira se você digitou-o corretamente!")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        if (emailStr == nil){
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
        }
        if (identificador == nil){
            if (senha.text!.count < 8){
                let popup = PopupDialog(title: "Ops!", message: "A sua senha deve conter pelo menos 8 caracteres")
                popup.buttonAlignment = .horizontal
                popup.transitionStyle = .bounceUp
                let button = CancelButton(title: "Ok", action: {
                })
                popup.addButton(button)
                // Present dialog
                self.present(popup, animated: true, completion: nil)
                return
            }
            if (senha.text! != repeteSenha.text!){
                let popup = PopupDialog(title: "Ops!", message: "As senhas não coincidem! Confira se você repetiu a sua senha corretamente")
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
        
        botaoCadastrar.startAnimation()
        
        PFUser.current()!["nome"] = nome.text!
        PFUser.current()!.username = cpf.text!
        PFUser.current()!["cpf"] = cpf.text!
        PFUser.current()!["telefone"] = telefone.text!
        PFUser.current()!["aceitarReceberSMS"] = aceitaSMS.isOn
        PFUser.current()!["aceitarReceberEmail"] = aceitaEMAIL.isOn
        if (identificador != nil){
            PFUser.current()!["identificadorUnico"] = identificador
            PFUser.current()!.password = "%aosidjf#"
            if (emailStr != nil){
                PFUser.current()!.email = emailStr
            } else {
                PFUser.current()!.email = email.text!
            }
        } else {
            PFUser.current()!.password = senha.text!
            PFUser.current()!.email = email.text!
        }
        
        PFUser.current()!.saveInBackground { (certo, erro) in
            
            if (erro != nil){
                if (erro?.localizedDescription == "Account already exists for this username.") {
                    self.botaoCadastrar.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.25, completion: {
                        let popup = PopupDialog(title: "Ops!", message: "CPF já cadastrado")
                        popup.buttonAlignment = .horizontal
                        popup.transitionStyle = .bounceUp
                        let button = CancelButton(title: "Ok", action: {
                        })
                        popup.addButton(button)
                        // Present dialog
                        self.present(popup, animated: true, completion: nil)
                    })
                } else if (erro?.localizedDescription == "Email has already been used.") {
                    self.botaoCadastrar.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.25, completion: {
                        let popup = PopupDialog(title: "Ops!", message: "E-mail já cadastrado")
                        popup.buttonAlignment = .horizontal
                        popup.transitionStyle = .bounceUp
                        let button = CancelButton(title: "Ok", action: {
                        })
                        popup.addButton(button)
                        // Present dialog
                        self.present(popup, animated: true, completion: nil)
                    })
                } else {
                    self.botaoCadastrar.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.25, completion: {
                        let popup = PopupDialog(title: "Ops!", message: "Algum erro aconteceu! Por favor, tente novamente")
                        popup.buttonAlignment = .horizontal
                        popup.transitionStyle = .bounceUp
                        let button = CancelButton(title: "Ok", action: {
                        })
                        popup.addButton(button)
                        // Present dialog
                        self.present(popup, animated: true, completion: nil)
                    })
                }
                return
            }
            
            self.botaoCadastrar.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.25) {
                self.dismiss(animated: true, completion: nil)
                self.delegate.onExit(sussecefull: true)
            }
        }
    }
    
    @IBAction func returnClicked(sender: UITextField){
        if ((sender.text?.count)! > 0){
            let tag = sender.tag
            if (tag == 5){
                self.view.endEditing(true)
                cadastrar()
            } else {
                //sender.resignFirstResponder()
                self.view.viewWithTag((tag+1))?.becomeFirstResponder()
            }
        }
    }
    
    @IBAction func cpfChanged(){
        
        let valor1 = cpf.text!
        let valor2 = valor1.replacingOccurrences(of: " ", with: "")
        let valor3 = valor2.replacingOccurrences(of: ".", with: "")
        let valor4 = valor3.replacingOccurrences(of: "-", with: "")
        var valor4Copy = valor4
        
        if (valor4.count == 0){
            cpf.text = ""
            return
        }
        
        var montandoCPF = ""
        
        for x in 0 ... 10 {
            if (valor4.count > x){
                let valorIndividual = valor4Copy[valor4Copy.startIndex]
                valor4Copy = String(valor4Copy[valor4Copy.index(after: valor4Copy.startIndex)..<valor4Copy.endIndex])
                montandoCPF.append(valorIndividual)
            } else {
                if (x != 0){
                    montandoCPF.append(" ")
                }
            }
            
            if (x == 2){
                montandoCPF.append(".")
            }
            
            if (x == 5){
                montandoCPF.append(".")
            }
            
            if (x == 8){
                montandoCPF.append("-")
            }
        }
        
        cpf.text = montandoCPF
        
        let split = montandoCPF.split(separator: " ")
        let newPosition = cpf.position(from: cpf.beginningOfDocument, offset: split[0].count)
        cpf.selectedTextRange = cpf.textRange(from: newPosition!, to: newPosition!)
        
        if (valor4.count == 11){
            returnClicked(sender: cpf)
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.count == 0 && range.length > 0 {
            
            if (textField.tag == 0){
                
                // Back pressed
                
                let valor1 = cpf.text!
                let valor2 = valor1.replacingOccurrences(of: " ", with: "")
                let valor3 = valor2.replacingOccurrences(of: ".", with: "")
                let valor4 = valor3.replacingOccurrences(of: "-", with: "")
                
                let valor5 = String(valor4[valor4.startIndex..<valor4.index(before: valor4.endIndex)])
                
                var valor5Copy = valor5
                
                if (valor5.count == 0){
                    cpf.text = ""
                    return false
                }
                
                var montandoCPF = ""
                
                for x in 0 ... 10 {
                    if (valor5.count > x){
                        let valorIndividual = valor5Copy[valor5Copy.startIndex]
                        valor5Copy = String(valor5Copy[valor5Copy.index(after: valor5Copy.startIndex)..<valor5Copy.endIndex])
                        montandoCPF.append(valorIndividual)
                    } else {
                        if (x != 0){
                            montandoCPF.append(" ")
                        }
                    }
                    
                    if (x == 2){
                        montandoCPF.append(".")
                    }
                    
                    if (x == 5){
                        montandoCPF.append(".")
                    }
                    
                    if (x == 8){
                        montandoCPF.append("-")
                    }
                }
                
                cpf.text = montandoCPF
                
                let split = montandoCPF.split(separator: " ")
                let newPosition = cpf.position(from: cpf.beginningOfDocument, offset: split[0].count)
                cpf.selectedTextRange = cpf.textRange(from: newPosition!, to: newPosition!)
                
                return false
                
            } else {
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
    
    func validaCPF() -> Bool{
        
        let valor1 = cpf.text!
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
                    self.holder.frame = CGRect(x: (self.frameInicialViewHolder?.origin.x)!, y: (self.frameInicialViewHolder?.origin.y)! - 35.0, width: (self.frameInicialViewHolder?.width)!, height: (self.frameInicialViewHolder?.height)!)
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
