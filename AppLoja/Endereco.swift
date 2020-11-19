//
//  Endereco.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 04/03/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import Foundation
import UIKit
import Parse
import TransitionButton
import PopupDialog
import MapKit

protocol EnderecoDelegate {
    func onAdicionarEndereco(sucesso: Bool, novoEndereco: String?)
}

class Endereco: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var oTable: UITableView!
    @IBOutlet weak var botaoAdicionar: TransitionButton!
    @IBOutlet weak var botaoFechar: TransitionButton!
    @IBOutlet weak var holderCEP: UIView!
    @IBOutlet weak var holderEndereco: UIView!
    @IBOutlet weak var holderEndereco2: UIView!
    @IBOutlet weak var holderNumero: UIView!
    @IBOutlet weak var holderComplemento: UIView!
    @IBOutlet weak var holderBairro: UIView!
    @IBOutlet weak var holderCidade: UIView!
    @IBOutlet weak var cidade: UITextField!
    @IBOutlet weak var bairro: UITextField!
    @IBOutlet weak var complemento: UITextField!
    @IBOutlet weak var numero: UITextField!
    @IBOutlet weak var endereco: UITextView!
    @IBOutlet weak var endereco2: UITextView!
    @IBOutlet weak var cep: UITextField!
    @IBOutlet weak var confirmeAsInfosLabel: UILabel!
    @IBOutlet weak var viewConfirmaEndereco: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var enderecoConfirmado: UITextView!
    
    var frameInicialViewHolder: CGRect!
    var placeHolderEndereco = "Digite o nome da sua rua"
    var sugestoes = [[String: Any]]()
    var delegate: EnderecoDelegate!
    var geoPoint: PFGeoPoint!
    var billing_address = [String : Any]()
    
    var pontoDeOrigem: PFGeoPoint!
    
    static func inicializeEndereco(delegate: EnderecoDelegate) -> Endereco{
        let tela = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "Endereco") as! Endereco
        tela.delegate = delegate
        return tela
    }
    
    @IBAction func fechar(){
        if (confirmandoEndereco){
            UIView.animate(withDuration: 0.35, animations: {
                self.viewConfirmaEndereco.alpha = 0
            }) { _ in
                self.viewConfirmaEndereco.isHidden = true
            }
            confirmandoEndereco = false
        } else {
            self.dismiss(animated: true, completion: nil)
            self.delegate.onAdicionarEndereco(sucesso: false, novoEndereco: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pontoDeOrigem = PFGeoPoint(latitude: -25.423647, longitude: -49.252177)
        
        holder.layer.cornerRadius = 16.0
        holder.clipsToBounds = true
        self.view.backgroundColor = UIColor.clear
        holder.layer.shadowColor = hexStringToUIColor("#00224B").cgColor
        holder.layer.shadowOpacity = 6
        holder.layer.shadowOffset = .zero
        holder.layer.shadowRadius = 10
        
        frameInicialViewHolder = holder.frame
        
        botaoAdicionar.spinnerColor = UIColor.white
        botaoAdicionar.cornerRadius = botaoAdicionar.frame.height/2
        botaoAdicionar.backgroundColor = hexStringToUIColor("#4BC562")
        botaoFechar.spinnerColor = UIColor.white
        botaoFechar.cornerRadius = botaoFechar.frame.height/2
        botaoFechar.backgroundColor = hexStringToUIColor("#EF343A")
        
        holderEndereco2.layer.cornerRadius = 8.0
        holderEndereco.layer.cornerRadius = 8.0
        holderCEP.layer.cornerRadius = 8.0
        holderNumero.layer.cornerRadius = 8.0
        holderComplemento.layer.cornerRadius = 8.0
        holderBairro.layer.cornerRadius = 8.0
        holderCidade.layer.cornerRadius = 8.0
        
        endereco2.text = placeHolderEndereco
        endereco.text = placeHolderEndereco
        endereco2.textColor = hexStringToUIColor("#939393")
        endereco.textColor = hexStringToUIColor("#939393")
        endereco2.delegate = self
        endereco.delegate = self
        
        viewConfirmaEndereco.isHidden = true
        holderEndereco2.isHidden = true
        holderNumero.isHidden = true
        holderComplemento.isHidden = true
        holderBairro.isHidden = true
        holderCidade.isHidden = true
        oTable.isHidden = true
        confirmeAsInfosLabel.isHidden = true
    
        atribuirPlaceholder(textField: cep, name: "Digite seu CEP")
        atribuirPlaceholder(textField: numero, name: "Digite o número na rua")
        atribuirPlaceholder(textField: complemento, name: "Digite o complemento")
        atribuirPlaceholder(textField: bairro, name: "Digite o bairro")
        atribuirPlaceholder(textField: cidade, name: "Digite a cidade")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView){
        if (textView.text == placeHolderEndereco && textView.textColor == hexStringToUIColor("#939393")){
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder()
    }

    func textViewDidEndEditing(_ textView: UITextView){
        if (textView.text == ""){
            textView.text = placeHolderEndereco
            textView.textColor = hexStringToUIColor("#939393")
        }
        textView.resignFirstResponder()
    }
    
    func atribuirPlaceholder(textField: UITextField, name: String){
        var placeHolder = NSMutableAttributedString()
        placeHolder = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont(name: "CeraRoundPro-Regular", size: 18.0)!])
        placeHolder.addAttribute(NSAttributedString.Key.foregroundColor, value: hexStringToUIColor("#939393"), range: NSRange(location:0, length: name.count))
        textField.attributedPlaceholder = placeHolder
    }
    
    @IBAction func returnClicked(sender2: UITextView){
        if ((sender2.text?.count)! > 0){
            let tag = sender2.tag
            //sender.resignFirstResponder()
            self.view.viewWithTag((tag+1))?.becomeFirstResponder()
        }
    }
    
    @IBAction func fecharkeyboard(){
        self.view.endEditing(true)
    }
    
    @IBAction func returnClicked(sender: UITextField){
        if ((sender.text?.count)! > 0){
            let tag = sender.tag
            //sender.resignFirstResponder()
            self.view.viewWithTag((tag+1))?.becomeFirstResponder()
        }
    }
    
    @IBAction func returnClickedFromCEP(sender: UITextField){
        if ((sender.text?.count)! > 0){
            let cepStr = sender.text!.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: ".", with: "")
            
            print("cepStr: \(cepStr)")
            
            if (cepStr.count != 8){
                return
            }
            
            botaoAdicionar.startAnimation()
            self.view.endEditing(true)
            
            let queue = DispatchQueue.global(qos: .default)
            queue.async(execute: { () -> Void in
                
                let urlWebService: String = "https://viacep.com.br/ws/\(cepStr)/json/"
                
                print(urlWebService)
                
                let session: URLSession = URLSession.shared
                let urlObject: URL = URL(string: urlWebService)!
                
                let myTask = session.downloadTask(with: urlObject, completionHandler: { (location, response, error) -> Void in
                    
                    if(error == nil) {
                        let objectData = try? Data(contentsOf: location!)
                        
                        do{
                            let jsonData: NSDictionary = try JSONSerialization.jsonObject(with: objectData!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                            
                            if (jsonData["erro"] == nil) {
                                
                                let logradouro = jsonData["logradouro"] as! String
                                let bairro = jsonData["bairro"] as! String
                                let cidade = jsonData["localidade"] as! String
                                
                                DispatchQueue.main.async(execute: {
                                    
                                    self.botaoAdicionar.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.35, completion: nil)
                                    self.endereco.text = ""
                                    self.endereco2.text = logradouro
                                    self.bairro.text = bairro
                                    self.cidade.text = cidade
                                    self.cep.text = ""
                                    
                                    self.endereco2.textColor = UIColor.black
                                    self.oTable.isHidden = true
                                    
                                    self.view.endEditing(true)
                                    
                                    self.animarHolders()
                                    
                                })
                            } else {
                                DispatchQueue.main.async {
                                    let popup = PopupDialog(title: "Ops!", message: "CEP inválido. Tente novamente")
                                    popup.buttonAlignment = .horizontal
                                    popup.transitionStyle = .bounceUp
                                    let button = CancelButton(title: "Ok", action: {
                                    })
                                    popup.addButton(button)
                                    // Present dialog
                                    self.present(popup, animated: true, completion: nil)
                                }
                            }
                        } catch {
                            print("Erro na chamada JSON")
                        }
                    } else {
                        
                    }
                    
                })
                
                myTask.resume()
            })
        }
    }
    
    @IBAction func cepChanged(){
        
        let valor1 = cep.text!
        let valor2 = valor1.replacingOccurrences(of: " ", with: "")
        let valor3 = valor2.replacingOccurrences(of: ".", with: "")
        let valor4 = valor3.replacingOccurrences(of: "-", with: "")
        var valor4Copy = valor4
        
        if (valor4.count == 0){
            cep.text = ""
            return
        }
        
        var montandoCEP = ""
        
        for x in 0 ... 7 {
            if (valor4.count > x){
                let valorIndividual = valor4Copy[valor4Copy.startIndex]
                valor4Copy = String(valor4Copy[valor4Copy.index(after: valor4Copy.startIndex)..<valor4Copy.endIndex])
                montandoCEP.append(valorIndividual)
            } else {
                //if (x != 0){
                 //   montandoAmex.append(" ")
                //}
            }
            
            if (valor4.count > 2){
                if (x == 1){
                    montandoCEP.append(".")
                }
            }
            
            if (valor4.count > 5){
                if (x == 4){
                    montandoCEP.append("-")
                }
            }
        }
        
        cep.text = montandoCEP
        
        let newPosition = cep.position(from: cep.beginningOfDocument, offset: montandoCEP.count)
        cep.selectedTextRange = cep.textRange(from: newPosition!, to: newPosition!)
        
        if (valor4.count == 8){
            returnClickedFromCEP(sender: cep)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.count == 0 && range.length > 0 {
            
            let newLength = (textField.text ?? "").count + string.count - range.length
            return newLength <= 7
            
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if (textView.text!.suffix(1) == "\n"){
            textView.text = ""
            self.view.endEditing(true)
            return
        }
        
        if (textView.tag == 1){
            return
        }
        
        holderEndereco2.isHidden = true
        holderBairro.isHidden = true
        holderCidade.isHidden = true
        holderComplemento.isHidden = true
        holderNumero.isHidden = true
        confirmeAsInfosLabel.isHidden = true
        
        let texto = textView.text!
        let textoDigitado = texto.folding(options: .diacriticInsensitive, locale: Locale.current)
        let enderecoASerProcurado = textoDigitado.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "%20")
        
        if (enderecoASerProcurado.count <= 5){
            
            sugestoes.removeAll()
            self.oTable.reloadData()
            
            setTableViewHidden(true, animated: false)
            
            return
        }
        
        
        if (enderecoASerProcurado.count > 5){
            let queue = DispatchQueue.global(qos: .default)
            queue.async(execute: { () -> Void in
                
                let urlWebService: String = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(enderecoASerProcurado)&types=address&language=pt-BR&key=\((configuration.object(forKey: "GOOGLE_API_KEY") as! String))&location=-25.476877,-49.278694&radius=400"
                
                print(urlWebService)
                
                let session: URLSession = URLSession.shared
                let urlObject: URL = URL(string: urlWebService)!
                
                let myTask = session.downloadTask(with: urlObject, completionHandler: { (location, response, error) -> Void in
                    
                    if(error == nil) {
                        let objectData = try? Data(contentsOf: location!)
                        
                        do{
                            let jsonData: NSDictionary = try JSONSerialization.jsonObject(with: objectData!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                            
                            let status : String = jsonData["status"] as! String
                            
                            if status == "OK" {
                                
                                let predictions = jsonData["predictions"] as! [[String : Any]]
                                print(predictions)
                                //TEXTO SUPERIOR E TALS
                                
                                self.sugestoes.removeAll()
                                
                                if (predictions.count > 0){
                                    for x in 0 ... predictions.count - 1 {
                                        
                                        let prediction = predictions[x]
                                        
                                        var respostaMap = [String : Any]()
                                        let endereco = prediction["description"] as! String
                                        let idGooglePlace = prediction["place_id"] as! String
                                        let estruturaFormatacaoTexto = prediction["structured_formatting"] as! [String : Any]

                                        let nomeRua = estruturaFormatacaoTexto["main_text"] as! String
                                        
                                        let terms = prediction["terms"] as! [[String : Any]]
                                        if (terms.count >= 5){
                                            let cidadeTermo = terms[(terms.count - 3)]
                                            let cidade = cidadeTermo["value"] as! String
                                            let bairroTermo = terms[(terms.count - 4)]
                                            let bairro = bairroTermo["value"] as! String
                                            respostaMap["bairro"] = bairro
                                            respostaMap["cidade"] = cidade
                                        } else {
                                            respostaMap["bairro"] = ""
                                            respostaMap["cidade"] = ""
                                        }
                                        
                                        
                                        respostaMap["titulo"] = endereco
                                        respostaMap["place_id"] = idGooglePlace
                                        respostaMap["nomeRua"] = nomeRua
                                        
                                        self.sugestoes.append(respostaMap)
                                        
                                    }
                                }
                                
                                DispatchQueue.main.async(execute: {
                                    
                                    let textoDigitado = (self.endereco.text!).folding(options: .diacriticInsensitive, locale: Locale.current)
                                    let enderecoASerProcurado = textoDigitado.replacingOccurrences(of: " ", with: "%20")
                                    
                                    if (enderecoASerProcurado.count <= 5){
                                        
                                        self.sugestoes.removeAll()
                                        self.oTable.reloadData()
                                        
                                        self.setTableViewHidden(true, animated: false)
                                        
                                        return
                                    }
                                    
                                    self.oTable.reloadData()
                                    self.setTableViewHidden(false, animated: true)
                                    
                                })
                            }
                        } catch {
                            print("Erro na chamada JSON")
                        }
                    } else {
                        
                    }
                    
                })
                
                myTask.resume()
            })
        }
    }
    
    func setTableViewHidden(_ hidden : Bool, animated : Bool){
        
        if (oTable.isHidden){
            oTable.isHidden = false
            if (!hidden){
                oTable.alpha = 0
            }
        }
        
        if (animated){
            UIView.animate(withDuration: 0.3, animations: {
                if (hidden){
                    self.oTable.alpha = 0
                } else {
                    self.oTable.alpha = 1
                }
            })
        } else {
            if (hidden){
                oTable.alpha = 0
            } else {
                oTable.alpha = 1
            }
        }
    }
    
    var confirmandoEndereco = false
    @IBAction func prosseguir(){
        
        if (confirmandoEndereco){
            botaoAdicionar.startAnimation()
            PFUser.current()!["enderecoEntrega"] = enderecoConfirmado.text!
            PFUser.current()!["billing_address"] = billing_address
            PFUser.current()!["enderecoPoint"] = geoPoint
            PFUser.current()!.saveInBackground { (sucesso, erro) in
                self.dismiss(animated: true, completion: nil)
                self.delegate.onAdicionarEndereco(sucesso: true, novoEndereco: self.enderecoConfirmado.text!)
            }
            return
        }
        
        if (endereco2.text!.count < 3){
            let popup = PopupDialog(title: "Ops!", message: "Confira se você digitou o endereço corretamente!")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        if (bairro.text!.count < 2){
            let popup = PopupDialog(title: "Ops!", message: "Confira se você digitou o bairro corretamente!")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        if (cidade.text!.count < 2){
            let popup = PopupDialog(title: "Ops!", message: "Confira se você digitou a cidade corretamente!")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        if (numero.text!.count < 1){
            let popup = PopupDialog(title: "Ops!", message: "Confira se você digitou o número corretamente!")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        
        botaoAdicionar.startAnimation()
        
        var strBuilder = "\(endereco2.text!), \(numero.text!)"
        var strBuilder2 = "\(endereco2.text!), \(numero.text!)"
        billing_address["number"] = numero.text!
        billing_address["street"] = endereco2.text!
        if (complemento.text!.count > 0){
            strBuilder.append(", \(complemento.text!)")
            billing_address["complement"] = complemento.text!
        } else {
            billing_address["complement"] = ""
        }
        strBuilder.append(" - \(bairro.text!)")
        strBuilder2.append(" - \(bairro.text!)")
        billing_address["district"] = bairro.text!
        strBuilder.append(", \(cidade.text!)")
        strBuilder2.append(", \(cidade.text!)")
        billing_address["city"] = cidade.text!
        
        CLGeocoder().geocodeAddressString(strBuilder2) { [self] (places, erro) in
            if (erro == nil){
                let placeImportante = places![0]
                
                self.terminarBuscaDoEndereco(strBuilder: strBuilder, latitude: (placeImportante.location?.coordinate.latitude)!, longitude: (placeImportante.location?.coordinate.longitude)!, postalCode: placeImportante.postalCode?.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: ".", with: ""), state: placeImportante.administrativeArea)
                
            } else {
                //Geocoding falhou pela Apple API, tentar pelo Google API..
                print(erro)
                
                DispatchQueue.global(qos: .background).async {
                    do {
                        
                        let textoDigitado = strBuilder2.folding(options: .diacriticInsensitive, locale: Locale.current)
                        let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(textoDigitado.replacingOccurrences(of: " ", with: "%20"))&key=\((configuration.object(forKey: "GOOGLE_API_KEY") as! String))")
                        let request = NSMutableURLRequest(url: url! as URL, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 60.0)
                        
                        request.setValue("application/json", forHTTPHeaderField:"Content-type")
                        request.setValue("application/json", forHTTPHeaderField: "Accept")
                        request.httpMethod = "GET"
                        print(request)
                        let response = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: nil)
                        let returnedObject = try JSONSerialization.jsonObject(with: response, options: JSONSerialization.ReadingOptions.mutableLeaves)
                        if !(returnedObject is [String : Any]){
                            throw LimveError.runtimeError("Tipo incompátivel")
                        }
                        
                        let respostaJson = returnedObject as! [String : Any]
                        if ((respostaJson["status"] as! String) != "OK"){
                            throw LimveError.runtimeError("Google MAPS Api inválida.")
                        }
                        
                        let primeiroResultado = (respostaJson["results"] as! [[String : Any]])[0]
                        let geometry = primeiroResultado["geometry"] as! [String : Any]
                        
                        let latitude = (geometry["location"] as! [String : Any])["lat"] as! Double
                        let longitude = (geometry["location"] as! [String : Any])["lng"] as! Double
                        let addressComponents = primeiroResultado["address_components"] as! [[String : Any]]
                        
                        var postalCode = ""
                        var administrativeArea = ""
                        for x in 0 ... addressComponents.count - 1 {
                            let addressComponent = addressComponents[x]
                            let types = addressComponent["types"] as! [String]
                            if (types[0] == "postal_code"){
                                postalCode = (addressComponent["long_name"] as! String).replacingOccurrences(of: "-", with: "")
                            }
                            if (types[0] == "administrative_area_level_1"){
                                administrativeArea = addressComponent["long_name"] as! String
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.terminarBuscaDoEndereco(strBuilder: strBuilder, latitude: latitude, longitude: longitude, postalCode: postalCode, state: administrativeArea)
                        }
                        
                        
                    } catch {
                        DispatchQueue.main.async {
                            self.botaoAdicionar.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.35) {
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func terminarBuscaDoEndereco(strBuilder: String!, latitude: Double!, longitude: Double!, postalCode: String!, state: String!){
        
        self.geoPoint = PFGeoPoint(latitude: latitude, longitude: longitude)
        print("distancia calculada: \(pontoDeOrigem.distanceInKilometers(to: self.geoPoint))")
        if (pontoDeOrigem.distanceInKilometers(to: self.geoPoint) > 28.0){
            self.botaoAdicionar.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.35) {
                
                let popup = PopupDialog(title: "Ops!", message: "Infelizmente sua região está fora da nossa área de cobertura. Mas não se preocupe, chegaremos ai em breve!")
                popup.buttonAlignment = .horizontal
                popup.transitionStyle = .bounceUp
                let button = CancelButton(title: "Ok", action: {
                })
                popup.addButton(button)
                // Present dialog
                self.present(popup, animated: true, completion: nil)
                
            }
            return
        }
        
        self.enderecoConfirmado.text = strBuilder
        self.confirmandoEndereco = true
        
        let annotation = MKPointAnnotation()
        let coordenadas = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        self.billing_address["postal_code"] = postalCode
        self.billing_address["state"] = state
        
        annotation.coordinate = coordenadas
        annotation.title = "Local de entrega"
        self.mapView.addAnnotation(annotation)
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        }
        
        self.viewConfirmaEndereco.alpha = 0
        self.viewConfirmaEndereco.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.viewConfirmaEndereco.alpha = 1
        }
        self.mapView.setCenter(coordenadas, animated: true)
        let region = MKCoordinateRegion( center: coordenadas, latitudinalMeters: CLLocationDistance(exactly: 190)!, longitudinalMeters: CLLocationDistance(exactly: 190)!)
        self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
        
        self.botaoAdicionar.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.35) {
            self.botaoAdicionar.setTitle("Confirmar endereço", for: [])
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sugestoes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaSugestao") as! CelulaSugestao
        
        cell.backgroundColor = UIColor.clear
        
        if (indexPath.row <= sugestoes.count){
            let sugestao = sugestoes[indexPath.row]
            cell.titulo.text = (sugestao["titulo"] as! String)
        } else {
            cell.titulo.text = ""
            
        }
        
        return cell
            
    }
    
    func animarHolders(){
       holderEndereco2.isHidden = false
        holderBairro.isHidden = false
        holderCidade.isHidden = false
        holderComplemento.isHidden = false
        holderNumero.isHidden = false
        confirmeAsInfosLabel.isHidden = false
        
        holderEndereco2.alpha = 0
        holderBairro.alpha = 0
        holderCidade.alpha = 0
        holderComplemento.alpha = 0
        holderNumero.alpha = 0
        confirmeAsInfosLabel.alpha = 0
        
        UIView.animate(withDuration: 0.25, animations: {
            self.confirmeAsInfosLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.25, animations: {
                self.holderEndereco2.alpha = 1
            }) { _ in
                UIView.animate(withDuration: 0.25, animations: {
                    self.holderNumero.alpha = 1
                }) { _ in
                    UIView.animate(withDuration: 0.25, animations: {
                        self.holderComplemento.alpha = 1
                    }) { _ in
                        UIView.animate(withDuration: 0.25, animations: {
                            self.holderBairro.alpha = 1
                        }) { _ in
                            UIView.animate(withDuration: 0.25, animations: {
                                self.holderCidade.alpha = 1
                            }) { _ in
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        endereco.text = ""
        let endereco = sugestoes[indexPath.row]
        endereco2.text = (endereco["nomeRua"] as! String)
        bairro.text = (endereco["bairro"] as! String)
        cidade.text = (endereco["cidade"] as! String)
        cep.text = ""
        endereco2.textColor = UIColor.black
        oTable.isHidden = true
        self.view.endEditing(true)
        
        animarHolders()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61.0
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
}

class CelulaSugestao : UITableViewCell{
    @IBOutlet weak var titulo: UILabel!
}
