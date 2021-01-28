//
//  FormasPagamento.swift
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
import NVActivityIndicatorView
import DynamicBlurView

class FormasPagamento: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var botaoAdicionar: TransitionButton!
    @IBOutlet weak var botaoFechar: TransitionButton!
    @IBOutlet weak var oTable: UITableView!
    @IBOutlet weak var loader: UIView!
    
    var formaDePagamentoTipo: String!
    var delegate: Carrinho!
    var cartaoSelecionado: Cartao?
    var formasPgto = [Cartao]()
    var raioPagueNaEntrega: Double!
    var deixarPagueNaEntrega = false
    var valorAPagar: Double!
    
    var precisaTroco = false
    var trocoPara = 0.0
    var pagueNaEntregaTipo = ""
    
    static func inicializeFormasPagamento(valorAPagar: Double, cartaoSelecionado: Cartao?, formaDePagamentoTipo: String, delegate: Carrinho) -> FormasPagamento{
        let tela = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "FormasPagamento") as! FormasPagamento
        tela.delegate = delegate
        tela.formaDePagamentoTipo = formaDePagamentoTipo
        tela.cartaoSelecionado = cartaoSelecionado
        tela.valorAPagar = valorAPagar
        return tela
    }
    
    @IBAction func fechar(){
        self.dismiss(animated: true, completion: nil)
        self.delegate.onExitFormasPagamento(sussecefull: false, formaDePagamentoTipo: "", cartao: nil, pagarEntregaTipo: nil, pagarEntregaStr: nil, trocoPara: 0.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        raioPagueNaEntrega = (configuration.object(forKey: "RAIO_PAGUENAENTREGA") as! Double)
        if (PFUser.current()!["enderecoPoint"] != nil){
            let enderecoPoint = PFUser.current()!["enderecoPoint"] as! PFGeoPoint
            if (enderecoPoint.distanceInKilometers(to: delegate.pontoOrigemLimve) > raioPagueNaEntrega){
                deixarPagueNaEntrega = false
            } else {
                deixarPagueNaEntrega = true
            }
        }
        
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
        
        loader.isHidden = false
        oTable.isHidden = true
        
        loader.backgroundColor = UIColor.clear
        let nv = NVActivityIndicatorView(frame: CGRect(origin: .zero, size: loader.frame.size), type: NVActivityIndicatorType.ballClipRotateMultiple, color: hexStringToUIColor("#3C65D1"), padding: 15.0)
        loader.backgroundColor = UIColor.clear
        loader.addSubview(nv)
        nv.startAnimating()
        
        DispatchQueue.global(qos: .background).async {
            do {
                
                let cartoesObj = try PFQuery(className: "Cartoes").findObjects()
                self.formasPgto.removeAll()
                for cartao in cartoesObj {
                    let newCard = Cartao(cartao: cartao)
                    self.formasPgto.append(newCard)
                }
                
                print("formaspgto: \(self.formasPgto)")
                
                DispatchQueue.main.async {
                    self.loader.isHidden = true
                    self.oTable.reloadData()
                    self.oTable.isHidden = false
                }
            } catch {
                
            }
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (deixarPagueNaEntrega){
            return formasPgto.count + 4
        } else {
            return formasPgto.count + 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var base = 1
        if (deixarPagueNaEntrega){
            base = 2
            if (indexPath.row == (tableView.numberOfRows(inSection: 0)-base)){
                let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaItemFormasPagamento") as! CelulaItemFormasPagamento
                
                cell.upper.layer.cornerRadius = cell.upper.frame.height/2
                cell.upper.layer.borderWidth = 2.0
                cell.upper.backgroundColor = UIColor.clear
                cell.upper.layer.borderColor = hexStringToUIColor("#0B6AB0").cgColor
                
                cell.inside.layer.cornerRadius = cell.inside.frame.height/2
                
                if (formaDePagamentoTipo.contains("entrega")){
                    cell.inside.backgroundColor = hexStringToUIColor("#0B6AB0")
                } else {
                    cell.inside.backgroundColor = UIColor.white
                }
                
                cell.imagem.image = UIImage(named: "delivery.png")
                cell.texto.text = "Pague na entrega \(adicionalPagueNaEntrega)"
                cell.texto.textColor = UIColor.red
                cell.tipoCartao.isHidden = true
                cell.texto.font = UIFont(name: "IntroScript-SemiBold", size: 18.0)
                
                return cell
            }
        } else {
            base = 1
        }
        
        if (indexPath.row == (tableView.numberOfRows(inSection: 0)-1)){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaItemNovaFormaPgto") as! CelulaItemNovaFormaPgto
            
            cell.selectionStyle = .gray
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaItemFormasPagamento") as! CelulaItemFormasPagamento
        
        cell.upper.layer.cornerRadius = cell.upper.frame.height/2
        cell.upper.layer.borderWidth = 2.0
        cell.upper.backgroundColor = UIColor.clear
        cell.upper.layer.borderColor = hexStringToUIColor("#0B6AB0").cgColor
        cell.texto.textColor = UIColor.black
        cell.texto.font = UIFont(name: "IntroScript-Regular", size: 18.0)
        
        cell.inside.layer.cornerRadius = cell.inside.frame.height/2
        
        if (indexPath.row == (tableView.numberOfRows(inSection: 0)-base-1)){
            //boleto
            
            if (formaDePagamentoTipo == "boleto"){
                cell.inside.backgroundColor = hexStringToUIColor("#0B6AB0")
            } else {
                cell.inside.backgroundColor = UIColor.white
            }
            
            cell.imagem.image = UIImage(named: "barcode.png")
            cell.texto.text = "Boleto bancário"
            cell.tipoCartao.isHidden = true
        } else if (indexPath.row == (tableView.numberOfRows(inSection: 0)-base-2)) {
            //transferencia bancária
            
            if (formaDePagamentoTipo == "transferencia"){
                cell.inside.backgroundColor = hexStringToUIColor("#0B6AB0")
            } else {
                cell.inside.backgroundColor = UIColor.white
            }
            
            cell.imagem.image = UIImage(named: "transferencia.png")
            cell.texto.text = "Transferência bancária"
            cell.tipoCartao.isHidden = true
        } else {
        
            if (cartaoSelecionado != nil){
                if (cartaoSelecionado!.cartaoId == formasPgto[indexPath.row].cartaoId){
                    cell.inside.backgroundColor = hexStringToUIColor("#0B6AB0")
                } else {
                    cell.inside.backgroundColor = UIColor.white
                }
            } else {
                cell.inside.backgroundColor = UIColor.white
            }
            
            if (formasPgto[indexPath.row].bandeira == CartaoTipo.mastercard){
                cell.imagem.image = UIImage(named: "mastercard.png")
                cell.texto.text = "MasterCard *** \(formasPgto[indexPath.row].final!)"
            } else if (formasPgto[indexPath.row].bandeira == CartaoTipo.visa){
                cell.imagem.image = UIImage(named: "visa.png")
                cell.texto.text = "Visa *** \(formasPgto[indexPath.row].final!)"
            } else if (formasPgto[indexPath.row].bandeira == CartaoTipo.elo){
                cell.imagem.image = UIImage(named: "elo.png")
                cell.texto.text = "Elo *** \(formasPgto[indexPath.row].final!)"
            } else if (formasPgto[indexPath.row].bandeira == CartaoTipo.amex){
                cell.imagem.image = UIImage(named: "amex.png")
                cell.texto.text = "Amex *** \(formasPgto[indexPath.row].final!)"
            } else {
                cell.imagem.image = UIImage(named: "outrocartao.png")
                cell.texto.text = "\(formasPgto[indexPath.row].bandeiraOutro!) *** \(formasPgto[indexPath.row].final!)"
            }
            
            cell.tipoCartao.isHidden = false
            if (formasPgto[indexPath.row].cartaoStyle == CartaoStyle.credito){
                cell.tipoCartao.text = "crédito"
            } else {
                cell.tipoCartao.text = "débito"
            }
            
            cell.selectionStyle = .gray
        }
        
        return cell
    }
    
    var adicionalPagueNaEntrega = ""
    var blurEffectView: UIView!
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var base = 1
        if (deixarPagueNaEntrega){
            base = 2
            if (indexPath.row == (tableView.numberOfRows(inSection: 0)-base)){
                cartaoSelecionado = nil
                formaDePagamentoTipo = "entrega"
                oTable.reloadData()
                
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
                
                let pgto = PagueNaEntrega.inicializePagueNaEntrega(valorAPagar: valorAPagar, delegate: self)
                self.present(pgto, animated: true, completion: {
                    blurView.trackingMode = .none
                })
                
                
                return
            }
        } else {
            base = 1
        }
        
        if (indexPath.row == (tableView.numberOfRows(inSection: 0)-1)){
            
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
            
            let adicionar = AdicionarCartao.inicializeAdicionarCartao(delegate: delegate)
            self.dismiss(animated: false) {
                self.delegate.present(adicionar, animated: true, completion: {
                    blurView.trackingMode = .none
                })
            }
            
            return
        }
        
        if (indexPath.row == (tableView.numberOfRows(inSection: 0)-base-1)){
            cartaoSelecionado = nil
            formaDePagamentoTipo = "boleto"
        } else if (indexPath.row == (tableView.numberOfRows(inSection: 0)-base-2)){
            cartaoSelecionado = nil
            formaDePagamentoTipo = "transferencia"
        } else {
            cartaoSelecionado = formasPgto[indexPath.row]
            if (cartaoSelecionado?.cartaoStyle == CartaoStyle.credito){
                formaDePagamentoTipo = "credito"
            } else {
                formaDePagamentoTipo = "debito"
            }
        }
        
        oTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == (tableView.numberOfRows(inSection: 0)-1)){
            return 61.0
        } else {
            return 56.0
        }
    }
    
    func retornaPagueNaEntrega(adicionalPagueNaEntrega: String?, tipo: String?, precisaTroco: Bool, trocoPara: Double?){
        UIView.animate(withDuration: 0.25, animations: {
            self.blurEffectView.alpha = 0
        }) { _ in
            self.blurEffectView.removeFromSuperview()
        }
        
        if (adicionalPagueNaEntrega != nil){
            self.adicionalPagueNaEntrega = adicionalPagueNaEntrega!
            if (trocoPara != nil){
                self.trocoPara = trocoPara!
            } else {
                self.trocoPara = -1.0
            }
            self.precisaTroco = precisaTroco
            self.formaDePagamentoTipo = "entrega"
            self.pagueNaEntregaTipo = tipo!
        } else {
            self.formaDePagamentoTipo = ""
            self.pagueNaEntregaTipo = ""
        }
        
        oTable.reloadData()
    }
    
    @IBAction func prosseguir(){
        self.dismiss(animated: true, completion: nil)
        
        if (formaDePagamentoTipo == "entrega"){
            
            var pagueNaEntregaStr = ""
            if (pagueNaEntregaTipo.contains("mastercard")){
                pagueNaEntregaStr = "Mastercard "
            } else if (pagueNaEntregaTipo.contains("visa")){
                pagueNaEntregaStr = "Visa "
            } else if (pagueNaEntregaTipo.contains("elo")){
                pagueNaEntregaStr = "Elo "
            } else {
                pagueNaEntregaStr = "Amex "
            }
            
            if (pagueNaEntregaTipo.contains("credito")){
                pagueNaEntregaStr = "\(pagueNaEntregaStr)(Crédito)"
            } else {
                pagueNaEntregaStr = "\(pagueNaEntregaStr)(Débito)"
            }
            
            if (pagueNaEntregaTipo.contains("dinheiro")){
                if (trocoPara > 0.0){
                    pagueNaEntregaStr = "Dinheiro - troco para \(formatarPreco(preco: trocoPara))"
                } else if (trocoPara == -1.0){
                    pagueNaEntregaStr = "Dinheiro - sem troco"
                }
            }
            
            self.delegate.onExitFormasPagamento(sussecefull: true, formaDePagamentoTipo: formaDePagamentoTipo, cartao: nil, pagarEntregaTipo: pagueNaEntregaTipo, pagarEntregaStr: pagueNaEntregaStr, trocoPara: trocoPara)
        } else {
            self.delegate.onExitFormasPagamento(sussecefull: true, formaDePagamentoTipo: formaDePagamentoTipo, cartao: cartaoSelecionado, pagarEntregaTipo: nil, pagarEntregaStr: nil, trocoPara: 0.0)
        }
    }
}

class CelulaItemFormasPagamento: UITableViewCell {
    @IBOutlet weak var upper: UIView!
    @IBOutlet weak var inside: UIView!
    @IBOutlet weak var imagem: UIImageView!
    @IBOutlet weak var texto: UILabel!
    @IBOutlet weak var tipoCartao: UILabel!
}

class CelulaItemNovaFormaPgto: UITableViewCell {
}

class CelulaItemPagueNaEntrega: UITableViewCell {
    
}
