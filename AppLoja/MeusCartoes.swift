//
//  MeusCartoes.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 28/02/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import UIKit
import InteractiveSideMenu
import TransitionButton
import Parse
import NVActivityIndicatorView
import DynamicBlurView

class MeusCartoes: UIViewController, SideMenuItemContent, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LoginCadastrarDelegate, AdicionarCartaoDelegate {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var loader: UIView!
    @IBOutlet weak var holderAvisoSemResultados: UIView!
    @IBOutlet weak var holderAvisoUsuarioNaoEncontrado: UIView!
    @IBOutlet weak var botaoCadastrarme: TransitionButton!
    @IBOutlet weak var botaoJaSouCadastrado: TransitionButton!
    @IBOutlet weak var botaoAdicionarCartao: TransitionButton!
    @IBOutlet weak var collectionView: UICollectionView!

    var widthCell: Double!
    var frameOriginalHolderAviso: CGRect!
    var frameOriginalHolderAvisoUsuario: CGRect!
    
    var cartoes = [Cartao]()
    
    static func inicializeMeusCartoes() -> MeusCartoes{
        let tela = MAIN_STORYBOARD.instantiateViewController(identifier: "MeusCartoes") as! MeusCartoes
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
        
        botaoAdicionarCartao.spinnerColor = UIColor.white
        botaoAdicionarCartao.cornerRadius = botaoAdicionarCartao.frame.height/2
        botaoAdicionarCartao.backgroundColor = hexStringToUIColor("#4BC562")
        botaoAdicionarCartao.addTarget(self, action: #selector(self.addCartao(sender:)), for: .touchUpInside)
        
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
        
        carregar()
    }
    
    func carregar(){
        DispatchQueue.global(qos: .background).async {
            do {
                
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
                
                let cartoesObj = try PFQuery(className: "Cartoes").findObjects()
                self.cartoes.removeAll()
                for cartao in cartoesObj {
                    let newCard = Cartao(cartao: cartao)
                    self.cartoes.append(newCard)
                }
                
                DispatchQueue.main.async {
                    if (self.cartoes.count == 0){
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
    
    func onExitCartao(sussecefull: Bool, cartao: Cartao!) {
        UIView.animate(withDuration: 0.25, animations: {
            self.blurEffectView.alpha = 0
        }) { _ in
            self.blurEffectView.removeFromSuperview()
        }
        
        if (sussecefull){
            self.loader.isHidden = false
            self.holderAvisoSemResultados.isHidden = true
            self.collectionView.isHidden = true
            
            DispatchQueue.global(qos: .background).async {
                do {
                    let cartoesObj = try PFQuery(className: "Cartoes").findObjects()
                    self.cartoes.removeAll()
                    for cartao in cartoesObj {
                        let newCard = Cartao(cartao: cartao)
                        self.cartoes.append(newCard)
                    }
                    
                    DispatchQueue.main.async {
                        self.holderAvisoSemResultados.isHidden = true
                        self.collectionView.reloadData()
                        self.collectionView.isHidden = false
                        self.loader.isHidden = true
                    }
                    
                } catch {
                    
                }
            }
        }
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
            
            loader.isHidden = false
            holderAvisoUsuarioNaoEncontrado.isHidden = true
            carregar()
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
        return cartoes.count + 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
      //  let totalCellWidth = widthCell * 2
        //let totalSpacingWidth: Double = 5 * (2 - 1)
        
        //let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        //let rightInset = leftInset
        
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (indexPath.item == cartoes.count){
             let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CelulaAddCartao", for: indexPath as IndexPath) as! CelulaAddCartao
            
            cell.holder.layer.cornerRadius = 6.0
            
            cell.holder.layer.shadowColor = hexStringToUIColor("#D9E0D9").cgColor
            cell.holder.layer.shadowOpacity = 2
            cell.holder.layer.shadowOffset = .zero
            cell.holder.layer.shadowRadius = 4
            
            cell.botaoAddCartao.spinnerColor = UIColor.white
            cell.botaoAddCartao.cornerRadius = cell.botaoAddCartao.frame.height/2
            cell.botaoAddCartao.backgroundColor = hexStringToUIColor("#4BC562")
            cell.botaoAddCartao.addTarget(self, action: #selector(self.addCartao(sender:)), for: .touchUpInside)
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CelulaCartao", for: indexPath as IndexPath) as! CelulaCartao
        
        cell.backgroundColor = UIColor.clear
        
        cell.holder.layer.cornerRadius = 6.0
        cell.imagem.layer.cornerRadius = 6.0
        cell.imagem.clipsToBounds = true
        
        cell.holder.layer.shadowColor = hexStringToUIColor("#D9E0D9").cgColor
        cell.holder.layer.shadowOpacity = 2
        cell.holder.layer.shadowOffset = .zero
        cell.holder.layer.shadowRadius = 4
        
        cell.botaoExcluirCartao.spinnerColor = UIColor.white
        cell.botaoExcluirCartao.cornerRadius = cell.botaoExcluirCartao.frame.height/2
        cell.botaoExcluirCartao.tag = indexPath.item
        cell.botaoExcluirCartao.backgroundColor = hexStringToUIColor("#4BC562")
        cell.botaoExcluirCartao.addTarget(self, action: #selector(self.excluirCartao(sender:)), for: .touchUpInside)
        
        //__//
        
        let cartao = cartoes[indexPath.item]
        
        if (cartao.bandeira == CartaoTipo.mastercard){
            cell.imagem.image = UIImage(named: "mastercard.png")
            cell.bandeiraCartao.text = "MasterCard"
        } else if (cartao.bandeira == CartaoTipo.visa){
            cell.imagem.image = UIImage(named: "visa.png")
            cell.bandeiraCartao.text = "Visa"
        } else if (cartao.bandeira == CartaoTipo.elo){
            cell.imagem.image = UIImage(named: "elo.png")
            cell.bandeiraCartao.text = "Elo"
        } else if (cartao.bandeira == CartaoTipo.amex){
            cell.imagem.image = UIImage(named: "amex.png")
            cell.bandeiraCartao.text = "American Express"
        } else {
            cell.imagem.image = UIImage(named: "outrocartao.png")
            cell.bandeiraCartao.text = cartao.bandeiraOutro
        }
        
        if (cartao.cartaoStyle == CartaoStyle.credito){
            cell.tipoCartao.text = "Crédito"
        } else {
            cell.tipoCartao.text = "Débito"
        }
        
        cell.finalCartao.text = "final \(cartao.final!)"
        cell.validadeCartao.text = "válido até \(cartao.validade!)"
        
        return cell
    }
    
    @objc func excluirCartao(sender: TransitionButton){
        
        sender.startAnimation()
        sender.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.25) {
            sender.backgroundColor = hexStringToUIColor("#EF343A")
            sender.setTitle("Confirma?", for: [])
            sender.addTarget(self, action: #selector(self.excluirCartaoConfirmado(sender:)), for: .touchUpInside)
        }
    }
    
    @objc func excluirCartaoConfirmado(sender: TransitionButton){
           
        let cartao = cartoes[sender.tag]
        cartao.excluirCartaoParaSempre()
        
        self.cartoes.remove(at: sender.tag)
        self.collectionView.deleteItems(at: [IndexPath(item: sender.tag, section: 0)])
        DispatchQueue.global(qos: .background).async {
            sleep(1)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
    }
    
    @objc func addCartao(sender: TransitionButton){
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
        
        let adicionar = AdicionarCartao.inicializeAdicionarCartao(delegate: self)
        self.present(adicionar, animated: true, completion: {
            blurView.trackingMode = .none
        })
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

class CelulaCartao: UICollectionViewCell {
    @IBOutlet weak var imagem: UIImageView!
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var bandeiraCartao: UILabel!
    @IBOutlet weak var finalCartao: UILabel!
    @IBOutlet weak var validadeCartao: UILabel!
    @IBOutlet weak var tipoCartao: UILabel!
    @IBOutlet weak var botaoExcluirCartao: TransitionButton!
}

class CelulaAddCartao: UICollectionViewCell {
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var botaoAddCartao: TransitionButton!
}
