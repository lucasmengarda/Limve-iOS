//
//  InicioVerdadeiro.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 08/08/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import UIKit
import Foundation
import InteractiveSideMenu
import TransitionButton
import Parse
import NVActivityIndicatorView
import DynamicBlurView
import Lottie
import GhostTypewriter
import PopupDialog
import ListPlaceholder

class InicioVerdadeiro: UIViewController, SideMenuItemContent, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, EnderecoDelegate, CarrinhoDelegate, LoginCadastrarDelegate {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var holderInicioVerdadeiro: UIView!
    @IBOutlet weak var holderLimveCupons: UIView!
    @IBOutlet weak var holderLimveCupons_bola: UIView!
    @IBOutlet weak var holderLimveCupons_bola_upper: UIView!
    @IBOutlet weak var limveCreditosLabel: UILabel!
    @IBOutlet weak var holderSearch: UIView!
    @IBOutlet weak var holderSearch2: UIView!
    @IBOutlet weak var searcher: TypewriterLabel!
    @IBOutlet weak var holderHeader: UIView!
    @IBOutlet weak var oTable: UITableView!
    @IBOutlet weak var qrCodeLogo: UIView!
    @IBOutlet weak var holderFooter: UIView!
    @IBOutlet weak var animFooter: UIView!
    @IBOutlet weak var quantidadeCarrinho: UILabel!
    
    @IBOutlet weak var loaderMaqLavar: UIView!
    @IBOutlet weak var loaderTexto: TypewriterLabel!
    @IBOutlet weak var holderLoader: UIView!
    
    @IBOutlet weak var botaoEndereco: UIButton!
    
    @IBOutlet weak var seuSaldoLabel: UILabel!
    @IBOutlet weak var seuSaldo: UILabel!
    
    
    var classesTelaInicial = [[String: Any]]()
    var marcasTelaInicial = [[String : Any]]()
    var produtosRecomendados = [Produto]()
    var destaques = [UIImage]()
    var destaquesLinks = [String]()
    
    var refreshControl: UIRefreshControl!
    var animationCheck: AnimationView!
    
    static var instance: InicioVerdadeiro!
    
    static func inicializeInicioVerdadeiro() -> InicioVerdadeiro{
        
        if (InicioVerdadeiro.instance != nil){
            return instance
        }
        
        let tela = MAIN_STORYBOARD.instantiateViewController(identifier: "InicioVerdadeiro") as! InicioVerdadeiro
        return tela
    }
    
    func chamadaFromCarrinho(){
        self.quantidadeCarrinho.text = "\(CarrinhoObject.get().quantidadeDeItensNoCarrinho())"
        self.oTable.reloadData()
    }
    
    @IBAction func abrirCarrinho(){
        self.quantidadeCarrinho.text = "\(CarrinhoObject.get().quantidadeDeItensNoCarrinho())"
        if (CarrinhoObject.get().produtos.count > 0){
            let carrinho = Carrinho.inicializeCarrinho(delegate: self)
            self.present(carrinho, animated: true, completion: nil)
        } else {
            let popup = PopupDialog(title: "Ops!", message: "Seu carrinho está vazio.")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.quantidadeCarrinho.text = "\(CarrinhoObject.get().quantidadeDeItensNoCarrinho())"
    }
    
    var textosSeachersHolder = -1
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global().async {
            do {
                configuration = try PFConfig.getConfig()
            } catch {
                
            }
        }
        
        let animationMaq = AnimationView(name: "cosmetics")
        animationMaq.loopMode = .loop
        animationMaq.animationSpeed = 0.8
        animationMaq.frame = CGRect(x: -25, y: -25, width: loaderMaqLavar.frame.width+50, height: loaderMaqLavar.frame.height+50)
        animationMaq.contentMode = .scaleAspectFill
        loaderMaqLavar.addSubview(animationMaq)
        animationMaq.play()
        
        let animationQrCode = AnimationView(name: "qrcode")
        animationQrCode.loopMode = .autoReverse
        animationQrCode.animationSpeed = 0.7
        animationQrCode.frame = CGRect(x: 0, y: 0, width: qrCodeLogo.frame.width, height: qrCodeLogo.frame.height)
        animationQrCode.contentMode = .scaleAspectFill
        qrCodeLogo.addSubview(animationQrCode)
        animationQrCode.play()
        
        oTable.tag = 1
        
        loaderTexto.typingTimeInterval = 0.05
        loaderTexto.animationStyle = .reveal
        loaderTexto.startTypewritingAnimation()
        
        oTable.tableHeaderView = holderHeader
        oTable.tableFooterView = holderFooter
        
        animationCheck = AnimationView(name: "check")
        animationCheck.loopMode = .playOnce
        animationCheck.animationSpeed = 1.5
        animationCheck.frame = CGRect(x: 0, y: 0, width: animFooter.frame.width, height: animFooter.frame.height+40)
        animationCheck.contentMode = .scaleAspectFill
        animFooter.addSubview(animationCheck)
        
        //--- searcher ---//
        holderSearch2.layer.cornerRadius = 16.0
        holderSearch.layer.cornerRadius = 16.0
        holderSearch.clipsToBounds = true
        
        holderSearch2.layer.shadowColor = hexStringToUIColor("#000").withAlphaComponent(0.17).cgColor
        holderSearch2.layer.shadowOpacity = 2
        holderSearch2.layer.shadowOffset = .zero
        holderSearch2.layer.shadowRadius = 5
        
        
        holder.layer.cornerRadius = 16.0
        holder.clipsToBounds = false
        
        holder.layer.shadowColor = hexStringToUIColor("#00224B").withAlphaComponent(0.6).cgColor
        holder.layer.shadowOpacity = 3
        holder.layer.shadowOffset = .zero
        holder.layer.shadowRadius = 10
        
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [hexStringToUIColor("#a01d5d").cgColor, hexStringToUIColor("#b12067").cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: holderLimveCupons_bola.frame.size.width, height: holderLimveCupons_bola.frame.size.height)
        
        holderLimveCupons_bola.layer.insertSublayer(gradient, at: 0)
        holderLimveCupons.layer.cornerRadius = 8.0
        
        holderLimveCupons_bola.layer.cornerRadius = self.holderLimveCupons_bola.frame.width/2
        holderLimveCupons_bola.clipsToBounds = true
        
        holderLimveCupons_bola_upper.layer.cornerRadius = self.holderLimveCupons_bola_upper.frame.width/2
        
        holderLimveCupons_bola_upper.layer.shadowColor = hexStringToUIColor("#000").withAlphaComponent(0.3).cgColor
        holderLimveCupons_bola_upper.layer.shadowOpacity = 3
        holderLimveCupons_bola_upper.layer.shadowOffset = .zero
        holderLimveCupons_bola_upper.layer.shadowRadius = 5
        
        holderLimveCupons.layer.shadowColor = hexStringToUIColor("#000").withAlphaComponent(0.3).cgColor
        holderLimveCupons.layer.shadowOpacity = 3
        holderLimveCupons.layer.shadowOffset = .zero
        holderLimveCupons.layer.shadowRadius = 5
        
        holderLimveCupons_bola_upper.layer.borderWidth = 2.0
        holderLimveCupons_bola_upper.layer.borderColor = hexStringToUIColor("F5F9FF").cgColor
        
        
        let gradient2: CAGradientLayer = CAGradientLayer()
        gradient2.colors = [hexStringToUIColor("#da3284").cgColor, hexStringToUIColor("#e05398").cgColor]
        gradient2.locations = [0.0, 1.0]
        gradient2.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient2.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient2.frame = CGRect(x: 0.0, y: 0.0, width: holderLimveCupons.frame.size.width, height: holderLimveCupons.frame.size.height)
        holderLimveCupons.layer.insertSublayer(gradient2, at: 0)
        holderLimveCupons.clipsToBounds = true
        
        
        let texto = "LimveCréditos"
        let attributedTexto = NSMutableAttributedString(string: texto)
        attributedTexto.addAttribute(.font, value: UIFont(name: "Ubuntu-Bold", size: 17.0)!, range: NSRange(location: 0, length: 5))
        attributedTexto.addAttribute(.font, value: UIFont(name: "Ubuntu-Light", size: 17.0)!, range: NSRange(location: 5, length: 8))
        
        limveCreditosLabel.attributedText = attributedTexto
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Atualizar")
        refreshControl.addTarget(self, action: #selector(self.carregarLimveCreditos), for: .valueChanged)
        oTable.addSubview(refreshControl) // not required when using UITableViewController
        
        if (InicioVerdadeiro.instance != nil){
            DispatchQueue.global().async { [self] in
                do {
                    try PFUser.current()?.fetch()
                    var enderecoEntrega: String!
                    if (PFUser.current()!["enderecoEntrega"] != nil){
                        enderecoEntrega = (PFUser.current()!["enderecoEntrega"] as! String)
                    } else {
                        enderecoEntrega = "Sem endereço cadastrado.."
                    }
                    DispatchQueue.main.async {
                        self.botaoEndereco.setTitle("\(enderecoEntrega!) ▿", for: [])
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.botaoEndereco.setTitle("Sem endereço cadastrado..", for: [])
                    }
                }
                
                do {
                    //Pegar LimveCréditos
                    carregarLimveCreditos()
                    //
                } catch {
                    
                }
            }
            self.oTable.reloadData()
        } else {
            DispatchQueue.global().async { [self] in
                do {
                    try PFUser.current()?.fetch()
                    var enderecoEntrega: String!
                    if (PFUser.current()!["enderecoEntrega"] != nil){
                        enderecoEntrega = (PFUser.current()!["enderecoEntrega"] as! String)
                    } else {
                        enderecoEntrega = "Sem endereço cadastrado.."
                    }
                    DispatchQueue.main.async {
                        self.botaoEndereco.setTitle("\(enderecoEntrega!) ▿", for: [])
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.botaoEndereco.setTitle("Sem endereço cadastrado..", for: [])
                    }
                }
                
                do {
                    //Pegar LimveCréditos
                    carregarLimveCreditos()
                    //
                    
                    configuration = try PFConfig.getConfig()
                    self.classesTelaInicial = configuration["classesTelaInicial"] as! [[String : Any]]
                    for x in 0 ... self.classesTelaInicial.count - 1 {
                        let query = PFQuery(className: "Produtos").whereKey("categoria", equalTo: (self.classesTelaInicial[x]["categoria"] as! String))
                        query.addDescendingOrder("margem")
                        query.addDescendingOrder("estoque")
                        query.limit = 6
                        query.skip = 0
                        var produtos = [Produto]()
                        let objs = try query.findObjects()
                        if (objs.count > 0){
                            for y in 0 ... objs.count - 1 {
                                produtos.append(Produto(produto: objs[y]))
                            }
                        }
                        self.classesTelaInicial[x]["produtos"] = produtos
                    }
                    
                    print(self.classesTelaInicial)
                    
                    self.marcasTelaInicial = configuration["marcasTelaInicial"] as! [[String : Any]]
                    for x in 0 ... self.marcasTelaInicial.count - 1 {
                        self.marcasTelaInicial[x]["imagem_ui"] = UIImage(named: (self.marcasTelaInicial[x]["imagem"] as! String))
                    }
                    
                    print(self.marcasTelaInicial)
                    
                    
                    let telaInicial = try PFQuery(className: "TelaInicial").getFirstObject()
                    let recomendadosQuery = (telaInicial["produtos"] as! PFRelation).query()
                    recomendadosQuery.addAscendingOrder("grauRelevancia")
                    let recomendados = try recomendadosQuery.findObjects()
                    produtosRecomendados.removeAll()
                    if (recomendados.count > 0){
                        for y in 0 ... recomendados.count - 1 {
                            produtosRecomendados.append(Produto(produto: recomendados[y]))
                        }
                    }
                    
                    destaques.removeAll()
                    destaquesLinks.removeAll()
                    for z in 1 ... 5 {
                        if (telaInicial["destaque\(z)"] != nil){
                            do {
                                let oldData = try (telaInicial["destaque\(z)"] as! PFFileObject).getData()
                                let imagem = UIImage(data: oldData)
                                destaques.append(imagem!)
                            } catch {
                                
                            }
                            
                            if (telaInicial["destaque\(z)_link"] != nil){
                                do {
                                    let url = (telaInicial["destaque\(z)_link"] as! String)
                                    destaquesLinks.append(url)
                                } catch {
                                    destaquesLinks.append("")
                                }
                            } else {
                                destaquesLinks.append("")
                            }
                        }
                    }
                } catch {
                    
                }
                
                DispatchQueue.main.async {
                    InicioVerdadeiro.instance = self
                    self.oTable.reloadData()
                    UIView.animate(withDuration: 0.25) {
                        self.holderLoader.layer.cornerRadius = 10.0
                        self.holderLoader.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: self.holderLoader.frame.width, height: self.holderLoader.frame.height)
                    } completion: { _ in
                        
                        self.searcher.text = "O que você procura hoje?"
                        self.searcher.typingTimeInterval = 0.05
                        self.searcher.animationStyle = .reveal
                        self.searcher.startTypewritingAnimation()
                        
                        let textosSearcher = ["Shampoos e Condicionadores...", "Marcas: Truss, L'oreal, Wella...", "Esmaltes...", "Produtos de limpeza...", "Tintas de cabelo...", "Hidratantes e pós-barba..."]
                        
                        var numberRepeats = 0
                        let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
                            print("Timer fired!")
                            self.textosSeachersHolder += 1
                            if (self.textosSeachersHolder > (textosSearcher.count - 1)){
                                self.textosSeachersHolder = 0
                            }
                            let name = textosSearcher[self.textosSeachersHolder]
                            
                            
                            self.searcher.text = name
                            
                            numberRepeats += 1
                            
                            if (numberRepeats == 7){
                                print("timer canceled")
                                timer.invalidate()
                                self.searcher.text = "O que você procura hoje?"
                            }
                            
                            self.searcher.typingTimeInterval = 0.05
                            self.searcher.animationStyle = .reveal
                            self.searcher.startTypewritingAnimation()
                        }
                    }
                    
                    //Login forçado
                    if (!isUserLoggedIn()){
                        abrirLogin()
                    }
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                do {
                    
                        do {
                            var publicIP = try String(contentsOf: URL(string: "https://api.ipify.org/")!, encoding: String.Encoding.utf8)
                            publicIP = publicIP.trimmingCharacters(in: CharacterSet.whitespaces)
                            IP_EXTERNO = publicIP
                            print("MEU IP É: \(IP_EXTERNO)")
                        }
                        catch {
                            print("Error: \(error)")
                        }
                    
                    try PFUser.current()?.fetch()
                    
                    UIApplication.shared.applicationIconBadgeNumber = 0
                    let currentInstallation = PFInstallation.current()
                    currentInstallation?.badge = 0
                    try PFUser.current()?.save()
                    print("USER ID: \((PFUser.current()))")
                    currentInstallation?["userId"] = (PFUser.current()!.objectId)
                    currentInstallation?.saveInBackground()
                } catch {
                    print("Erro \(error.localizedDescription)")
                    PFUser.logOut()
                }
            }
        }
    }
    
    @objc func carregarLimveCreditos(){
        DispatchQueue.global().async {
            do {
                try PFUser.current()!.fetch()
            } catch {
                
            }
            var saldoDou = 0.0
            if (PFUser.current()!["saldoLimveCreditos"] != nil){
                saldoDou = (PFUser.current()!["saldoLimveCreditos"] as! Double)
            }
            DispatchQueue.main.async {
                self.seuSaldo.text = formatarPreco(preco: saldoDou)
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.tag == 1){
            if (oTable.contentOffset.y >= (oTable.contentSize.height - oTable.frame.size.height)) {
                self.animationCheck.play()
                print("willdisplay")
            }
        }
    }
    
    @IBAction func clicarPedidosAndamento(){
        NavigationMenuViewController.myVC.menuContainerViewController!.selectContentViewController(MinhasCompras.inicializeMinhasCompras())
        NavigationMenuViewController.myVC.menuContainerViewController!.hideSideMenu()
    }
    
    @IBAction func abrirMenu(){
        self.view.endEditing(true)
        showSideMenu()
    }
    
    @IBAction func buscarProduto(){
        NavigationMenuViewController.myVC.menuContainerViewController!.selectContentViewController(TelaInicial.inicializeTelaInicialAsBuscarAcionado())
        NavigationMenuViewController.myVC.menuContainerViewController!.hideSideMenu()
    }
    
    @objc func clicarVerTodos(sender: TransitionButton){
        let tagClasse = sender.tag
        let classe = classesTelaInicial[tagClasse]
        
        //abrir mais produtos
        let categoria = (classe["categoria"] as! String)
        let subtitulo = (classe["subtitulo"] as! String)
        NavigationMenuViewController.myVC.menuContainerViewController!.selectContentViewController(TelaInicial.inicializeTelaInicial(categoria: categoria, titulo: subtitulo))
        NavigationMenuViewController.myVC.menuContainerViewController!.hideSideMenu()
    }
    
    @objc func abrirProduto(sender: UIControl){
        
        if (sender.tag < 100){
            
            let produto = produtosRecomendados[sender.tag]
            let telaProduto = TelaProduto.inicializeTelaProduto(produto: produto, delegate: nil, delegate2: self)
            self.present(telaProduto, animated: true, completion: nil)
            
        } else if (sender.tag < 300) {
            
            //abrir destaque
            let linkDestaque = destaquesLinks[(sender.tag-100)]
            if (linkDestaque.count > 0){
                guard let url = URL(string: linkDestaque) else {
                  return //be safe
                }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            
        } else if (sender.tag < 500) {
            
            let tag = sender.tag-300
            let marca = (marcasTelaInicial[tag]["marca"] as! String)
            NavigationMenuViewController.myVC.menuContainerViewController!.selectContentViewController(TelaInicial.inicializeTelaInicialAsMarca(marca: marca))
            NavigationMenuViewController.myVC.menuContainerViewController!.hideSideMenu()
            //abrirmarca
            
        } else {
            //produtos
            
            let tagClasse = (NSString(string: String(format: "%.0f", (Double(sender.tag) / 1000.0))).integerValue) - 10
            let tagRow = sender.tag - (tagClasse*1000) - 10000
            
            print("tagClasse: \(tagClasse) | tagRow: \(tagRow)")
            
            let classe = classesTelaInicial[tagClasse]
            
            if (tagRow == (classe["produtos"] as! [Produto]).count){
               
                //abrir mais produtos
                let categoria = (classe["categoria"] as! String)
                let subtitulo = (classe["subtitulo"] as! String)
                NavigationMenuViewController.myVC.menuContainerViewController!.selectContentViewController(TelaInicial.inicializeTelaInicial(categoria: categoria, titulo: subtitulo))
                NavigationMenuViewController.myVC.menuContainerViewController!.hideSideMenu()
                
            } else {
                
                let produto = (classe["produtos"] as! [Produto])[tagRow]
                //abrir produto
                let telaProduto = TelaProduto.inicializeTelaProduto(produto: produto, delegate: nil, delegate2: self)
                self.present(telaProduto, animated: true, completion: nil)
            }
        }
    }
    
    @objc func botaoAdicionarCarrinhoPressed(sender: UIButton){
        if (sender.tag < 100){
            
            let produto = produtosRecomendados[sender.tag]
            //abrir produto
            if (produto.estoque == 0){
                return
            }
            
            CarrinhoObject.get().adicionarAoCarrinho(produto: produto)
            self.quantidadeCarrinho.text = "\(CarrinhoObject.get().quantidadeDeItensNoCarrinho())"
            
            self.showToast(message: "Adicionado ao carrinho!", font: UIFont(name: "Ubuntu-Regular", size: 14.0)!)
            self.oTable.reloadData()
            
        } else if (sender.tag < 300) {
            //nil
        } else if (sender.tag < 500) {
            //nil
        } else {
            //produtos
            
            let tagClasse = (NSString(string: String(format: "%.0f", (Double(sender.tag) / 1000.0))).integerValue) - 10
            let tagRow = sender.tag - (tagClasse*1000) - 10000
            
            print("tagClasse: \(tagClasse) | tagRow: \(tagRow)")
            
            let classe = classesTelaInicial[tagClasse]
            
            if (tagRow == (classe["produtos"] as! [Produto]).count){
                //nil
            } else {
                
                let produto = (classe["produtos"] as! [Produto])[tagRow]
                //abrir produto
                if (produto.estoque == 0){
                    return
                }
                
                CarrinhoObject.get().adicionarAoCarrinho(produto: produto)
                self.quantidadeCarrinho.text = "\(CarrinhoObject.get().quantidadeDeItensNoCarrinho())"
                
                self.showToast(message: "Adicionado ao carrinho!", font: UIFont(name: "Ubuntu-Regular", size: 14.0)!)
                self.oTable.reloadData()
                
            }
        }
    }
    
    @IBAction func alterarEndereco(){
        inicializarEfeitosDeBlur()
        
        let adicionar = Endereco.inicializeEndereco(delegate: self)
        self.present(adicionar, animated: true, completion: {
            self.blurView.trackingMode = .none
        })
    }
    
    @IBAction func limveCreditos(){
        let lc = LimveCreditos.inicializeLimveCreditos()
        self.present(lc, animated: true, completion: nil)
    }
    
    @IBAction func qrCodeScanner(){
        var codigo = ""
        if (PFUser.current()!["codLimveCreditos"] == nil){
            codigo = "limve_\(PFUser.current()!.objectId!)"
        } else {
            codigo = (PFUser.current()!["codLimveCreditos"] as! String)
        }
        
        let lc = LimveQR.inicializeLimveQR(meuCodigo: codigo)
        self.present(lc, animated: true, completion: nil)
    }
    
    func onAdicionarEndereco(sucesso: Bool, novoEndereco: String?) {
        UIView.animate(withDuration: 0.25, animations: {
            self.blurEffectView.alpha = 0
        }) { _ in
            self.blurEffectView.removeFromSuperview()
        }
        
        if (sucesso){
            botaoEndereco.setTitle("\(novoEndereco!) ▿", for: [])
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (destaques.count > 0){
            return 1 + 1 + 1 + 1
        } else {
            return 1 + 1 + 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (destaques.count > 0){
            if (section == 0){
                //recomendados
                return 1
            } else if (section == 1){
                //destaques
                return 1
            } else if (section == 2){
                //marcas
                return 1
            } else {
                return classesTelaInicial.count
            }
        } else {
            if (section == 0){
                //recomendados
                return 1
            } else if (section == 1){
                //marcas
                return 1
            } else {
                return classesTelaInicial.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaProdutoHolderInicioVerdadeiro") as! CelulaProdutoHolderInicioVerdadeiro
            
            cell.holder.layer.cornerRadius = 8.0
            cell.holder.layer.shadowColor = hexStringToUIColor("#000").withAlphaComponent(0.3).cgColor
            cell.holder.layer.shadowOpacity = 1
            cell.holder.layer.shadowOffset = .zero
            cell.holder.layer.shadowRadius = 2
            
            cell.botaoVerTodos.isHidden = true
            
            cell.subtitulo.text = "Nossos recomendados"
            cell.titulo.text = "FEITO PARA VOCÊ"
            
            cell.collectionView.tag = 0
            cell.collectionView.reloadData()
            
            cell.backgroundColor = UIColor.clear
            
            return cell
            
        } else if (indexPath.section == 1){
            
            if (destaques.count > 0){
                //destaques
                let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaDestaquesHolderInicioVerdadeiro") as! CelulaDestaquesHolderInicioVerdadeiro
                
                cell.collectionView.reloadData()
                
                cell.backgroundColor = UIColor.clear
                
                return cell
            } else {
                
                //marcas
                let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaMarcasHolderInicioVerdadeiro") as! CelulaMarcasHolderInicioVerdadeiro
                
                cell.collectionView.reloadData()
                
                cell.backgroundColor = UIColor.clear
                
                return cell
            }
            
        } else if (indexPath.section == 2){
            
            if (destaques.count > 0){
                //marcas
                let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaMarcasHolderInicioVerdadeiro") as! CelulaMarcasHolderInicioVerdadeiro
                
                cell.backgroundColor = UIColor.clear
                
                cell.collectionView.reloadData()
                
                return cell
            } else {
                //produtos
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaProdutoHolderInicioVerdadeiro") as! CelulaProdutoHolderInicioVerdadeiro
                
                cell.holder.layer.cornerRadius = 8.0
                cell.holder.layer.shadowColor = hexStringToUIColor("#000").withAlphaComponent(0.3).cgColor
                cell.holder.layer.shadowOpacity = 1
                cell.holder.layer.shadowOffset = .zero
                cell.holder.layer.shadowRadius = 2
                
                cell.collectionView.tag = indexPath.row + 1000
                let classe = classesTelaInicial[indexPath.row]
                
                cell.botaoVerTodos.isHidden = false
                cell.botaoVerTodos.tag = indexPath.row
                cell.botaoVerTodos.addTarget(self, action: #selector(self.clicarVerTodos(sender:)), for: .touchUpInside)
                
                cell.subtitulo.text = (classe["subtitulo"] as! String)
                cell.titulo.text = (classe["titulo"] as! String)
                
                cell.collectionView.reloadData()
                
                cell.backgroundColor = UIColor.clear
                
                return cell
            }
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaProdutoHolderInicioVerdadeiro") as! CelulaProdutoHolderInicioVerdadeiro
            
            cell.holder.layer.cornerRadius = 8.0
            cell.holder.layer.shadowColor = hexStringToUIColor("#000").withAlphaComponent(0.3).cgColor
            cell.holder.layer.shadowOpacity = 1
            cell.holder.layer.shadowOffset = .zero
            cell.holder.layer.shadowRadius = 2
            
            cell.collectionView.tag = indexPath.row + 1000
            let classe = classesTelaInicial[indexPath.row]
            
            cell.botaoVerTodos.isHidden = false
            cell.botaoVerTodos.tag = indexPath.row
            cell.botaoVerTodos.addTarget(self, action: #selector(self.clicarVerTodos(sender:)), for: .touchUpInside)
            
            cell.subtitulo.text = (classe["subtitulo"] as! String)
            cell.titulo.text = (classe["titulo"] as! String)
            
            cell.collectionView.reloadData()
            
            cell.backgroundColor = UIColor.clear
            
            return cell
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (collectionView.tag == 0){
            //recomendados
            return produtosRecomendados.count
        } else if (collectionView.tag == 1){
            //destaques
            return destaques.count
        } else if (collectionView.tag == 2){
            //marcas
            return marcasTelaInicial.count
        } else {
            let tag = collectionView.tag % 1000
            return (classesTelaInicial[tag]["produtos"] as! [Produto]).count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (collectionView.tag == 0){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CelulaProdutoInicioVerdadeiro", for: indexPath as IndexPath) as! CelulaProdutoInicioVerdadeiro
            
            cell.backgroundColor = UIColor.clear
            
            cell.imagem.layer.cornerRadius = 10.0
            
            let produto = produtosRecomendados[indexPath.item]
            
            cell.marca.text = produto.marca
            cell.preco.text = formatarPreco(preco: produto.precoVenda)
            cell.viewClicavel.tag = indexPath.item
            cell.viewClicavel.addTarget(self, action: #selector(self.abrirProduto(sender:)), for: .touchUpInside)
            cell.botaoAdicionarCarrinho.tag = indexPath.item
            cell.botaoAdicionarCarrinho.addTarget(self, action: #selector(self.botaoAdicionarCarrinhoPressed(sender:)), for: .touchUpInside)
            cell.botaoAdicionadoCarrinho.tag = indexPath.item
            cell.botaoAdicionadoCarrinho.addTarget(self, action: #selector(self.botaoAdicionarCarrinhoPressed(sender:)), for: .touchUpInside)
            
            if (produto.estoque > 0){
                if (CarrinhoObject.get().produtosId.contains(produto.produtoId)){
                    cell.botaoAdicionadoCarrinho.isHidden = false
                    cell.botaoAdicionarCarrinho.isHidden = true
                } else {
                    cell.botaoAdicionadoCarrinho.isHidden = true
                    cell.botaoAdicionarCarrinho.isHidden = false
                }
                cell.estoqueZerado.isHidden = true
            } else {
                cell.botaoAdicionadoCarrinho.isHidden = true
                cell.botaoAdicionarCarrinho.isHidden = true
                cell.estoqueZerado.isHidden = false
            }
            
            produto.retornaImagem(imageView: cell.imagem, loader: cell.loader)
            
            let texto = "\(produto.descricao!)\n\(produto.subdescricao!)"
            let attributedTexto = NSMutableAttributedString(string: texto)
            attributedTexto.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: produto.descricao.count))
            
            attributedTexto.addAttribute(.foregroundColor, value: hexStringToUIColor("#0C5985"), range: NSRange(location: produto.descricao.count, length: produto.subdescricao.count+1))
            attributedTexto.addAttribute(.font, value: UIFont(name: "Ubuntu-Regular", size: 12.0)!, range: NSRange(location: 0, length: produto.descricao.count))
            attributedTexto.addAttribute(.font, value: UIFont(name: "Ubuntu-Medium", size: 12.0)!, range: NSRange(location: produto.descricao.count, length: produto.subdescricao.count+1))
            
            cell.descricao.attributedText = attributedTexto
            
            return cell
        } else if (collectionView.tag == 1) {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CelulaDestaquesInicioVerdadeiro", for: indexPath as IndexPath) as! CelulaDestaquesInicioVerdadeiro
            
            cell.backgroundColor = UIColor.clear
            
            let destaque = destaques[indexPath.item]
            
            cell.holderImagem.layer.cornerRadius = 10.0
            cell.holderImagem.layer.shadowColor = hexStringToUIColor("#000").withAlphaComponent(0.3).cgColor
            cell.holderImagem.layer.shadowOpacity = 2
            cell.holderImagem.layer.shadowOffset = .zero
            cell.holderImagem.layer.shadowRadius = 3
            cell.imagem.layer.cornerRadius = 10.0
            cell.imagem.image = destaque
            cell.imagem.clipsToBounds = true
            
            cell.viewClicavel.tag = indexPath.item + 100
            cell.viewClicavel.addTarget(self, action: #selector(self.abrirProduto(sender:)), for: .touchUpInside)
            
            return cell
            
        } else if (collectionView.tag == 2) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CelulaMarcasInicioVerdadeiro", for: indexPath as IndexPath) as! CelulaMarcasInicioVerdadeiro
            
            cell.backgroundColor = UIColor.clear
            
            cell.holderImagem.layer.cornerRadius = 10.0
            cell.holderImagem.layer.shadowColor = hexStringToUIColor("#000").withAlphaComponent(0.3).cgColor
            cell.holderImagem.layer.shadowOpacity = 1
            cell.holderImagem.layer.shadowOffset = .zero
            cell.holderImagem.layer.shadowRadius = 2
            cell.imagem.layer.cornerRadius = 10.0
            
            let marca = marcasTelaInicial[indexPath.item]
            
            let img = marca["imagem_ui"] as! UIImage
            cell.imagem.image = img
            cell.texto.text = (marca["marca"] as! String)
            
            cell.viewClicavel.tag = indexPath.item + 300
            cell.viewClicavel.addTarget(self, action: #selector(self.abrirProduto(sender:)), for: .touchUpInside)
            
            return cell
        } else {
            //produtos
            
            let tag = collectionView.tag % 1000
            let classe = classesTelaInicial[tag]
            
            if (indexPath.item == (classe["produtos"] as! [Produto]).count){
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CelulaProdutoAddInicioVerdadeiro", for: indexPath as IndexPath) as! CelulaProdutoAddInicioVerdadeiro
                
                cell.viewClicavel.tag = indexPath.item + (tag*1000) + 10000
                cell.viewClicavel.addTarget(self, action: #selector(self.abrirProduto(sender:)), for: .touchUpInside)
                
                cell.backgroundColor = UIColor.clear
                
                return cell
            } else {
                let produto = (classe["produtos"] as! [Produto])[indexPath.item]
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CelulaProdutoInicioVerdadeiro", for: indexPath as IndexPath) as! CelulaProdutoInicioVerdadeiro
                
                cell.backgroundColor = UIColor.clear
                
                cell.imagem.layer.cornerRadius = 10.0
                
                cell.marca.text = produto.marca
                cell.preco.text = formatarPreco(preco: produto.precoVenda)
                cell.viewClicavel.tag = indexPath.item + (tag*1000) + 10000
                cell.viewClicavel.addTarget(self, action: #selector(self.abrirProduto(sender:)), for: .touchUpInside)
                cell.botaoAdicionarCarrinho.tag = indexPath.item + (tag*1000) + 10000
                cell.botaoAdicionarCarrinho.addTarget(self, action: #selector(self.botaoAdicionarCarrinhoPressed(sender:)), for: .touchUpInside)
                
                produto.retornaImagem(imageView: cell.imagem, loader: cell.loader)
                
                if (produto.estoque > 0){
                    if (CarrinhoObject.get().produtosId.contains(produto.produtoId)){
                        cell.botaoAdicionadoCarrinho.isHidden = false
                        cell.botaoAdicionarCarrinho.isHidden = true
                    } else {
                        cell.botaoAdicionadoCarrinho.isHidden = true
                        cell.botaoAdicionarCarrinho.isHidden = false
                    }
                    cell.estoqueZerado.isHidden = true
                } else {
                    cell.botaoAdicionadoCarrinho.isHidden = true
                    cell.botaoAdicionarCarrinho.isHidden = true
                    cell.estoqueZerado.isHidden = false
                }
                
                let texto = "\(produto.descricao!)\n\(produto.subdescricao!)"
                let attributedTexto = NSMutableAttributedString(string: texto)
                attributedTexto.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: produto.descricao.count))
                
                attributedTexto.addAttribute(.foregroundColor, value: hexStringToUIColor("#0C5985"), range: NSRange(location: produto.descricao.count, length: produto.subdescricao.count+1))
                attributedTexto.addAttribute(.font, value: UIFont(name: "Ubuntu-Regular", size: 12.0)!, range: NSRange(location: 0, length: produto.descricao.count))
                attributedTexto.addAttribute(.font, value: UIFont(name: "Ubuntu-Medium", size: 12.0)!, range: NSRange(location: produto.descricao.count, length: produto.subdescricao.count+1))
                
                cell.descricao.attributedText = attributedTexto
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0){
            return 318.0
        } else if (indexPath.section == 1){
            if (destaques.count > 0){
                return 181.0
            } else {
                return 233.0
            }
        } else if (indexPath.section == 2){
            if (destaques.count > 0){
                return 233.0
            } else {
                return 318.0
            }
        }
        
        return 318.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //let widthScreen = UIScreen.main.bounds.size.width
        //let square = (widthScreen - 16.0)/2 //30 é referente ao espaçamento entre celulas
        
        if (collectionView.tag == 0){
            return CGSize(width: 127.0, height: 198.0)
        } else if (collectionView.tag == 1) {
            return CGSize(width: 210.0, height: 105.0)
        } else if (collectionView.tag == 2) {
            return CGSize(width: 140.0, height: 140.0)
        } else {
            return CGSize(width: 127.0, height: 198.0)
        }
    }
    
    var blurEffectView: UIView!
    var blurView: DynamicBlurView!
    
    func inicializarEfeitosDeBlur(){
        blurView = DynamicBlurView(frame: self.view.bounds)
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
    }
    
    func abrirLogin(){
        let login = LoginController.inicializeLoginController(delegate: self)
        self.present(login, animated: true, completion: nil)
    }
    
    func onExit(sussecefull: Bool) {
        if (sussecefull){
            if (isUserLoggedIn()){
                if (NavigationMenuViewController.myVC.loginButton != nil){
                    NavigationMenuViewController.myVC.loginButton.isHidden = true
                    NavigationMenuViewController.myVC.cadastrarButton.isHidden = true
                    NavigationMenuViewController.myVC.sejaBemVindoLabel.text = "Seja bem-vindo(a),"
                    NavigationMenuViewController.myVC.nomeLabel.text = formatarNomeDoUsuario()
                    NavigationMenuViewController.myVC.segundoNomeLabel.text = formatarNomeDoUsuario()
                }
                viewDidLoad()
            } else {
                if (NavigationMenuViewController.myVC.loginButton != nil){
                    NavigationMenuViewController.myVC.loginButton.isHidden = false
                    NavigationMenuViewController.myVC.cadastrarButton.isHidden = false
                    NavigationMenuViewController.myVC.sejaBemVindoLabel.text = "Identifique-se"
                    NavigationMenuViewController.myVC.nomeLabel.text = ""
                    NavigationMenuViewController.myVC.segundoNomeLabel.text = ""
                }
            }
        }
    }
}

class CelulaProdutoHolderInicioVerdadeiro: UITableViewCell {
    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var subtitulo: UITextView!
    @IBOutlet weak var botaoVerTodos: TransitionButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var holder: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        botaoVerTodos.spinnerColor = hexStringToUIColor("#718B53")
        botaoVerTodos.setTitleColor(hexStringToUIColor("#718B53"), for: [])
        botaoVerTodos.cornerRadius = botaoVerTodos.frame.height/2
        botaoVerTodos.backgroundColor = UIColor.white
        botaoVerTodos.clipsToBounds = false
        
        botaoVerTodos.layer.shadowColor = hexStringToUIColor("#000").withAlphaComponent(0.3).cgColor
        botaoVerTodos.layer.shadowOpacity = 1
        botaoVerTodos.layer.shadowOffset = .zero
        botaoVerTodos.layer.shadowRadius = 2
    }
}

class CelulaProdutoInicioVerdadeiro: UICollectionViewCell {
    @IBOutlet weak var marca: UILabel!
    @IBOutlet weak var descricao: UITextView!
    @IBOutlet weak var preco: UILabel!
    @IBOutlet weak var loader: UIView!
    @IBOutlet weak var viewClicavel: UIControl!
    @IBOutlet weak var botaoAdicionarCarrinho: UIControl!
    @IBOutlet weak var botaoAdicionadoCarrinho: UIControl!
    @IBOutlet weak var estoqueZerado: UIView!
    @IBOutlet weak var imagem: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loader.backgroundColor = UIColor.clear
        let nv = NVActivityIndicatorView(frame: CGRect(origin: .zero, size: loader.frame.size), type: NVActivityIndicatorType.ballClipRotateMultiple, color: hexStringToUIColor("#3C65D1"), padding: 15.0)
        loader.backgroundColor = UIColor.clear
        loader.addSubview(nv)
        nv.startAnimating()
    }
}

class CelulaProdutoAddInicioVerdadeiro: UICollectionViewCell {
    @IBOutlet weak var loader: UIView!
    @IBOutlet weak var viewClicavel: UIControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let animationSeeAll = AnimationView(name: "seeall")
        animationSeeAll.loopMode = .loop
        animationSeeAll.animationSpeed = 0.8
        animationSeeAll.frame = CGRect(x: -25, y: -25, width: loader.frame.width+50, height: loader.frame.height+50)
        animationSeeAll.contentMode = .scaleAspectFill
        loader.addSubview(animationSeeAll)
        animationSeeAll.play()
    }
}

class CelulaDestaquesHolderInicioVerdadeiro: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}


class CelulaDestaquesInicioVerdadeiro: UICollectionViewCell {
    @IBOutlet weak var holderImagem: UIView!
    @IBOutlet weak var imagem: UIImageView!
    @IBOutlet weak var viewClicavel: UIControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class CelulaMarcasHolderInicioVerdadeiro: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}


class CelulaMarcasInicioVerdadeiro: UICollectionViewCell {
    @IBOutlet weak var holderImagem: UIView!
    @IBOutlet weak var imagem: UIImageView!
    @IBOutlet weak var texto: UILabel!
    @IBOutlet weak var viewClicavel: UIControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
