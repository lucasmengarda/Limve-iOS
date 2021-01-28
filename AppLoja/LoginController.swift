//
//  LoginController.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 28/02/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import Foundation
import Parse
import UIKit
import TransitionButton
import PopupDialog
import DynamicBlurView
import GhostTypewriter
import AuthenticationServices


class LoginController: UIViewController, UITextFieldDelegate, RecuperacaoSenhaDelegate, LoginCadastrarDelegate, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    @IBOutlet weak var limveLabel: UILabel!
    @IBOutlet weak var botaoApple: TransitionButton!
    @IBOutlet weak var blurCPF: UIVisualEffectView!
    @IBOutlet weak var blurSenha: UIVisualEffectView!
    @IBOutlet weak var holderCPF: UIView!
    @IBOutlet weak var loaderTexto: TypewriterLabel!
    @IBOutlet weak var holderSenha: UIView!
    @IBOutlet weak var blurExplorarApp: UIVisualEffectView!
    @IBOutlet weak var cpf: UITextField!
    @IBOutlet weak var senha: UITextField!
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var botaoEntrar: TransitionButton!
    
    var frameInicialViewHolder: CGRect!
    var delegate: LoginCadastrarDelegate!
    
    
    static func inicializeLoginController(delegate: LoginCadastrarDelegate) -> LoginController{
        let tela = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "LoginController") as! LoginController
        tela.delegate = delegate
        return tela
    }
    
    @IBAction func fechar(){
        if (!keyboardHidden){
            self.view.endEditing(true)
            return
        }
        self.dismiss(animated: true, completion: nil)
        self.delegate.onExit(sussecefull: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let texto = "Limve.com"
        let attributedTexto = NSMutableAttributedString(string: texto)
        attributedTexto.addAttribute(.font, value: UIFont(name: "Ubuntu-Bold", size: 32.0)!, range: NSRange(location: 0, length: 5))
        attributedTexto.addAttribute(.font, value: UIFont(name: "Ubuntu-Light", size: 24.0)!, range: NSRange(location: 5, length: 4))
        
        limveLabel.attributedText = attributedTexto
        
        frameInicialViewHolder = holder.frame
        
        botaoEntrar.spinnerColor = UIColor.white
        botaoEntrar.cornerRadius = botaoEntrar.frame.height/2
        botaoEntrar.backgroundColor = hexStringToUIColor("#57005B")
        
        cpf.delegate = self
        
        botaoApple.spinnerColor = UIColor.black
        botaoApple.cornerRadius = 16.0
        
        holderCPF.layer.cornerRadius = 8.0
        holderSenha.layer.cornerRadius = 8.0
        blurCPF.layer.cornerRadius = 8.0
        blurSenha.layer.cornerRadius = 8.0
        blurCPF.clipsToBounds = true
        blurSenha.clipsToBounds = true
        
        blurExplorarApp.layer.cornerRadius = 16.0
        blurExplorarApp.clipsToBounds = true
        
        holderCPF.layer.shadowColor = hexStringToUIColor("#666666").withAlphaComponent(0.5).cgColor
        holderCPF.layer.shadowOpacity = 2
        holderCPF.layer.shadowOffset = .zero
        holderCPF.layer.shadowRadius = 4
        
        holderSenha.layer.shadowColor = hexStringToUIColor("#666666").withAlphaComponent(0.5).cgColor
        holderSenha.layer.shadowOpacity = 2
        holderSenha.layer.shadowOffset = .zero
        holderSenha.layer.shadowRadius = 4
        
        loaderTexto.typingTimeInterval = 0.05
        loaderTexto.animationStyle = .reveal
        loaderTexto.startTypewritingAnimation()
        
        var placeHolder = NSMutableAttributedString()
        let name  = "Digite seu CPF"
        placeHolder = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont(name: "CeraRoundPro-Regular", size: 18.0)!])
        placeHolder.addAttribute(NSAttributedString.Key.foregroundColor, value: hexStringToUIColor("#e5e5e5"), range: NSRange(location:0, length: name.count))
        cpf.attributedPlaceholder = placeHolder
        
        var placeHolder2 = NSMutableAttributedString()
        let name2  = "Digite sua senha"
        placeHolder2 = NSMutableAttributedString(string: name2, attributes: [NSAttributedString.Key.font: UIFont(name: "CeraRoundPro-Regular", size: 18.0)!])
        placeHolder2.addAttribute(NSAttributedString.Key.foregroundColor, value: hexStringToUIColor("#e5e5e5"), range: NSRange(location:0, length: name2.count))
        senha.attributedPlaceholder = placeHolder2
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    var blurEffectView: UIView!
    @IBAction func recuperacaoDeSenha(){
        if (cpf.text!.count < 14 || !validaCPF()){
            let popup = PopupDialog(title: "Ops!", message: "Para recuperar a senha, digite um CPF válido.")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        
        let params = ["usuario": cpf.text!]
        print(params)
        
        PFCloud.callFunction(inBackground: "recuperacaoDeSenha", withParameters: params) { [self] (certo, erro) in
            if (erro != nil){
                let popup = PopupDialog(title: "Erro!", message: "Usuário não encontrado para o CPF: \(self.cpf.text!)!")
                popup.buttonAlignment = .horizontal
                popup.transitionStyle = .bounceUp
                let button = CancelButton(title: "Ok", action: {
                })
                popup.addButton(button)
                // Present dialog
                self.present(popup, animated: true, completion: nil)
                return
            }
            
            let blurView = DynamicBlurView(frame: self.view.bounds)
            blurView.blurRadius = 4
            blurView.trackingMode = .tracking
            blurView.isDeepRendering = true
            blurView.tintColor = .clear
            blurView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            
            let overlay = UIView(frame: self.view.bounds)
            overlay.backgroundColor = .black
            overlay.alpha = 0.4
            overlay.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            
            blurEffectView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
            blurEffectView.backgroundColor = UIColor.clear
            
            blurEffectView.addSubview(blurView)
            blurEffectView.addSubview(overlay)
            
            self.view.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
            
            UIView.animate(withDuration: 0.25, animations: {
                self.blurEffectView.alpha = 1
            }) { _ in
                
            }
            
            let recup = RecuperacaoSenhaController.inicializeRecuperacaoSenhaController(usuario: self.cpf.text!, delegate: self)
            
            self.present(recup, animated: true, completion: {
                blurView.trackingMode = .none
            })
        }
    }
    
    func onExitRecupSenha(sussecefull: Bool) {
        UIView.animate(withDuration: 0.25, animations: {
            self.blurEffectView.alpha = 0
        }) { _ in
            self.blurEffectView.removeFromSuperview()
        }
        
        if (sussecefull){
            let popup = PopupDialog(title: "Sucesso!", message: "Sua senha foi alterada com sucesso!")
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
    
    func onExit(sussecefull: Bool) {
        UIView.animate(withDuration: 0.25, animations: {
            self.blurEffectView.alpha = 0
        }) { _ in
            self.blurEffectView.removeFromSuperview()
        }
        
        if (sussecefull){
            botaoApple.stopAnimation()
            self.delegate.onExit(sussecefull: true)
            self.dismiss(animated: true, completion: nil)
            return
        }
    }
    
    @IBAction func loginComAApple(){
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
        print("ERRO NO LOGIN COM A APPLE")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                
                // Create an account in your system.
                let userIdentifier = appleIDCredential.user
                let fullName = appleIDCredential.fullName
                let email = appleIDCredential.email
                
                print("userIdentifier: \(userIdentifier) | fullName: \(fullName) | email: \(email)")
                
                botaoApple.startAnimation()
                
                PFCloud.callFunction(inBackground: "buscarUsuarioPorIdentificadorUnico", withParameters: ["identificador": userIdentifier]) { (resultado, erro) in
                    
                    if (erro != nil){
                        //usuario não existe
                        print("usuario nao existe")
                        
                        let formatter = PersonNameComponentsFormatter()
                        formatter.style = PersonNameComponentsFormatter.Style.long
                        
                        var nomeStr: String?
                        if (fullName != nil){
                            nomeStr = formatter.string(from: fullName!)
                        }
                        
                        self.abrirCadastrarAsLoginApple(identificador: userIdentifier, email: email, nome: nomeStr)
                        
                    } else {
                        //usuário existe
                        let username = ((resultado as! [String : Any])["username"] as! String)
                        let senhaUnica = ((resultado as! [String : Any])["senhaUnica"] as! String)
                        
                        print("username: \(username) | senhaUnica: \(senhaUnica)")
                        
                        self.cpf.text = username
                        self.senha.text = senhaUnica
                        
                        self.botaoApple.stopAnimation()
                        self.entrar()
                        
                    }
                    
                }
            default:
                break
            }
    }
    
    var blurView: DynamicBlurView!
    func inicializarEfeitosDeBlur(){
        blurView = DynamicBlurView(frame: self.view.bounds)
        blurView.blurRadius = 4
        blurView.trackingMode = .tracking
        blurView.isDeepRendering = true
        blurView.tintColor = .clear
        blurView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        let overlay = UIView(frame: self.view.bounds)
        overlay.backgroundColor = .black
        overlay.alpha = 0.4
        overlay.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        blurEffectView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        blurEffectView.backgroundColor = UIColor.clear
        
        blurEffectView.addSubview(blurView)
        blurEffectView.addSubview(overlay)
        
        self.view.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        
        UIView.animate(withDuration: 0.25, animations: {
            self.blurEffectView.alpha = 1
        }) { _ in
            
        }
    }
    
    @IBAction func abrirCadastrar(){
        
        inicializarEfeitosDeBlur()
        let cadastrar = CadastrarController.inicializeCadastrarController(delegate: self)
        self.present(cadastrar, animated: true, completion: {
            self.blurView.trackingMode = .none
        })
    }
    
    func abrirCadastrarAsLoginApple(identificador: String, email: String?, nome: String?){
        
        inicializarEfeitosDeBlur()
        let cadastrar = CadastrarController.inicializeCadastrarControllerAsLoginApple(identificador: identificador, email: email, nome: nome, delegate: self)
        self.present(cadastrar, animated: true, completion: {
            self.blurView.trackingMode = .none
        })
    }
    
    @IBAction func returnClickedFromCPF(){
        if ((cpf.text?.count)! > 0){
            senha.becomeFirstResponder()
        } else {
            cpf.resignFirstResponder()
        }
    }
    
    @IBAction func returnClickedFromPassword(){
        self.view.endEditing(true)
    }
    
    @IBAction func entrar(){
        
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
        
        botaoEntrar.startAnimation()
        
        PFUser.logInWithUsername(inBackground: cpf.text!, password: senha.text!) { (certo, erro) in
            if (erro == nil){
                self.botaoEntrar.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.25) {
                    self.dismiss(animated: true, completion: nil)
                    self.delegate.onExit(sussecefull: true)
                }
            } else {
                self.botaoEntrar.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.25) {
                    let popup = PopupDialog(title: "Ops!", message: "CPF não encontrado ou senha incorreta, por favor, tente novamente!")
                    popup.buttonAlignment = .horizontal
                    popup.transitionStyle = .bounceUp
                    let button = CancelButton(title: "Ok", action: {
                    })
                    popup.addButton(button)
                    // Present dialog
                    self.present(popup, animated: true, completion: nil)
                }
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
            returnClickedFromCPF()
        }
        
    }
    
    @IBAction func fecharKeyboard(){
        self.view.endEditing(true)
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.count == 0 && range.length > 0 {
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
        }
        
        return true
    }
    
    var keyboardHidden = true
    //KEYBOARD OBSERVERS
    @objc func keyboardWillHide(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let _ = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                keyboardHidden = true
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
                keyboardHidden = false
                UIView.animate(withDuration: 0.25, animations: {
                    self.holder.frame = CGRect(x: (self.frameInicialViewHolder?.origin.x)!, y: (self.frameInicialViewHolder?.origin.y)! - (keyboardHeight2/3), width: (self.frameInicialViewHolder?.width)!, height: (self.frameInicialViewHolder?.height)!)
                })
            }
        }
    }
    //
}
