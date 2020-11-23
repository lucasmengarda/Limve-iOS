//
//  Public.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 30/01/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import Foundation
import UIKit
import Parse
import FBSDKCoreKit

public var MAIN_STORYBOARD = UIStoryboard(name: "Main",bundle: nil)
public var deslogado: Bool = false
public var configuration: PFConfig!
public var IP_EXTERNO: String! = ""

public func hexStringToUIColor (_ hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines as CharacterSet as CharacterSet).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString = cString.substring(from: cString.index(cString.startIndex, offsetBy: 1))
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

public func formatarPreco(preco: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "pt-BR")
    return formatter.string(from: NSNumber(value: preco))!
}

public func isUserLoggedIn() -> Bool {
    if (PFUser.current() == nil || PFUser.current()?.sessionToken == nil || PFUser.current()!["nome"] == nil){
        return false
    } else {
        return true
    }
}

public func formatarNomeDoUsuario() -> String{
    let username = (PFUser.current()!["nome"] as! String)
    if (username.split(separator: " ").count > 1){
        let primeiroNome = username.split(separator: " ")[0]
        let segundoNome = username.split(separator: " ")[1]
        if (primeiroNome.count < 6){
            return primeiroNome + " " + segundoNome
        } else {
            return String(primeiroNome)
        }
    } else {
        return username
    }
}

class UnderlinedLabel: UILabel {

override var text: String? {
    didSet {
        guard let text = text else { return }
        let textRange = NSMakeRange(0, text.count)
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(NSAttributedString.Key.strikethroughStyle , value: NSUnderlineStyle.single.rawValue, range: textRange)
        // Add other attributes if needed
        self.attributedText = attributedText
        }
    }
    override func awakeFromNib() {
        guard let text = text else { return }
        let textRange = NSMakeRange(0, text.count)
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(NSAttributedString.Key.strikethroughStyle , value: NSUnderlineStyle.single.rawValue, range: textRange)
        // Add other attributes if needed
        self.attributedText = attributedText
    }
}

public func getObjectIdFromPFObject(_ pfObject: PFObject) -> String{
    let id = "\(pfObject.objectId)"
    let ObjectIdFinal = id.replacingOccurrences(of: "Optional", with: "")
    let ObjectIdFinal2 = ObjectIdFinal.replacingOccurrences(of: "\"", with: "")
    let ObjectIdFinal3 = ObjectIdFinal2.replacingOccurrences(of: "(", with: "")
    let ObjectIdFinal4 = ObjectIdFinal3.replacingOccurrences(of: ")", with: "")
    return ObjectIdFinal4
}

extension UITextView {
    func numberOfLines() -> Int {
        let layoutManager = self.layoutManager
        let numberOfGlyphs = layoutManager.numberOfGlyphs
        var lineRange: NSRange = NSMakeRange(0, 1)
        var index = 0
        var numberOfLines = 0

        while index < numberOfGlyphs {
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange)
            numberOfLines += 1
        }
        return numberOfLines
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
}

struct LimveError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    public var localizedDescription: String {
        return message
    }
    
    static func runtimeError(_ message: String) -> LimveError{
        let lv = LimveError(message)
        return lv
    }
}

extension UITextField {
    func disableAutoFill() {
        if #available(iOS 12, *) {
            textContentType = .oneTimeCode
        } else {
            textContentType = .init(rawValue: "")
        }
    }
}

public enum TipoDeepLink {
    case branch
    case link_appAberto
    case link_appFechado
}

public enum AcaoDeepLink {
    case abrirProduto
}

public var filaDeepLinks = [[AcaoDeepLink : String]]()

public func processarDeeplink(_ tipo: TipoDeepLink, params: [AnyHashable : Any], _ url: URL?){
    if (tipo == .branch){
        print("BRANCH PARAMS: \(params)")
        if (params["produtoid"] != nil){
            deepLinkAcaoAbrirProduto(produtoId: params["produtoid"] as! String)
            return
        }
    } else if (tipo == .link_appAberto || tipo == .link_appFechado){
        print("App aberto com o URL (Scheme): \(url)")
        
        if (url!.absoluteString.contains("limve://")){
            let limparURL1 = url!.absoluteString.replacingOccurrences(of: "limve://", with: "")
            if (limparURL1.contains("?")){
                if (limparURL1.split(separator: "?")[0] == "abrirproduto"){
                    let produtoId = url!.queryParameters["produtoid"]
                    if (produtoId != nil){
                        
                        if (tipo == .link_appAberto){
                            deepLinkAcaoAbrirProduto(produtoId: produtoId!)
                        } else {
                            filaDeepLinks.append([AcaoDeepLink.abrirProduto: produtoId!])
                        }
                        
                        return
                    }
                }
            }
        }
    }
}

public func deepLinkAcaoAbrirProduto(produtoId: String){
    NavigationMenuViewController.myVC.menuContainerViewController!.selectContentViewController(TelaInicial.inicializeTelaInicialFromDeepLink(produtoId: produtoId))
    NavigationMenuViewController.myVC.menuContainerViewController!.hideSideMenu()
}

public func averiguarDeepLinksNaFila(){
    if (filaDeepLinks.count > 0){
        for acao in filaDeepLinks {
            if (acao.keys.first! == .abrirProduto){
                let produtoId = acao[.abrirProduto]
                NavigationMenuViewController.myVC.menuContainerViewController!.selectContentViewController(TelaInicial.inicializeTelaInicialFromDeepLink(produtoId: produtoId))
                NavigationMenuViewController.myVC.menuContainerViewController!.hideSideMenu()
            }
        }
        filaDeepLinks.removeAll()
    }
}

//eventos de rastreio do FacebookAds
func logAddToCartEvent(produto: Produto) {
    
    let parameters = [
        AppEvents.ParameterName.content.rawValue: "\(produto.marca!) \(produto.descricao!)",
        AppEvents.ParameterName.contentID.rawValue: produto.produtoId,
        AppEvents.ParameterName.contentType.rawValue: produto.categoria,
        AppEvents.ParameterName.currency.rawValue: "BRL"
    ]

    AppEvents.logEvent(.addedToCart, valueToSum: produto.precoVenda, parameters: parameters as [String : Any])
}

func logVerProduto(produto: Produto) {
    
    let parameters = [
        AppEvents.ParameterName.content.rawValue: "\(produto.marca!) \(produto.descricao!)",
        AppEvents.ParameterName.contentID.rawValue: produto.produtoId,
        AppEvents.ParameterName.contentType.rawValue: produto.categoria,
        AppEvents.ParameterName.currency.rawValue: "BRL"
    ]

    AppEvents.logEvent(.viewedContent, valueToSum: produto.precoVenda, parameters: parameters as [String : Any])
}

func logSearchEvent(produto: Produto, searchString: String) {
    
    let parameters = [
        AppEvents.ParameterName.content.rawValue: "\(produto.marca!) \(produto.descricao!)",
        AppEvents.ParameterName.contentID.rawValue: produto.produtoId!,
        AppEvents.ParameterName.contentType.rawValue: produto.categoria!,
        AppEvents.ParameterName.searchString.rawValue: searchString,
        AppEvents.ParameterName.success.rawValue: NSNumber(value: true)
    ] as [String : Any]

    AppEvents.logEvent(.searched, parameters: parameters)
}

func logAdicionarAosFavoritos(produto: Produto) {
    let parameters = [
        AppEvents.ParameterName.content.rawValue: "\(produto.marca!) \(produto.descricao!)",
        AppEvents.ParameterName.contentID.rawValue: produto.produtoId,
        AppEvents.ParameterName.contentType.rawValue: produto.categoria,
        AppEvents.ParameterName.currency.rawValue: "BRL"
    ]

    AppEvents.logEvent(.addedToWishlist, valueToSum: produto.precoVenda, parameters: parameters as [String : Any])
}

func logAddPaymentInfoEvent(success: Bool) {
    
    let parameters = [
        AppEvents.ParameterName.success.rawValue: NSNumber(value: success ? 1 : 0)
    ]

    AppEvents.logEvent(.addedPaymentInfo, parameters: parameters)
}

extension URL {
    var queryParameters: QueryParameters { return QueryParameters(url: self) }
}

class QueryParameters {
    let queryItems: [URLQueryItem]
    init(url: URL?) {
        queryItems = URLComponents(string: url?.absoluteString ?? "")?.queryItems ?? []
        print(queryItems)
    }
    subscript(name: String) -> String? {
        return queryItems.first(where: { $0.name == name })?.value
    }
}
