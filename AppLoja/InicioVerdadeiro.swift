//
//  InicioVerdadeiro.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 08/08/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import UIKit
import Foundation
import InteractiveSideMenu
import TransitionButton
import Parse
import NVActivityIndicatorView
import DynamicBlurView

class InicioVerdadeiro: UIViewController, SideMenuItemContent {
    
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var holderInicioVerdadeiro: UIView!
    @IBOutlet weak var botaoNavegar: TransitionButton!
    @IBOutlet weak var botaoBuscar: TransitionButton!

    var frameOriginalHolderInicio: CGRect!
    
    static func inicializeInicioVerdadeiro() -> InicioVerdadeiro{
        let tela = MAIN_STORYBOARD.instantiateViewController(identifier: "InicioVerdadeiro") as! InicioVerdadeiro
        return tela
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        holder.layer.cornerRadius = 16.0
        holder.clipsToBounds = false
        frameOriginalHolderInicio = holderInicioVerdadeiro.frame
        holderInicioVerdadeiro.frame = CGRect(x: holderInicioVerdadeiro.frame.origin.x, y: UIScreen.main.bounds.size.height, width: holderInicioVerdadeiro.frame.width, height: holderInicioVerdadeiro.frame.height)
        
        holder.layer.shadowColor = hexStringToUIColor("#00224B").cgColor
        holder.layer.shadowOpacity = 6
        holder.layer.shadowOffset = .zero
        holder.layer.shadowRadius = 10
        
        botaoNavegar.backgroundColor = hexStringToUIColor("#4BC562")
        botaoNavegar.spinnerColor = UIColor.white
        botaoNavegar.cornerRadius = botaoNavegar.frame.height/2
        
        botaoBuscar.backgroundColor = hexStringToUIColor("#f9813a")
        botaoBuscar.spinnerColor = UIColor.white
        botaoBuscar.cornerRadius = botaoNavegar.frame.height/2
        
        UIView.animate(withDuration: 0.35) {
            self.holderInicioVerdadeiro.frame = self.frameOriginalHolderInicio
        }
        
        DispatchQueue.global(qos: .background).async {
            do {
                
                    do {
                        var publicIP = try String(contentsOf: URL(string: "https://api.ipify.org/")!, encoding: String.Encoding.utf8)
                        publicIP = publicIP.trimmingCharacters(in: CharacterSet.whitespaces)
                        IP_EXTERNO = publicIP
                        print("MEU IP É: \(IP_EXTERNO)")
                    }
                    catch {
                        print("Error: \(error)")
                    }
                
                configuration = try PFConfig.getConfig()
                try PFUser.current()?.fetch()
                
                UIApplication.shared.applicationIconBadgeNumber = 0
                let currentInstallation = PFInstallation.current()
                currentInstallation?.badge = 0
                try PFUser.current()?.save()
                print("USER ID: \((PFUser.current()))")
                currentInstallation?["userId"] = (PFUser.current()!.objectId)
                currentInstallation?.saveInBackground()
            } catch {
                print("Erro \(error.localizedDescription)")
                PFUser.logOut()
            }
        }
    }
    
    @IBAction func abrirMenu(){
        self.view.endEditing(true)
        showSideMenu()
    }
    
    @IBAction func buscarProduto(){
        NavigationMenuViewController.myVC.menuContainerViewController!.selectContentViewController(TelaInicial.inicializeTelaInicialAsBuscarAcionado())
        NavigationMenuViewController.myVC.menuContainerViewController!.hideSideMenu()
    }
    
}
