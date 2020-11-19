//
//  File.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 28/02/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import Foundation
import UIKit
import Parse


enum CartaoTipo {
    case amex
    case mastercard
    case visa
    case elo
    case outro
}

enum CartaoStyle {
    case credito
    case debito
}

class Cartao {
    
    var bandeira : CartaoTipo!
    var bandeiraOutro: String!
    var final : String!
    var validade : String!
    var cartaoId : String!
    var parseObject: PFObject!
    var cartaoStyle: CartaoStyle!
    var cardGetNet: [String : Any]!
    
    func excluirCartaoParaSempre(){
        parseObject.deleteInBackground()
    }
    
    init(cartao: PFObject){
        parseObject = cartao
        if ((cartao["bandeira"] as! String) == "Master"){
            bandeira = .mastercard
        } else if ((cartao["bandeira"] as! String) == "Visa"){
            bandeira = .visa
        } else if ((cartao["bandeira"] as! String) == "Elo"){
            bandeira = .elo
        } else if ((cartao["bandeira"] as! String) == "Amex"){
            bandeira = .amex
        } else {
            bandeira = .outro
            bandeiraOutro = (cartao["bandeira"] as! String)
        }
        
        if ((cartao["tipo"] as! String) == "credito"){
            cartaoStyle = .credito
        } else {
            cartaoStyle = .debito
        }
        
        cardGetNet = (cartao["cardGetNet"] as! [String : Any])
        final = (cartao["final"] as! String)
        validade = (cartao["validade"] as! String)
        cartaoId = (cartao["cartaoId"] as! String)
    }
    
    init(){
        let randomInt = Int.random(in: 0..<5)
        if (randomInt == 0){
            bandeira = .mastercard
        } else if (randomInt == 1){
            bandeira = .visa
        } else if (randomInt == 2){
            bandeira = .amex
        } else if (randomInt == 3){
            bandeira = .elo
        } else {
            bandeira = .outro
        }
        
        let num1 = Int.random(in: 0..<9)
        let num2 = Int.random(in: 0..<9)
        let num3 = Int.random(in: 0..<9)
        let num4 = Int.random(in: 0..<9)
        
        final = "\(num1)\(num2)\(num3)\(num4)"
        validade = "11/2027"
    }
}


