//
//  OrdenarPor.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 06/03/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import Foundation
import UIKit
import Parse
import TransitionButton
import PopupDialog

protocol OrdenarPorDelegate{
    func onExitOrdenar(sussecefull: Bool, ordenacao: String?)
}

class OrdenarPor: UIViewController {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var botaoAdicionar: TransitionButton!
    @IBOutlet weak var botaoFechar: TransitionButton!
    @IBOutlet weak var alfabeticaUpper: UIView!
    @IBOutlet weak var alfabeticaInside: UIView!
    @IBOutlet weak var popularidadeUpper: UIView!
    @IBOutlet weak var popularidadeInside: UIView!
    @IBOutlet weak var precoMaiorUpper: UIView!
    @IBOutlet weak var precoMaiorInside: UIView!
    @IBOutlet weak var precoMenorUpper: UIView!
    @IBOutlet weak var precoMenorInside: UIView!
    @IBOutlet weak var lancamentoUpper: UIView!
    @IBOutlet weak var lancamentoInside: UIView!
    
    var delegate: OrdenarPorDelegate!
    
    static func inicializeOrdenarPor(ordenacao: String, delegate: OrdenarPorDelegate) -> OrdenarPor{
        let tela = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "OrdenarPor") as! OrdenarPor
        tela.delegate = delegate
        tela.ordenarSelecionado = ordenacao
        return tela
    }
    
    @IBAction func fechar(){
        self.dismiss(animated: true, completion: nil)
        self.delegate.onExitOrdenar(sussecefull: false, ordenacao: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alfabeticaUpper.layer.cornerRadius = alfabeticaUpper.frame.height/2
        alfabeticaUpper.layer.borderWidth = 2.0
        alfabeticaUpper.backgroundColor = UIColor.clear
        alfabeticaUpper.layer.borderColor = hexStringToUIColor("#0B6AB0").cgColor
        
        alfabeticaInside.layer.cornerRadius = alfabeticaInside.frame.height/2
        
        popularidadeUpper.layer.cornerRadius = popularidadeUpper.frame.height/2
        popularidadeUpper.layer.borderWidth = 2.0
        popularidadeUpper.backgroundColor = UIColor.clear
        popularidadeUpper.layer.borderColor = hexStringToUIColor("#0B6AB0").cgColor
        
        popularidadeInside.layer.cornerRadius = popularidadeInside.frame.height/2
        
        precoMaiorUpper.layer.cornerRadius = precoMaiorUpper.frame.height/2
        precoMaiorUpper.layer.borderWidth = 2.0
        precoMaiorUpper.backgroundColor = UIColor.clear
        precoMaiorUpper.layer.borderColor = hexStringToUIColor("#0B6AB0").cgColor
        
        precoMaiorInside.layer.cornerRadius = precoMaiorInside.frame.height/2
        
        precoMenorUpper.layer.cornerRadius = precoMenorUpper.frame.height/2
        precoMenorUpper.layer.borderWidth = 2.0
        precoMenorUpper.backgroundColor = UIColor.clear
        precoMenorUpper.layer.borderColor = hexStringToUIColor("#0B6AB0").cgColor
        
        precoMenorInside.layer.cornerRadius = precoMenorInside.frame.height/2
        
        lancamentoUpper.layer.cornerRadius = lancamentoUpper.frame.height/2
        lancamentoUpper.layer.borderWidth = 2.0
        lancamentoUpper.backgroundColor = UIColor.clear
        lancamentoUpper.layer.borderColor = hexStringToUIColor("#0B6AB0").cgColor
        
        lancamentoInside.layer.cornerRadius = lancamentoInside.frame.height/2
        
        holder.layer.cornerRadius = 16.0
        holder.clipsToBounds = true
        self.view.backgroundColor = UIColor.clear
        holder.layer.shadowColor = hexStringToUIColor("#00224B").cgColor
        holder.layer.shadowOpacity = 6
        holder.layer.shadowOffset = .zero
        holder.layer.shadowRadius = 10
        
        botaoAdicionar.spinnerColor = UIColor.white
        botaoAdicionar.cornerRadius = botaoAdicionar.frame.height/2
        botaoAdicionar.backgroundColor = hexStringToUIColor("#4BC562")
        botaoFechar.spinnerColor = UIColor.white
        botaoFechar.cornerRadius = botaoFechar.frame.height/2
        botaoFechar.backgroundColor = hexStringToUIColor("#EF343A")
        
        setarNovaBandeira()
        
    }
    
    var ordenarSelecionado = ""
    func setarNovaBandeira(){
        
        alfabeticaInside.backgroundColor = UIColor.white
        popularidadeInside.backgroundColor = UIColor.white
        precoMaiorInside.backgroundColor = UIColor.white
        precoMenorInside.backgroundColor = UIColor.white
        lancamentoInside.backgroundColor = UIColor.white
        
        UIView.animate(withDuration: 0.25) {
            if (self.ordenarSelecionado == "alfabetica"){
                self.alfabeticaInside.backgroundColor = hexStringToUIColor("#0B6AB0")
            }
            if (self.ordenarSelecionado == "popularidade"){
                self.popularidadeInside.backgroundColor = hexStringToUIColor("#0B6AB0")
            }
            if (self.ordenarSelecionado == "precoMaior"){
                self.precoMaiorInside.backgroundColor = hexStringToUIColor("#0B6AB0")
            }
            if (self.ordenarSelecionado == "precoMenor"){
                self.precoMenorInside.backgroundColor = hexStringToUIColor("#0B6AB0")
            }
            if (self.ordenarSelecionado == "lancamento"){
                self.lancamentoInside.backgroundColor = hexStringToUIColor("#0B6AB0")
            }
        }
    }
    
    @IBAction func selectOrdenar(sender: UIControl){
        if (sender.tag == 0){
            ordenarSelecionado = "alfabetica"
        } else if (sender.tag == 1){
            ordenarSelecionado = "popularidade"
        } else if (sender.tag == 2){
            ordenarSelecionado = "precoMaior"
        } else if (sender.tag == 3){
            ordenarSelecionado = "precoMenor"
        } else {
            ordenarSelecionado = "lancamento"
        }
        setarNovaBandeira()
    }
    
    @IBAction func prosseguir(){
        self.dismiss(animated: true, completion: nil)
        self.delegate.onExitOrdenar(sussecefull: true, ordenacao: ordenarSelecionado)
    }
}

