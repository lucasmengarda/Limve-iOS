//
//  Produto.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 17/02/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import Foundation
import UIKit
import Parse

class Produto {
    
    var categoria : String!
    var estoque : Double!
    var precoVenda : Double!
    var precoSemDesconto = 0.0
    var marca : String!
    var descricao : String!
    var descricaolonga: String!
    var subdescricao : String!
    var imagem : UIImage!
    var imagemLoaded = false
    
    var produtoId : String!
    
    var file: PFFileObject?
    
    var quantidade = 1
    var valorDesteProdutoNoCarrinho = 0.0
    
    public func atualizarValorDoProdutoNoCarrinho(){
        self.valorDesteProdutoNoCarrinho = (Double(quantidade) * precoVenda)
    }
    
    init(produto: PFObject){
        
        categoria = (produto.object(forKey: "categoria") as! String)
        estoque = (produto.object(forKey: "estoque") as! Double)
        precoVenda = (produto.object(forKey: "precodevenda") as! Double)
        marca = (produto.object(forKey: "marca") as! String)
        descricao = (produto.object(forKey: "descricao") as! String)
        if (produto.object(forKey: "subdescricao") != nil) {
            subdescricao = (produto.object(forKey: "subdescricao") as! String)
        } else {
            subdescricao = ""
        }
        if (produto.object(forKey: "descricaolonga") != nil) {
            descricaolonga = (produto.object(forKey: "descricaolonga") as! String)
        } else {
            descricaolonga = "Produto sem descrição, por enquanto!"
        }
        if (produto.object(forKey: "precoDeVendaAntigo") != nil) {
            precoSemDesconto = (produto.object(forKey: "precoDeVendaAntigo") as! Double)
        }
        
        file = produto.object(forKey: "imagem") as? PFFileObject
        
        if (file != nil){
            DispatchQueue.global(qos: .background).async {
                do {
                    let oldData = try self.file?.getData()
                    self.imagem = UIImage(data: oldData!)
                    self.imagemLoaded = true
                } catch {
                    
                }
            }
            imagemLoaded = false
        } else {
            self.imagem = UIImage(named: "semimagem.jpg")
            self.imagemLoaded = true
        }
        
        produtoId = getObjectIdFromPFObject(produto)
    }
    
    func retornaImagem(imageView: UIImageView, loader: UIView){
        if (file != nil){
            if (imagemLoaded){
                imageView.image = imagem
                loader.isHidden = true
                imageView.isHidden = false
            } else {
                DispatchQueue.global(qos: .background).async {
                    do {
                        let oldData = try self.file?.getData()
                        self.imagem = UIImage(data: oldData!)
                        self.imagemLoaded = true
                        DispatchQueue.main.async {
                            imageView.image = self.imagem
                            loader.isHidden = true
                            imageView.isHidden = false
                        }
                    } catch {
                        
                    }
                }
            }
        } else {
            self.imagem = UIImage(named: "semimagem.jpg")
            self.imagemLoaded = true
            imageView.image = imagem
            loader.isHidden = true
            imageView.isHidden = false
        }
    }
}
