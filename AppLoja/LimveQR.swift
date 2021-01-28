//
//  LimveQR.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 11/12/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Lottie
import TransitionButton
import PopupDialog
import Parse

class LimveQR : UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var viewCamera: UIView!
    @IBOutlet weak var scanQRAnim: UIView!
    @IBOutlet weak var scanQRAnim2: UIView!
    @IBOutlet weak var seuQrCode: UIImageView!
    @IBOutlet weak var seuCodigoEscrito: UILabel!
    @IBOutlet weak var seuQrHolder: UIView!
    @IBOutlet weak var seuQrHolder2: UIView!
    @IBOutlet weak var seuQrHolder3: UIView!
    @IBOutlet weak var limveQRLabel: UILabel!
    @IBOutlet weak var abrirCameraButton: TransitionButton!
    @IBOutlet weak var validarButton: TransitionButton!
    @IBOutlet weak var holderDosHolders: UIView!
    
    @IBOutlet weak var blurCamera1: UIVisualEffectView!
    @IBOutlet weak var blurCamera2: UIVisualEffectView!
    @IBOutlet weak var flashHolder: UIVisualEffectView!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var codigoDigitado: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    var captureSession : AVCaptureSession?
    var videoPreviewLayer : AVCaptureVideoPreviewLayer?
    
    var codigo = ""
    
    let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                              AVMetadataObject.ObjectType.code39,
                              AVMetadataObject.ObjectType.code39Mod43,
                              AVMetadataObject.ObjectType.code93,
                              AVMetadataObject.ObjectType.code128,
                              AVMetadataObject.ObjectType.ean8,
                              AVMetadataObject.ObjectType.ean13,
                              AVMetadataObject.ObjectType.aztec,
                              AVMetadataObject.ObjectType.pdf417,
                              AVMetadataObject.ObjectType.qr]
    
    static func inicializeLimveQR(meuCodigo: String) -> LimveQR{
        let tela = MAIN_STORYBOARD.instantiateViewController(identifier: "LimveQR") as! LimveQR
        tela.codigo = meuCodigo
        return tela
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.translatesAutoresizingMaskIntoConstraints = true
        contentView.frame = CGRect(x: 0, y: 0, width: contentView.frame.size.width, height: (contentView.frame.size.height + 211.0))
        scrollView.addSubview(contentView)
        scrollView.contentSize = contentView.frame.size
        
        let texto = "LimveQRCode"
        let attributedTexto = NSMutableAttributedString(string: texto)
        attributedTexto.addAttribute(.font, value: UIFont(name: "Ubuntu-Bold", size: 26.0)!, range: NSRange(location: 0, length: 5))
        attributedTexto.addAttribute(.font, value: UIFont(name: "Ubuntu-Light", size: 26.0)!, range: NSRange(location: 5, length: 6))
        
        limveQRLabel.attributedText = attributedTexto
        
        let animationQR = AnimationView(name: "qrcodeinstruction")
        animationQR.loopMode = .loop
        animationQR.animationSpeed = 0.7
        animationQR.frame = CGRect(x: 5, y: -5, width: scanQRAnim.frame.width+10, height: scanQRAnim.frame.height+10)
        animationQR.contentMode = .scaleAspectFill
        scanQRAnim.addSubview(animationQR)
        animationQR.play(toProgress: 0.75)
        
        seuQrHolder.layer.cornerRadius = 16.0
        seuQrHolder.layer.shadowColor = hexStringToUIColor("#000").withAlphaComponent(0.25).cgColor
        seuQrHolder.layer.shadowOpacity = 2
        seuQrHolder.layer.shadowOffset = .zero
        seuQrHolder.layer.shadowRadius = 3
        
        seuQrHolder2.layer.cornerRadius = 16.0
        seuQrHolder2.layer.shadowColor = hexStringToUIColor("#000").withAlphaComponent(0.25).cgColor
        seuQrHolder2.layer.shadowOpacity = 2
        seuQrHolder2.layer.shadowOffset = .zero
        seuQrHolder2.layer.shadowRadius = 3
        
        seuQrHolder3.layer.cornerRadius = 16.0
        seuQrHolder3.layer.shadowColor = hexStringToUIColor("#000").withAlphaComponent(0.25).cgColor
        seuQrHolder3.layer.shadowOpacity = 2
        seuQrHolder3.layer.shadowOffset = .zero
        seuQrHolder3.layer.shadowRadius = 3
        
        flashHolder.layer.cornerRadius = flashHolder.frame.height/2
        flashHolder.clipsToBounds = true
        flashHolder.isHidden = true
        flashHolder.alpha = 0.0
        
        viewCamera.clipsToBounds = true
        viewCamera.layer.cornerRadius = 16.0
        
        seuCodigoEscrito.text = codigo
        
         let data = codigo.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        let qrCodeCI = filter?.outputImage
        let scaleX = seuQrCode.frame.size.width / (qrCodeCI?.extent.size.width)!
        let scaleY = seuQrCode.frame.size.height / (qrCodeCI?.extent.size.height)!
        let transformedImage = qrCodeCI?.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))//Scale transformation
        seuQrCode.image = UIImage(ciImage: transformedImage!)
        
        
        abrirCameraButton.spinnerColor = hexStringToUIColor("#200003")
        abrirCameraButton.setTitleColor(hexStringToUIColor("#200003"), for: [])
        abrirCameraButton.cornerRadius = abrirCameraButton.frame.height/2
        abrirCameraButton.backgroundColor = UIColor.white
        abrirCameraButton.clipsToBounds = false
        abrirCameraButton.layer.shadowColor = hexStringToUIColor("#000").withAlphaComponent(0.3).cgColor
        abrirCameraButton.layer.shadowOpacity = 1
        abrirCameraButton.layer.shadowOffset = .zero
        abrirCameraButton.layer.shadowRadius = 2
        
        validarButton.spinnerColor = hexStringToUIColor("#200003")
        validarButton.setTitleColor(hexStringToUIColor("#200003"), for: [])
        validarButton.cornerRadius = validarButton.frame.height/2
        validarButton.backgroundColor = UIColor.white
        validarButton.clipsToBounds = false
        validarButton.layer.shadowColor = hexStringToUIColor("#000").withAlphaComponent(0.3).cgColor
        validarButton.layer.shadowOpacity = 1
        validarButton.layer.shadowOffset = .zero
        validarButton.layer.shadowRadius = 2
        
    }
    
    @IBAction func abrirCameraFunction(){
        let captureDevice = AVCaptureDevice.default(for: .video)
        if (captureDevice == nil){
            return
        }
        
        flashHolder.isHidden = false
        UIView.animate(withDuration: 0.25) {
            
            self.seuQrHolder2.frame = CGRect(x: self.seuQrHolder2.frame.origin.x, y: self.seuQrHolder2.frame.origin.y, width: self.seuQrHolder2.frame.width, height: 343.0)
            self.abrirCameraButton.alpha = 0.0
            self.holderDosHolders.frame = CGRect(x: self.holderDosHolders.frame.origin.x, y: self.holderDosHolders.frame.origin.y + 211.0, width: self.holderDosHolders.frame.width, height: self.holderDosHolders.frame.height)
            self.flashHolder.alpha = 1.0
            
        } completion: { _ in
            do {
                // Get an instance of the AVCaptureDeviceInput class using the previous device object.
                let input = try AVCaptureDeviceInput(device: captureDevice!)
                
                // Initialize the captureSession object.
                self.captureSession = AVCaptureSession()
                
                // Set the input device on the capture session.
                self.captureSession?.addInput(input)
                
                // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
                let captureMetadataOutput = AVCaptureMetadataOutput()
                self.captureSession?.addOutput(captureMetadataOutput)
                
                // Set delegate and use the default dispatch queue to execute the call back
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                captureMetadataOutput.metadataObjectTypes = self.supportedCodeTypes
                
                // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
                self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
                self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.videoPreviewLayer?.frame = CGRect(x: 0, y: 0, width: self.viewCamera.frame.width, height: self.viewCamera.frame.height)
                self.viewCamera.layer.addSublayer(self.videoPreviewLayer!)
                
                //Start capturing.
                self.captureSession?.startRunning()
                
            } catch {
                // If any error occurs, simply print it out and don't continue any more.
                print(error)
                return
            }
            
            self.viewCamera.bringSubviewToFront(self.blurCamera1)
            self.viewCamera.bringSubviewToFront(self.blurCamera2)
            
            UIView.animate(withDuration: 0.2) {
                self.blurCamera1.frame = CGRect(x: 0, y: 0, width: 50.0, height: self.blurCamera1.frame.height)
                self.blurCamera2.frame = CGRect(x: (self.viewCamera.frame.width - 50), y: 0, width: 50.0, height: self.blurCamera2.frame.height)
            } completion: { [self] _ in
                let animationQR = AnimationView(name: "qrcodescan")
                animationQR.loopMode = .loop
                animationQR.animationSpeed = 0.3
                animationQR.frame = CGRect(x: -30, y: -30, width: self.scanQRAnim2.frame.width+60, height: self.scanQRAnim2.frame.height+60)
                animationQR.contentMode = .scaleAspectFill
                self.scanQRAnim2.addSubview(animationQR)
                animationQR.play()
            }

        }
    }
    
    @IBAction func toggleFlash(){
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        if (device!.hasTorch) {
            do {
                try device!.lockForConfiguration()
                if (device!.torchMode == AVCaptureDevice.TorchMode.on) {
                    device!.torchMode = AVCaptureDevice.TorchMode.off
                    flashButton.tintColor = UIColor.black
                } else {
                    do {
                        try device!.setTorchModeOn(level: 1.0)
                        flashButton.tintColor = UIColor.white
                    } catch {
                        print(error)
                    }
                }
                device!.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func fechar(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func processarCupom(){
        let texto = self.codigoDigitado.text
        
        if (texto!.count == 0){
            let popup = PopupDialog(title: "Ops!", message: "Você não inseriu nenhum cupom")
            popup.buttonAlignment = .horizontal
            popup.transitionStyle = .bounceUp
            let button = CancelButton(title: "Ok", action: {
            })
            popup.addButton(button)
            // Present dialog
            self.present(popup, animated: true, completion: nil)
            return
        }
        validarButton.startAnimation()
        
        self.view.endEditing(true)
        
        var params = [String : Any]()
        let produtosManual = [[String : Any]]()
        
        if (PFUser.current()!["enderecoPoint"] == nil){
            params["localizacaoEntregaLat"] = -25.423647
            params["localizacaoEntregaLng"] = -49.252177
        } else {
            let geop = (PFUser.current()!["enderecoPoint"] as! PFGeoPoint)
            params["localizacaoEntregaLat"] = geop.latitude
            params["localizacaoEntregaLng"] = geop.longitude
        }
        
        params["carrinho"] = produtosManual
        params["cupom"] = texto!.replacingOccurrences(of: " ", with: "")

        PFCloud.callFunction(inBackground: "aplicarCupom", withParameters: params) { [self] (resultado, erro) in
            
            if (resultado != nil){
                let resultadoJson = resultado as! [String: Any]
                
                if (resultadoJson["erro"] as! Bool){
                    if (resultadoJson["erroValorMinimo"] == nil){
                        let motivo = (resultadoJson["motivo"] as! String)
                        let popup = PopupDialog(title: "Ops!", message: motivo)
                        popup.buttonAlignment = .horizontal
                        popup.transitionStyle = .bounceUp
                        let button = CancelButton(title: "Ok", action: {
                        })
                        popup.addButton(button)
                        // Present dialog
                        self.present(popup, animated: true, completion: nil)
                        return
                    }
                }
                
                CUPOM_SALVO = texto!
                self.validarButton.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.25) {
                    self.validarButton.setTitle("Validado!", for: [])
                }
                self.showToast(message: "Cupom aplicado!", font: UIFont(name: "Ubuntu-Regular", size: 14.0)!)
                //self.dismiss(animated: true, completion: nil)
                
            } else {
                self.validarButton.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.25, completion: nil)
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
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if (metadataObjects == nil || metadataObjects.count == 0) {
            //qrCodeFrameView?.frame = CGRect.zero
            print("No QR/barcode is detected")
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if (supportedCodeTypes.contains(metadataObj.type)) {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            
            let qrCodeObjectBounds = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)?.bounds
            
            if ((qrCodeObjectBounds?.origin.x)! < 0){
                return
            }
            if ((qrCodeObjectBounds?.origin.y)! < 0){
                return
            }
            
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            captureSession?.stopRunning()
            
            if (metadataObj.stringValue != nil) {
                print(metadataObj.stringValue)
                
                self.codigoDigitado.text = metadataObj.stringValue
                self.scanQRAnim2.isHidden = true
                self.processarCupom()
                
            } else {
                captureSession?.startRunning()
            }
        }
    }
}
