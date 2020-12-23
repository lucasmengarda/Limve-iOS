//
//  Obrigado.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 19/03/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import Foundation
import UIKit
import Parse
import TransitionButton
import PopupDialog
import NVActivityIndicatorView
import DynamicBlurView
import AudioToolbox

protocol ObrigadoDelegate {
    func onExitObrigado()
}

class Obrigado: UIViewController {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var botaoFechar: TransitionButton!
    @IBOutlet weak var autenticacaoText: UITextView!
    
    var delegate: ObrigadoDelegate!
    var frameInicialViewHolder: CGRect!
    var autenticacao: String!
    
    static func inicializeObrigado(autenticacao: String, delegate: ObrigadoDelegate) -> Obrigado{
        let tela = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "Obrigado") as! Obrigado
        tela.delegate = delegate
        tela.autenticacao = autenticacao
        return tela
    }
    
    @IBAction func fechar(){
        self.dismiss(animated: false, completion: nil)
        self.delegate.onExitObrigado()
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
        
        botaoFechar.spinnerColor = UIColor.white
        botaoFechar.cornerRadius = botaoFechar.frame.height/2
        botaoFechar.backgroundColor = hexStringToUIColor("#EF343A")
        
        autenticacaoText.text = "AUTENTICAÇÃO: #\(autenticacao!)"
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func atribuirPlaceholder(textField: UITextField, name: String){
        var placeHolder = NSMutableAttributedString()
        placeHolder = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont(name: "CeraRoundPro-Regular", size: 18.0)!])
        placeHolder.addAttribute(NSAttributedString.Key.foregroundColor, value: hexStringToUIColor("#939393"), range: NSRange(location:0, length: name.count))
        textField.attributedPlaceholder = placeHolder
    }
}

class ObrigadoEntrega: UIViewController {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var botaoFechar: TransitionButton!
    
    var delegate: ObrigadoDelegate!
    var frameInicialViewHolder: CGRect!
    
    static func inicializeObrigadoEntrega(delegate: ObrigadoDelegate) -> ObrigadoEntrega{
        let tela = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "ObrigadoEntrega") as! ObrigadoEntrega
        tela.delegate = delegate
        return tela
    }
    
    @IBAction func fechar(){
        self.dismiss(animated: false, completion: nil)
        self.delegate.onExitObrigado()
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
        
        botaoFechar.spinnerColor = UIColor.white
        botaoFechar.cornerRadius = botaoFechar.frame.height/2
        botaoFechar.backgroundColor = hexStringToUIColor("#EF343A")
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}
