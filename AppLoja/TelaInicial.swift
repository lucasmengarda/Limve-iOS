//
//  ViewController.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 28/01/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import UIKit
import InteractiveSideMenu
import TransitionButton
import Parse
import NVActivityIndicatorView
import DynamicBlurView
import PopupDialog

class TelaInicial: UIViewController, SideMenuItemContent, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, OrdenarPorDelegate {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var loader: UIView!
    @IBOutlet weak var holderSearch: UIView!
    @IBOutlet weak var searcher: UITextField!
    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var quantidadeCarrinho: UILabel!
    @IBOutlet weak var holderAvisoSemResultados: UIView!
    @IBOutlet weak var collectionView: UICollectionView!

    var widthCell: Double!
    var frameOriginalHolderAviso: CGRect!
    
    var categoria = "amaciante"
    var tituloStr = "Amaciante"
    var produtos = [Produto]()
    var ordenacao: String! = "popularidade"
    var exibindoFavoritos = false
    var buscandoProduto = false
    
    var yUtilizar: CGFloat!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.quantidadeCarrinho.text = "\(CarrinhoObject.get().produtos.count)"
    }
    
    static func inicializeTelaInicial(categoria: String, titulo: String) -> TelaInicial{
        let tela = MAIN_STORYBOARD.instantiateViewController(identifier: "TelaInicial") as! TelaInicial
        tela.tituloStr = titulo
        tela.categoria = categoria
        tela.exibindoFavoritos = false
        return tela
    }
    
    static func inicializeTelaInicialAsProdutosFavoritos() -> TelaInicial{
        let tela = MAIN_STORYBOARD.instantiateViewController(identifier: "TelaInicial") as! TelaInicial
        tela.exibindoFavoritos = true
        tela.tituloStr = "Favoritos"
        return tela
    }
    
    static func inicializeTelaInicialAsBuscarAcionado() -> TelaInicial{
        let tela = MAIN_STORYBOARD.instantiateViewController(identifier: "TelaInicial") as! TelaInicial
        tela.exibindoFavoritos = false
        tela.buscandoProduto = true
        tela.tituloStr = "Amaciante"
        tela.categoria = "amaciante"
        return tela
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titulo.text = tituloStr
        holder.layer.cornerRadius = 16.0
        holder.clipsToBounds = false
        holderAvisoSemResultados.isHidden = true
        frameOriginalHolderAviso = holderAvisoSemResultados.frame
        
        holderSearch.layer.cornerRadius = 16.0
        holderSearch.clipsToBounds = true
        
        holder.layer.shadowColor = hexStringToUIColor("#00224B").cgColor
        holder.layer.shadowOpacity = 6
        holder.layer.shadowOffset = .zero
        holder.layer.shadowRadius = 10
        
        yUtilizar = self.holder.frame.origin.y
        
        var placeHolder = NSMutableAttributedString()
        var name  = ""
        if (buscandoProduto){
            name  = "Digite um produto/marca..."
        } else {
            name  = "Pesquisar por produtos..."
        }
        placeHolder = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont(name: "CeraRoundPro-Light", size: 16.0)!])
        placeHolder.addAttribute(NSAttributedString.Key.foregroundColor, value: hexStringToUIColor("#82E9FF"), range: NSRange(location:0, length: name.count))

        // Add attribute
        searcher.attributedPlaceholder = placeHolder
        
        //flowLayout.headerReferenceSize = CGSize(width: self.collectionView.frame.size.width, height: 100)
        
        widthCell = Double((UIScreen.main.bounds.size.width - 16.0)/2)
        
        collectionView.isHidden = true
        
        loader.backgroundColor = UIColor.clear
        let nv = NVActivityIndicatorView(frame: CGRect(origin: .zero, size: loader.frame.size), type: NVActivityIndicatorType.ballClipRotateMultiple, color: hexStringToUIColor("#3C65D1"), padding: 15.0)
        loader.backgroundColor = UIColor.clear
        loader.addSubview(nv)
        nv.startAnimating()
        
        if (buscandoProduto){
            self.searcher.becomeFirstResponder()
        }
        
        DispatchQueue.global(qos: .background).async {
            do {
                
                if (self.exibindoFavoritos){
                    try PFUser.current()!.fetch()
                    if (PFUser.current()!["favoritos"] != nil){
                        self.query = PFQuery(className: "Produtos").whereKey("objectId", containedIn: (PFUser.current()!["favoritos"] as! [String]))
                    } else {
                        self.query = PFQuery(className: "Produtos").whereKey("objectId", containedIn: [String]())
                    }
                } else {
                    self.query = PFQuery(className: "Produtos").whereKey("categoria", equalTo: self.categoria)
                }
                if (self.ordenacao == "popularidade"){
                    self.query.order(byDescending: "estoque")
                } else if (self.ordenacao == "alfabetica"){
                    self.query.order(byAscending: "descricao")
                } else if (self.ordenacao == "precoMaior"){
                    self.query.order(byDescending: "precodevenda")
                } else if (self.ordenacao == "precoMenor"){
                    self.query.order(byAscending: "precodevenda")
                } else {
                    self.query.order(byAscending: "novidade")
                }

                self.isLoadMorePossible = true
                self.skip = 0
                self.query.limit = 15
                self.query.skip = self.skip
                
                let produtosServer = try self.query.findObjects()
                
                self.produtos.removeAll()
                for produto in produtosServer{
                    self.produtos.append(Produto(produto: produto))
                }
                
                DispatchQueue.main.async {
                    if (self.produtos.count == 0){
                        self.holderAvisoSemResultados.frame = CGRect(x: -self.holderAvisoSemResultados.frame.width, y: self.holderAvisoSemResultados.frame.origin.y, width: self.holderAvisoSemResultados.frame.width, height: self.holderAvisoSemResultados.frame.height)
                        self.holderAvisoSemResultados.isHidden = false
                        UIView.animate(withDuration: 0.35) {
                            self.holderAvisoSemResultados.frame = CGRect(x: self.frameOriginalHolderAviso.origin.x, y: self.holderAvisoSemResultados.frame.origin.y, width: self.holderAvisoSemResultados.frame.width, height: self.holderAvisoSemResultados.frame.height)
                        }
                    } else {
                        
                        if (produtosServer.count == 15){
                            self.isLoadMorePossible = true
                        } else {
                            self.isLoadMorePossible = false
                        }
                        
                        self.holderAvisoSemResultados.isHidden = true
                        self.collectionView.reloadData()
                        self.collectionView.isHidden = false
                        self.lockedToLoadMore = false
                        
                        self.view.layoutIfNeeded()
                    }
                    self.loader.isHidden = true
                    
                    self.quantidadeCarrinho.text = "\(CarrinhoObject.get().produtos.count)"
                }
            } catch {
                
            }
        }
        
        if (exibindoFavoritos){
             self.holder.frame = CGRect(x: self.holder.frame.origin.x, y: (self.yUtilizar-66.0), width: self.holder.frame.width, height: (UIScreen.main.bounds.height - (self.yUtilizar-66.0) ))
        }
    }
    
    func chamadaFromCarrinho(){
        self.quantidadeCarrinho.text = "\(CarrinhoObject.get().produtos.count)"
        self.collectionView.reloadData()
    }
    
    var blurEffectView: UIView!
    @objc func abrirOrdenar(){
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
        
        let adicionar = OrdenarPor.inicializeOrdenarPor(ordenacao: self.ordenacao, delegate: self)
        self.present(adicionar, animated: true, completion: {
            blurView.trackingMode = .none
        })
    }
    
    func onExitOrdenar(sussecefull: Bool, ordenacao: String?) {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.blurEffectView.alpha = 0
        }) { _ in
            self.blurEffectView.removeFromSuperview()
        }
        
        if (sussecefull){

            lockedToLoadMore = true
            self.ordenacao = ordenacao
            self.collectionView.isHidden = true
            self.loader.isHidden = false
            
            DispatchQueue.global(qos: .background).async {
                do {
                    if (self.ordenacao == "popularidade"){
                        self.query.order(byDescending: "estoque")
                    } else if (self.ordenacao == "alfabetica"){
                        self.query.order(byAscending: "descricao")
                    } else if (self.ordenacao == "precoMaior"){
                        self.query.order(byDescending: "precodevenda")
                    } else if (self.ordenacao == "precoMenor"){
                        self.query.order(byAscending: "precodevenda")
                    } else {
                        self.query.order(byAscending: "novidade")
                    }
                    
                    self.isLoadMorePossible = true
                    self.skip = 0
                    self.query.limit = 15
                    self.query.skip = self.skip
                    
                    let produtosServer = try self.query.findObjects()
                    
                    self.produtos.removeAll()
                    for produto in produtosServer{
                        self.produtos.append(Produto(produto: produto))
                    }
                    
                    DispatchQueue.main.async {
                        self.loader.isHidden = true
                        if (produtosServer.count == 15){
                            self.isLoadMorePossible = true
                        } else {
                            self.isLoadMorePossible = false
                        }
                        
                        self.holderAvisoSemResultados.isHidden = true
                        self.collectionView.reloadData()
                        self.collectionView.isHidden = false
                        self.lockedToLoadMore = false
                    }
                    
                } catch {
                    
                }
            }
            
            self.collectionView.reloadData()
        }
    }

    @IBAction func abrirMenu(){
        self.view.endEditing(true)
        showSideMenu()
    }
    
    @IBAction func abrirCarrinho(){
        self.quantidadeCarrinho.text = "\(CarrinhoObject.get().produtos.count)"
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            
            let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerView", for: indexPath as IndexPath) as! CelulaHeader
            
            if (isSearching){
                headerCell.ordenarPorButton.setTitle("Pesquisando por: \(searchText)", for: [])
            } else {
                if (ordenacao == "alfabetica"){
                    headerCell.ordenarPorButton.setTitle("Ordenar por: ordem alfabética", for: [])
                } else if (ordenacao == "popularidade"){
                    headerCell.ordenarPorButton.setTitle("Ordenar por: popularidade", for: [])
                } else if (ordenacao == "precoMaior"){
                    headerCell.ordenarPorButton.setTitle("Ordenar por: preço (maior para o menor)", for: [])
                } else if (ordenacao == "precoMenor"){
                    headerCell.ordenarPorButton.setTitle("Ordenar por: preço (menor para o maior)", for: [])
                } else {
                    headerCell.ordenarPorButton.setTitle("Ordenar por: lançamentos primeiro", for: [])
                }
            }
            
            headerCell.ordenarPorButton.addTarget(self, action: #selector(self.abrirOrdenar), for: .touchUpInside)
            
            return headerCell
        
        default:
            
            let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerView", for: indexPath as IndexPath) as! CelulaHeader
            return headerCell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (isSearching){
            if (isLoadMorePossible){
                return produtosPesquisados.count + 1
            } else {
                return produtosPesquisados.count
            }
        } else {
            if (isLoadMorePossible){
                return produtos.count + 1
            } else {
                return produtos.count
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
      //  let totalCellWidth = widthCell * 2
        //let totalSpacingWidth: Double = 5 * (2 - 1)
        
        //let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        //let rightInset = leftInset
        
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if (isLoadMorePossible && indexPath.item == collectionView.numberOfItems(inSection: 0)-1){
            loadMore()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (isLoadMorePossible){
            var comparativo = 0
            if (isSearching){
                comparativo = produtosPesquisados.count
            } else {
                comparativo = produtos.count
            }
            if (indexPath.item == comparativo){
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CelulaLoader", for: indexPath as IndexPath) as! CelulaLoader
                
                cell.backgroundColor = UIColor.clear
                
                cell.holder.layer.cornerRadius = 6.0
                cell.holder.layer.shadowColor = hexStringToUIColor("#D9E0D9").cgColor
                cell.holder.layer.shadowOpacity = 2
                cell.holder.layer.shadowOffset = .zero
                cell.holder.layer.shadowRadius = 4
                
                return cell
            }
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CelulaProduto", for: indexPath as IndexPath) as! CelulaProduto
        
        cell.backgroundColor = UIColor.clear
        
        cell.holder.layer.cornerRadius = 6.0
        cell.imagem.layer.cornerRadius = 6.0
        cell.imagem.clipsToBounds = true
        
        cell.holder.layer.shadowColor = hexStringToUIColor("#D9E0D9").cgColor
        cell.holder.layer.shadowOpacity = 2
        cell.holder.layer.shadowOffset = .zero
        cell.holder.layer.shadowRadius = 4
        
        cell.botaoAdicionarCarrinho.spinnerColor = UIColor.white
        cell.botaoAdicionarCarrinho.cornerRadius = cell.botaoAdicionarCarrinho.frame.height/2
        cell.botaoAdicionarCarrinho.tag = (indexPath.section*10000) + indexPath.row
        cell.botaoAdicionarCarrinho.addTarget(self, action: #selector(self.botaoAdicionarCarrinhoPressed(sender:)), for: .touchUpInside)
        cell.viewClicavel.tag = indexPath.row
        cell.viewClicavel.addTarget(self, action: #selector(self.abrirProduto(sender:)), for: .touchUpInside)
        
        //__//
        
        var produto: Produto!
        if (isSearching){
            produto = produtosPesquisados[indexPath.row]
        } else {
            produto = produtos[indexPath.row]
        }
        
        
        if (produto.estoque > 0){
            if (CarrinhoObject.get().produtosId.contains(produto.produtoId)){
                cell.botaoAdicionarCarrinho.setTitle("Adicionado!", for: [])
                cell.botaoAdicionarCarrinho.backgroundColor = hexStringToUIColor("#3C65D1")
            } else {
                cell.botaoAdicionarCarrinho.setTitle("Adicionar ao carrinho", for: [])
                cell.botaoAdicionarCarrinho.backgroundColor = hexStringToUIColor("#4BC562")
            }
            cell.estoquezerado.isHidden = true
        } else {
            cell.botaoAdicionarCarrinho.setTitle("Produto sem estoque", for: [])
            cell.botaoAdicionarCarrinho.backgroundColor = hexStringToUIColor("#C9B3B9")
            cell.estoquezerado.isHidden = false
        }
        
        if (PFUser.current()!["favoritos"] != nil){
            if ((PFUser.current()!["favoritos"] as! [String]).contains(produto.produtoId)){
                cell.favorito.isHidden = false
            } else {
                cell.favorito.isHidden = true
            }
        } else {
            cell.favorito.isHidden = true
        }
        
        if (produto.precoSemDesconto != 0.0 && produto.precoSemDesconto > produto.precoVenda){
            cell.precoAntesDaPromocao.isHidden = false
            cell.preco.textColor = hexStringToUIColor("#D13C2F")
            cell.precoAntesDaPromocao.text = formatarPreco(preco: produto.precoSemDesconto)
        } else {
            cell.precoAntesDaPromocao.isHidden = true
            cell.preco.textColor = hexStringToUIColor("#116AB6")
            cell.precoAntesDaPromocao.text = formatarPreco(preco: produto.precoSemDesconto)
        }
        
        if (produto.imagemLoaded){
            cell.loader.isHidden = true
            cell.imagem.isHidden = false
            cell.imagem.tag = indexPath.row
            produto.retornaImagem(imageView: cell.imagem, loader: cell.loader)
        } else {
            cell.loader.isHidden = false
            cell.imagem.isHidden = true
            cell.imagem.tag = indexPath.row
            produto.retornaImagem(imageView: cell.imagem, loader: cell.loader)
        }
        
        cell.marcaProduto.text = produto.marca
        cell.preco.text = formatarPreco(preco: produto.precoVenda)
        
        let texto = "\(produto.descricao!)\n\(produto.subdescricao!)"
        let attributedTexto = NSMutableAttributedString(string: texto)
        attributedTexto.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: produto.descricao.count))
        
        attributedTexto.addAttribute(.foregroundColor, value: hexStringToUIColor("#0C5985"), range: NSRange(location: produto.descricao.count, length: produto.subdescricao.count+1))
        attributedTexto.addAttribute(.font, value: UIFont(name: "Ubuntu-Regular", size: 12.0)!, range: NSRange(location: 0, length: produto.descricao.count))
        attributedTexto.addAttribute(.font, value: UIFont(name: "Ubuntu-Medium", size: 12.0)!, range: NSRange(location: produto.descricao.count, length: produto.subdescricao.count+1))
        
        cell.descricaoProduto.attributedText = attributedTexto
        
        return cell
    }
    
    @objc func abrirProduto(sender: UIControl){
        if (isSearching){
            
            logSearchEvent(produto: produtosPesquisados[sender.tag], searchString: searcher.text!)
            
            let telaProduto = TelaProduto.inicializeTelaProduto(produto: produtosPesquisados[sender.tag], delegate: self)
            self.present(telaProduto, animated: true, completion: nil)
        } else {
            let telaProduto = TelaProduto.inicializeTelaProduto(produto: produtos[sender.tag], delegate: self)
            self.present(telaProduto, animated: true, completion: nil)
        }
    }
    
    @objc func botaoAdicionarCarrinhoPressed(sender: TransitionButton){
        
        
        print("botao apertado")
        let row = sender.tag % 1000
        var produto: Produto!
        if (isSearching){
            produto = produtosPesquisados[row]
        } else {
            produto = produtos[row]
        }
        
        if (produto.estoque == 0){
            return
        }
        
        let section = (sender.tag - row)/1000
        sender.startAnimation()
        sender.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.5) {
            self.collectionView.reloadItems(at: [IndexPath(item: row, section: section)])
        }
        
        CarrinhoObject.get().adicionarAoCarrinho(produto: produto)
        quantidadeCarrinho.text = "\(CarrinhoObject.get().produtos.count)"
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        
    }
    
    var isSearchbarVisible = true
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (exibindoFavoritos){
            return
        }
        var produtosMostrando: [Produto]!
        if (isSearching){
            produtosMostrando = produtosPesquisados
        } else {
            produtosMostrando = produtos
        }
        
        if (scrollView.contentOffset.y > 5 && produtosMostrando.count > 4){
            if (isSearchbarVisible){
                UIView.animate(withDuration: 0.25) {
                    self.holder.frame = CGRect(x: self.holder.frame.origin.x, y: (self.yUtilizar-66.0), width: self.holder.frame.width, height: (UIScreen.main.bounds.height - (self.yUtilizar-66.0)))
                    self.holder.layer.cornerRadius = 0.0
                    
                    self.holder.layer.shadowColor = hexStringToUIColor("#00224B").cgColor
                    self.holder.layer.shadowOpacity = 2
                    self.holder.layer.shadowOffset = .zero
                    self.holder.layer.shadowRadius = 3
                }
                isSearchbarVisible = false
            }
        } else {
            if (!isSearchbarVisible){
                UIView.animate(withDuration: 0.25) {
                    self.holder.frame = CGRect(x: self.holder.frame.origin.x, y: self.yUtilizar, width: self.holder.frame.width, height: (UIScreen.main.bounds.height - self.yUtilizar))
                    self.holder.layer.cornerRadius = 16.0
                    
                    self.holder.layer.shadowColor = hexStringToUIColor("#00224B").cgColor
                    self.holder.layer.shadowOpacity = 6
                    self.holder.layer.shadowOffset = .zero
                    self.holder.layer.shadowRadius = 10
                }
                isSearchbarVisible = true
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let widthScreen = UIScreen.main.bounds.size.width
        let square = (widthScreen - 16.0)/2 //30 é referente ao espaçamento entre celulas
        
        return CGSize(width: square, height: CGFloat(301.0))
    }
    
    var isSearching = false
    var searchText = ""
    var query: PFQuery<PFObject>!
    var skip = 0
    var isLoadMorePossible = false
    var lockedToLoadMore = true
    var produtosPesquisados = [Produto]()
    var xx = 0
    @IBAction func textDidChange(sender: UITextField){
        
        xx += 1
        print("textDidChange called \(xx)")
        searchText = sender.text!
        if (self.query != nil){
            self.query.cancel()
        }
        self.query = nil
        lockedToLoadMore = true
        
        if (searchText.count == 0){
            isSearching = false
            titulo.text = tituloStr
            self.collectionView.reloadData()
            return
        } else {
            titulo.text = "Pesquisa"
            isSearching = true
        }
        
        produtosPesquisados.removeAll()
        collectionView.reloadData()
        
        DispatchQueue.global(qos: .background).async {
            let query1 = PFQuery(className: "Produtos")
            query1.whereKey("descricao", matchesRegex: self.normalizarRegex(texto: self.searchText))
            let query2 = PFQuery(className: "Produtos")
            query2.whereKey("marca", matchesRegex: self.normalizarRegex(texto: self.searchText))
            let query3 = PFQuery(className: "Produtos")
            query3.whereKey("subdescricao", matchesRegex: self.normalizarRegex(texto: self.searchText))
            
            self.query = PFQuery.orQuery(withSubqueries: [query1, query2, query3])
            if (self.ordenacao == "popularidade"){
                self.query.order(byDescending: "estoque")
            } else if (self.ordenacao == "alfabetica"){
                self.query.order(byAscending: "descricao")
            } else if (self.ordenacao == "precoMaior"){
                self.query.order(byDescending: "precodevenda")
            } else if (self.ordenacao == "precoMenor"){
                self.query.order(byAscending: "precodevenda")
            } else {
                self.query.order(byAscending: "novidade")
            }
            self.isLoadMorePossible = true
            self.skip = 0
            self.query.limit = 15
            self.query.skip = self.skip
            
            do {
                let objects = try self.query.findObjects()
                print(objects)
                print("Quantidade: \(objects.count)")
                if (objects.count == 15){
                    self.isLoadMorePossible = true
                } else {
                    self.isLoadMorePossible = false
                }
                
                DispatchQueue.main.async {
                    self.produtosPesquisados.removeAll()
                    var prodsId = [String]()
                    for obj in objects {
                        let prod = Produto(produto: obj)
                        if (!prodsId.contains(prod.produtoId)){
                            self.produtosPesquisados.append(prod)
                            prodsId.append(prod.produtoId)
                        }
                    }
                    
                    self.collectionView.reloadData()
                    self.lockedToLoadMore = false
                }
            } catch {
                
            }
        }
    }
    
    func loadMore(){
        
        if (lockedToLoadMore){
            return
        }
        
        if (query == nil){
            return
        }
        
        self.skip += 15
        DispatchQueue.global(qos: .background).async {
            
            self.query.skip = self.skip
            if (self.ordenacao == "popularidade"){
                self.query.order(byDescending: "estoque")
            } else if (self.ordenacao == "alfabetica"){
                self.query.order(byAscending: "descricao")
            } else if (self.ordenacao == "precoMaior"){
                self.query.order(byDescending: "precodevenda")
            } else if (self.ordenacao == "precoMenor"){
                self.query.order(byAscending: "precodevenda")
            } else {
                self.query.order(byAscending: "novidade")
            }
            
            do {
                let objects = try self.query.findObjects()
                
                if (objects.count == 15){
                    self.isLoadMorePossible = true
                } else {
                    self.isLoadMorePossible = false
                }
                
                DispatchQueue.main.async {
                    var prodsId = [String]()
                    for obj in objects {
                        let prod = Produto(produto: obj)
                        if (self.isSearching){
                            self.produtosPesquisados.append(prod)
                            prodsId.append(prod.produtoId)
                        } else {
                            self.produtos.append(prod)
                            prodsId.append(prod.produtoId)
                        }
                    }
                    
                    self.collectionView.reloadData()
                }
                
            } catch {
                
            }
        }
    }
    
    func normalizarRegex(texto: String) -> String {
        var textoNormalizado = texto.folding(options: .diacriticInsensitive, locale: Locale.current)
        var regex = "^(?i)\\b.*(?="
        textoNormalizado = textoNormalizado.replacingOccurrences(of: "e", with: "[éeèêë]")
        textoNormalizado = textoNormalizado.replacingOccurrences(of: "a", with: "[áaâàã]")
        textoNormalizado = textoNormalizado.replacingOccurrences(of: "i", with: "[iíìî]")
        textoNormalizado = textoNormalizado.replacingOccurrences(of: "u", with: "[úuùûü]")
        textoNormalizado = textoNormalizado.replacingOccurrences(of: "o", with: "[óoòôöõ]")
        textoNormalizado = textoNormalizado.replacingOccurrences(of: "c", with: "[cç]")
        regex.append(textoNormalizado)
        regex.append(").*\\b")
        print("regex: \(regex)")
        return regex
    }
    
    @IBAction func returnButton(){
        self.view.endEditing(true)
    }
}

class CelulaProduto: UICollectionViewCell {
    @IBOutlet weak var loader: UIView!
    @IBOutlet weak var imagem: UIImageView!
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var marcaProduto: UILabel!
    @IBOutlet weak var descricaoProduto: UITextView!
    @IBOutlet weak var subDescricaoProduto: UILabel!
    @IBOutlet weak var preco: UILabel!
    @IBOutlet weak var botaoAdicionarCarrinho: TransitionButton!
    @IBOutlet weak var viewClicavel: UIControl!
    @IBOutlet weak var favorito: UIImageView!
    @IBOutlet weak var estoquezerado: UIView!
    @IBOutlet weak var precoAntesDaPromocao: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loader.backgroundColor = UIColor.clear
        let nv = NVActivityIndicatorView(frame: CGRect(origin: .zero, size: loader.frame.size), type: NVActivityIndicatorType.ballClipRotateMultiple, color: hexStringToUIColor("#3C65D1"), padding: 15.0)
        loader.backgroundColor = UIColor.clear
        loader.addSubview(nv)
        nv.startAnimating()
        
    }
}

class CelulaLoader: UICollectionViewCell {
    @IBOutlet weak var loader: UIView!
    @IBOutlet weak var holder: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loader.backgroundColor = UIColor.clear
        let nv = NVActivityIndicatorView(frame: CGRect(origin: .zero, size: loader.frame.size), type: NVActivityIndicatorType.ballClipRotateMultiple, color: hexStringToUIColor("#3C65D1"), padding: 15.0)
        loader.backgroundColor = UIColor.clear
        loader.addSubview(nv)
        nv.startAnimating()
        
    }
}

class CelulaHeader: UICollectionReusableView {
    @IBOutlet weak var ordenarPorButton: UIButton!
}
