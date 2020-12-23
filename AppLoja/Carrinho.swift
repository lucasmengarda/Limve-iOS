//
//  Carrinho.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 11/02/20.
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
import FBSDKCoreKit

protocol CarrinhoDelegate {
    func chamadaFromCarrinho()
}

class Carrinho: UIViewController, UITableViewDelegate, UITableViewDataSource, EnderecoDelegate, ParcelamentoDelegate, AdicionarCartaoDelegate, DocumentoFiscalDelegate, CvvDelegate, ObrigadoDelegate, MelhoreSuaExperienciaDelegate {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var oTable: UITableView!
    
    
    var taxaDeEntregaDouble: Double!
    var minimoParcelamento: Double!
    var raioEntregaGratis: Double!
    var minimoTaxaDeEntregaGratis: Double!
    var pontoOrigemLimve: PFGeoPoint!
    var parcelar = 1
    static var cpfCnpj: String!
    static var nome: String!
    static var cartaoSelecionado: Cartao!
    static var formaPagamentoSelecionado: String = ""
    static var possuiCartao = false
    var delegate: CarrinhoDelegate!
    var cupomAtivoLimveCreditos = false

    static var trocoPara = 0.0
    static var pagueEntregaStr = ""
    
    static func inicializeCarrinho(delegate: CarrinhoDelegate) -> Carrinho{
        let car = MAIN_STORYBOARD.instantiateViewController(identifier: "Carrinho") as! Carrinho
        car.delegate = delegate
        return car
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        oTable.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] timer in
            print("Timer fired - Carrinho!")
            
            if (CUPOM_SALVO.count > 0){
                if (self.oTable.cellForRow(at: IndexPath(row: 0, section: 3)) != nil){
                    let sender = (self.oTable.cellForRow(at: IndexPath(row: 0, section: 3)) as! CelulaCupomOferta).botaoCupom
                    self.validarCupomDeDesconto(sender: sender!)
                    timer.invalidate()
                }
            } else {
                timer.invalidate()
            }
        }
        
        taxaDeEntregaDouble = (configuration.object(forKey: "taxaDeEntrega") as! Double)
        minimoParcelamento = (configuration.object(forKey: "minimoParcelamento") as! Double)
        minimoTaxaDeEntregaGratis = (configuration.object(forKey: "minimoTaxaDeEntregaGratis") as! Double)
        raioEntregaGratis = (configuration.object(forKey: "RAIO_ENTREGAGRATIS") as! Double)
        pontoOrigemLimve = PFGeoPoint(latitude: -25.423647, longitude: -49.252177)
        
        holder.layer.cornerRadius = 16.0
        //holder.clipsToBounds = false
        
        holder.layer.shadowColor = hexStringToUIColor("#00224B").cgColor
        holder.layer.shadowOpacity = 6
        holder.layer.shadowOffset = .zero
        holder.layer.shadowRadius = 10
        
        oTable.backgroundColor = UIColor.clear
        
        if (Carrinho.cpfCnpj == nil){
            if (PFUser.current()!["cpf"] != nil){
                Carrinho.cpfCnpj = (PFUser.current()!["cpf"] as! String)
            } else {
                Carrinho.cpfCnpj = ""
            }
            if (PFUser.current()!["nome"] != nil){
                Carrinho.nome = (PFUser.current()!["nome"] as! String)
            } else {
                Carrinho.nome = ""
            }
        }
    }
    
    @IBAction func fechar(){
        self.delegate.chamadaFromCarrinho()
        self.dismiss(animated: true, completion: nil)
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
    
    @IBAction func alterarEndereco(sender: TransitionButton){
        
        inicializarEfeitosDeBlur()
        
        let adicionar = Endereco.inicializeEndereco(delegate: self)
        self.present(adicionar, animated: true, completion: {
            self.blurView.trackingMode = .none
        })
    }
    
    func onAdicionarEndereco(sucesso: Bool, novoEndereco: String?) {
        UIView.animate(withDuration: 0.25, animations: {
            self.blurEffectView.alpha = 0
        }) { _ in
            self.blurEffectView.removeFromSuperview()
        }
        
        if (sucesso){
            if (cupomAtivo){
                self.oTable.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableView.RowAnimation.automatic)
                calcularTotais(true)
                self.oTable.reloadRows(at: [IndexPath(row: 0, section: 4), IndexPath(row: 0, section: 5)], with: UITableView.RowAnimation.automatic)
            } else {
                self.oTable.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableView.RowAnimation.automatic)
                self.oTable.reloadRows(at: [IndexPath(row: 0, section: 4), IndexPath(row: 0, section: 5)], with: UITableView.RowAnimation.automatic)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0){
            return 1
        } else if (section == 1){
            return CarrinhoObject.get().produtosId.count + 1
        } else if (section == 2){
            return 1
        } else if (section == 3) {
            return 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaEntrega") as! CelulaEntrega
            
            cell.holder.layer.cornerRadius = 6.0
            cell.holder.layer.shadowColor = hexStringToUIColor("#D9E0D9").cgColor
            cell.holder.layer.shadowOpacity = 2
            cell.holder.layer.shadowOffset = .zero
            cell.holder.layer.shadowRadius = 4
            
            cell.botao.backgroundColor = hexStringToUIColor("#4BC562")
            cell.botao.spinnerColor = UIColor.white
            cell.botao.cornerRadius = cell.botao.frame.height/2
            
            if (PFUser.current()!["enderecoEntrega"] != nil){
                cell.imagem.image = UIImage(named: "map.png")
                cell.endereco.text = (PFUser.current()!["enderecoEntrega"] as! String)
                cell.botao.setTitle("Alterar meu endereço", for: [])
            } else {
                cell.imagem.image = UIImage(named: "lost.png")
                cell.endereco.text = "Nenhum endereço cadastrado"
                cell.botao.setTitle("Pesquisar meu endereço", for: [])
            }
            
            cell.backgroundColor = UIColor.clear
            
            return cell
        } else if (indexPath.section == 1){
            if (indexPath.row == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaItemCarrinhoHeader") as! CelulaItemCarrinhoHeader
                
                cell.holder.layer.shadowColor = hexStringToUIColor("#D9E0D9").cgColor
                cell.holder.layer.shadowOpacity = 2
                cell.holder.layer.shadowOffset = .zero
                cell.holder.layer.shadowRadius = 4
                
                cell.backgroundColor = UIColor.clear
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaItemCarrinho") as! CelulaItemCarrinho
                
                cell.holder.layer.shadowColor = hexStringToUIColor("#D9E0D9").cgColor
                cell.holder.layer.shadowOpacity = 2
                cell.holder.layer.shadowOffset = .zero
                cell.holder.layer.shadowRadius = 4
                
                cell.backgroundColor = UIColor.clear
                
                let produto = CarrinhoObject.get().produtos[indexPath.row - 1]
                
                cell.marca.text = produto.marca
                cell.preco.text = formatarPreco(preco: produto.valorDesteProdutoNoCarrinho)
                cell.quantidade.text = "\(produto.quantidade)x"
                produto.retornaImagem(imageView: cell.imagem, loader: cell.loader)
                
                cell.botaoMais.tag = (indexPath.row - 1)
                cell.botaoMais.addTarget(self, action: #selector(self.aumentarQuantidade(sender:)), for: .touchUpInside)
                cell.botaoMenos.tag = (indexPath.row - 1)
                cell.botaoMenos.addTarget(self, action: #selector(self.diminuirQuantidade(sender:)), for: .touchUpInside)
                
                let texto = "\(produto.descricao!)\n\(produto.subdescricao!)"
                let attributedTexto = NSMutableAttributedString(string: texto)
                attributedTexto.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: produto.descricao.count))
                
                attributedTexto.addAttribute(.foregroundColor, value: hexStringToUIColor("#0C5985"), range: NSRange(location: produto.descricao.count, length: produto.subdescricao.count+1))
                attributedTexto.addAttribute(.font, value: UIFont(name: "Ubuntu-Regular", size: 12.0)!, range: NSRange(location: 0, length: produto.descricao.count))
                attributedTexto.addAttribute(.font, value: UIFont(name: "Ubuntu-Medium", size: 12.0)!, range: NSRange(location: produto.descricao.count, length: produto.subdescricao.count+1))
                
                cell.descricao.attributedText = attributedTexto
                
                return cell
            }
            
        } else if (indexPath.section == 2) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaLimveCreditos") as! CelulaLimveCreditos
            
            cell.holder.layer.cornerRadius = 6.0
            cell.holder.layer.shadowColor = hexStringToUIColor("#D9E0D9").cgColor
            cell.holder.layer.shadowOpacity = 2
            cell.holder.layer.shadowOffset = .zero
            cell.holder.layer.shadowRadius = 4
            
            cell.backgroundColor = UIColor.clear
            
            var saldoDou = 0.0
            if (PFUser.current()!["saldoLimveCreditos"] != nil){
                saldoDou = (PFUser.current()!["saldoLimveCreditos"] as! Double)
            }
            let saldoStr = "Seu saldo: \(formatarPreco(preco: saldoDou))"
            let attributedTexto3 = NSMutableAttributedString(string: saldoStr)
            attributedTexto3.addAttribute(.font, value: UIFont(name: "Ubuntu-Regular", size: 13.0)!, range: NSRange(location: 0, length: saldoStr.count))
            attributedTexto3.addAttribute(.font, value: UIFont(name: "Ubuntu-Bold", size: 17.0)!, range: NSRange(location: 11, length: (saldoStr.count - 11)))
            
            
            cell.seuSaldo.attributedText = attributedTexto3
            
            let texto = "LimveCréditos"
            let attributedTexto = NSMutableAttributedString(string: texto)
            attributedTexto.addAttribute(.font, value: UIFont(name: "Ubuntu-Bold", size: 20.0)!, range: NSRange(location: 0, length: 5))
            attributedTexto.addAttribute(.font, value: UIFont(name: "Ubuntu-Light", size: 20.0)!, range: NSRange(location: 5, length: 8))
            
            cell.limveCreditosLabel.attributedText = attributedTexto
            
            if (utilizandoLimveCreditos){
                cell.botaoUsarMeusCreditos.backgroundColor = hexStringToUIColor("#F26161")
                cell.botaoUsarMeusCreditos.setTitle("Parar de usar meu saldo", for: [])
            } else {
                cell.botaoUsarMeusCreditos.backgroundColor = hexStringToUIColor("#3C65D1")
                cell.botaoUsarMeusCreditos.setTitle("Utilizar meu saldo", for: [])
            }
            
            cell.botaoUsarMeusCreditos.spinnerColor = UIColor.white
            cell.botaoUsarMeusCreditos.cornerRadius = 6.0
            cell.botaoUsarMeusCreditos.addTarget(self, action: #selector(usarLimveCreditosButton(sender:)), for: .touchUpInside)
            
            cell.viewClicavel.addTarget(self, action: #selector(abrirLimveCreditos), for: .touchUpInside)
            
            if (saldoDou == 0.0){
                cell.botaoUsarMeusCreditos.isEnabled = false
                cell.botaoUsarMeusCreditos.alpha = 0.45
            } else {
                cell.botaoUsarMeusCreditos.isEnabled = true
                cell.botaoUsarMeusCreditos.alpha = 1.0
            }
            
            return cell
            
        } else if (indexPath.section == 3){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaCupomOferta") as! CelulaCupomOferta
            
            cell.holder.layer.cornerRadius = 6.0
            cell.holder.layer.shadowColor = hexStringToUIColor("#D9E0D9").cgColor
            cell.holder.layer.shadowOpacity = 2
            cell.holder.layer.shadowOffset = .zero
            cell.holder.layer.shadowRadius = 4
            
            cell.backgroundColor = UIColor.clear
            
            cell.botaoCupom.backgroundColor = hexStringToUIColor("#F26161")
            cell.botaoCupom.spinnerColor = UIColor.white
            cell.botaoCupom.cornerRadius = 6.0
            cell.botaoCupom.tag = 1
            cell.botaoCupom.addTarget(self, action: #selector(validarCupomDeDesconto(sender:)), for: .touchUpInside)
            
            if (CUPOM_SALVO.count > 0){
                cell.cupom.text = CUPOM_SALVO
            }
            
            return cell
            
        } else if (indexPath.section == 4){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaFinal") as! CelulaFinal
            
            cell.holder.layer.cornerRadius = 6.0
            cell.holder.layer.shadowColor = hexStringToUIColor("#D9E0D9").cgColor
            cell.holder.layer.shadowOpacity = 2
            cell.holder.layer.shadowOffset = .zero
            cell.holder.layer.shadowRadius = 4
            
            cell.backgroundColor = UIColor.clear
            
            
            var precoTotal = 0.0
            var taxaEntrega = 0.0
            var desconto = 0.0
            if (cupomAtivo){
                taxaEntrega = taxaDeEntregaDouble
                precoTotal = precoAposCupom
                desconto = (CarrinhoObject.get().valorDoCarrinho + taxaEntrega) - precoAposCupom
            } else {
                if (PFUser.current()!["enderecoPoint"] == nil){
                    taxaEntrega = -1.0
                } else {
                    let point = PFUser.current()!["enderecoPoint"] as! PFGeoPoint
                    print("verificando entrega grátis: \(point.distanceInKilometers(to: pontoOrigemLimve))")
                    if (point.distanceInKilometers(to: pontoOrigemLimve) > raioEntregaGratis){
                        if (CarrinhoObject.get().valorDoCarrinho < minimoTaxaDeEntregaGratis){
                            taxaEntrega = taxaDeEntregaDouble
                        }
                    }
                }
                
                precoTotal = (CarrinhoObject.get().valorDoCarrinho + taxaEntrega)
            }
            
            cell.total.text = formatarPreco(preco: precoTotal)
            cell.desconto.text = "- \(formatarPreco(preco: desconto))"
            if (taxaEntrega == 0.0){
                cell.taxaDeEntrega.text = "Grátis"
                cell.taxaDeEntrega.font = UIFont(name: "CeraRoundPro-Medium", size: 20.0)
            } else if (taxaEntrega == -1.0) {
                cell.taxaDeEntrega.text = "Sem endereço"
                cell.taxaDeEntrega.font = UIFont(name: "CeraRoundPro-Light", size: 15.0)
            } else {
                cell.taxaDeEntrega.text = formatarPreco(preco: taxaEntrega)
                cell.taxaDeEntrega.font = UIFont(name: "CeraRoundPro-Light", size: 20.0)
            }
            
            cell.totalItens.text = "Total - \(CarrinhoObject.get().produtosId.count) produtos:"
            
            if (CarrinhoObject.get().valorDoCarrinho > minimoParcelamento){
                let div3 = precoTotal/3
                cell.parcelado.text = "(ou 3x de \(formatarPreco(preco: div3)))"
            } else {
                cell.parcelado.text = "Parcelamento apenas em compras acima de \(formatarPreco(preco: minimoParcelamento))"
            }
            
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaPagamento") as! CelulaPagamento
            
            cell.holder.layer.cornerRadius = 6.0
            cell.holder.layer.shadowColor = hexStringToUIColor("#D9E0D9").cgColor
            cell.holder.layer.shadowOpacity = 2
            cell.holder.layer.shadowOffset = .zero
            cell.holder.layer.shadowRadius = 4
            
            cell.botao.backgroundColor = hexStringToUIColor("#4BC562")
            cell.botao.spinnerColor = UIColor.white
            cell.botao.cornerRadius = cell.botao.frame.height/2
            cell.botao.addTarget(self, action: #selector(self.finalizarCompra(sender:)), for: .touchUpInside)
            
            cell.botaoTrocarCPF.backgroundColor = hexStringToUIColor("#3C65D1")
            cell.botaoTrocarCPF.spinnerColor = UIColor.white
            cell.botaoTrocarCPF.cornerRadius = 6.0
            cell.botaoTrocarCPF.addTarget(self, action: #selector(self.trocarDocumentoFiscal(isFinalizacao:)), for: .touchUpInside)
            
            cell.botaoTrocarParcelamento.backgroundColor = hexStringToUIColor("#3C65D1")
            cell.botaoTrocarParcelamento.spinnerColor = UIColor.white
            cell.botaoTrocarParcelamento.cornerRadius = 6.0
            cell.botaoTrocarParcelamento.addTarget(self, action: #selector(self.alterarParcelamento), for: .touchUpInside)
            
            if (CarrinhoObject.get().valorDoCarrinho > minimoParcelamento){
                if (Carrinho.formaPagamentoSelecionado == "credito"){
                    cell.botaoTrocarParcelamento.isHidden = false
                } else {
                    self.parcelar = 1
                    cell.botaoTrocarParcelamento.isHidden = true
                }
            } else {
                self.parcelar = 1
                cell.botaoTrocarParcelamento.isHidden = true
            }
            
            if (Carrinho.cpfCnpj.count == 0){
                cell.trocarCPF.text = "Sem documento fiscal"
            } else {
                cell.trocarCPF.text = Carrinho.cpfCnpj
            }
            
            if (Carrinho.nome.count == 0){
                cell.trocarNome.text = "Consumidor não identificado"
            } else {
                cell.trocarNome.text = Carrinho.nome
            }
            
            var taxaEntrega = 0.0
            if (CarrinhoObject.get().valorDoCarrinho < minimoTaxaDeEntregaGratis){
                taxaEntrega = taxaDeEntregaDouble
            }
            var precoTotal = 0.0
            if (cupomAtivo){
                precoTotal = precoAposCupom
            } else {
                precoTotal = (CarrinhoObject.get().valorDoCarrinho + taxaEntrega)
            }
            
            if (parcelar == 1){
                cell.trocarParcelamento.text = "1x de \(formatarPreco(preco: precoTotal))"
            } else if (parcelar == 2){
                cell.trocarParcelamento.text = "2x de \(formatarPreco(preco: precoTotal/2))"
            } else {
                cell.trocarParcelamento.text = "3x de \(formatarPreco(preco: precoTotal/3))"
            }
            
            cell.botaoTrocarPagamento.backgroundColor = hexStringToUIColor("#3C65D1")
            cell.botaoTrocarPagamento.spinnerColor = UIColor.white
            cell.botaoTrocarPagamento.cornerRadius = 6.0
            cell.botaoTrocarPagamento.addTarget(self, action: #selector(self.adicionarPagamento), for: .touchUpInside)
            
            cell.backgroundColor = UIColor.clear
            
            
            if (precoTotal == 0.0){
                cell.botaoTrocarPagamento.isHidden = true
                cell.loader.isHidden = true
                cell.restanteView.isHidden = false
                cell.trocarPagamento.text = "Usando LimveCréditos"
            } else {
                cell.botaoTrocarPagamento.isHidden = false
                if (Carrinho.cartaoSelecionado == nil){
                    
                    if (Carrinho.formaPagamentoSelecionado == ""){
                        if (Carrinho.possuiCartao){
                            cell.pagarEntregaLabel.isHidden = true
                            cell.loader.isHidden = true
                            cell.restanteView.isHidden = false
                            cell.trocarPagamento.text = "Selecione como irá pagar"
                            cell.botaoTrocarPagamento.setTitle("Escolher", for: [])
                        } else {
                            cell.loader.isHidden = false
                            cell.restanteView.isHidden = true
                            
                            DispatchQueue.global(qos: .background).async {
                                do {
                                    
                                    let cartoesObj = try PFQuery(className: "Cartoes").findObjects()
                                    if (cartoesObj.count > 0){
                                        Carrinho.cartaoSelecionado = Cartao(cartao: cartoesObj[0])
                                        if (Carrinho.cartaoSelecionado.cartaoStyle == CartaoStyle.credito){
                                            Carrinho.formaPagamentoSelecionado = "credito"
                                        } else {
                                            Carrinho.formaPagamentoSelecionado = "debito"
                                        }
                                    } else {
                                        Carrinho.possuiCartao = true
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.oTable.reloadData()
                                    }
                                } catch {
                                    
                                }
                            }
                        }
                    } else {
                        cell.loader.isHidden = true
                        cell.restanteView.isHidden = false
                        cell.pagarEntregaLabel.isHidden = true
                        if (Carrinho.formaPagamentoSelecionado == "boleto"){
                            cell.trocarPagamento.text = "Boleto bancário"
                        } else if (Carrinho.formaPagamentoSelecionado == "transferencia"){
                            cell.trocarPagamento.text = "Transferência bancária"
                        } else if (Carrinho.formaPagamentoSelecionado.contains("entrega")) {
                            cell.trocarPagamento.text = "Pagar na entrega"
                            cell.pagarEntregaLabel.isHidden = false
                            cell.pagarEntregaLabel.text = Carrinho.pagueEntregaStr
                        } else {
                            cell.trocarPagamento.text = "Auxílio emergencial Caixa"
                        }
                        cell.botaoTrocarPagamento.setTitle("Trocar", for: [])
                    }
                    
                } else {
                    cell.pagarEntregaLabel.isHidden = true
                    if (Carrinho.formaPagamentoSelecionado == "credito" || Carrinho.formaPagamentoSelecionado == "debito"){
                        if (Carrinho.cartaoSelecionado.bandeira == CartaoTipo.mastercard){
                            if (Carrinho.cartaoSelecionado.cartaoStyle == CartaoStyle.credito){
                                cell.trocarPagamento.text = "{CC} MasterCard *** \(Carrinho.cartaoSelecionado.final!)"
                            } else {
                                cell.trocarPagamento.text = "{DB} Maestro *** \(Carrinho.cartaoSelecionado.final!)"
                            }
                        } else if (Carrinho.cartaoSelecionado.bandeira == CartaoTipo.visa){
                            if (Carrinho.cartaoSelecionado.cartaoStyle == CartaoStyle.credito){
                                cell.trocarPagamento.text = "{CC} Visa *** \(Carrinho.cartaoSelecionado.final!)"
                            } else {
                                cell.trocarPagamento.text = "{DB} Visa Electron *** \(Carrinho.cartaoSelecionado.final!)"
                            }
                        } else if (Carrinho.cartaoSelecionado.bandeira == CartaoTipo.elo){
                            if (Carrinho.cartaoSelecionado.cartaoStyle == CartaoStyle.credito){
                                cell.trocarPagamento.text = "{CC} Elo *** \(Carrinho.cartaoSelecionado.final!)"
                            } else {
                                cell.trocarPagamento.text = "{DB} Elo *** \(Carrinho.cartaoSelecionado.final!)"
                            }
                        } else if (Carrinho.cartaoSelecionado.bandeira == CartaoTipo.amex){
                            if (Carrinho.cartaoSelecionado.cartaoStyle == CartaoStyle.credito){
                                cell.trocarPagamento.text = "{CC} Amex *** \(Carrinho.cartaoSelecionado.final!)"
                            } else {
                                cell.trocarPagamento.text = "{DB} Amex *** \(Carrinho.cartaoSelecionado.final!)"
                            }
                        } else {
                            if (Carrinho.cartaoSelecionado.cartaoStyle == CartaoStyle.credito){
                                cell.trocarPagamento.text = "{CC} \(Carrinho.cartaoSelecionado.bandeiraOutro!) *** \(Carrinho.cartaoSelecionado.final!)"
                            } else {
                                cell.trocarPagamento.text = "{DB} \(Carrinho.cartaoSelecionado.bandeiraOutro!) *** \(Carrinho.cartaoSelecionado.final!)"
                            }
                        }
                    } else if (Carrinho.formaPagamentoSelecionado == "boleto") {
                        cell.trocarPagamento.text = "Boleto bancário"
                    } else if (Carrinho.formaPagamentoSelecionado == "transferencia"){
                        cell.trocarPagamento.text = "Transferência bancária"
                    } else if (Carrinho.formaPagamentoSelecionado.contains("entrega")) {
                        cell.trocarPagamento.text = "Pague na entrega"
                        cell.pagarEntregaLabel.isHidden = false
                        cell.pagarEntregaLabel.text = Carrinho.pagueEntregaStr
                    }
                    
                    cell.loader.isHidden = true
                    cell.restanteView.isHidden = false
                    cell.botaoTrocarPagamento.setTitle("Trocar", for: [])
                }
            }
            
            return cell
        }
        
    }
    
    var utilizandoLimveCreditos = false
    @objc func usarLimveCreditosButton(sender: TransitionButton){
        
        if (!utilizandoLimveCreditos){
            var codigo = ""
            if (PFUser.current()!["codLimveCreditos"] == nil){
                codigo = "limve_\(PFUser.current()!.objectId!)"
            } else {
                codigo = (PFUser.current()!["codLimveCreditos"] as! String)
            }
            
            utilizandoLimveCreditos = true
            (oTable.cellForRow(at: IndexPath(row: 0, section: 3)) as! CelulaCupomOferta).cupom.text = codigo
            validarCupomDeDesconto(sender: (oTable.cellForRow(at: IndexPath(row: 0, section: 3)) as! CelulaCupomOferta).botaoCupom)
            
            oTable.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .automatic)
            
        } else {
            
            utilizandoLimveCreditos = false
            (oTable.cellForRow(at: IndexPath(row: 0, section: 3)) as! CelulaCupomOferta).cupom.text = ""
            cupomAtivo = false
            oTable.reloadData()
            
        }
        
    }
    
    var cupomAtivo: Bool = false
    var precoAposCupom = 0.0
    @objc func validarCupomDeDesconto(sender: TransitionButton){
        
        if (PFUser.current()!["enderecoPoint"] == nil){
            let popup = PopupDialog(title: "Ops!", message: "Para validar seu cupom, cadastre um endereço primeiro.")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        
        (self.oTable.cellForRow(at: IndexPath(row: 0, section: 3)) as! CelulaCupomOferta).avisoCupom.text = "VALIDANDO..."
        let textoCupom = (oTable.cellForRow(at: IndexPath(row: 0, section: 3)) as! CelulaCupomOferta).cupom.text
        print("TEXTO DO CUPOM: \(textoCupom)")
        
        if (textoCupom == nil || textoCupom?.count == 0){
            let popup = PopupDialog(title: "Ops!", message: "Você não inseriu nenhum cupom de desconto.")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        
        self.view.endEditing(true)
        
        var params = [String : Any]()
        var produtosManual = [[String : Any]]()
        for x in 0 ... CarrinhoObject.get().produtos.count - 1 {
            
            let produto = CarrinhoObject.get().produtos[x]
            produtosManual.append(["precoUnitario": produto.precoVenda!, "quantidade": produto.quantidade, "produtoId": produto.produtoId!])
        }
        
        let geop = (PFUser.current()!["enderecoPoint"] as! PFGeoPoint)
        params["localizacaoEntregaLat"] = geop.latitude
        params["localizacaoEntregaLng"] = geop.longitude

        params["carrinho"] = produtosManual
        params["cupom"] = textoCupom!.replacingOccurrences(of: " ", with: "")

        PFCloud.callFunction(inBackground: "aplicarCupom", withParameters: params) { [self] (resultado, erro) in
            
            if (resultado != nil){
                let resultadoJson = resultado as! [String: Any]
                
                if (resultadoJson["erro"] as! Bool){
                    
                    self.taxaDeEntregaDouble = (configuration["taxaDeEntrega"] as! Double)
                    calcularTotais(false)
                    let motivo = (resultadoJson["motivo"] as! String)
                    self.cupomAtivo = false
                    self.cupomAtivoLimveCreditos = false
                    
                    if (resultadoJson["erroValorMinimo"] == nil){
                        let popup = PopupDialog(title: "Ops!", message: motivo)
                        popup.buttonAlignment = .horizontal
                        popup.transitionStyle = .bounceUp
                        let button = CancelButton(title: "Ok", action: {
                        })
                        popup.addButton(button)
                        // Present dialog
                        self.present(popup, animated: true, completion: nil)
                    } else {
                        self.cupomAtivoLimveCreditos = true
                    }
                    
                    if (self.oTable.cellForRow(at: IndexPath(row: 0, section: 3)) != nil){
                        (self.oTable.cellForRow(at: IndexPath(row: 0, section: 3)) as! CelulaCupomOferta).avisoCupom.text = motivo.uppercased()
                    }
                    
                    oTable.reloadData()
                    
                    return
                }
                
                let mensagem = resultadoJson["mensagem"] as! String
                let taxaDeEntrega = resultadoJson["taxaDeEntrega"] as! Double
                precoAposCupom = resultadoJson["precoAposCupom"] as! Double
                
                if (!cupomAtivo){
                    (oTable.cellForRow(at: IndexPath(row: 0, section: 3)) as! CelulaCupomOferta).botaoCupom.tag = 0
                    self.showToast(message: "Cupom aplicado!", font: UIFont(name: "CeraRoundPro-Medium", size: 17.0)!)
                }
                
                (self.oTable.cellForRow(at: IndexPath(row: 0, section: 3)) as! CelulaCupomOferta).avisoCupom.text = mensagem
                taxaDeEntregaDouble = taxaDeEntrega
                cupomAtivo = true
                
                calcularTotais(false)
                oTable.reloadData()
                
            } else {
                (self.oTable.cellForRow(at: IndexPath(row: 0, section: 3)) as! CelulaCupomOferta).avisoCupom.text = "SE TIVER UM CUPOM, DIGITE-O ACIMA"
                self.cupomAtivo = false
                self.taxaDeEntregaDouble = (configuration["taxaDeEntrega"] as! Double)
                calcularTotais(false)
                oTable.reloadData()
                
                let popup = PopupDialog(title: "Ops!", message: "Ocorreu um erro interno. Tente novamente")
                popup.buttonAlignment = .horizontal
                popup.transitionStyle = .bounceUp
                let button = CancelButton(title: "Ok", action: {
                })
                popup.addButton(button)
                // Present dialog
                self.present(popup, animated: true, completion: nil)
            }
        }
        
    }
    
    func calcularTotais(_ alterandoQuantidades: Bool){
        
        if (alterandoQuantidades){
            let sender = (self.oTable.cellForRow(at: IndexPath(row: 0, section: 3)) as! CelulaCupomOferta).botaoCupom
            validarCupomDeDesconto(sender: sender!)
            return
        }
        
        oTable.reloadData()
    }
    
    @objc func abrirLimveCreditos(){
        let lc = LimveCreditos.inicializeLimveCreditos()
        self.present(lc, animated: true, completion: nil)
    }
    
    @objc func alterarParcelamento(){
        inicializarEfeitosDeBlur()
        
        let precoTotal = verificarPrecoTotal()
        if (precoTotal == 0.0){
            return
        }
        
        let parc = Parcelamento.inicializeParcelamento(valorTotal: precoTotal, parcelamento: parcelar, delegate: self)
        self.present(parc, animated: true, completion: {
            self.blurView.trackingMode = .none
        })
    }
    
    func onExitParcelar(sussecefull: Bool, parcelamento: Int?) {
        UIView.animate(withDuration: 0.25, animations: {
            self.blurEffectView.alpha = 0
        }) { _ in
            self.blurEffectView.removeFromSuperview()
        }
        
        if (sussecefull){
            self.parcelar = parcelamento!
            self.oTable.reloadData()
        }
    }
    
    func verificarPrecoTotal() -> Double{
        var precoTotal = 0.0
        var taxaEntrega = 0.0
        if (cupomAtivo){
            precoTotal = precoAposCupom
        } else {
            if (PFUser.current()!["enderecoPoint"] == nil){
                let popup = PopupDialog(title: "Ops!", message: "Insira um endereço de entrega!")
                popup.buttonAlignment = .horizontal
                popup.transitionStyle = .bounceUp
                let button = CancelButton(title: "Ok", action: {
                })
                popup.addButton(button)
                // Present dialog
                self.present(popup, animated: true, completion: nil)
                return 0.0
            } else {
                let point = PFUser.current()!["enderecoPoint"] as! PFGeoPoint
                if (point.distanceInKilometers(to: pontoOrigemLimve) > raioEntregaGratis){
                    if (CarrinhoObject.get().valorDoCarrinho < minimoTaxaDeEntregaGratis){
                        taxaEntrega = taxaDeEntregaDouble
                    }
                }
            }
            
            precoTotal = (CarrinhoObject.get().valorDoCarrinho + taxaEntrega)
        }
        return precoTotal
    }
    
    @objc func adicionarPagamento(){
        
        inicializarEfeitosDeBlur()
        
        let precoTotal = verificarPrecoTotal()
        if (precoTotal == 0.0){
            return
        }
        
        let pgto = FormasPagamento.inicializeFormasPagamento(valorAPagar: precoTotal, cartaoSelecionado: Carrinho.cartaoSelecionado, formaDePagamentoTipo: Carrinho.formaPagamentoSelecionado, delegate: self)
        self.present(pgto, animated: true, completion: {
            self.blurView.trackingMode = .none
        })
    }
    
    func onExitFormasPagamento(sussecefull: Bool, formaDePagamentoTipo: String, cartao: Cartao?, pagarEntregaTipo: String?, pagarEntregaStr: String?, trocoPara: Double) {
        UIView.animate(withDuration: 0.25, animations: {
            self.blurEffectView.alpha = 0
        }) { _ in
            self.blurEffectView.removeFromSuperview()
        }
        
        if (sussecefull){
            if (pagarEntregaTipo != nil){
                Carrinho.formaPagamentoSelecionado = "entrega_\(pagarEntregaTipo!)"
                Carrinho.pagueEntregaStr = pagarEntregaStr!
                Carrinho.trocoPara = trocoPara
                Carrinho.cartaoSelecionado = nil
            } else {
                if (cartao == nil){
                    Carrinho.formaPagamentoSelecionado = formaDePagamentoTipo
                    Carrinho.cartaoSelecionado = nil
                } else {
                    Carrinho.cartaoSelecionado = cartao!
                    if (Carrinho.cartaoSelecionado.cartaoStyle == CartaoStyle.debito){
                        Carrinho.formaPagamentoSelecionado = "debito"
                    } else {
                        Carrinho.formaPagamentoSelecionado = "credito"
                    }
                    print(Carrinho.formaPagamentoSelecionado)
                }
            }
            self.oTable.reloadData()
        }
    }
    
    func onExitCartao(sussecefull: Bool, cartao: Cartao!) {
        UIView.animate(withDuration: 0.25, animations: {
            self.blurEffectView.alpha = 0
        }) { _ in
            self.blurEffectView.removeFromSuperview()
        }
        
        if (sussecefull){
            Carrinho.cartaoSelecionado = cartao!
            Carrinho.possuiCartao = true
            if (Carrinho.cartaoSelecionado.cartaoStyle == CartaoStyle.debito){
                Carrinho.formaPagamentoSelecionado = "debito"
            } else {
                Carrinho.formaPagamentoSelecionado = "credito"
            }
            self.oTable.reloadRows(at: [IndexPath(row: 0, section: 4)], with: .automatic)
        }
    }
    
    @objc func trocarDocumentoFiscal(isFinalizacao: Bool = false){
        
        inicializarEfeitosDeBlur()
        
        let dc = DocumentoFiscal.inicializeDocumentoFiscal(cpfCnpj: Carrinho.cpfCnpj, nome: Carrinho.nome, delegate: self)
        if (isFinalizacao){
            dc.isFinalizacao = true
        }
        self.present(dc, animated: true, completion: {
            self.blurView.trackingMode = .none
        })
    }
    
    var botaoHolder: TransitionButton!
    func onExitDocumentoFiscal(sucesseful: Bool, cpfCnpj: String?, nome: String?, isFinalizacao: Bool) {
        UIView.animate(withDuration: 0.25, animations: {
            self.blurEffectView.alpha = 0
        }) { _ in
            self.blurEffectView.removeFromSuperview()
        }
        
        if (sucesseful){
            Carrinho.cpfCnpj = cpfCnpj
            Carrinho.nome = nome
            self.oTable.reloadRows(at: [IndexPath(row: 0, section: 4)], with: .automatic)
            
            if (isFinalizacao){
                viewBlocker = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
                viewBlocker.backgroundColor = UIColor.clear
                self.view.addSubview(viewBlocker)
                finalizarCompra(botao: botaoHolder, cvv: "")
            }
        }
    }
    
    @objc func aumentarQuantidade(sender: UIButton){
        
        print("estoque: \(Int(CarrinhoObject.get().produtos[sender.tag].estoque))) | quantidade: \(CarrinhoObject.get().produtos[sender.tag].quantidade + 1)")
        
        if (CarrinhoObject.get().produtos[sender.tag].quantidade + 1 > Int(CarrinhoObject.get().produtos[sender.tag].estoque)){
            let popup = PopupDialog(title: "Ops!", message: "Nosso estoque desse produto excede a tentativa de compra.")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        
        CarrinhoObject.get().produtos[sender.tag].quantidade += 1
        CarrinhoObject.get().produtos[sender.tag].atualizarValorDoProdutoNoCarrinho()
        CarrinhoObject.get().atualizarValorDoCarrinho()
        logAddToCartEvent(produto: CarrinhoObject.get().produtos[sender.tag])
        if (cupomAtivoLimveCreditos || cupomAtivo){
            calcularTotais(true)
        } else {
            oTable.reloadRows(at: [IndexPath(row: sender.tag + 1, section: 1), IndexPath(row: 0, section: 4), IndexPath(row: 0, section: 5)], with: .automatic)
        }
    }
    
    @objc func diminuirQuantidade(sender: UIButton){
        if (CarrinhoObject.get().produtos[sender.tag].quantidade == 1){
            CarrinhoObject.get().removerDoCarrinho(produto: CarrinhoObject.get().produtos[sender.tag])
            oTable.reloadData()
            if (CarrinhoObject.get().produtos.count == 0){
                self.delegate.chamadaFromCarrinho()
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            CarrinhoObject.get().produtos[sender.tag].quantidade -= 1
            CarrinhoObject.get().produtos[sender.tag].atualizarValorDoProdutoNoCarrinho()
            CarrinhoObject.get().atualizarValorDoCarrinho()
            if (cupomAtivoLimveCreditos || cupomAtivo){
                calcularTotais(true)
            } else {
                oTable.reloadRows(at: [IndexPath(row: sender.tag + 1, section: 1), IndexPath(row: 0, section: 4), IndexPath(row: 0, section: 5)], with: .automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0){
            return 206.0
        } else if (indexPath.section == 1){
            if (indexPath.row == 0){
                return 48.0
            } else {
                return 127.0
            }
        } else if (indexPath.section == 2){
            return 135.0
        } else if (indexPath.section == 3){
            return 123.0
        } else if (indexPath.section == 4){
            return 137.0
        } else {
            return 499.0
        }
    }
    
    @objc func finalizarCompra(sender: TransitionButton){
        
        if (PFUser.current()!["enderecoEntrega"] == nil){
            let popup = PopupDialog(title: "Ops!", message: "Você não selecionou nenhum endereço para entrega.")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        
        var taxaEntrega = 0.0
        if (CarrinhoObject.get().valorDoCarrinho < minimoTaxaDeEntregaGratis){
            taxaEntrega = taxaDeEntregaDouble
        }
        var precoTotal = 0.0
        if (cupomAtivo){
            precoTotal = precoAposCupom
        } else {
            precoTotal = CarrinhoObject.get().valorDoCarrinho + taxaEntrega
        }
        
        if (Carrinho.formaPagamentoSelecionado == ""){
            let popup = PopupDialog(title: "Ops!", message: "Você não selecionou nenhuma forma de pagamento.")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        
        if (precoTotal < 25.0){
            let popup = PopupDialog(title: "Ops!", message: "O pedido mínimo na Limve é de R$ 25,00. Continue a fazer compras para chegar lá!")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        
        if (precoTotal > 150.0 && Carrinho.cpfCnpj.count == 0){
            let popup = PopupDialog(title: "Ops!", message: "Para compras acima de R$ 150 é obrigatório emissão de CPF/CNPJ na nota. Por favor, insira seu documento fiscal.")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        
        if (Carrinho.nome.count == 0){
            let popup = PopupDialog(title: "Ops!", message: "Por favor, insira o nome do destinatário dos produtos. Utilizamos ele para identificar o recebedor")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        
        sender.startAnimation()
        
        let hasEmail = (PFUser.current()!["email"] != nil)
        let hasTelefone = (PFUser.current()!["telefone"] != nil)
        
        if (!hasEmail || !hasTelefone){
            botaoHolder = sender
            abrirMelhoreSuaExperiencia()
            return
        }
        
        if (Carrinho.formaPagamentoSelecionado == "boleto" || Carrinho.formaPagamentoSelecionado == "transferencia" || Carrinho.formaPagamentoSelecionado.contains("entrega")){
            
            if (Carrinho.cpfCnpj.count == 0 || Carrinho.nome.count == 0){
                botaoHolder = sender
                trocarDocumentoFiscal(isFinalizacao: true)
            } else {
                viewBlocker = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
                viewBlocker.backgroundColor = UIColor.clear
                self.view.addSubview(viewBlocker)
                finalizarCompra(botao: sender, cvv: "")
            }
            
            return
        }
        
        inicializarEfeitosDeBlur()
        
        let cvv = Cvv.inicializeCvv(botao: sender, cartao: Carrinho.cartaoSelecionado, delegate: self)
        self.present(cvv, animated: true, completion: {
            self.blurView.trackingMode = .none
        })
    }
    
    func abrirObrigado(autenticacao: String){
        inicializarEfeitosDeBlur()
        
        let obg = Obrigado.inicializeObrigado(autenticacao: autenticacao, delegate: self)
        self.present(obg, animated: true, completion: {
            self.blurView.trackingMode = .none
        })
    }
    
    func abrirObrigadoEntrega(){
        inicializarEfeitosDeBlur()
        
        let obg = ObrigadoEntrega.inicializeObrigadoEntrega(delegate: self)
        self.present(obg, animated: true, completion: {
            self.blurView.trackingMode = .none
        })
    }
    
    func abrirMelhoreSuaExperiencia(){
        inicializarEfeitosDeBlur()
        
        let melhore = MelhoreSuaExperiencia.inicializeMelhoreSuaExperiencia(delegate: self)
        self.present(melhore, animated: true, completion: {
            self.blurView.trackingMode = .none
        })
    }
    
    func abrirObrigadoBoleto(boleto: [String : Any]){
        inicializarEfeitosDeBlur()
        
        let nf = ObrigadoBoleto.inicializeObrigado(boleto: boleto, delegate: self)
        self.present(nf, animated: true, completion: {
            self.blurView.trackingMode = .none
        })
    }
    
    func abrirObrigadoTransferencia(valor: Double){
        inicializarEfeitosDeBlur()
        
        let nf = ObrigadoTransferencia.inicializeObrigado(valor: valor, delegate: self)
        self.present(nf, animated: true, completion: {
            self.blurView.trackingMode = .none
        })
    }
    
    func onExitObrigado() {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.blurEffectView.alpha = 0
        }) { _ in
            self.blurEffectView.removeFromSuperview()
        }
        
        self.dismiss(animated: true, completion: nil)
        
        PFUser.current()!.fetchInBackground()
        CarrinhoObject.get().removerTodosDoCarrinho()
        fechar()
    }
    
    var viewBlocker: UIView!
    func onExitCvv(sucesseful: Bool, botao: TransitionButton, cvv: String?) {
        UIView.animate(withDuration: 0.25, animations: {
            self.blurEffectView.alpha = 0
        }) { _ in
            self.blurEffectView.removeFromSuperview()
        }
        
        if (sucesseful){
            viewBlocker = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
            viewBlocker.backgroundColor = UIColor.clear
            self.view.addSubview(viewBlocker)
            
            finalizarCompra(botao: botao, cvv: cvv)
        } else {
            botao.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.35) {
                
            }
        }
    }
    
    func onExitMelhoreSuaExperiencia(telefone: String, email: String) {
        UIView.animate(withDuration: 0.25, animations: {
            self.blurEffectView.alpha = 0
        }) { _ in
            self.blurEffectView.removeFromSuperview()
        }
        
        if (telefone.count > 0){
            PFUser.current()!["telefone"] = telefone
            PFUser.current()!["email"] = email
            PFUser.current()!.saveInBackground()
        }
        
        
        if (Carrinho.formaPagamentoSelecionado == "boleto" || Carrinho.formaPagamentoSelecionado == "transferencia"){
            
            if (Carrinho.cpfCnpj.count == 0 || Carrinho.nome.count == 0){
                trocarDocumentoFiscal(isFinalizacao: true)
            } else {
                viewBlocker = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
                viewBlocker.backgroundColor = UIColor.clear
                self.view.addSubview(viewBlocker)
                finalizarCompra(botao: botaoHolder, cvv: "")
            }
            
            return
        }
    
        inicializarEfeitosDeBlur()
        
        let cvv = Cvv.inicializeCvv(botao: botaoHolder, cartao: Carrinho.cartaoSelecionado, delegate: self)
        self.present(cvv, animated: true, completion: {
            self.blurView.trackingMode = .none
        })
    }
    
    func finalizarCompra(botao: TransitionButton, cvv: String?){
        //processar e finalizar compra
        DispatchQueue.global(qos: .background).async { [self] in
            do {
                
                try PFUser.current()!.fetch()
                
                var params = [String : Any]()
                var produtosMap = [String : Int]()
                for x in 0 ... CarrinhoObject.get().produtos.count - 1{
                    let produto = CarrinhoObject.get().produtos[x]
                    produtosMap[produto.produtoId] = produto.quantidade
                }
                params["produtosMap"] = produtosMap
                params["formaDePagamento"] = Carrinho.formaPagamentoSelecionado
                params["trocoPara"] = Carrinho.trocoPara
                params["cpf"] = Carrinho.cpfCnpj
                
                if (Carrinho.formaPagamentoSelecionado == "boleto" || Carrinho.formaPagamentoSelecionado == "transferencia" || Carrinho.formaPagamentoSelecionado.contains("entrega")){
                    
                } else {
                    //credito ou debito
                    
                    params["cardIdCielo"] = Carrinho.cartaoSelecionado.cartaoId
                    if (Carrinho.cartaoSelecionado.bandeira == CartaoTipo.amex){
                        params["cardBandeira"] = "Amex"
                    } else if (Carrinho.cartaoSelecionado.bandeira == CartaoTipo.mastercard){
                        params["cardBandeira"] = "Master"
                    } else if (Carrinho.cartaoSelecionado.bandeira == CartaoTipo.visa){
                        params["cardBandeira"] = "Visa"
                    } else if (Carrinho.cartaoSelecionado.bandeira == CartaoTipo.elo){
                        params["cardBandeira"] = "Elo"
                    } else {
                        params["cardBandeira"] = Carrinho.cartaoSelecionado.bandeiraOutro
                    }
                    
                    params["cardFinal"] = Carrinho.cartaoSelecionado.final
                    params["cardGetNet"] = Carrinho.cartaoSelecionado.cardGetNet
                }
                
                let endEntrega = (PFUser.current()!["enderecoEntrega"] as! String)
                let endGeoPoint = (PFUser.current()!["enderecoPoint"] as! PFGeoPoint)
                params["enderecoEntrega"] = endEntrega
                params["billing_address"] = (PFUser.current()!["billing_address"] as! [String : Any])
                
                print(params)
                
                params["enderecoLatitude"] = endGeoPoint.latitude
                params["enderecoLongitude"] = endGeoPoint.longitude
                
                let letters = "0123456789"
                let randomStr = String((0..<5).map{ _ in letters.randomElement()! })
                
                let sessionId = "8230678\((PFUser.current()?.objectId)!.uppercased())\(randomStr)"
                
                do {
                    params["device_print"] = sessionId
                    params["ip_address"] = IP_EXTERNO
                    
                    params["parcelas"] = self.parcelar
                    params["cvv"] = cvv!
                    if (PFUser.current()!["nome"] == nil){
                         params["nome"] = "Comprador anônimo"
                    } else {
                         params["nome"] = (PFUser.current()!["nome"] as! String)
                    }
                    
                    if (self.cupomAtivo){
                        params["cupom"] = (self.oTable.cellForRow(at: IndexPath(row: 0, section: 3)) as! CelulaCupomOferta).cupom.text!.replacingOccurrences(of: " ", with: "")
                    }
                    
                    print(params)
                    let resultado = try PFCloud.callFunction("processarCompra", withParameters: params)
                    
                    print(resultado)
                    
                    DispatchQueue.main.async { [self] in
                        
                        do {
                            self.viewBlocker.removeFromSuperview()
                            
                            if (!(resultado is [String : Any])){
                                throw LimveError.runtimeError("Falha de conexão. Tente novamente")
                            }
                            let resultadoJson = (resultado as! [String : Any])
                            let erro = resultadoJson["erro"] as! Bool
                            if (erro){
                                let motivo = (resultadoJson["motivo"] as! String)
                                throw LimveError.runtimeError(motivo)
                            }
                            
                            botao.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.15) {
                                
                                var taxaEntrega = 0.0
                                if (CarrinhoObject.get().valorDoCarrinho < minimoTaxaDeEntregaGratis){
                                    taxaEntrega = taxaDeEntregaDouble
                                }
                                AppEvents.logPurchase((CarrinhoObject.get().valorDoCarrinho + taxaEntrega), currency: "BRL")
                                
                                if (Carrinho.formaPagamentoSelecionado == "boleto"){
                                    let boleto = (resultadoJson["boleto"] as! [String : Any])
                                    self.abrirObrigadoBoleto(boleto: boleto)
                                } else if (Carrinho.formaPagamentoSelecionado == "transferencia"){
                                    let valor = (resultadoJson["valor"] as! Double)
                                    self.abrirObrigadoTransferencia(valor: valor)
                                } else if (Carrinho.formaPagamentoSelecionado.contains("entrega")){
                                    print("pagamento na entrega")
                                    self.abrirObrigadoEntrega()
                                } else {
                                    let proofOfSale = (resultadoJson["proofOfSale"] as! String)
                                    self.abrirObrigado(autenticacao: proofOfSale)
                                }
                            }
                        } catch {
                            let error2 = error as! LimveError
                            botao.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.2) {
                                
                                let popup = PopupDialog(title: "Ops!", message: error2.message)
                                popup.buttonAlignment = .horizontal
                                popup.transitionStyle = .bounceUp
                                let button = CancelButton(title: "Ok", action: {
                                })
                                popup.addButton(button)
                                // Present dialog
                                self.present(popup, animated: true, completion: nil)
                                
                            }
                        }
                    }
                } catch {
                    print(error)
                    DispatchQueue.main.async {
                        self.viewBlocker.removeFromSuperview()
                        
                        botao.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.2) {
                            
                            let popup = PopupDialog(title: "Ops!", message: "Erro de conexão")
                            popup.buttonAlignment = .horizontal
                            popup.transitionStyle = .bounceUp
                            let button = CancelButton(title: "Ok", action: {
                            })
                            popup.addButton(button)
                            // Present dialog
                            self.present(popup, animated: true, completion: nil)
                            
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.viewBlocker.removeFromSuperview()
                    
                    botao.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.2) {
                        
                        let popup = PopupDialog(title: "Ops!", message: "Erro de conexão")
                        popup.buttonAlignment = .horizontal
                        popup.transitionStyle = .bounceUp
                        let button = CancelButton(title: "Ok", action: {
                        })
                        popup.addButton(button)
                        // Present dialog
                        self.present(popup, animated: true, completion: nil)
                        
                    }
                }
            }
        }
    }
    
    func createRequest(_ myUrl : String, type : String, params : NSDictionary?, completion : @escaping (Any?, Error?) -> Void ) {
        let url = URL(string: myUrl)
        let request = NSMutableURLRequest(url: url! as URL, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 60.0)
        if (params != nil && type != "GET") {
            let data = try! JSONSerialization.data(withJSONObject: params!, options: JSONSerialization.WritingOptions.prettyPrinted)
            request.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
            request.httpBody = data
        }
        request.setValue("application/json", forHTTPHeaderField:"Content-type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = type
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue(),
                                                completionHandler: {(response: URLResponse?, data: Data?, error:Error?) -> Void in
                                                    print("THIS IS DATA: \(data)")
                                                    do {
                                                        let returnedObject = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves)
                                                        completion(returnedObject,error)
                                                    } catch {
                                                        completion(nil,error)
                                                    }
        })
    }
}

class CelulaEntrega: UITableViewCell {
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var endereco: UITextView!
    @IBOutlet weak var imagem: UIImageView!
    @IBOutlet weak var botao: TransitionButton!
}

class CelulaItemCarrinhoHeader: UITableViewCell {
    @IBOutlet weak var holder: UIView!
}

class CelulaItemCarrinho: UITableViewCell {
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var loader: UIView!
    @IBOutlet weak var marca: UILabel!
    @IBOutlet weak var descricao: UITextView!
    @IBOutlet weak var quantidade: UILabel!
    @IBOutlet weak var preco: UILabel!
    @IBOutlet weak var imagem: UIImageView!
    @IBOutlet weak var botaoMais: UIButton!
    @IBOutlet weak var botaoMenos: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loader.backgroundColor = UIColor.clear
        let nv = NVActivityIndicatorView(frame: CGRect(origin: .zero, size: loader.frame.size), type: NVActivityIndicatorType.ballClipRotateMultiple, color: hexStringToUIColor("#3C65D1"), padding: 15.0)
        loader.backgroundColor = UIColor.clear
        loader.addSubview(nv)
        nv.startAnimating()
        
    }
}

class CelulaCupomOferta: UITableViewCell {
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var cupom: UITextField!
    @IBOutlet weak var avisoCupom: UILabel!
    @IBOutlet weak var botaoCupom: TransitionButton!
}

class CelulaLimveCreditos: UITableViewCell {
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var limveCreditosLabel: UILabel!
    @IBOutlet weak var seuSaldo: UILabel!
    @IBOutlet weak var viewClicavel: UIControl!
    @IBOutlet weak var botaoUsarMeusCreditos: TransitionButton!
}

class CelulaFinal: UITableViewCell {
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var taxaDeEntrega: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var parcelado: UILabel!
    @IBOutlet weak var totalItens: UILabel!
    @IBOutlet weak var desconto: UILabel!
}

class CelulaPagamento: UITableViewCell {
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var botao: TransitionButton!
    @IBOutlet weak var botaoTrocarPagamento: TransitionButton!
    @IBOutlet weak var trocarPagamento: UILabel!
    @IBOutlet weak var pagarEntregaLabel: UILabel!
    @IBOutlet weak var botaoTrocarParcelamento: TransitionButton!
    @IBOutlet weak var trocarParcelamento: UILabel!
    @IBOutlet weak var botaoTrocarCPF: TransitionButton!
    @IBOutlet weak var trocarCPF: UILabel!
    @IBOutlet weak var trocarNome: UILabel!
    @IBOutlet weak var loader: UIView!
    @IBOutlet weak var restanteView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loader.backgroundColor = UIColor.clear
        let nv = NVActivityIndicatorView(frame: CGRect(origin: .zero, size: loader.frame.size), type: NVActivityIndicatorType.ballClipRotateMultiple, color: hexStringToUIColor("#3C65D1"), padding: 15.0)
        loader.backgroundColor = UIColor.clear
        loader.addSubview(nv)
        nv.startAnimating()
        
    }
}
