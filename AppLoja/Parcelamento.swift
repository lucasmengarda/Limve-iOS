//
//  Parcelamento.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 09/03/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import Foundation
import UIKit
import Parse
import TransitionButton
import PopupDialog

protocol ParcelamentoDelegate{
    func onExitParcelar(sussecefull: Bool, parcelamento: Int?)
}

class Parcelamento: UIViewController {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var botaoAdicionar: TransitionButton!
    @IBOutlet weak var botaoFechar: TransitionButton!
    @IBOutlet weak var vez1Upper: UIView!
    @IBOutlet weak var vez1Inside: UIView!
    @IBOutlet weak var vez2Upper: UIView!
    @IBOutlet weak var vez2Inside: UIView!
    @IBOutlet weak var vez3Upper: UIView!
    @IBOutlet weak var vez3Inside: UIView!
    @IBOutlet weak var escrita1vez: UILabel!
    @IBOutlet weak var escrita2vez: UILabel!
    @IBOutlet weak var escrita3vez: UILabel!
    
    var delegate: ParcelamentoDelegate!
    var parcelarSelecionado = 1
    var valorTotal: Double!
    
    static func inicializeParcelamento(valorTotal: Double, parcelamento: Int, delegate: ParcelamentoDelegate) -> Parcelamento{
        let tela = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "Parcelamento") as! Parcelamento
        tela.delegate = delegate
        tela.parcelarSelecionado = parcelamento
        tela.valorTotal = valorTotal
        return tela
    }
    
    @IBAction func fechar(){
        self.dismiss(animated: true, completion: nil)
        self.delegate.onExitParcelar(sussecefull: false, parcelamento: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vez1Upper.layer.cornerRadius = vez1Upper.frame.height/2
        vez1Upper.layer.borderWidth = 2.0
        vez1Upper.backgroundColor = UIColor.clear
        vez1Upper.layer.borderColor = hexStringToUIColor("#0B6AB0").cgColor
        
        vez1Inside.layer.cornerRadius = vez1Inside.frame.height/2
        
        vez2Upper.layer.cornerRadius = vez2Upper.frame.height/2
        vez2Upper.layer.borderWidth = 2.0
        vez2Upper.backgroundColor = UIColor.clear
        vez2Upper.layer.borderColor = hexStringToUIColor("#0B6AB0").cgColor
        
        vez2Inside.layer.cornerRadius = vez2Inside.frame.height/2
        
        vez3Upper.layer.cornerRadius = vez3Upper.frame.height/2
        vez3Upper.layer.borderWidth = 2.0
        vez3Upper.backgroundColor = UIColor.clear
        vez3Upper.layer.borderColor = hexStringToUIColor("#0B6AB0").cgColor
        
        vez3Inside.layer.cornerRadius = vez3Inside.frame.height/2
        
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
        
        escrita1vez.text = "1 parcela de \(formatarPreco(preco: valorTotal)) (sem juros)"
        escrita2vez.text = "2 parcelas de \(formatarPreco(preco: valorTotal/2)) (sem juros)"
        escrita3vez.text = "3 parcelas de \(formatarPreco(preco: valorTotal/3)) (sem juros)"
        
        setarNovaBandeira()
        
    }
    
    func setarNovaBandeira(){
        
        vez1Inside.backgroundColor = UIColor.white
        vez2Inside.backgroundColor = UIColor.white
        vez3Inside.backgroundColor = UIColor.white
        
        UIView.animate(withDuration: 0.25) {
            if (self.parcelarSelecionado == 1){
                self.vez1Inside.backgroundColor = hexStringToUIColor("#0B6AB0")
            }
            if (self.parcelarSelecionado == 2){
                self.vez2Inside.backgroundColor = hexStringToUIColor("#0B6AB0")
            }
            if (self.parcelarSelecionado == 3){
                self.vez3Inside.backgroundColor = hexStringToUIColor("#0B6AB0")
            }
        }
    }
    
    @IBAction func selectOrdenar(sender: UIControl){
        if (sender.tag == 0){
            parcelarSelecionado = 1
        } else if (sender.tag == 1){
            parcelarSelecionado = 2
        } else if (sender.tag == 2){
            parcelarSelecionado = 3
        }
        setarNovaBandeira()
    }
    
    @IBAction func prosseguir(){
        self.dismiss(animated: true, completion: nil)
        self.delegate.onExitParcelar(sussecefull: true, parcelamento: parcelarSelecionado)
    }
}

