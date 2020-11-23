//
//  AdicionarCartao.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 01/03/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import Foundation
import UIKit
import Parse
import TransitionButton
import PopupDialog

protocol AdicionarCartaoDelegate{
    func onExitCartao(sussecefull: Bool, cartao: Cartao!)
}

class AdicionarCartao: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var botaoAdicionar: TransitionButton!
    @IBOutlet weak var botaoFechar: TransitionButton!
    @IBOutlet weak var holderNome: UIView!
    @IBOutlet weak var holderNumeroCartao: UIView!
    @IBOutlet weak var holderValidade: UIView!
    @IBOutlet weak var nome: UITextField!
    @IBOutlet weak var numeroCartao: UITextField!
    @IBOutlet weak var validade: UITextField!
    @IBOutlet weak var masterCardUpper: UIView!
    @IBOutlet weak var masterCardInside: UIView!
    @IBOutlet weak var visaUpper: UIView!
    @IBOutlet weak var visaInside: UIView!
    @IBOutlet weak var amexUpper: UIView!
    @IBOutlet weak var amexInside: UIView!
    @IBOutlet weak var eloUpper: UIView!
    @IBOutlet weak var eloInside: UIView!
    
    @IBOutlet weak var creditoUpper: UIView!
    @IBOutlet weak var creditoInside: UIView!
    @IBOutlet weak var debitoUpper: UIView!
    @IBOutlet weak var debitoInside: UIView!
    
    var frameInicialViewHolder: CGRect!
    var delegate: AdicionarCartaoDelegate!
    
    static func inicializeAdicionarCartao(delegate: AdicionarCartaoDelegate) -> AdicionarCartao{
        let tela = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "AdicionarCartao") as! AdicionarCartao
        tela.delegate = delegate
        return tela
    }
    
    @IBAction func fechar(){
        
        let popup = PopupDialog(title: "Tem certeza?", message: "Você tem certeza que deseja cancelar a inclusão de um cartão? O processo feito até aqui não será salvo.")
        popup.buttonAlignment = .horizontal
        popup.transitionStyle = .bounceUp
        let button = DefaultButton(title: "Não", action: {
        })
        let button2 = CancelButton(title: "Sim", action: {
            self.dismiss(animated: true, completion: nil)
            self.delegate.onExitCartao(sussecefull: false, cartao: nil)
        })
        popup.addButton(button)
        popup.addButton(button2)
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global().async {
            do {
                configuration = try PFConfig.getConfig()
                try PFUser.current()?.fetch()
            } catch {
                
            }
        }
        
        masterCardUpper.layer.cornerRadius = masterCardUpper.frame.height/2
        masterCardUpper.layer.borderWidth = 2.0
        masterCardUpper.backgroundColor = UIColor.clear
        masterCardUpper.layer.borderColor = hexStringToUIColor("#0B6AB0").cgColor
        
        masterCardInside.layer.cornerRadius = masterCardInside.frame.height/2
        
        visaUpper.layer.cornerRadius = masterCardUpper.frame.height/2
        visaUpper.layer.borderWidth = 2.0
        visaUpper.backgroundColor = UIColor.clear
        visaUpper.layer.borderColor = hexStringToUIColor("#0B6AB0").cgColor
        
        visaInside.layer.cornerRadius = masterCardInside.frame.height/2
        
        amexUpper.layer.cornerRadius = masterCardUpper.frame.height/2
        amexUpper.layer.borderWidth = 2.0
        amexUpper.backgroundColor = UIColor.clear
        amexUpper.layer.borderColor = hexStringToUIColor("#0B6AB0").cgColor
        
        amexInside.layer.cornerRadius = masterCardInside.frame.height/2
        
        eloUpper.layer.cornerRadius = masterCardUpper.frame.height/2
        eloUpper.layer.borderWidth = 2.0
        eloUpper.backgroundColor = UIColor.clear
        eloUpper.layer.borderColor = hexStringToUIColor("#0B6AB0").cgColor
        
        eloInside.layer.cornerRadius = masterCardInside.frame.height/2
        
        creditoUpper.layer.cornerRadius = creditoUpper.frame.height/2
        creditoUpper.layer.borderWidth = 2.0
        creditoUpper.backgroundColor = UIColor.clear
        creditoUpper.layer.borderColor = hexStringToUIColor("#7B8185").cgColor
        
        creditoInside.layer.cornerRadius = creditoInside.frame.height/2
        
        
        debitoUpper.layer.cornerRadius = debitoUpper.frame.height/2
        debitoUpper.layer.borderWidth = 2.0
        debitoUpper.backgroundColor = UIColor.clear
        debitoUpper.layer.borderColor = hexStringToUIColor("#7B8185").cgColor
        
        debitoInside.layer.cornerRadius = debitoInside.frame.height/2
        
        
        holder.layer.cornerRadius = 16.0
        holder.clipsToBounds = true
        self.view.backgroundColor = UIColor.clear
        holder.layer.shadowColor = hexStringToUIColor("#00224B").cgColor
        holder.layer.shadowOpacity = 6
        holder.layer.shadowOffset = .zero
        holder.layer.shadowRadius = 10
        
        frameInicialViewHolder = holder.frame
        numeroCartao.delegate = self
        
        botaoAdicionar.spinnerColor = UIColor.white
        botaoAdicionar.cornerRadius = botaoAdicionar.frame.height/2
        botaoAdicionar.backgroundColor = hexStringToUIColor("#4BC562")
        botaoFechar.spinnerColor = UIColor.white
        botaoFechar.cornerRadius = botaoFechar.frame.height/2
        botaoFechar.backgroundColor = hexStringToUIColor("#EF343A")
        
        holderNome.layer.cornerRadius = 8.0
        holderNumeroCartao.layer.cornerRadius = 8.0
        holderValidade.layer.cornerRadius = 8.0
    
        atribuirPlaceholder(textField: nome, name: "Titular do cartão")
        atribuirPlaceholder(textField: numeroCartao, name: "Número do cartão")
        atribuirPlaceholder(textField: validade, name: "Data de validade")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func atribuirPlaceholder(textField: UITextField, name: String){
        var placeHolder = NSMutableAttributedString()
        placeHolder = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont(name: "CeraRoundPro-Regular", size: 18.0)!])
        placeHolder.addAttribute(NSAttributedString.Key.foregroundColor, value: hexStringToUIColor("#939393"), range: NSRange(location:0, length: name.count))
        textField.attributedPlaceholder = placeHolder
    }
    
    var bandeiraSelecionada = ""
    func setarNovaBandeira(){
        
        visaInside.backgroundColor = UIColor.white
        
        masterCardInside.backgroundColor = UIColor.white
        amexInside.backgroundColor = UIColor.white
        eloInside.backgroundColor = UIColor.white
        
        UIView.animate(withDuration: 0.25) {
            if (self.bandeiraSelecionada == "Visa"){
                self.visaInside.backgroundColor = hexStringToUIColor("#0B6AB0")
            }
            if (self.bandeiraSelecionada == "Master"){
                self.masterCardInside.backgroundColor = hexStringToUIColor("#0B6AB0")
            }
            if (self.bandeiraSelecionada == "Amex"){
                self.amexInside.backgroundColor = hexStringToUIColor("#0B6AB0")
            }
            if (self.bandeiraSelecionada == "Elo"){
                self.eloInside.backgroundColor = hexStringToUIColor("#0B6AB0")
            }
        }
        
        if (self.bandeiraSelecionada == "Elo" || self.bandeiraSelecionada == "Amex"){
            if (tipoCartao == "debito"){
                tipoCartao = "credito"
                setarTipo(sender: nil)
            }
        }
    }
    
    @IBAction func selectedBandeira(sender: UIControl){
        if (sender.tag == 0){
            bandeiraSelecionada = "Master"
        } else if (sender.tag == 1){
            bandeiraSelecionada = "Visa"
        } else if (sender.tag == 2){
            bandeiraSelecionada = "Amex"
        } else {
            bandeiraSelecionada = "Elo"
        }
        setarNovaBandeira()
    }
    
    var tipoCartao = ""
    @IBAction func setarTipo(sender: UIControl?){
        if (sender != nil){
            if (sender!.tag == 0){
                //credito
                tipoCartao = "credito"
            } else {
                //debito
                tipoCartao = "debito"
            }
        }
        
        if (self.bandeiraSelecionada == "Elo" || self.bandeiraSelecionada == "Amex"){
            if (tipoCartao == "debito"){
                tipoCartao = "credito"
                setarTipo(sender: nil)
            }
        }
        
        creditoInside.backgroundColor = UIColor.white
        debitoInside.backgroundColor = UIColor.white
        
        UIView.animate(withDuration: 0.25) {
            if (self.tipoCartao == "credito"){
                self.creditoInside.backgroundColor = hexStringToUIColor("#7B8185")
            }
            if (self.tipoCartao == "debito"){
                self.debitoInside.backgroundColor = hexStringToUIColor("#7B8185")
            }
        }
    }
    
    @IBAction func returnClicked(sender: UITextField){
        if ((sender.text?.count)! > 0){
            let tag = sender.tag
            if (tag == 2){
                self.view.endEditing(true)
            } else {
                //sender.resignFirstResponder()
                self.view.viewWithTag((tag+1))?.becomeFirstResponder()
            }
        }
    }
    
    @IBAction func numeroCartaoChanged(){
        
        let bandeiraCartaoCopy = bandeiraSelecionada
        
        let valor1 = numeroCartao.text!
        let valor2 = valor1.replacingOccurrences(of: " ", with: "")
        let valor3 = valor2.replacingOccurrences(of: ".", with: "")
        var valor3Copy = valor3
        
        if (valor3.count == 0){
            numeroCartao.text = ""
            return
        }
        
        if (valor3Copy.count > 3){
            let firstFour = valor3Copy.prefix(4)
            if (firstFour == "5067" || firstFour == "4576" || firstFour == "4011" || firstFour == "6363" || firstFour == "4389" || firstFour == "6362"){
                bandeiraSelecionada = "Elo"
            } else {
                if (valor3Copy.prefix(1) == "4"){
                    bandeiraSelecionada = "Visa"
                } else {
                    let firstTwo = valor3Copy.prefix(2)
                    if (firstTwo == "50" || firstTwo == "51" || firstTwo == "52" || firstTwo == "53" || firstTwo == "54" || firstTwo == "55"){
                        bandeiraSelecionada = "Master"
                    }
                    if (firstTwo == "34" || firstTwo == "37"){
                        bandeiraSelecionada = "Amex"
                    }
                }
            }
        }
        
        var modifiedCreditCardString = ""
        if (bandeiraSelecionada == "Amex"){
            var montandoAmex = ""
            
            for x in 0 ... 14 {
                if (valor3.count > x){
                    let valorIndividual = valor3Copy[valor3Copy.startIndex]
                    valor3Copy = String(valor3Copy[valor3Copy.index(after: valor3Copy.startIndex)..<valor3Copy.endIndex])
                    montandoAmex.append(valorIndividual)
                } else {
                    //if (x != 0){
                     //   montandoAmex.append(" ")
                    //}
                }
                
                if (valor3.count > 4){
                    if (x == 3){
                        montandoAmex.append(" ")
                    }
                }
                
                if (valor3.count > 10){
                    if (x == 9){
                        montandoAmex.append(" ")
                    }
                }
            }
            modifiedCreditCardString = montandoAmex
        } else {
            var montandoCartao = ""
            
            for x in 0 ... 15 {
                if (valor3.count > x){
                    let valorIndividual = valor3Copy[valor3Copy.startIndex]
                    valor3Copy = String(valor3Copy[valor3Copy.index(after: valor3Copy.startIndex)..<valor3Copy.endIndex])
                    montandoCartao.append(valorIndividual)
                } else {
                    //if (x != 0){
                     //   montandoAmex.append(" ")
                    //}
                }
                
                if (valor3.count > 4){
                    if (x == 3){
                        montandoCartao.append(" ")
                    }
                }
                if (valor3.count > 8){
                    if (x == 7){
                        montandoCartao.append(" ")
                    }
                }
                if (valor3.count > 12){
                    if (x == 11){
                        montandoCartao.append(" ")
                    }
                }
            }
            modifiedCreditCardString = montandoCartao
        }
        
        numeroCartao.text = modifiedCreditCardString
        
        let newPosition = numeroCartao.position(from: numeroCartao.beginningOfDocument, offset: modifiedCreditCardString.count)
        numeroCartao.selectedTextRange = numeroCartao.textRange(from: newPosition!, to: newPosition!)
        
        if (bandeiraCartaoCopy != bandeiraSelecionada){
            setarNovaBandeira()
        }
        
        if (bandeiraSelecionada == "Amex" && valor3.count == 15){
            returnClicked(sender: numeroCartao)
        } else if (valor3.count == 16){
            returnClicked(sender: numeroCartao)
        }
    }
    
    @IBAction func validadeChangedChanged(){
        
        let valor1 = validade.text!
        let valor2 = valor1.replacingOccurrences(of: " ", with: "")
        let valor3 = valor2.replacingOccurrences(of: "/", with: "")
        var valor3Copy = valor3
        
        if (valor3.count == 0){
            validade.text = ""
            return
        }
        
        var dataFinal = ""
        
        for x in 0 ... 14 {
            if (valor3.count > x){
                let valorIndividual = valor3Copy[valor3Copy.startIndex]
                valor3Copy = String(valor3Copy[valor3Copy.index(after: valor3Copy.startIndex)..<valor3Copy.endIndex])
                dataFinal.append(valorIndividual)
            } else {
                //if (x != 0){
                 //   montandoAmex.append(" ")
                //}
            }
            
            if (valor3.count > 2){
                if (x == 1){
                    dataFinal.append("/")
                }
            }
        }
        
        validade.text = dataFinal
        
        let newPosition = numeroCartao.position(from: numeroCartao.beginningOfDocument, offset: dataFinal.count)
        numeroCartao.selectedTextRange = numeroCartao.textRange(from: newPosition!, to: newPosition!)
        
        if (valor3.count == 4){
            self.view.endEditing(true)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.count == 0 && range.length > 0 {
            
            if (textField.tag == 1){
                
                if (bandeiraSelecionada == "Amex"){
                    let newLength = (textField.text ?? "").count + string.count - range.length
                    return newLength <= 17
                } else {
                    let newLength = (textField.text ?? "").count + string.count - range.length
                    return newLength <= 19
                }
                
            } else {
                let newLength = (textField.text ?? "").count + string.count - range.length
                return newLength <= 5
            }
        }
        
        return true
    }
    
    @IBAction func fecharKeyboard(){
        self.view.endEditing(true)
    }
    
    @IBAction func cadastrarCartao(){
        if (nome.text!.count < 3){
            let popup = PopupDialog(title: "Ops!", message: "Confira se você digitou o nome do titular corretamente!")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        
        let valor1 = numeroCartao.text!
        let valor2 = valor1.replacingOccurrences(of: " ", with: "")
        let valor3 = valor2.replacingOccurrences(of: ".", with: "")
        if (valor3.count < 15){
            let popup = PopupDialog(title: "Ops!", message: "Confira se você digitou o número do cartão corretamente!")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        if (validade.text!.count != 5){
            let popup = PopupDialog(title: "Ops!", message: "Confira se você digitou a validade do cartão corretamente!")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        if (bandeiraSelecionada.count == 0){
            let popup = PopupDialog(title: "Ops!", message: "Confira se você marcou qual a bandeira do cartão!")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        if (tipoCartao.count == 0){
            let popup = PopupDialog(title: "Ops!", message: "Confira se você marcou qual o tipo do cartão!")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        
        let viewBlocker = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        viewBlocker.backgroundColor = UIColor.clear
        self.view.addSubview(viewBlocker)
        
        botaoAdicionar.startAnimation()
        
        let validadeSplited = validade.text!.split(separator: "/")
        
        let numeroCartaoInteiro = numeroCartao.text!.replacingOccurrences(of: " ", with: "")
        
        var paramsCloud = [String : Any]()
        paramsCloud["CustomerName"] = nome.text!
        paramsCloud["CardNumber"] = numeroCartaoInteiro
        paramsCloud["Holder"] = nome.text!
        paramsCloud["ExpirationDate"] = "\(validadeSplited[0])/20\(validadeSplited[1])"
        paramsCloud["Brand"] = bandeiraSelecionada
        print(paramsCloud)
        
        var paramsGetnetForToken = [String : Any]()
        paramsGetnetForToken["card_number"] = numeroCartaoInteiro
        print(paramsGetnetForToken)
        
        var paramsGetNet = [String : Any]()
        paramsGetNet["number_token"] = ""
        paramsGetNet["cardholder_name"] = nome.text!
        paramsGetNet["expiration_month"] = "\(validadeSplited[0])"
        paramsGetNet["expiration_year"] = "\(validadeSplited[1])"
        if (bandeiraSelecionada == "Master"){
            paramsGetNet["brand"] = "Mastercard"
        } else {
            paramsGetNet["brand"] = bandeiraSelecionada
        }
        print(paramsGetNet)
        
        var url = ""
        var urlGetnet1 = ""
        var urlGetnet2 = ""
        var urlGetnet3 = ""
        
        url = configuration.object(forKey: "URL_CIELO") as! String
        
        if ((configuration.object(forKey: "IS_SANDBOX") as! Bool)){
             urlGetnet1 = "https://api-sandbox.getnet.com.br/v1/tokens/card"
             urlGetnet2 = "https://api-sandbox.getnet.com.br/v1/cards"
             urlGetnet3 = "https://api-sandbox.getnet.com.br/v1/cards/verification"
        } else {
             urlGetnet1 = "https://api.getnet.com.br/v1/tokens/card"
             urlGetnet2 = "https://api.getnet.com.br/v1/cards"
             urlGetnet3 = "https://api.getnet.com.br/v1/cards/verification"
        }
        
        DispatchQueue.global().async { [self] in
            do {
                
                let accessTokenData = try PFCloud.callFunction("requererAuthGetNet", withParameters: nil) as! [String:Any]
                if (accessTokenData["erro"] as! Bool){
                    throw LimveError.runtimeError((accessTokenData["motivo"] as! String))
                }
                let accessToken = accessTokenData["access_token"] as! String
                
                let dataGetnet1 = try self.createRequestGetNet(urlGetnet1, type: "POST", params: paramsGetnetForToken as NSDictionary, accessToken: accessToken) as! [String : Any]
                print(dataGetnet1)
                if (dataGetnet1["number_token"] == nil){
                    throw LimveError.runtimeError("Erro na obtenção do token do cartão")
                }
                let card_numberToken = (dataGetnet1["number_token"] as! String)
                
                //Verificação primeiro na GetNet
                paramsGetNet["number_token"] = card_numberToken
            
                if ((bandeiraSelecionada == "Master" || bandeiraSelecionada == "Visa") && (tipoCartao == "credito")){
                    let dataGetnet3 = try self.createRequestGetNet(urlGetnet3, type: "POST", params: paramsGetNet as NSDictionary, accessToken: accessToken) as! [String : Any]
                    print(dataGetnet3)
                    let status = (dataGetnet3["status"] as! String)
                    if (status != "VERIFIED"){
                        throw LimveError.runtimeError("Cartão inválido ou bloqueado.")
                    }
                }
                
                paramsGetNet["customer_id"] = (PFUser.current()!.objectId!)
                let dataGetnet2 = try self.createRequestGetNet(urlGetnet2, type: "POST", params: paramsGetNet as NSDictionary, accessToken: accessToken) as! [String : Any]
                print(dataGetnet2)
                
                let cardId = (dataGetnet2["card_id"] as! String)
                paramsGetNet["card_id"] = cardId
                
                let data = try self.createRequestCielo(url, type: "POST", params: paramsCloud as NSDictionary) as! [String : Any]
                print(data)
                
                if (data["CardToken"] == nil){
                    throw LimveError.runtimeError("Erro com a API da Cielo")
                }
                
                let tokenCartao = data["CardToken"] as! String
                
                let cartao = PFObject(className: "Cartoes")
                cartao.acl = PFACL(user: PFUser.current()!)
                cartao["bandeira"] = self.bandeiraSelecionada
                cartao["cartaoId"] = tokenCartao
                cartao["cardGetNet"] = paramsGetNet
                cartao["tipo"] = self.tipoCartao
                if (self.bandeiraSelecionada == "Amex"){
                    cartao["final"] = numeroCartaoInteiro.suffix(5)
                } else {
                    cartao["final"] = numeroCartaoInteiro.suffix(4)
                }
                cartao["validade"] = "\(validadeSplited[0])/20\(validadeSplited[1])"
                cartao["userId"] = PFUser.current()!.objectId!
                
                try cartao.save()
                
                DispatchQueue.main.async(execute: {
                    
                    logAddPaymentInfoEvent(success: true)
                    
                    viewBlocker.removeFromSuperview()
                    self.botaoAdicionar.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.25) {
                        self.dismiss(animated: true, completion: nil)
                         self.delegate.onExitCartao(sussecefull: true, cartao: Cartao(cartao: cartao))
                    }
                })
            } catch {
                logAddPaymentInfoEvent(success: false)
                print(error)
                DispatchQueue.main.async(execute: {
                    viewBlocker.removeFromSuperview()
                    self.retornaErro()
                })
            }
        }
    }
    
    func retornaErro(){
        self.botaoAdicionar.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.35) {
            let popup = PopupDialog(title: "Ops!", message: "Cartão inválido ou com problema! Confira se você digitou os dados corretamente e tente novamente")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
        }
    }
    
    @IBAction func retornaInformacoesDebito(){
        let popup = PopupDialog(title: "Uso do débito", message: "O uso do débito on-line é permitido de acordo com seu banco e a bandeira do seu cartão, conforme segue: \n\nBradesco (Visa e Master)\nBanco do Brasil (Visa e Master)\nSantander (Visa e Master)\nItaú (Visa e Master)\nCaixa (apenas Mastercard)\n\nA bandeira Elo está disponível apenas para o aúxilio emergencial 2020. O cartão virtual CAIXA não pode ser armazenado e deve ser incluído ao final de cada compra.")
        popup.buttonAlignment = .horizontal
        popup.transitionStyle = .zoomIn
        let button = CancelButton(title: "Ok", action: {
        })
        popup.addButton(button)
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }

    
    //KEYBOARD OBSERVERS
    @objc func keyboardWillHide(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let _ = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                UIView.animate(withDuration: 0.25, animations: {
                    self.holder.frame = self.frameInicialViewHolder!
                })
            }
        }
    }
    @objc func keyboardWillShow(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let keyboardHeight2 = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                //This is keyboard Height
                UIView.animate(withDuration: 0.25, animations: {
                    self.holder.frame = CGRect(x: (self.frameInicialViewHolder?.origin.x)!, y: (self.frameInicialViewHolder?.origin.y)! - (keyboardHeight2/3), width: (self.frameInicialViewHolder?.width)!, height: (self.frameInicialViewHolder?.height)!)
                })
            }
        }
    }
    //
    
    func createRequestCielo(_ myUrl : String, type : String, params : NSDictionary?) throws -> Any {
        let url = URL(string: myUrl)
        let request = NSMutableURLRequest(url: url! as URL, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 60.0)
        if params != nil {
            let data = try! JSONSerialization.data(withJSONObject: params!, options: JSONSerialization.WritingOptions.prettyPrinted)
            request.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
            request.httpBody = data
        }
        request.setValue("application/json", forHTTPHeaderField:"Content-type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if ((configuration.object(forKey: "IS_SANDBOX") as! Bool)){
            request.setValue((configuration.object(forKey: "CIELO_MERCHANT_KEY_SANDBOX") as! String), forHTTPHeaderField: "MerchantKey")
            request.setValue((configuration.object(forKey: "CIELO_MERCHANT_ID_SANDBOX") as! String), forHTTPHeaderField: "MerchantId")
        } else {
            request.setValue((configuration.object(forKey: "CIELO_MERCHANT_KEY") as! String), forHTTPHeaderField: "MerchantKey")
            request.setValue((configuration.object(forKey: "CIELO_MERCHANT_ID") as! String), forHTTPHeaderField: "MerchantId")
        }
        request.httpMethod = type
        let response = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: nil)
        let returnedObject = try JSONSerialization.jsonObject(with: response, options: JSONSerialization.ReadingOptions.mutableLeaves)
        if !(returnedObject is [String : Any]){
            throw LimveError.runtimeError("Tipo incompátivel")
        }
        return returnedObject
    }
    
    func createRequestGetNet(_ myUrl : String, type : String, params : NSDictionary?, accessToken: String) throws -> Any  {
        let url = URL(string: myUrl)
        let request = NSMutableURLRequest(url: url! as URL, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 60.0)
        if params != nil {
            let data = try! JSONSerialization.data(withJSONObject: params!, options: JSONSerialization.WritingOptions.prettyPrinted)
            request.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
            request.httpBody = data
        }
        request.setValue("application/json", forHTTPHeaderField:"Content-type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = type
        print(request)
        let response = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: nil)
        let returnedObject = try JSONSerialization.jsonObject(with: response, options: JSONSerialization.ReadingOptions.mutableLeaves)
        if !(returnedObject is [String : Any]){
            throw LimveError.runtimeError("Tipo incompátivel")
        }
        return returnedObject
    }
}
