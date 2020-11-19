//
//  CarrinhoObjects.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 17/02/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import Foundation
import UIKit

class CarrinhoObject {
    static var carrinhoObject = CarrinhoObject()
    var produtos = [Produto]()
    var produtosId = [String]()
    
    var valorDoCarrinho = 0.0;
    
    static func get() -> CarrinhoObject{
        return carrinhoObject
    }
    
    func removerDoCarrinho(produto: Produto){
        var novoProdutosId = [String]()
        for produtoId in produtosId {
            if (produtoId != produto.produtoId){
                novoProdutosId.append(produtoId)
            }
        }
        var novoProdutos = [Produto]()
        for produtoIn in produtos {
            if (produtoIn.produtoId != produto.produtoId){
                novoProdutos.append(produtoIn)
            }
        }
        
        self.produtosId = novoProdutosId
        self.produtos = novoProdutos
        
        atualizarValorDoCarrinho()
    }
    
    func removerTodosDoCarrinho(){
        self.produtosId = [String]()
        self.produtos = [Produto]()
        
        atualizarValorDoCarrinho()
    }
    
    func adicionarAoCarrinho(produto: Produto){
        
        logAddToCartEvent(produto: produto)
        
        if (!produtosId.contains(produto.produtoId)){
            produtos.append(produto)
            produtosId.append(produto.produtoId)
            
            produto.valorDesteProdutoNoCarrinho = (Double(produto.quantidade) * produto.precoVenda)
        }
        atualizarValorDoCarrinho()
    }
    
    func atualizarValorDoCarrinho(){
        valorDoCarrinho = 0.0
        for product in produtos {
            valorDoCarrinho += product.valorDesteProdutoNoCarrinho
        }
    }
}
