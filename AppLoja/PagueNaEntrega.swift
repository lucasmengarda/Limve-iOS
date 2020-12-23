//
//  PagueNaEntrega.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 17/12/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import Foundation
import UIKit
import Parse
import TransitionButton
import PopupDialog
import NVActivityIndicatorView
import DynamicBlurView

class PagueNaEntrega: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var botaoAdicionar: TransitionButton!
    @IBOutlet weak var oTable: UITableView!
    
    var pagueNaEntregaTipo: String!
    var delegate: FormasPagamento!
    
    var trocoPara = 0.0
    var valorAPagar = 0.0
    
    static func inicializePagueNaEntrega(valorAPagar: Double, delegate: FormasPagamento) -> PagueNaEntrega{
        let tela = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "PagueNaEntrega") as! PagueNaEntrega
        tela.delegate = delegate
        tela.valorAPagar = valorAPagar
        return tela
    }
    
    @IBAction func fechar(){
        self.dismiss(animated: true, completion: nil)
        self.delegate.retornaPagueNaEntrega(adicionalPagueNaEntrega: nil, tipo: "", precisaTroco: false, trocoPara: nil)
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
        
        botaoAdicionar.spinnerColor = UIColor.white
        botaoAdicionar.cornerRadius = botaoAdicionar.frame.height/2
        botaoAdicionar.backgroundColor = hexStringToUIColor("#4BC562")
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaItemFormasPagamento") as! CelulaItemFormasPagamento
        
        cell.upper.layer.cornerRadius = cell.upper.frame.height/2
        cell.upper.layer.borderWidth = 2.0
        cell.upper.backgroundColor = UIColor.clear
        cell.upper.layer.borderColor = hexStringToUIColor("#0B6AB0").cgColor
        
        cell.inside.layer.cornerRadius = cell.inside.frame.height/2
        
        if (indexPath.row == 0){
            //dinheiro
            
            if (pagueNaEntregaTipo == "dinheiro"){
                cell.inside.backgroundColor = hexStringToUIColor("#0B6AB0")
            } else {
                cell.inside.backgroundColor = UIColor.white
            }
            
            cell.imagem.image = UIImage(named: "money.png")
            cell.tipoCartao.isHidden = true
            
            if (trocoPara > 0.0){
                cell.texto.text = "Dinheiro (Troco para: \(formatarPreco(preco: trocoPara)))"
            } else if (trocoPara == -1.0) {
                cell.texto.text = "Dinheiro (Sem troco)"
            } else {
                cell.texto.text = "Dinheiro"
            }
            
        } else if (indexPath.row == 1){
            //mastercard
            
            if (pagueNaEntregaTipo == "mastercard-debito"){
                cell.inside.backgroundColor = hexStringToUIColor("#0B6AB0")
            } else {
                cell.inside.backgroundColor = UIColor.white
            }
            
            cell.imagem.image = UIImage(named: "mastercard.png")
            cell.tipoCartao.isHidden = false
            cell.tipoCartao.text = "débito"
            
            cell.texto.text = "MasterCard"
            
        } else if (indexPath.row == 2){
            //mastercard
            
            if (pagueNaEntregaTipo == "mastercard-credito"){
                cell.inside.backgroundColor = hexStringToUIColor("#0B6AB0")
            } else {
                cell.inside.backgroundColor = UIColor.white
            }
            
            cell.imagem.image = UIImage(named: "mastercard.png")
            cell.tipoCartao.isHidden = false
            cell.tipoCartao.text = "crédito"
            
            cell.texto.text = "MasterCard"
            
        } else if (indexPath.row == 3){
            //visa
            
            if (pagueNaEntregaTipo == "visa-debito"){
                cell.inside.backgroundColor = hexStringToUIColor("#0B6AB0")
            } else {
                cell.inside.backgroundColor = UIColor.white
            }
            
            cell.imagem.image = UIImage(named: "visa.png")
            cell.tipoCartao.isHidden = false
            cell.tipoCartao.text = "débito"
            
            cell.texto.text = "Visa"
            
        } else if (indexPath.row == 4){
            //visa
            
            if (pagueNaEntregaTipo == "visa-credito"){
                cell.inside.backgroundColor = hexStringToUIColor("#0B6AB0")
            } else {
                cell.inside.backgroundColor = UIColor.white
            }
            
            cell.imagem.image = UIImage(named: "visa.png")
            cell.tipoCartao.isHidden = false
            cell.tipoCartao.text = "crédito"
            
            cell.texto.text = "Visa"
            
        } else if (indexPath.row == 5){
            //elo
            
            if (pagueNaEntregaTipo == "elo-debito"){
                cell.inside.backgroundColor = hexStringToUIColor("#0B6AB0")
            } else {
                cell.inside.backgroundColor = UIColor.white
            }
            
            cell.imagem.image = UIImage(named: "elo.png")
            cell.tipoCartao.isHidden = false
            cell.tipoCartao.text = "débito"
            
            cell.texto.text = "Elo"
            
        } else if (indexPath.row == 6){
            //elo
            
            if (pagueNaEntregaTipo == "elo-credito"){
                cell.inside.backgroundColor = hexStringToUIColor("#0B6AB0")
            } else {
                cell.inside.backgroundColor = UIColor.white
            }
            
            cell.imagem.image = UIImage(named: "elo.png")
            cell.tipoCartao.isHidden = false
            cell.tipoCartao.text = "crédito"
            
            cell.texto.text = "Elo"
            
        } else if (indexPath.row == 7){
            //amex
            
            if (pagueNaEntregaTipo == "amex-debito"){
                cell.inside.backgroundColor = hexStringToUIColor("#0B6AB0")
            } else {
                cell.inside.backgroundColor = UIColor.white
            }
            
            cell.imagem.image = UIImage(named: "amex.png")
            cell.tipoCartao.isHidden = false
            cell.tipoCartao.text = "débito"
            
            cell.texto.text = "American Express"
            
        } else if (indexPath.row == 8){
            //amex
            
            if (pagueNaEntregaTipo == "amex-credito"){
                cell.inside.backgroundColor = hexStringToUIColor("#0B6AB0")
            } else {
                cell.inside.backgroundColor = UIColor.white
            }
            
            cell.imagem.image = UIImage(named: "amex.png")
            cell.tipoCartao.isHidden = false
            cell.tipoCartao.text = "crédito"
            
            cell.texto.text = "American Express"
            
        }
        
        return cell
    }
    
    var blurEffectView: UIView!
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.row == 0){
            //dinheiro
            
            pagueNaEntregaTipo = "dinheiro"
            
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
            
            let pgto = Dinheiro.inicializeDinheiro(valorCompra: self.valorAPagar, delegate: self)
            self.present(pgto, animated: true, completion: {
                blurView.trackingMode = .none
            })
            
        } else if (indexPath.row == 1){
            //mastercard
            
            pagueNaEntregaTipo = "mastercard-debito"
            
        } else if (indexPath.row == 2){
            //mastercard
            
            pagueNaEntregaTipo = "mastercard-credito"
            
        } else if (indexPath.row == 3){
            //visa
            
            pagueNaEntregaTipo = "visa-debito"
            
        } else if (indexPath.row == 4){
            //visa
            
            pagueNaEntregaTipo = "visa-credito"
            
        } else if (indexPath.row == 5){
            //elo
            
            pagueNaEntregaTipo = "elo-debito"
            
        } else if (indexPath.row == 6){
            //elo
            
            pagueNaEntregaTipo = "elo-credito"
            
        } else if (indexPath.row == 7){
            //amex
            
            pagueNaEntregaTipo = "amex-debito"
            
        } else if (indexPath.row == 8){
            //amex
           
            pagueNaEntregaTipo = "amex-credito"
        }
        
        oTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
    func retornaTroco(precisaTroco: Bool?, troco: Double?){
        UIView.animate(withDuration: 0.25, animations: {
            self.blurEffectView.alpha = 0
        }) { _ in
            self.blurEffectView.removeFromSuperview()
        }
        
        if (precisaTroco != nil){
            
            if (precisaTroco!){
                self.trocoPara = troco!
            } else {
                self.trocoPara = -1.0
            }
        } else {
            pagueNaEntregaTipo = ""
            self.trocoPara = 0.0
        }
        
        self.oTable.reloadData()
    }
    
    @IBAction func prosseguir(){
        if (pagueNaEntregaTipo == ""){
            let popup = PopupDialog(title: "Ops!", message: "Você não selecionou uma opção de pagamento na entrega")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        
        if (pagueNaEntregaTipo.contains("dinheiro")){
            if (trocoPara > 0.0){
                self.delegate.retornaPagueNaEntrega(adicionalPagueNaEntrega: "(Dinheiro)", tipo: pagueNaEntregaTipo, precisaTroco: true, trocoPara: trocoPara)
            } else if (trocoPara == -1.0){
                self.delegate.retornaPagueNaEntrega(adicionalPagueNaEntrega: "(Dinheiro)", tipo: pagueNaEntregaTipo, precisaTroco: false, trocoPara: nil)
            }
        } else if (pagueNaEntregaTipo.contains("mastercard")){
            self.delegate.retornaPagueNaEntrega(adicionalPagueNaEntrega: "(Mastercard)", tipo: pagueNaEntregaTipo, precisaTroco: false, trocoPara: nil)
        } else if (pagueNaEntregaTipo.contains("visa")){
            self.delegate.retornaPagueNaEntrega(adicionalPagueNaEntrega: "(Visa)", tipo: pagueNaEntregaTipo, precisaTroco: false, trocoPara: nil)
        } else if (pagueNaEntregaTipo.contains("elo")){
            self.delegate.retornaPagueNaEntrega(adicionalPagueNaEntrega: "(Elo)", tipo: pagueNaEntregaTipo, precisaTroco: false, trocoPara: nil)
        } else {
            self.delegate.retornaPagueNaEntrega(adicionalPagueNaEntrega: "(Amex)", tipo: pagueNaEntregaTipo, precisaTroco: false, trocoPara: nil)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}


class Dinheiro: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var botaoProsseguir: TransitionButton!
    @IBOutlet weak var holderTroco: UIView!
    @IBOutlet weak var troco: UITextField!
    @IBOutlet weak var simUpper: UIView!
    @IBOutlet weak var simInside: UIView!
    @IBOutlet weak var naoUpper: UIView!
    @IBOutlet weak var naoInside: UIView!
    @IBOutlet weak var subtitulo: UITextView!
    
    
    var precisaDeTroco = false
    var delegate: PagueNaEntrega!
    
    var frameInicialViewHolder: CGRect!
    
    var trocoPara = 0.0
    var valorCompra: Double!
    
    static func inicializeDinheiro(valorCompra: Double, delegate: PagueNaEntrega) -> Dinheiro{
        let tela = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "Dinheiro") as! Dinheiro
        tela.delegate = delegate
        tela.valorCompra = valorCompra
        return tela
    }
    
    @IBAction func fechar(){
        self.delegate.retornaTroco(precisaTroco: nil, troco: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func fecharKeyboard(){
        self.view.endEditing(true)
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
        
        botaoProsseguir.spinnerColor = UIColor.white
        botaoProsseguir.cornerRadius = botaoProsseguir.frame.height/2
        botaoProsseguir.backgroundColor = hexStringToUIColor("#4BC562")
        
        simUpper.layer.cornerRadius = simUpper.frame.height/2
        simUpper.layer.borderWidth = 2.0
        simUpper.backgroundColor = UIColor.clear
        simUpper.layer.borderColor = hexStringToUIColor("#0B6AB0").cgColor
        
        simInside.layer.cornerRadius = simInside.frame.height/2
        
        naoUpper.layer.cornerRadius = naoUpper.frame.height/2
        naoUpper.layer.borderWidth = 2.0
        naoUpper.backgroundColor = UIColor.clear
        naoUpper.layer.borderColor = hexStringToUIColor("#0B6AB0").cgColor
        
        naoInside.layer.cornerRadius = naoInside.frame.height/2
        
        atribuirPlaceholder(textField: troco, name: "Ex.: R$ 50")
        frameInicialViewHolder = holder.frame
        
        
        self.naoInside.backgroundColor = hexStringToUIColor("#0B6AB0")
        self.holderTroco.alpha = 0.4
        self.troco.isEnabled = false
        
        troco.delegate = self
        
        let texto = "Vai precisar de troco? O valor da sua compra é \(formatarPreco(preco: valorCompra))"
        let attributedTexto = NSMutableAttributedString(string: texto)
        attributedTexto.addAttribute(.font, value: UIFont(name: "CeraRoundPro-Regular", size: 14.0)!, range: NSRange(location: 0, length: texto.count))
        attributedTexto.addAttribute(.font, value: UIFont(name: "CeraRoundPro-Bold", size: 14.0)!, range: NSRange(location: 46, length: (texto.count - 46)))
        subtitulo.attributedText = attributedTexto
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func atribuirPlaceholder(textField: UITextField, name: String){
        var placeHolder = NSMutableAttributedString()
        placeHolder = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont(name: "Ubuntu-Light", size: 18.0)!])
        placeHolder.addAttribute(NSAttributedString.Key.foregroundColor, value: hexStringToUIColor("#939393"), range: NSRange(location:0, length: name.count))
        textField.attributedPlaceholder = placeHolder
    }
    
    @IBAction func setarTroco(sender: UIControl?){
        if (sender != nil){
            if (sender!.tag == 0){
                //credito
                precisaDeTroco = false
            } else {
                //debito
                precisaDeTroco = true
            }
        }
        
        simInside.backgroundColor = UIColor.white
        naoInside.backgroundColor = UIColor.white
        
        self.view.endEditing(true)
        
        UIView.animate(withDuration: 0.25) { [self] in
            if (self.precisaDeTroco){
                self.simInside.backgroundColor = hexStringToUIColor("#0B6AB0")
                self.holderTroco.alpha = 1.0
                self.troco.isEnabled = true
            }
            if (!self.precisaDeTroco){
                self.naoInside.backgroundColor = hexStringToUIColor("#0B6AB0")
                self.holderTroco.alpha = 0.4
                self.troco.isEnabled = false
            }
        }
    }
    
    @IBAction func prosseguir(){
        
        if (precisaDeTroco){
            let valorDigitado = NSString(string: (self.troco.text?.replacingOccurrences(of: "R$", with: "").replacingOccurrences(of: " ", with: ""))!).doubleValue
            
            print("valorDigitado: \(valorDigitado)")
            
            if (valorDigitado > valorCompra){
                self.dismiss(animated: true, completion: nil)
                self.delegate.retornaTroco(precisaTroco: precisaDeTroco, troco: valorDigitado)
            } else {
                let popup = PopupDialog(title: "Ops!", message: "O valor inserido para troco é menor que o valor da sua compra (que é de \(formatarPreco(preco: valorCompra)))")
                popup.buttonAlignment = .horizontal
                popup.transitionStyle = .bounceUp
                let button = CancelButton(title: "Ok", action: {
                })
                popup.addButton(button)
                // Present dialog
                self.present(popup, animated: true, completion: nil)
                return
            }
            
        } else {
            self.dismiss(animated: true, completion: nil)
            self.delegate.retornaTroco(precisaTroco: precisaDeTroco, troco: nil)
        }
    }
    
    @IBAction func returnClicked(){
        self.view.endEditing(true)
    }
    
    //KEYBOARD OBSERVERS
    @objc func keyboardWillHide(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let _ = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                UIView.animate(withDuration: 0.25, animations: {
                    self.holder.frame = CGRect(x: (self.frameInicialViewHolder?.origin.x)!, y: (self.frameInicialViewHolder?.origin.y)! - 50.0, width: (self.frameInicialViewHolder?.width)!, height: (self.frameInicialViewHolder?.height)!)
                })
            }
        }
    }
    @objc func keyboardWillShow(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let keyboardHeight2 = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                //This is keyboard Height
                UIView.animate(withDuration: 0.25, animations: {
                    self.holder.frame = CGRect(x: (self.frameInicialViewHolder?.origin.x)!, y: (self.frameInicialViewHolder?.origin.y)! - keyboardHeight2 - 60.0, width: (self.frameInicialViewHolder?.width)!, height: (self.frameInicialViewHolder?.height)!)
                })
            }
        }
    }
    //
}
