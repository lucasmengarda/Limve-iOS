//
//  NotaFiscal.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 15/10/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import Foundation
import UIKit
import Parse
import TransitionButton
import PopupDialog
import NVActivityIndicatorView
import DynamicBlurView
import SafariServices

class NotaFiscal: UIViewController {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var botaoAbrirLink: TransitionButton!
    @IBOutlet weak var botaoFechar: TransitionButton!
    
    @IBOutlet weak var horario: UILabel!
    @IBOutlet weak var nome: UILabel!
    @IBOutlet weak var cpf: UILabel!
    @IBOutlet weak var calculoImposto: UILabel!
    @IBOutlet weak var chaveNfe: UILabel!
    @IBOutlet weak var valorNfe: UILabel!
    
    @IBOutlet weak var qrCode: UIImageView!
    
    var compra: Compra!
    var delegate: ComprasVerDetalhes!
    
    static func inicializeNotaFiscal(compra: Compra, delegate: ComprasVerDetalhes) -> NotaFiscal{
        let tela = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "NotaFiscal") as! NotaFiscal
        tela.compra = compra
        tela.delegate = delegate
        return tela
    }
    
    @IBAction func fechar(){
        delegate.onExitObrigado()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        holder.layer.cornerRadius = 16.0
        holder.clipsToBounds = true
        self.view.backgroundColor = UIColor.clear
        holder.layer.shadowColor = hexStringToUIColor("#00224B").cgColor
        holder.layer.shadowOpacity = 6
        holder.layer.shadowOffset = .zero
        holder.layer.shadowRadius = 10
        
        botaoAbrirLink.spinnerColor = UIColor.white
        botaoAbrirLink.cornerRadius = botaoAbrirLink.frame.height/2
        botaoAbrirLink.backgroundColor = hexStringToUIColor("#4BC562")
        botaoFechar.spinnerColor = UIColor.white
        botaoFechar.cornerRadius = botaoFechar.frame.height/2
        botaoFechar.backgroundColor = hexStringToUIColor("#EF343A")
        
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        let df2 = DateFormatter()
        df2.dateFormat = "HH:mm"
        
        horario.text = "\(df.string(from: compra.horarioEmissaoNF)) às \(df2.string(from: compra.horarioEmissaoNF))"
        nome.text = (compra.notaFiscal["nomeCliente"] as! String)
        cpf.text = (compra.notaFiscal["cpfCliente"] as! String)
        calculoImposto.text = (compra.notaFiscal["calculoImposto"] as! String)
        valorNfe.text = "R$ \(String.init(format: "%.2f", (compra.notaFiscal["valorDaNfe"] as! Double)).replacingOccurrences(of: ".", with: ","))"
        chaveNfe.text = (compra.notaFiscal["chave"] as! String)
        
        let link = compra.notaFiscal["link"] as! String
        
        let data = link.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        let qrCodeCI = filter?.outputImage
        let scaleX = qrCode.frame.size.width / (qrCodeCI?.extent.size.width)!
        let scaleY = qrCode.frame.size.height / (qrCodeCI?.extent.size.height)!
        let transformedImage = qrCodeCI?.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))//Scale transformation
        qrCode.image = UIImage(ciImage: transformedImage!)
        
    }
    
    @IBAction func abrirLink(){
        let link = compra.notaFiscal["link"] as! String
        if let url = URL(string: link.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!) {
            UIApplication.shared.open(url)
        }
    }
    
}
