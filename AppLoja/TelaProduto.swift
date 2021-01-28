//
//  TelaProduto.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 12/02/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import UIKit
import InteractiveSideMenu
import SHSearchBar
import TransitionButton
import NVActivityIndicatorView
import Parse
import PopupDialog

class TelaProduto: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var oTable: UITableView!
    @IBOutlet weak var loader: UIView!
    
    @IBOutlet weak var imagemPromocaoAtiva: UIImageView!
    @IBOutlet weak var botaoAdicionarAoCarrinho: TransitionButton!
    @IBOutlet weak var botaoFavorito: TransitionButton!
    
    @IBOutlet weak var imagemFundo: UIImageView!
    @IBOutlet weak var imagemSobreposta: UIImageView!
    
    var delegate: TelaInicial!
    var delegate2: InicioVerdadeiro!
    var descricaoLongaHeight: CGFloat!
    var produto: Produto!
    var produtosSimilares = [Produto]()
    var loadProdutosSimilares = 0
    var favoritado = 0
    
    var yUtilizar: CGFloat!
    
    static func inicializeTelaProduto(produto: Produto, delegate: TelaInicial?, delegate2: InicioVerdadeiro?) -> TelaProduto {
        let tela = MAIN_STORYBOARD.instantiateViewController(identifier: "TelaProduto") as! TelaProduto
        tela.produto = produto
        tela.delegate = delegate
        tela.delegate2 = delegate2
        return tela
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logVerProduto(produto: self.produto)
        
        imagemSobreposta.layer.cornerRadius = 8.0
        imagemSobreposta.layer.shadowColor = hexStringToUIColor("#00224B").cgColor
        imagemSobreposta.layer.shadowOpacity = 6
        imagemSobreposta.layer.shadowOffset = .zero
        imagemSobreposta.layer.shadowRadius = 10
        
        imagemSobreposta.isHidden = true
        imagemFundo.isHidden = true
        
        yUtilizar = self.holder.frame.origin.y
        
        loader.backgroundColor = UIColor.clear
        let nv = NVActivityIndicatorView(frame: CGRect(origin: .zero, size: loader.frame.size), type: NVActivityIndicatorType.ballClipRotateMultiple, color: UIColor.white, padding: 15.0)
        loader.backgroundColor = UIColor.clear
        loader.addSubview(nv)
        nv.startAnimating()
        
        produto.retornaImagem(imageView: imagemSobreposta, loader: loader)
        produto.retornaImagem(imageView: imagemFundo, loader: loader)
        
        botaoAdicionarAoCarrinho.backgroundColor = hexStringToUIColor("#4BC562")
        botaoAdicionarAoCarrinho.spinnerColor = UIColor.white
        botaoAdicionarAoCarrinho.cornerRadius = botaoAdicionarAoCarrinho.frame.height/2
        
        botaoFavorito.backgroundColor = hexStringToUIColor("#953B61")
        botaoFavorito.spinnerColor = UIColor.white
        botaoFavorito.cornerRadius = botaoAdicionarAoCarrinho.frame.height/2
        
        holder.layer.cornerRadius = 16.0
        holder.layer.shadowColor = hexStringToUIColor("#00224B").cgColor
        holder.layer.shadowOpacity = 6
        holder.layer.shadowOffset = .zero
        holder.layer.shadowRadius = 10
        
        oTable.backgroundColor = UIColor.clear
        
        descricaoLongaHeight = produto.descricaolonga.height(withConstrainedWidth: oTable.frame.width - 40, font: UIFont(name: "Ubuntu-Regular", size: 16.0)!) + 56.0
        
        if (produto.estoque == 0){
            botaoAdicionarAoCarrinho.alpha = 0.6
        } else {
            botaoAdicionarAoCarrinho.alpha = 1.0
        }
        
        botaoFavorito.setTitle("...", for: [])
        DispatchQueue.global(qos: .background).async {
            do {
                try PFUser.current()?.fetch()
                if (PFUser.current()!["favoritos"] != nil){
                    let favoritos = PFUser.current()!["favoritos"] as! [String]
                    if (favoritos.contains(self.produto.produtoId)){
                        DispatchQueue.main.async {
                            self.botaoFavorito.setTitle("Desfavoritar", for: [])
                            self.botaoFavorito.backgroundColor = hexStringToUIColor("#FF344E")
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.botaoFavorito.setTitle("Favoritar", for: [])
                            self.botaoFavorito.backgroundColor = hexStringToUIColor("#953B61")
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.botaoFavorito.setTitle("Favoritar", for: [])
                        self.botaoFavorito.backgroundColor = hexStringToUIColor("#953B61")
                    }
                }
            } catch {
            }
        }
        
        if (CarrinhoObject.get().produtosId.contains(produto.produtoId)){
            self.botaoAdicionarAoCarrinho.setTitle("Adicionado!", for: [])
            self.botaoAdicionarAoCarrinho.backgroundColor = hexStringToUIColor("#3C65D1")
        }
    }
    
    @IBAction func fechar(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    
        
        if (indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaInfoProduto") as! CelulaInfoProduto
            
            cell.holder.layer.cornerRadius = 6.0
            cell.holder.layer.shadowColor = hexStringToUIColor("#D9E0D9").cgColor
            cell.holder.layer.shadowOpacity = 2
            cell.holder.layer.shadowOffset = .zero
            cell.holder.layer.shadowRadius = 4
            
            cell.marca.text = produto.marca
            cell.descricao.text = produto.descricao
            if (produto.subdescricao.count == 0){
                cell.subdescricao.isHidden = true
                cell.subDescricaoTitle.isHidden = true
            } else {
                cell.subdescricao.isHidden = false
                cell.subDescricaoTitle.isHidden = false
                
                cell.subdescricao.text = produto.subdescricao
            }
            if (produto.precoSemDesconto != 0.0 && produto.precoSemDesconto > produto.precoVenda){
                cell.dePreco.isHidden = false
                cell.porPreco.isHidden = false
                cell.precoAntigo.isHidden = false
                cell.preco.textColor = hexStringToUIColor("#D13C2F")
                cell.precoAntigo.text = formatarPreco(preco: produto.precoSemDesconto)
                imagemPromocaoAtiva.isHidden = false
            } else {
                cell.dePreco.isHidden = true
                cell.porPreco.isHidden = true
                cell.precoAntigo.isHidden = true
                cell.preco.textColor = hexStringToUIColor("#57005B")
                imagemPromocaoAtiva.isHidden = true
            }
            
            cell.preco.text = formatarPreco(preco: produto.precoVenda)
            
            cell.backgroundColor = UIColor.clear
            
            return cell
        } else if (indexPath.section == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaSimilares") as! CelulaSimilares
            
            cell.holder.layer.shadowColor = hexStringToUIColor("#D9E0D9").cgColor
            cell.holder.layer.shadowOpacity = 2
            cell.holder.layer.shadowOffset = .zero
            cell.holder.layer.shadowRadius = 4
            
            cell.backgroundColor = UIColor.clear
            
            cell.theCollectionView.backgroundColor = UIColor.clear
            cell.theCollectionView.delegate = self
            cell.theCollectionView.dataSource = self
            
            if (loadProdutosSimilares == 0){
                cell.theCollectionView.isHidden = true
                cell.loader.isHidden = false
                DispatchQueue.global(qos: .background).async {
                    
                    self.loadProdutosSimilares = 1
                    do {
                        let query1 = PFQuery(className: "Produtos").whereKey("categoria", equalTo: self.produto.categoria!)
                        query1.whereKey("marca", contains: self.produto.marca)
                        query1.whereKey("objectId", notEqualTo: self.produto.produtoId!)
                        query1.limit = 15
                        query1.order(byDescending: "estoque")
                        
                        let produtos1 = try query1.findObjects()
                        
                        let query2 = PFQuery(className: "Produtos").whereKey("categoria", equalTo: self.produto.categoria!)
                        query2.whereKey("objectId", notEqualTo: self.produto.produtoId!)
                        query2.limit = 4
                        query2.order(byDescending: "estoque")
                        
                        let produtos2 = try query2.findObjects()
                        
                        let query3 = PFQuery(className: "Produtos").whereKey("marca", contains: self.produto.marca)
                        query3.whereKey("objectId", notEqualTo: self.produto.produtoId!)
                        query3.limit = 11
                        query3.order(byDescending: "estoque")
                        
                        let produtos3 = try query3.findObjects()
                        
                        var produtosJuntos = [PFObject]()
                        if (produtos1.count < 10){
                            produtosJuntos.append(contentsOf: produtos2)
                            if (produtosJuntos.count < 15){
                                produtosJuntos.append(contentsOf: produtos3)
                            }
                        } else {
                            produtosJuntos.append(contentsOf: produtos1)
                        }
                        
                        self.produtosSimilares.removeAll()
                        for prd in produtosJuntos {
                            self.produtosSimilares.append(Produto(produto: prd))
                        }
                    } catch {
                        
                    }
                    
                    DispatchQueue.main.async {
                        self.loadProdutosSimilares = 2
                        cell.theCollectionView.reloadData()
                        cell.theCollectionView.isHidden = false
                        cell.loader.isHidden = true
                        print("produtos similares: \(self.produtosSimilares.count)")
                    }
                }
            } else if (loadProdutosSimilares == 1){
                cell.theCollectionView.isHidden = true
                cell.loader.isHidden = false
            } else {
                cell.theCollectionView.isHidden = false
                cell.loader.isHidden = true
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaDescricao") as! CelulaDescricao
                       
            cell.holder.layer.shadowColor = hexStringToUIColor("#D9E0D9").cgColor
            cell.holder.layer.shadowOpacity = 2
            cell.holder.layer.shadowOffset = .zero
            cell.holder.layer.shadowRadius = 4
                       
            cell.descricaoLonga.text = produto.descricaolonga
            cell.backgroundColor = UIColor.clear
                       
            return cell
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return produtosSimilares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CelulaProdutoSimilar", for: indexPath as IndexPath) as! CelulaProdutoSimilar
        
        cell.backgroundColor = UIColor.clear
        
        cell.holder.layer.cornerRadius = 6.0
        cell.holder.layer.borderColor = hexStringToUIColor("#D0F1F7").cgColor
        cell.holder.layer.borderWidth = 1.0
        
        cell.holder.layer.shadowColor = hexStringToUIColor("#D9E0D9").cgColor
        cell.holder.layer.shadowOpacity = 2
        cell.holder.layer.shadowOffset = .zero
        cell.holder.layer.shadowRadius = 4
        
        cell.marca.text = produtosSimilares[indexPath.item].marca
        cell.preco.text = formatarPreco(preco: produtosSimilares[indexPath.item].precoVenda)
        cell.viewClicavel.tag = indexPath.item
        cell.viewClicavel.addTarget(self, action: #selector(self.abrirProduto(sender:)), for: .touchUpInside)
        
        produtosSimilares[indexPath.item].retornaImagem(imageView: cell.imagem, loader: cell.loader)
        
        if (produtosSimilares[indexPath.item].estoque == 0){
            cell.estoqueZerado.isHidden = false
        } else {
            cell.estoqueZerado.isHidden = true
        }
        
        let texto = "\(produtosSimilares[indexPath.item].descricao!)\n\(produtosSimilares[indexPath.item].subdescricao!)"
        let attributedTexto = NSMutableAttributedString(string: texto)
        attributedTexto.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: produtosSimilares[indexPath.item].descricao.count))
        
        attributedTexto.addAttribute(.foregroundColor, value: hexStringToUIColor("#0C5985"), range: NSRange(location: produtosSimilares[indexPath.item].descricao.count, length: produtosSimilares[indexPath.item].subdescricao.count+1))
        attributedTexto.addAttribute(.font, value: UIFont(name: "Ubuntu-Regular", size: 12.0)!, range: NSRange(location: 0, length: produtosSimilares[indexPath.item].descricao.count))
        attributedTexto.addAttribute(.font, value: UIFont(name: "Ubuntu-Medium", size: 12.0)!, range: NSRange(location: produtosSimilares[indexPath.item].descricao.count, length: produtosSimilares[indexPath.item].subdescricao.count+1))
        
        cell.descricao.attributedText = attributedTexto
        
        return cell
        
    }
    
    @objc func abrirProduto(sender: UIControl){
        
        if (produtosSimilares[sender.tag].estoque == 0){
            return
        }
        
        self.dismiss(animated: false, completion: nil)
        let telaProduto = TelaProduto.inicializeTelaProduto(produto: produtosSimilares[sender.tag], delegate: delegate, delegate2: delegate2)
        self.presentingViewController!.present(telaProduto, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0){
            return 336.0
        } else if (indexPath.section == 1){
            return 295.0
        } else {
            return descricaoLongaHeight + 56.0
        }
    }
    
    var isCabecalhoVisible = true
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (scrollView.tag == 1){
            return
        }
        
        if (scrollView.contentOffset.y > 5){
            if (isCabecalhoVisible){
                UIView.animate(withDuration: 0.25) {
                    
                    //self.imagemSobreposta.alpha = 0
                    
                    self.holder.frame = CGRect(x: self.holder.frame.origin.x, y: (self.yUtilizar - 105.0), width: self.holder.frame.width, height: (self.view.frame.height - (self.yUtilizar - 105.0)))
                    self.holder.layer.cornerRadius = 0.0
                    
                    self.holder.layer.shadowColor = hexStringToUIColor("#00224B").cgColor
                    self.holder.layer.shadowOpacity = 2
                    self.holder.layer.shadowOffset = .zero
                    self.holder.layer.shadowRadius = 3
                }
                isCabecalhoVisible = false
            }
        } else {
            if (!isCabecalhoVisible){
                UIView.animate(withDuration: 0.25) {
                    //self.imagemSobreposta.alpha = 1.0
                    
                    self.holder.frame = CGRect(x: self.holder.frame.origin.x, y: self.yUtilizar, width: self.holder.frame.width, height: (self.view.frame.height - self.yUtilizar))
                    self.holder.layer.cornerRadius = 16.0
                    
                    self.holder.layer.shadowColor = hexStringToUIColor("#00224B").cgColor
                    self.holder.layer.shadowOpacity = 6
                    self.holder.layer.shadowOffset = .zero
                    self.holder.layer.shadowRadius = 10
                }
                isCabecalhoVisible = true
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //let widthScreen = UIScreen.main.bounds.size.width
        //let square = (widthScreen - 16.0)/2 //30 é referente ao espaçamento entre celulas
        
        return CGSize(width: 177.0, height: 227.0)
    }
    
    @IBAction func adicionarAoCarrinho(){
        
        if (produto.estoque == 0){
            let popup = PopupDialog(title: "Ops!", message: "Produto sem estoque!")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        
        botaoAdicionarAoCarrinho.startAnimation()
        botaoAdicionarAoCarrinho.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.5) {
            self.botaoAdicionarAoCarrinho.setTitle("Adicionado!", for: [])
            self.botaoAdicionarAoCarrinho.backgroundColor = hexStringToUIColor("#3C65D1")
            self.fechar()
        }
        CarrinhoObject.get().adicionarAoCarrinho(produto: produto)
        if (delegate != nil){
            delegate.quantidadeCarrinho.text = "\(CarrinhoObject.get().produtos.count)"
            delegate.collectionView.reloadData()
        } else {
            delegate2.quantidadeCarrinho.text = "\(CarrinhoObject.get().produtos.count)"
            delegate2.oTable.reloadData()
        }
    }
    
    @IBAction func favoritar(){
        botaoFavorito.startAnimation()
        DispatchQueue.global(qos: .background).async {
            do {
                try PFUser.current()?.fetch()
                if (PFUser.current()!["favoritos"] != nil){
                    var favoritos = PFUser.current()!["favoritos"] as! [String]
                    if (favoritos.contains(self.produto.produtoId)){
                        var novoFavoritos = [String]()
                        for fav in favoritos {
                            if (fav != self.produto.produtoId){
                                novoFavoritos.append(fav)
                            }
                        }
                        PFUser.current()!["favoritos"] = novoFavoritos
                        try PFUser.current()?.save()
                        
                        DispatchQueue.main.async {
                            self.botaoFavorito.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.0) {
                                self.botaoFavorito.setTitle("Favoritar", for: [])
                                self.botaoFavorito.backgroundColor = hexStringToUIColor("#953B61")
                            }
                        }
                    } else {
                        logAdicionarAosFavoritos(produto: self.produto)
                        favoritos.append(self.produto.produtoId)
                        PFUser.current()!["favoritos"] = favoritos
                        try PFUser.current()?.save()
                        DispatchQueue.main.async {
                            if (self.delegate != nil){
                                self.delegate.collectionView.reloadData()
                            } else {
                                self.delegate2.oTable.reloadData()
                            }
                            self.botaoFavorito.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.0) {
                                self.botaoFavorito.setTitle("Desfavoritar", for: [])
                                self.botaoFavorito.backgroundColor = hexStringToUIColor("#FF344E")
                            }
                        }
                    }
                } else {
                    logAdicionarAosFavoritos(produto: self.produto)
                    var favoritos = [String]()
                    favoritos.append(self.produto.produtoId)
                    PFUser.current()!["favoritos"] = favoritos
                    try PFUser.current()?.save()
                    DispatchQueue.main.async {
                        self.botaoFavorito.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.0) {
                            self.botaoFavorito.setTitle("Desfavoritar", for: [])
                            self.botaoFavorito.backgroundColor = hexStringToUIColor("#FF344E")
                        }
                    }
                }
            } catch {
                
            }
        }
    }
}

class CelulaInfoProduto: UITableViewCell {
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var marca: UILabel!
    @IBOutlet weak var descricao: UITextView!
    @IBOutlet weak var subDescricaoTitle: UILabel!
    @IBOutlet weak var subdescricao: UILabel!
    @IBOutlet weak var dePreco: UILabel!
    @IBOutlet weak var precoAntigo: UILabel!
    @IBOutlet weak var porPreco: UILabel!
    @IBOutlet weak var preco: UILabel!
}

class CelulaDescricao: UITableViewCell {
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var descricaoLonga: UITextView!
}

class CelulaSimilares: UITableViewCell {
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var theCollectionView: UICollectionView!
    @IBOutlet weak var loader: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loader.backgroundColor = UIColor.clear
        let nv = NVActivityIndicatorView(frame: CGRect(origin: .zero, size: loader.frame.size), type: NVActivityIndicatorType.ballClipRotateMultiple, color: hexStringToUIColor("#57005B"), padding: 15.0)
        loader.backgroundColor = UIColor.clear
        loader.addSubview(nv)
        nv.startAnimating()
    }
}

class CelulaProdutoSimilar: UICollectionViewCell {
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var marca: UILabel!
    @IBOutlet weak var descricao: UITextView!
    @IBOutlet weak var preco: UILabel!
    @IBOutlet weak var loader: UIView!
    @IBOutlet weak var viewClicavel: UIControl!
    @IBOutlet weak var estoqueZerado: UIView!
    @IBOutlet weak var imagem: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loader.backgroundColor = UIColor.clear
        let nv = NVActivityIndicatorView(frame: CGRect(origin: .zero, size: loader.frame.size), type: NVActivityIndicatorType.ballClipRotateMultiple, color: hexStringToUIColor("#57005B"), padding: 15.0)
        loader.backgroundColor = UIColor.clear
        loader.addSubview(nv)
        nv.startAnimating()
    }
}
