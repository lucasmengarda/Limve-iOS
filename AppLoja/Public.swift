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
import PopupDialog

public var MAIN_STORYBOARD = UIStoryboard(name: "Main",bundle: nil)
public var deslogado: Bool = false
public var configuration: PFConfig!
public var IP_EXTERNO: String! = ""

public var CUPOM_SALVO = ""

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
    case link
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
        if (params["cupom"] != nil){
            CUPOM_SALVO = (params["cupom"] as! String)
            print("CUPOM SALVO: \(CUPOM_SALVO)")
            var limveApp : UIWindow?
            limveApp = UIApplication.shared.keyWindow
            
            var appTopController = limveApp?.rootViewController
            
            if (appTopController?.presentedViewController != nil){
                appTopController = limveApp?.rootViewController?.presentedViewController
            }
            
            appTopController?.showToast(message: "Cupom '\(CUPOM_SALVO)' adicionado!", font: UIFont(name: "Ubuntu-Regular", size: 13.0)!)
            return
        }
    } else if (tipo == .link){
        print("App aberto com o URL (Scheme): \(url)")
        
        if (url!.absoluteString.contains("limve://")){
            let limparURL1 = url!.absoluteString.replacingOccurrences(of: "limve://", with: "")
            if (limparURL1.contains("?")){
                if (limparURL1.split(separator: "?")[0] == "abrirproduto"){
                    let produtoId = url!.queryParameters["produtoid"]
                    if (produtoId != nil){
                        
                        deepLinkAcaoAbrirProduto(produtoId: produtoId!)
                        
                        return
                    }
                    let cupom = url!.queryParameters["cupom"]
                    if (cupom != nil){
                        CUPOM_SALVO = (params["cupom"] as! String)
                        print("CUPOM SALVO: \(CUPOM_SALVO)")
                        var limveApp : UIWindow?
                        limveApp = UIApplication.shared.keyWindow
                        
                        var appTopController = limveApp?.rootViewController
                        
                        if (appTopController?.presentedViewController != nil){
                            appTopController = limveApp?.rootViewController?.presentedViewController
                        }
                        
                        appTopController?.showToast(message: "Cupom '\(CUPOM_SALVO)' adicionado!", font: UIFont(name: "Ubuntu-Regular", size: 13.0)!)
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

extension UIViewController {

    func showToast(message : String, font: UIFont) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 145, y: self.view.frame.size.height-150, width: 290, height: 42))
        toastLabel.backgroundColor = UIColor.white
        
        toastLabel.layer.shadowColor = hexStringToUIColor("#00224B").withAlphaComponent(0.5).cgColor
        toastLabel.layer.shadowOpacity = 2
        toastLabel.layer.shadowOffset = .zero
        toastLabel.layer.shadowRadius = 3
        
        toastLabel.textColor = UIColor.black
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10.0;
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2.0, delay: 3.0, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
