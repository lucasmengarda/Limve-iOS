//
//  MinhasCompras.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 03/03/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import UIKit
import InteractiveSideMenu
import TransitionButton
import Parse
import NVActivityIndicatorView
import DynamicBlurView

class MinhasCompras: UIViewController, SideMenuItemContent, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LoginCadastrarDelegate, ComprasVerDetalhesDelegate {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var loader: UIView!
    @IBOutlet weak var holderAvisoSemResultados: UIView!
    @IBOutlet weak var holderAvisoUsuarioNaoEncontrado: UIView!
    @IBOutlet weak var botaoCadastrarme: TransitionButton!
    @IBOutlet weak var botaoJaSouCadastrado: TransitionButton!
    @IBOutlet weak var collectionView: UICollectionView!

    var widthCell: Double!
    var frameOriginalHolderAviso: CGRect!
    var frameOriginalHolderAvisoUsuario: CGRect!
    
    var compras = [Compra]()
    
    static func inicializeMinhasCompras() -> MinhasCompras{
        let tela = MAIN_STORYBOARD.instantiateViewController(identifier: "MinhasCompras") as! MinhasCompras
        return tela
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        holder.layer.cornerRadius = 16.0
        holder.clipsToBounds = false
        holderAvisoSemResultados.isHidden = true
        holderAvisoUsuarioNaoEncontrado.isHidden = true
        frameOriginalHolderAviso = holderAvisoSemResultados.frame
        frameOriginalHolderAvisoUsuario = holderAvisoUsuarioNaoEncontrado.frame
        
        holder.layer.shadowColor = hexStringToUIColor("#00224B").cgColor
        holder.layer.shadowOpacity = 6
        holder.layer.shadowOffset = .zero
        holder.layer.shadowRadius = 10
        
        botaoJaSouCadastrado.spinnerColor = UIColor.white
        botaoJaSouCadastrado.cornerRadius = botaoJaSouCadastrado.frame.height/2
        botaoJaSouCadastrado.backgroundColor = hexStringToUIColor("#406EBD")
        botaoCadastrarme.spinnerColor = UIColor.white
        botaoCadastrarme.cornerRadius = botaoCadastrarme.frame.height/2
        botaoCadastrarme.backgroundColor = hexStringToUIColor("#2E4F88")
        
        widthCell = Double((UIScreen.main.bounds.size.width - 16.0)/2)
        
        collectionView.isHidden = true
        
        loader.backgroundColor = UIColor.clear
        let nv = NVActivityIndicatorView(frame: CGRect(origin: .zero, size: loader.frame.size), type: NVActivityIndicatorType.ballClipRotateMultiple, color: hexStringToUIColor("#3C65D1"), padding: 15.0)
        loader.backgroundColor = UIColor.clear
        loader.addSubview(nv)
        nv.startAnimating()
        
        
        DispatchQueue.global(qos: .background).async {
            do {
                
                /*
                if (!isUserLoggedIn()){
                    DispatchQueue.main.async {
                        self.holderAvisoUsuarioNaoEncontrado.frame = CGRect(x: -self.holderAvisoUsuarioNaoEncontrado.frame.width, y: self.holderAvisoUsuarioNaoEncontrado.frame.origin.y, width: self.holderAvisoUsuarioNaoEncontrado.frame.width, height: self.holderAvisoUsuarioNaoEncontrado.frame.height)
                        self.holderAvisoUsuarioNaoEncontrado.isHidden = false
                        UIView.animate(withDuration: 0.35) {
                            self.holderAvisoUsuarioNaoEncontrado.frame = CGRect(x: self.frameOriginalHolderAvisoUsuario.origin.x, y: self.holderAvisoUsuarioNaoEncontrado.frame.origin.y, width: self.holderAvisoUsuarioNaoEncontrado.frame.width, height: self.holderAvisoUsuarioNaoEncontrado.frame.height)
                        self.loader.isHidden = true
                        }
                    }
                    return
                }
 */
                
                let query = PFQuery(className: "Compras").addDescendingOrder("createdAt")
                let comprasObj = try query.findObjects()
                self.compras.removeAll()
                for compra in comprasObj {
                    let newCompra = Compra(compra: compra)
                    let prod = (compra["produtos"] as! PFRelation)
                    let prods = try prod.query().findObjects()
                    newCompra.setProdutosArr(produtos: prods)
                    self.compras.append(newCompra)
                }
                
                DispatchQueue.main.async {
                    if (self.compras.count == 0){
                        self.holderAvisoSemResultados.frame = CGRect(x: -self.holderAvisoSemResultados.frame.width, y: self.holderAvisoSemResultados.frame.origin.y, width: self.holderAvisoSemResultados.frame.width, height: self.holderAvisoSemResultados.frame.height)
                        self.holderAvisoSemResultados.isHidden = false
                        UIView.animate(withDuration: 0.35) {
                            self.holderAvisoSemResultados.frame = CGRect(x: self.frameOriginalHolderAviso.origin.x, y: self.holderAvisoSemResultados.frame.origin.y, width: self.holderAvisoSemResultados.frame.width, height: self.holderAvisoSemResultados.frame.height)
                        }
                    } else {
                        self.holderAvisoSemResultados.isHidden = true
                        self.collectionView.reloadData()
                        self.collectionView.isHidden = false
                    }
                    self.loader.isHidden = true
                }
            } catch {
                
            }
        }
        
    }
    
    var blurEffectView: UIView!
    
    @IBAction func login(){
        
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
        
        let login = LoginController.inicializeLoginController(delegate: self)
        self.present(login, animated: true, completion: {
            blurView.trackingMode = .none
        })
    }
    
    @IBAction func cadastrarse(){
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
        
        let cadastrar = CadastrarController.inicializeCadastrarController(delegate: self)
        self.present(cadastrar, animated: true, completion: {
            blurView.trackingMode = .none
        })
    }
    
    func onExit(sussecefull: Bool) {
        UIView.animate(withDuration: 0.25, animations: {
            self.blurEffectView.alpha = 0
        }) { _ in
            self.blurEffectView.removeFromSuperview()
        }
        
        if (sussecefull){
            if (isUserLoggedIn()){
                NavigationMenuViewController.myVC.loginButton.isHidden = true
                NavigationMenuViewController.myVC.cadastrarButton.isHidden = true
                NavigationMenuViewController.myVC.sejaBemVindoLabel.text = "Seja bem-vindo(a),"
                NavigationMenuViewController.myVC.nomeLabel.text = formatarNomeDoUsuario()
                NavigationMenuViewController.myVC.segundoNomeLabel.text = formatarNomeDoUsuario()
            } else {
                NavigationMenuViewController.myVC.loginButton.isHidden = false
                NavigationMenuViewController.myVC.cadastrarButton.isHidden = false
                NavigationMenuViewController.myVC.sejaBemVindoLabel.text = "Identifique-se"
                NavigationMenuViewController.myVC.nomeLabel.text = ""
                NavigationMenuViewController.myVC.segundoNomeLabel.text = ""
            }
        }
    }
    
    
    @IBAction func abrirMenu(){
        self.view.endEditing(true)
        showSideMenu()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return compras.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
      //  let totalCellWidth = widthCell * 2
        //let totalSpacingWidth: Double = 5 * (2 - 1)
        
        //let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        //let rightInset = leftInset
        
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CelulaCompra", for: indexPath as IndexPath) as! CelulaCompra
        
        cell.backgroundColor = UIColor.clear
        
        cell.holder.layer.cornerRadius = 6.0
        
        cell.holder.layer.shadowColor = hexStringToUIColor("#D9E0D9").cgColor
        cell.holder.layer.shadowOpacity = 2
        cell.holder.layer.shadowOffset = .zero
        cell.holder.layer.shadowRadius = 4
        
        cell.botaoVerDetalhes.spinnerColor = UIColor.white
        cell.botaoVerDetalhes.cornerRadius = cell.botaoVerDetalhes.frame.height/2
        cell.botaoVerDetalhes.tag = indexPath.item
        cell.botaoVerDetalhes.backgroundColor = hexStringToUIColor("#4BC562")
        cell.botaoVerDetalhes.addTarget(self, action: #selector(self.verDetalhes(sender:)), for: .touchUpInside)
        
        //__//
        
        let compra = compras[indexPath.item]
        
        if (compra.formaDePagamento == "boleto"){
            cell.bandeiraCartao.image = UIImage(named: "barcode.png")
            if (compra.boletoId == "cancelado"){
                cell.finalCartao.text = "cancelado"
                cell.finalCartao.textColor = .red
            } else {
                if (compra.compraPaga){
                    cell.finalCartao.text = "aprovado"
                    cell.finalCartao.textColor = .green
                } else {
                    cell.finalCartao.text = "pendente"
                    cell.finalCartao.textColor = .orange
                }
            }
        } else if (compra.formaDePagamento == "transferencia"){
            cell.bandeiraCartao.image = UIImage(named: "transferencia.png")
            if (compra.compraPaga){
                cell.finalCartao.text = "transferido"
                cell.finalCartao.textColor = .green
            } else {
                cell.finalCartao.text = "pendente"
                cell.finalCartao.textColor = .orange
            }
        } else if (compra.formaDePagamento == "auxilio"){
            cell.bandeiraCartao.image = UIImage(named: "auxilioemergencial.png")
            cell.finalCartao.text = "aprovado"
            cell.finalCartao.textColor = .green
        } else if (compra.formaDePagamento.contains("entrega")){
            cell.bandeiraCartao.image = UIImage(named: "delivery.png")
            cell.finalCartao.text = "pgto entrega"
            cell.finalCartao.textColor = .black
        } else {
            if (compra.cartaoCobradoBandeira == "Master"){
                cell.bandeiraCartao.image = UIImage(named: "mastercard.png")
            } else if (compra.cartaoCobradoBandeira == "Visa"){
                cell.bandeiraCartao.image = UIImage(named: "visa.png")
            } else if (compra.cartaoCobradoBandeira == "Elo"){
                cell.bandeiraCartao.image = UIImage(named: "elo.png")
            } else if (compra.cartaoCobradoBandeira == "Amex"){
                cell.bandeiraCartao.image = UIImage(named: "amex.png")
            } else {
                cell.bandeiraCartao.image = UIImage(named: "outrocartao.png")
            }
            cell.finalCartao.text = "final \(compra.cartaoCobradoFinal!)"
            cell.finalCartao.textColor = .black
        }
        
        cell.preco.text = formatarPreco(preco: compra.precoTotal)
        if (compra.cestaDeProdutos.count == 1){
            cell.quantidadeProdutos.text = "1 produto"
        } else {
            cell.quantidadeProdutos.text = "\(compra.cestaDeProdutos.count) produtos"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "HH:mm"
        
        cell.data.text = "\(formatter.string(from: compra.data)) às \(formatter2.string(from: compra.data))"
        
        return cell
    }
    
    @objc func verDetalhes(sender: TransitionButton){
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
        
        let cvd = ComprasVerDetalhes.inicializeComprasVerDetalhes(compra: compras[sender.tag], produtos: compras[sender.tag].produtosArr, produtosManual: compras[sender.tag].cestaDeProdutos, delegate: self)
        self.present(cvd, animated: true, completion: {
            blurView.trackingMode = .none
        })
    }
    
    func onExit() {
        UIView.animate(withDuration: 0.25, animations: {
            self.blurEffectView.alpha = 0
        }) { _ in
            self.blurEffectView.removeFromSuperview()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let widthScreen = UIScreen.main.bounds.size.width
        let square = (widthScreen - 16.0)/2 //30 é referente ao espaçamento entre celulas
        
        return CGSize(width: square, height: CGFloat(233.0))
    }
}

class CelulaCompra: UICollectionViewCell {
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var bandeiraCartao: UIImageView!
    @IBOutlet weak var finalCartao: UILabel!
    @IBOutlet weak var quantidadeProdutos: UILabel!
    @IBOutlet weak var preco: UILabel!
    @IBOutlet weak var data: UILabel!
    @IBOutlet weak var botaoVerDetalhes: TransitionButton!
}

