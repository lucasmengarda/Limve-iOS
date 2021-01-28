//
//  Cvv.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 13/03/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import Foundation
import UIKit
import Parse
import TransitionButton
import PopupDialog
import NVActivityIndicatorView
import DynamicBlurView

protocol CvvDelegate {
    func onExitCvv(sucesseful: Bool, botao: TransitionButton, cvv: String?)
}

class Cvv: UIViewController {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var botaoSelecionar: TransitionButton!
    @IBOutlet weak var botaoFechar: TransitionButton!
    @IBOutlet weak var cvv: UITextField!
    @IBOutlet weak var textoIndicativo: UITextView!
    
    var delegate: CvvDelegate!
    var frameInicialViewHolder: CGRect!
    var botao: TransitionButton!
    var cartao: Cartao!
    
    static func inicializeCvv(botao: TransitionButton, cartao: Cartao!, delegate: CvvDelegate) -> Cvv{
        let tela = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "Cvv") as! Cvv
        tela.delegate = delegate
        tela.botao = botao
        tela.cartao = cartao
        return tela
    }
    
    @IBAction func fecharKeyboard(){
        self.view.endEditing(true)
    }
    
    @IBAction func fechar(){
        self.dismiss(animated: true, completion: nil)
        self.delegate.onExitCvv(sucesseful: false, botao: botao, cvv: nil)
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
        
        atribuirPlaceholder(textField: cvv, name: "Digite o CVV")
        
        var bandeiraStr = ""
        if (cartao.bandeira == CartaoTipo.amex){
            bandeiraStr = "Amex"
        } else if (cartao.bandeira == CartaoTipo.mastercard){
            bandeiraStr = "Mastercard"
        } else if (cartao.bandeira == CartaoTipo.visa){
            bandeiraStr = "Visa"
        } else if (cartao.bandeira == CartaoTipo.elo){
            bandeiraStr = "Elo"
        } else {
            bandeiraStr = cartao.bandeiraOutro
        }
        textoIndicativo.text = "Digite o código de segurança do seu cartão \(bandeiraStr) final \(cartao.final!):"
        
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
        
        if (cvv.text!.count < 2){
            let popup = PopupDialog(title: "Ops!", message: "CVV inválido. Confira se você digitou-o corretamente!")
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
        self.delegate.onExitCvv(sucesseful: true, botao: botao, cvv: cvv.text!)
    }
    
    @IBAction func returnClicked(sender: UITextField){
        if ((sender.text?.count)! > 0){
            self.view.endEditing(true)
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
