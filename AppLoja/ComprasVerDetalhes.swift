//
//  ComprasVerDetalhes.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 23/03/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import UIKit
import InteractiveSideMenu
import SHSearchBar
import TransitionButton
import NVActivityIndicatorView
import DynamicBlurView
import Parse
import PopupDialog
import DynamicBlurView

protocol ComprasVerDetalhesDelegate {
    func onExit()
}

class ComprasVerDetalhes: UIViewController, UITableViewDelegate, UITableViewDataSource, ObrigadoDelegate {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var oTable: UITableView!
    @IBOutlet weak var botaoFechar: TransitionButton!
    @IBOutlet weak var botaoVerNf: TransitionButton!
    @IBOutlet weak var taxaDeEntrega: UILabel!
    @IBOutlet weak var valorPago: UILabel!
    @IBOutlet weak var parceladoEm: UILabel!
    
    var delegate: ComprasVerDetalhesDelegate!
    var produtosManual = [[String : Any]]()
    var produtos: [String : Produto]!
    var compra: Compra!
    var semImagem: UIImage!
    
    static func inicializeComprasVerDetalhes(compra: Compra, produtos: [String : Produto], produtosManual: [[String : Any]], delegate: ComprasVerDetalhesDelegate) -> ComprasVerDetalhes{
        let car = MAIN_STORYBOARD.instantiateViewController(identifier: "ComprasVerDetalhes") as! ComprasVerDetalhes
        car.delegate = delegate
        car.produtosManual = produtosManual
        car.produtos = produtos
        car.compra = compra
        return car
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
        
        oTable.backgroundColor = UIColor.clear
        
        botaoFechar.spinnerColor = UIColor.white
        botaoFechar.cornerRadius = botaoFechar.frame.height/2
        botaoFechar.backgroundColor = hexStringToUIColor("#EF343A")
        
        botaoVerNf.spinnerColor = UIColor.white
        botaoVerNf.cornerRadius = botaoVerNf.frame.height/2
        botaoVerNf.backgroundColor = hexStringToUIColor("#4BC562")
        
        taxaDeEntrega.text = formatarPreco(preco: compra.freteCobrado)
        valorPago.text = formatarPreco(preco: compra.precoTotal)
        if (compra.parcelas == 1){
            parceladoEm.text = "(Pago em 1x)"
        } else {
            parceladoEm.text = "(Parcelado em \(compra.parcelas!)x)"
        }
        
        semImagem = UIImage(named: "semimagem.jpg")
        
        
        if (compra.formaDePagamento == "boleto" && !compra.compraPaga){
            botaoVerNf.setTitle("Ver meu boleto", for: [])
        } else if (compra.formaDePagamento == "transferencia" && !compra.compraPaga){
            botaoVerNf.setTitle("Ver dados para transferência", for: [])
        } else {
            botaoVerNf.setTitle("Ver minha nota fiscal", for: [])
        }
    }
    
    var blurEffectView: UIView!
    @IBAction func verMinhaNF(){
        
        if (compra.notaFiscal == nil && compra.compraPaga){
            let popup = PopupDialog(title: "Ops!", message: "Sua nota fiscal ainda não foi emitida. Te avisaremos quando sua NF estiver pronta!")
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
        
        if (compra.formaDePagamento == "boleto" && !compra.compraPaga){
            let nf = ObrigadoBoleto.inicializeObrigado(boleto: compra.boleto, delegate: self)
            self.present(nf, animated: true, completion: {
                blurView.trackingMode = .none
            })
        } else if (compra.formaDePagamento == "transferencia" && !compra.compraPaga){
            let nf = ObrigadoTransferencia.inicializeObrigado(valor: compra.precoTotal, delegate: self)
            self.present(nf, animated: true, completion: {
                blurView.trackingMode = .none
            })
        } else {
            let nf = NotaFiscal.inicializeNotaFiscal(compra: compra, delegate: self)
            self.present(nf, animated: true, completion: {
                blurView.trackingMode = .none
            })
        }
        
    }
    
    func onExitObrigado() {
        UIView.animate(withDuration: 0.25, animations: {
            self.blurEffectView.alpha = 0
        }) { _ in
            self.blurEffectView.removeFromSuperview()
        }
    }
    
    @IBAction func fechar(){
        self.delegate.onExit()
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return produtosManual.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaItemCarrinho") as! CelulaItemCarrinho
        
        cell.holder.layer.shadowColor = hexStringToUIColor("#D9E0D9").cgColor
        cell.holder.layer.shadowOpacity = 2
        cell.holder.layer.shadowOffset = .zero
        cell.holder.layer.shadowRadius = 4
        
        cell.backgroundColor = UIColor.clear
        
        let produto = produtosManual[indexPath.row]
        
        cell.marca.text = (produto["marca"] as? String)
        let precoUnitario = (produto["precoUnitario"] as! Double)
        let quantidade = (produto["quantidade"] as! Int)
        let total = precoUnitario*Double(quantidade)
        cell.preco.text = formatarPreco(preco: total)
        cell.quantidade.text = "\(quantidade)x"
        
        let produtoId = (produto["produtoId"] as! String)
        
        if (produtos.keys.contains(produtoId)){
            produtos[produtoId]!.retornaImagem(imageView: cell.imagem, loader: cell.loader)
        } else {
            cell.imagem.image = semImagem
        }
        
        let descricaoProd = (produto["descricao"] as! String)
        var subdescricaoProd = (produto["subdescricao"] as? String)
        
        var texto = ""
        if (subdescricaoProd == nil){
            subdescricaoProd = ""
        }
        texto = "\(descricaoProd)\n\(subdescricaoProd!)"
        let attributedTexto = NSMutableAttributedString(string: texto)
        attributedTexto.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: descricaoProd.count))
        
        attributedTexto.addAttribute(.foregroundColor, value: hexStringToUIColor("#0C5985"), range: NSRange(location: descricaoProd.count, length: subdescricaoProd!.count+1))
        attributedTexto.addAttribute(.font, value: UIFont(name: "Ubuntu-Regular", size: 12.0)!, range: NSRange(location: 0, length: descricaoProd.count))
        attributedTexto.addAttribute(.font, value: UIFont(name: "Ubuntu-Medium", size: 12.0)!, range: NSRange(location: descricaoProd.count, length: subdescricaoProd!.count+1))
        
        cell.descricao.attributedText = attributedTexto
        
        return cell
        
    }
    
   
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 127.0
    }
    
    
}
