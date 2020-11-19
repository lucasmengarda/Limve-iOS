//
//  RecuperacaoSenha.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 03/11/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import Foundation
import Parse
import UIKit
import TransitionButton
import PopupDialog

protocol RecuperacaoSenhaDelegate {
    func onExit(sussecefull: Bool)
}

class RecuperacaoSenhaController: UIViewController {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var botaoCadastrar: TransitionButton!
    @IBOutlet weak var botaoFechar: TransitionButton!
    @IBOutlet weak var holderCodigo: UIView!
    @IBOutlet weak var holderSenha: UIView!
    @IBOutlet weak var holderRepeteSenha: UIView!
    @IBOutlet weak var codigo: UITextField!
    @IBOutlet weak var senha: UITextField!
    @IBOutlet weak var repeteSenha: UITextField!
    
    var frameInicialViewHolder: CGRect!
    var delegate: RecuperacaoSenhaDelegate!
    var usuario: String!
    
    static func inicializeRecuperacaoSenhaController(usuario: String, delegate: RecuperacaoSenhaDelegate) -> RecuperacaoSenhaController{
        let tela = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "RecuperacaoSenhaController") as! RecuperacaoSenhaController
        tela.delegate = delegate
        tela.usuario = usuario
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
        
        holderCodigo.layer.cornerRadius = 8.0
        holderSenha.layer.cornerRadius = 8.0
        holderRepeteSenha.layer.cornerRadius = 8.0
    
        atribuirPlaceholder(textField: codigo, name: "Digite o código recebido")
        atribuirPlaceholder(textField: senha, name: "Digite uma nova senha")
        atribuirPlaceholder(textField: repeteSenha, name: "Confirme sua senha")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        senha.disableAutoFill()
        repeteSenha.disableAutoFill()
        
    }
    
    @IBAction func fecharKeyboard(){
        self.view.endEditing(true)
    }
    
    func atribuirPlaceholder(textField: UITextField, name: String){
        var placeHolder = NSMutableAttributedString()
        placeHolder = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont(name: "CeraRoundPro-Regular", size: 16.0)!])
        placeHolder.addAttribute(NSAttributedString.Key.foregroundColor, value: hexStringToUIColor("#939393"), range: NSRange(location:0, length: name.count))
        textField.attributedPlaceholder = placeHolder
    }
    
    @IBAction func cadastrar(){
        
        if (codigo.text!.count < 6){
            let popup = PopupDialog(title: "Ops!", message: "Confira se você digitou o código corretamente!")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        
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
        
        botaoCadastrar.startAnimation()
        
        let params = ["codigo": codigo.text!, "newPassword": senha.text!, "username": usuario]
        PFCloud.callFunction(inBackground: "alterarSenha-recuperacao", withParameters: params) { (certo, erro) in
            
            if (erro != nil){
                
                self.botaoCadastrar.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.25, completion: {
                    let popup = PopupDialog(title: "Algum erro aconteceu!", message: erro?.localizedDescription)
                    popup.buttonAlignment = .horizontal
                    popup.transitionStyle = .bounceUp
                    let button = CancelButton(title: "Ok", action: {
                    })
                    popup.addButton(button)
                    // Present dialog
                    self.present(popup, animated: true, completion: nil)
                })
                
                return
            }
            
            self.botaoCadastrar.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.25) {
                self.dismiss(animated: true, completion: nil)
                self.delegate.onExit(sussecefull: true)
            }
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
