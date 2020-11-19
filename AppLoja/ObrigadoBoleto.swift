//
//  ObrigadoBoleto.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 19/10/20.
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

class ObrigadoBoleto: UIViewController {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var botaoFechar: TransitionButton!
    @IBOutlet weak var botaoCopiar: TransitionButton!
    @IBOutlet weak var codigoDeBarras: UILabel!
    
    var delegate: ObrigadoDelegate!
    var frameInicialViewHolder: CGRect!
    var autenticacao: String!
    var boleto: [String : Any]!
    
    static func inicializeObrigado(boleto: [String : Any], delegate: ObrigadoDelegate) -> ObrigadoBoleto{
        let tela = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "ObrigadoBoleto") as! ObrigadoBoleto
        tela.delegate = delegate
        tela.boleto = boleto
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
        
        botaoCopiar.spinnerColor = UIColor.white
        botaoCopiar.cornerRadius = botaoCopiar.frame.height/2
        botaoCopiar.backgroundColor = hexStringToUIColor("#4BC562")
        botaoFechar.spinnerColor = UIColor.white
        botaoFechar.cornerRadius = botaoFechar.frame.height/2
        botaoFechar.backgroundColor = hexStringToUIColor("#EF343A")
        
        codigoDeBarras.text = (boleto["typeful_line"] as! String)
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    @IBAction func copiarCodigoDeBarras(){
        botaoCopiar.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.3) { [self] in
            self.botaoCopiar.setTitle("Copiado!", for: [])
        }
        UIPasteboard.general.string = (boleto["bar_code"] as! String)
    }
    
    func atribuirPlaceholder(textField: UITextField, name: String){
        var placeHolder = NSMutableAttributedString()
        placeHolder = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont(name: "CeraRoundPro-Regular", size: 18.0)!])
        placeHolder.addAttribute(NSAttributedString.Key.foregroundColor, value: hexStringToUIColor("#939393"), range: NSRange(location:0, length: name.count))
        textField.attributedPlaceholder = placeHolder
    }
}
