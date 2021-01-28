//
//  LimveCreditos.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 10/12/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import Foundation
import UIKit
import Parse
import Lottie
import GhostTypewriter
import PopupDialog
import TransitionButton
import NVActivityIndicatorView
import FacebookShare

class LimveCreditos: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var holderCodigo: UIView!
    @IBOutlet weak var limveCreditosLabel: UILabel!
    @IBOutlet weak var descricaoLabel: UILabel!
    @IBOutlet weak var codigoLabel: TypewriterLabel!
    @IBOutlet weak var oTable: UITableView!
    @IBOutlet weak var saldo: UILabel!
    @IBOutlet weak var holderHeader: UIView!
    
    @IBOutlet weak var whatsappAnim: UIView!
    @IBOutlet weak var facebookAnim: UIView!
    @IBOutlet weak var qrcodeAnim: UIView!
    @IBOutlet weak var moreAnim: UIView!
    
    @IBOutlet weak var loader: UIView!
    
    var codigo = ""
    var extratos = [PFObject]()
    var refreshControl: UIRefreshControl!
    
    static func inicializeLimveCreditos() -> LimveCreditos{
        let tela = MAIN_STORYBOARD.instantiateViewController(identifier: "LimveCreditos") as! LimveCreditos
        return tela
    }
    
    @IBAction func fechar(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (PFUser.current()!["codLimveCreditos"] == nil){
            codigo = "limve_\(PFUser.current()!.objectId!)"
        } else {
            codigo = (PFUser.current()!["codLimveCreditos"] as! String)
        }
        
        holderCodigo.layer.cornerRadius = 16.0
        holderCodigo.layer.shadowColor = hexStringToUIColor("#000").withAlphaComponent(0.25).cgColor
        holderCodigo.layer.shadowOpacity = 3
        holderCodigo.layer.shadowOffset = .zero
        holderCodigo.layer.shadowRadius = 6
        
        codigoLabel.text = codigo
        codigoLabel.typingTimeInterval = 0.12
        codigoLabel.animationStyle = .reveal
        codigoLabel.startTypewritingAnimation()
        
        let texto = "LimveCréditos"
        let attributedTexto = NSMutableAttributedString(string: texto)
        attributedTexto.addAttribute(.font, value: UIFont(name: "Ubuntu-Bold", size: 26.0)!, range: NSRange(location: 0, length: 5))
        attributedTexto.addAttribute(.font, value: UIFont(name: "Ubuntu-Light", size: 26.0)!, range: NSRange(location: 5, length: 8))
        
        limveCreditosLabel.attributedText = attributedTexto
        
        let textoDescricao = "Ganhe R$30 para cada amigo que completar o primeiro pedido com a Limve, utilizando seu código! Seus amigos também ganharão R$35 no primeiro pedido conosco."
        let attributedTexto2 = NSMutableAttributedString(string: textoDescricao)
        attributedTexto2.addAttribute(.font, value: UIFont(name: "Ubuntu-Light", size: 14.0)!, range: NSRange(location: 0, length: textoDescricao.count))
        attributedTexto2.addAttribute(.font, value: UIFont(name: "Ubuntu-Bold", size: 14.0)!, range: NSRange(location: 87, length: 6))
        
        descricaoLabel.attributedText = attributedTexto2
        
        var saldoDou = 0.0
        if (PFUser.current()!["saldoLimveCreditos"] != nil){
            saldoDou = (PFUser.current()!["saldoLimveCreditos"] as! Double)
        }
        let saldoStr = "Seu saldo: \(formatarPreco(preco: saldoDou))"
        let attributedTexto3 = NSMutableAttributedString(string: saldoStr)
        attributedTexto3.addAttribute(.font, value: UIFont(name: "Ubuntu-Regular", size: 15.0)!, range: NSRange(location: 0, length: saldoStr.count))
        attributedTexto3.addAttribute(.font, value: UIFont(name: "Ubuntu-Bold", size: 20.0)!, range: NSRange(location: 11, length: (saldoStr.count - 11)))
        
        
        saldo.attributedText = attributedTexto3
        oTable.tableHeaderView = holderHeader
        
        
        let animationMore = AnimationView(name: "more")
        animationMore.loopMode = .playOnce
        animationMore.animationSpeed = 0.7
        animationMore.frame = CGRect(x: -60, y: -55, width: moreAnim.frame.width+120, height: moreAnim.frame.height+120)
        animationMore.contentMode = .scaleAspectFill
        moreAnim.addSubview(animationMore)
        animationMore.play(toProgress: 0.95)
        
        
        let animationWhats = AnimationView(name: "whatsapp")
        animationWhats.loopMode = .playOnce
        animationWhats.animationSpeed = 0.7
        animationWhats.frame = CGRect(x: 0, y: 0, width: whatsappAnim.frame.width, height: whatsappAnim.frame.height)
        animationWhats.contentMode = .scaleAspectFill
        whatsappAnim.addSubview(animationWhats)
        animationWhats.play()
        
        let animationFB = AnimationView(name: "facebook")
        animationFB.loopMode = .playOnce
        animationFB.animationSpeed = 0.7
        animationFB.frame = CGRect(x: 0, y: 0, width: facebookAnim.frame.width, height: facebookAnim.frame.height)
        animationFB.contentMode = .scaleAspectFill
        facebookAnim.addSubview(animationFB)
        animationFB.play()
        
        let animationQR = AnimationView(name: "qrcode2")
        animationQR.loopMode = .playOnce
        animationQR.animationSpeed = 2.0
        animationQR.frame = CGRect(x: 0, y: 0, width: qrcodeAnim.frame.width, height: qrcodeAnim.frame.height)
        animationQR.contentMode = .scaleAspectFill
        qrcodeAnim.addSubview(animationQR)
        animationQR.play()
        
        
        loader.backgroundColor = UIColor.clear
        let nv = NVActivityIndicatorView(frame: CGRect(origin: .zero, size: loader.frame.size), type: NVActivityIndicatorType.lineSpinFadeLoader, color: hexStringToUIColor("#000"), padding: 15.0)
        loader.backgroundColor = UIColor.clear
        loader.addSubview(nv)
        nv.startAnimating()
        
        oTable.isHidden = true
        
        carregar()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Atualizar")
        refreshControl.addTarget(self, action: #selector(self.carregar), for: .valueChanged)
        oTable.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    @objc func carregar(){
        DispatchQueue.global().async {
            do {
                let extratosQ = PFQuery(className: "LimveCreditos")
                extratosQ.limit = 1000
                extratosQ.addDescendingOrder("createdAt")
                self.extratos = try extratosQ.findObjects()
                
                DispatchQueue.main.async {
                    self.oTable.reloadData()
                    self.loader.isHidden = true
                    self.oTable.isHidden = false
                    self.refreshControl.endRefreshing()
                }
            } catch {
                
            }
        }
    }
    
    @IBAction func copiar(){
        UIPasteboard.general.string = "https://limve.app.link/compartilhar?cupom=\(codigo)"
        
        let popup = PopupDialog(title: "Copiado!", message: "O código \(codigo) foi copiado para seu dispositivo. Compartilhe com seus amigos para ganhar prêmios!")
        popup.buttonAlignment = .horizontal
        popup.transitionStyle = .bounceUp
        let button = CancelButton(title: "Ok", action: {
        })
        popup.addButton(button)
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    
    @IBAction func whatsappShare(){
        let url = "whatsapp://send?text=Ei! Quer ganhar R$35 para gastar em itens de limpeza doméstica e higiene pessoal? Clique no link, faça o Download da Limve e use meu cupom! Uhul.\nhttps://limve.app.link/compartilhar?cupom=\(codigo)"
        
        if let urlString = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            if let whatsappURL = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL) {
                    UIApplication.shared.openURL(whatsappURL)
                } else {
                    print("Install Whatsapp")
                }
            }
        }
    }
    
    @IBAction func facebookShare(){
        let shareContent = ShareLinkContent()
        shareContent.contentURL = URL.init(string: "https://limve.app.link/compartilhar?cupom=\(codigo)")!
        shareContent.quote = "Ei! Quer ganhar R$35 para gastar em itens de limpeza doméstica e higiene pessoal? Clique no link, faça o Download da Limve e use meu cupom! Uhul."
        ShareDialog(fromViewController: self, content: shareContent, delegate: nil).show()
    }
    
    @IBAction func moreShare(){
        let ac = UIActivityViewController(activityItems: ["Ei! Quer ganhar R$35 para gastar em itens de limpeza doméstica e higiene pessoal? Clique no link, faça o Download da Limve e use meu cupom! Uhul.\n https://limve.app.link/compartilhar?cupom=\(codigo)"], applicationActivities: nil)
        self.present(ac, animated: true, completion: nil)
    }
    
    @IBAction func qrCodeShare(){
        let limveqr = LimveQR.inicializeLimveQR(meuCodigo: codigo)
        self.present(limveqr, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return extratos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaItemLimveCreditos") as! CelulaItemLimveCreditos
        
        cell.holder.layer.shadowColor = hexStringToUIColor("#000").withAlphaComponent(0.3).cgColor
        cell.holder.layer.shadowOpacity = 3
        cell.holder.layer.shadowOffset = .zero
        cell.holder.layer.shadowRadius = 3
        
        cell.backgroundColor = UIColor.clear
        
        if (indexPath.row == 0){
            //topo
            cell.holder.frame = CGRect(x: cell.holder.frame.origin.x, y: 6, width: cell.holder.frame.width, height: 64.0)
            //cell.holder.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
        } else if (indexPath.row == (oTable.numberOfRows(inSection: 0) - 1)){
            //vale
            cell.holder.frame = CGRect(x: cell.holder.frame.origin.x, y: 0, width: cell.holder.frame.width, height: 64.0)
            //cell.holder.roundCorners(corners: [.allCorners], radius: 0.0)
        } else {
            //meio
            cell.holder.frame = CGRect(x: cell.holder.frame.origin.x, y: 0, width: cell.holder.frame.width, height: 70.0)
            //cell.holder.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10.0)
        }
        
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        cell.data.text = df.string(from: extratos[indexPath.row].createdAt!)
        let valor = (extratos[indexPath.row]["valor"] as! Double)
        if (valor > 0){
            cell.valor.text = "+\(formatarPreco(preco: valor))"
        } else {
            cell.valor.text = formatarPreco(preco: valor)
        }
        
        if (extratos[indexPath.row]["textoQualquer"] != nil){
            cell.texto.text = (extratos[indexPath.row]["textoQualquer"] as! String)
        } else {
            cell.texto.text = "Crédito de cupom: Nova compra | Indicação: \(extratos[indexPath.row]["nomePessoaIndicada"] as! String)"
        }
        
        if (extratos[indexPath.row]["isCredito"] as! Bool){
            cell.imagem.image = UIImage(named: "income")
        } else {
            cell.imagem.image = UIImage(named: "decrease")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
}

class CelulaItemLimveCreditos: UITableViewCell {
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var imagem: UIImageView!
    @IBOutlet weak var texto: UILabel!
    @IBOutlet weak var data: UILabel!
    @IBOutlet weak var valor: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
