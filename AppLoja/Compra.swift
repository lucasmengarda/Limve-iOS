//
//  Compra.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 03/03/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import Foundation
import UIKit
import Parse

class Compra {
    
    var precoTotal: Double!
    var enderecoEntrega: String!
    var freteCobrado: Double!
    var cestaDeProdutos: [[String : Any]]!
    var cartaoCobradoFinal: String!
    var cartaoCobradoBandeira: String!
    var data: Date!
    var parcelas: Int!
    var formaDePagamento: String!
    var compraPaga: Bool!
    
    var notaFiscal: [String : Any]!
    var boleto: [String : Any]!
    var boletoId: String!
    var horarioEmissaoNF: Date!
    
    var produtosArr = [String : Produto]()

    init(compra: PFObject){
        precoTotal = (compra["precoTotal"] as! Double)
        enderecoEntrega = (compra["enderecoEntrega"] as! String)
        freteCobrado = (compra["freteCobrado"] as! Double)
        cartaoCobradoFinal = (compra["cartaoCobradoFinal"] as! String)
        cartaoCobradoBandeira = (compra["cartaoCobradoBandeira"] as! String)
        cestaDeProdutos = compra["produtosManual"] as! [[String : Any]]
        data = compra.createdAt!
        parcelas = (compra["parcelas"] as! Int)
        formaDePagamento = (compra["formaDePagamento"] as! String)
        compraPaga = (compra["pago"] as! Bool)
        if (compra["notaFiscal"] != nil){
            horarioEmissaoNF = (compra["horarioEmissaoNF"] as! Date)
            notaFiscal = (compra["notaFiscal"] as! [String : Any])
        }
        if (compra["boleto"] != nil){
            boleto = (compra["boleto"] as! [String : Any])
            boletoId = (compra["boleto_id"] as! String)
        }
    }
    
    func setProdutosArr(produtos: [PFObject]){
        for produto in produtos {
            produtosArr[getObjectIdFromPFObject(produto)] = Produto(produto: produto)
        }
    }
}
