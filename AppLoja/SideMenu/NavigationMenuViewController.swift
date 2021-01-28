//
//  NavigationMenuViewController.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 29/01/2020.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import Foundation
import InteractiveSideMenu
import Parse
import TransitionButton
import DynamicBlurView
import FBSDKCoreKit

var selectedMenuItem = 0

class NavigationMenuViewController: MenuViewController, UITableViewDelegate, UITableViewDataSource, SectionHeaderViewDelegate, LoginCadastrarDelegate  {
    
    let SectionHeaderViewIdentifier = "SectionHeaderViewIdentifier"
    
    public static var sectionInfoArray = [SectionInfo]()
    public static var abertosFechados = [String:Bool]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoHolder: UIView!
    @IBOutlet weak var sejaBemVindoLabel: UILabel!
    @IBOutlet weak var nomeLabel: UILabel!
    @IBOutlet weak var segundoNomeLabel: UILabel!
    @IBOutlet weak var loginButton: TransitionButton!
    @IBOutlet weak var cadastrarButton: TransitionButton!
    @IBOutlet weak var footerHolder: UIView!
    
    var hostVC: HostViewController!
    static var myVC: NavigationMenuViewController!
    
    static func inicialize(delegate: HostViewController) -> NavigationMenuViewController{
        let vc = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "NavigationMenu") as! NavigationMenuViewController
        vc.hostVC = delegate
        NavigationMenuViewController.myVC = vc
        return vc
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let sectionHeaderNib: UINib = UINib(nibName: "SectionHeaderView", bundle: nil)
        self.tableView.register(sectionHeaderNib, forHeaderFooterViewReuseIdentifier: SectionHeaderViewIdentifier)
        
        let sectionHeaderNib2: UINib = UINib(nibName: "SectionHeaderWhats", bundle: nil)
        self.tableView.register(sectionHeaderNib2, forHeaderFooterViewReuseIdentifier: "SectionHeaderWhats")

        // you can change section height based on your needs
       // self.tableView.sectionHeaderHeight = 30
        
        loginButton.spinnerColor = UIColor.white
        loginButton.cornerRadius = loginButton.frame.height/2
        loginButton.backgroundColor = hexStringToUIColor("#CD5D7D")
        
        cadastrarButton.spinnerColor = UIColor.white
        cadastrarButton.cornerRadius = cadastrarButton.frame.height/2
        cadastrarButton.backgroundColor = hexStringToUIColor("#a01d5d")
        
        
        //
        self.view.backgroundColor = hexStringToUIColor("#944e6c")
        tableView.backgroundColor = UIColor.clear
        tableView.tableHeaderView = logoHolder
        tableView.tableFooterView = footerHolder
        
        let section0: SectionInfo = SectionInfo(itemsInSection: [], sectionTitle: "Início", sectionId: "inicio")
        let section1: SectionInfo = SectionInfo(itemsInSection: [], sectionTitle: "Produtos favoritos", sectionId: "produtos_favoritos")
        let section2: SectionInfo = SectionInfo(itemsInSection: [["shampoos": "Shampoos"], ["condicionadores": "Condicionadores"], ["shampoos-premium": "Shampoos Premium"], ["cabelos-kits": "Kits"], ["condicionadores-premium": "Condicionadores Premium"], ["hidratacao": "Hidratação"], ["colorantes": "Colorantes"], ["descolorantes": "Descolorantes"], ["cabelos-linha-infantil": "Linha infantil"]], sectionTitle: "Cabelos", sectionId: "cabelos")
        
        let section3: SectionInfo = SectionInfo(itemsInSection: [["lapis-delineador": "Lápis e delineador"], ["maquiagem-acessorios": "Acessórios"], ["sobrancelhas": "Sobrancelhas"], ["bases-corretivos": "Bases e Corretivos"], ["contornos-blush-po": "Contornos, Blush e Pó"], ["kits-paletas": "Kits e Paletas"], ["olhos": "Olhos"], ["primer": "Primer"]], sectionTitle: "Maquiagem", sectionId: "maquiagem")
        
        let section4: SectionInfo = SectionInfo(itemsInSection: [["esmaltes": "Esmaltes"], ["unhas-posticas": "Unhas Postiças"], ["removedores-esmalte": "Removedores de esmalte"], ["unhas-acessorios": "Acessórios"]], sectionTitle: "Unhas", sectionId: "unhas")
        
        let section5: SectionInfo = SectionInfo(itemsInSection: [["mascaras-faciais": "Máscaras Faciais"], ["hidratantes": "Hidratantes"], ["demaquilantes": "Demaquilantes"], ["esfoliantes": "Esfoliantes"], ["sabonetes-faciais": "Sabonetes faciais"], ["tonicos-adstringentes": "Tônicos e Adstringentes"], ["anti-idade": "Anti-idade"], ["anti-acne": "Antiacne"], ["protetor-solar-facial": "Protetor solar facial"]], sectionTitle: "Skincare", sectionId: "skincare")
        

        let section6: SectionInfo = SectionInfo(itemsInSection: [["desodorantes-femininos": "Desodorantes femininos"], ["desodorantes-masculinos": "Desodorantes masculinos"], ["sabonetes-em-barra": "Sabonete em barra"], ["sabonetes-liquido": "Sabonete líquido"], ["sabonetes-intimos": "Sabonete íntimo"], ["lenços-umedecidos": "Lenços umedecidos"], ["bronzeador-solar": "Bronzeador solar"], ["protetor-solar": "Protetor solar"], ["produtos-barba": "Produtos para a barba"], ["escova-dental": "Escova dental"], ["creme-dental": "Creme dental"], ["antissepticos": "Antissépticos"]], sectionTitle: "Cuidados pessoais", sectionId: "cuidados-pessoais")
        

        let section7: SectionInfo = SectionInfo(itemsInSection: [["amaciante": "Amaciante"], ["tira-manchas": "Tira Manchas"], ["sabao-em-po": "Sabão em pó"], ["sabao-liquido": "Sabão líquido"], ["alvejantes-e-cloros": "Alvejantes e Cloros"], ["desengordurante": "Desengordurantes"], ["desinfetantes": "Desinfetantes"], ["lava-louça": "Lava Louças"], ["limpa-vidro": "Limpa Vidros"], ["limpador-saponaceo": "Limpadores e Saponáceos"], ["lustra-moveis-ceras": "Lustra móveis e Ceras"], ["agua-sanitaria": "Água sanitária"], ["alcool": "Álcool"], ["lenços-limpeza": "Lenços de limpeza"]], sectionTitle: "Produtos de limpeza", sectionId: "produtos-limpeza")
        
        
        let section8: SectionInfo = SectionInfo(itemsInSection: [], sectionTitle: "Minhas compras", sectionId: "minhas_compras")
        let section9: SectionInfo = SectionInfo(itemsInSection: [], sectionTitle: "Meus cartões", sectionId: "meus_cartoes")
        let section10: SectionInfo = SectionInfo(itemsInSection: [], sectionTitle: "whatsapp", sectionId: "whatsapp")
        
        NavigationMenuViewController.sectionInfoArray.append(section0)
        NavigationMenuViewController.sectionInfoArray.append(section1)
        NavigationMenuViewController.sectionInfoArray.append(section2)
        NavigationMenuViewController.sectionInfoArray.append(section3)
        NavigationMenuViewController.sectionInfoArray.append(section4)
        NavigationMenuViewController.sectionInfoArray.append(section5)
        NavigationMenuViewController.sectionInfoArray.append(section6)
        NavigationMenuViewController.sectionInfoArray.append(section7)
        NavigationMenuViewController.sectionInfoArray.append(section8)
        NavigationMenuViewController.sectionInfoArray.append(section9)
        
        if (isUserLoggedIn()){
            loginButton.isHidden = true
            cadastrarButton.isHidden = true
            sejaBemVindoLabel.text = "Seja bem-vindo(a),"
            nomeLabel.text = formatarNomeDoUsuario()
            segundoNomeLabel.text = formatarNomeDoUsuario()

            let section11: SectionInfo = SectionInfo(itemsInSection: [], sectionTitle: "Sair", sectionId: "sair")
            NavigationMenuViewController.sectionInfoArray.append(section11)
            NavigationMenuViewController.sectionInfoArray.append(section10)
        } else {
            loginButton.isHidden = false
            cadastrarButton.isHidden = false
            sejaBemVindoLabel.text = "Identifique-se"
            nomeLabel.text = ""
            segundoNomeLabel.text = ""

            NavigationMenuViewController.sectionInfoArray.append(section10)
        }
    }
    
    var blurEffectView: UIView!
    
    @IBAction func login(){
        let login = LoginController.inicializeLoginController(delegate: self)
        menuContainerViewController!.hideSideMenu()
        menuContainerViewController?.present(login, animated: true, completion: nil)
    }
    
    @IBAction func cadastrarse(){
        let blurView = DynamicBlurView(frame: self.view.bounds)
        blurView.blurRadius = 4
        blurView.trackingMode = .tracking
        blurView.isDeepRendering = true
        blurView.tintColor = .clear
        blurView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        let overlay = UIView(frame: self.view.bounds)
        overlay.backgroundColor = .black
        overlay.alpha = 0.4
        overlay.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        blurEffectView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        blurEffectView.backgroundColor = UIColor.clear
        
        blurEffectView.addSubview(blurView)
        blurEffectView.addSubview(overlay)
        
        menuContainerViewController!.view.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        
        UIView.animate(withDuration: 0.25, animations: {
            self.blurEffectView.alpha = 1
        }) { _ in
            
        }
        
        let cadastrar = CadastrarController.inicializeCadastrarController(delegate: self)
        menuContainerViewController!.hideSideMenu()
        menuContainerViewController?.present(cadastrar, animated: true, completion: {
            blurView.trackingMode = .none
        })
    }
    
    func onExit(sussecefull: Bool) {
        if (self.blurEffectView != nil){
            UIView.animate(withDuration: 0.25, animations: {
                self.blurEffectView.alpha = 0
            }) { _ in
                self.blurEffectView.removeFromSuperview()
            }
        }
        
        if (sussecefull){
            if (isUserLoggedIn()){
                loginButton.isHidden = true
                cadastrarButton.isHidden = true
                sejaBemVindoLabel.text = "Seja bem-vindo(a),"
                nomeLabel.text = formatarNomeDoUsuario()
                segundoNomeLabel.text = formatarNomeDoUsuario()
                
                let section10: SectionInfo = SectionInfo(itemsInSection: [], sectionTitle: "Sair", sectionId: "sair")
                NavigationMenuViewController.sectionInfoArray.append(section10)
                tableView.reloadData()
            } else {
                loginButton.isHidden = false
                cadastrarButton.isHidden = false
                sejaBemVindoLabel.text = "Identifique-se"
                nomeLabel.text = ""
                segundoNomeLabel.text = ""
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return NavigationMenuViewController.sectionInfoArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if NavigationMenuViewController.sectionInfoArray.count > 0 {
            let sectionInfo: SectionInfo = NavigationMenuViewController.sectionInfoArray[section]
            if sectionInfo.open {
                return sectionInfo.open ? sectionInfo.itemsInSection.count : 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sectionInfo: SectionInfo = NavigationMenuViewController.sectionInfoArray[indexPath.section]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CelulaMenu", for: indexPath) as! CelulaMenu
        cell.texto.text = sectionInfo.itemsInSection[indexPath.row].values.first!
        
        if (sectionInfo.itemsInSection[indexPath.row].keys.first! == "mostrar-todos"){
            cell.texto.font = UIFont(name: "Ubuntu-Bold", size: 17.0)
        } else {
            cell.texto.font = UIFont(name: "Ubuntu-Regular", size: 16.0)
        }
        
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedMenuItem = indexPath.row
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 4 || indexPath.section == 5 || indexPath.section == 6 || indexPath.section == 7){
            let info = NavigationMenuViewController.sectionInfoArray[indexPath.section].itemsInSection[indexPath.row]
            
            let categoria = info.keys.first!
            print("categoriaClicada: \(categoria)")
            
            menuContainerViewController!.selectContentViewController(TelaInicial.inicializeTelaInicial(categoria: categoria, titulo: info.values.first!))
            menuContainerViewController!.hideSideMenu()
        }
        
        /*
        if (indexPath.row == 2){
            PFUser.logOutInBackground()
            hostVC.onDeslogado()
            selectedMenuItem = 0
            tableView.reloadData()
        } else{
            menuContainerViewController.selectContentViewController(menuContainerViewController.contentViewControllers[selectedMenuItem])
        }
        */
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionInfo: SectionInfo = NavigationMenuViewController.sectionInfoArray[section]
        let titulo = sectionInfo.sectionTitle
        
        if (titulo == "whatsapp"){
            let sectionHeaderView: SectionHeaderView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeaderWhats") as! SectionHeaderView

            sectionHeaderView.section = section
            sectionHeaderView.delegate = self
            sectionHeaderView.linha.backgroundColor = hexStringToUIColor("#CD5D7D")
            
            let backGroundView = UIView()
            backGroundView.backgroundColor = UIColor.clear
            sectionHeaderView.backgroundView = backGroundView
            return sectionHeaderView
        } else {
            let sectionHeaderView: SectionHeaderView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderViewIdentifier) as! SectionHeaderView

            sectionHeaderView.titleLabel.text = sectionInfo.sectionTitle
            sectionHeaderView.section = section
            sectionHeaderView.delegate = self
            
            if (sectionInfo.itemsInSection.count == 0){
                sectionHeaderView.dot.isHidden = true
                sectionHeaderView.disclosureButton.isHidden = true
            } else {
                sectionHeaderView.dot.isHidden = true
                sectionHeaderView.disclosureButton.isHidden = false
            }
            
            if (sectionInfo.sectionId == "minhas_compras" || sectionInfo.sectionId == "meus_cartoes" || sectionInfo.sectionId == "produtos_favoritos" || sectionInfo.sectionId == "sair" || sectionInfo.sectionId == "inicio"){
                
                sectionHeaderView.linha.backgroundColor = hexStringToUIColor("#CD5D7D")
                sectionHeaderView.titleLabel.font = UIFont(name: "CeraRoundPro-Light", size: 16.5)
            } else {
                sectionHeaderView.linha.backgroundColor = hexStringToUIColor("#a01d5d")
                sectionHeaderView.titleLabel.font = UIFont(name: "CeraRoundPro-Bold", size: 16.5)
            }
            
            let backGroundView = UIView()
            backGroundView.backgroundColor = UIColor.clear
            sectionHeaderView.backgroundView = backGroundView
            return sectionHeaderView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    func sectionHeaderView(sectionHeaderView: SectionHeaderView, sectionOpened: Int) {
        let sectionInfo: SectionInfo = NavigationMenuViewController.sectionInfoArray[sectionOpened]
        let countOfRowsToInsert = sectionInfo.itemsInSection.count
        sectionInfo.open = true
        NavigationMenuViewController.abertosFechados[sectionInfo.sectionTitle!] = true
        var indexPathToInsert: [IndexPath] = [IndexPath]()
        for i in 0..<countOfRowsToInsert {
            indexPathToInsert.append(IndexPath(row: i, section: sectionOpened))
        }
        print("inserting rows at \(indexPathToInsert)")
        self.tableView.insertRows(at: indexPathToInsert, with: .top)
        
        //--//
        
        if (sectionOpened == 11){
            //whatsapp
            AppEvents.logEvent(AppEvents.Name.contact)
            print("whatsapp")
            let urlWhats = "whatsapp://send?phone=+5541991114455"
            if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
                if let whatsappURL = URL(string: urlString) {
                    if UIApplication.shared.canOpenURL(whatsappURL) {
                        UIApplication.shared.openURL(whatsappURL)
                    } else {
                        print("Install Whatsapp")
                    }
                }
            }
            NavigationMenuViewController.abertosFechados[sectionInfo.sectionTitle!] = false
        }
        
        if (sectionOpened == 10){
            
            if (sectionInfo.sectionTitle == "whatsapp"){
                //whatsapp
                print("whatsapp")
                AppEvents.logEvent(AppEvents.Name.contact)
                let urlWhats = "whatsapp://send?phone=+5541991114455"
                if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
                    if let whatsappURL = URL(string: urlString) {
                        if UIApplication.shared.canOpenURL(whatsappURL) {
                            UIApplication.shared.openURL(whatsappURL)
                        } else {
                            print("Install Whatsapp")
                        }
                    }
                }
            } else {
            
                PFUser.logOutInBackground()
            
                loginButton.isHidden = false
                cadastrarButton.isHidden = false
                sejaBemVindoLabel.text = "Identifique-se"
                nomeLabel.text = ""
                segundoNomeLabel.text = ""
                
                let currentInstallation = PFInstallation.current()
                currentInstallation?["userId"] = ""
                currentInstallation?.saveInBackground()
                
                NavigationMenuViewController.sectionInfoArray.remove(at: 11)
                tableView.reloadData()
                
            }
            NavigationMenuViewController.abertosFechados[sectionInfo.sectionTitle!] = false
        }
        
        if (sectionOpened == 9){
            menuContainerViewController!.selectContentViewController(MeusCartoes.inicializeMeusCartoes())
            menuContainerViewController!.hideSideMenu()
            
            for x in 0 ... NavigationMenuViewController.sectionInfoArray.count - 1 {
                if (NavigationMenuViewController.sectionInfoArray[x].open){
                    self.sectionHeaderView(sectionHeaderView: sectionHeaderView, sectionClosed: x)
                }
            }
            self.tableView.reloadData()
            NavigationMenuViewController.abertosFechados[sectionInfo.sectionTitle!] = false
        }
        
        if (sectionOpened == 8){
            menuContainerViewController!.selectContentViewController(MinhasCompras.inicializeMinhasCompras())
            menuContainerViewController!.hideSideMenu()
            
            for x in 0 ... NavigationMenuViewController.sectionInfoArray.count - 1 {
                if (NavigationMenuViewController.sectionInfoArray[x].open){
                    self.sectionHeaderView(sectionHeaderView: sectionHeaderView, sectionClosed: x)
                }
            }
            self.tableView.reloadData()
            NavigationMenuViewController.abertosFechados[sectionInfo.sectionTitle!] = false
        }
        
        if (sectionOpened == 1){
            menuContainerViewController!.selectContentViewController(TelaInicial.inicializeTelaInicialAsProdutosFavoritos())
            menuContainerViewController!.hideSideMenu()
            
            for x in 0 ... NavigationMenuViewController.sectionInfoArray.count - 1 {
                if (NavigationMenuViewController.sectionInfoArray[x].open){
                    self.sectionHeaderView(sectionHeaderView: sectionHeaderView, sectionClosed: x)
                }
            }
            self.tableView.reloadData()
            NavigationMenuViewController.abertosFechados[sectionInfo.sectionTitle!] = false
        }
        
        if (sectionOpened == 0){
            menuContainerViewController!.selectContentViewController(InicioVerdadeiro.inicializeInicioVerdadeiro())
            menuContainerViewController!.hideSideMenu()
            
            for x in 0 ... NavigationMenuViewController.sectionInfoArray.count - 1 {
                if (NavigationMenuViewController.sectionInfoArray[x].open){
                    self.sectionHeaderView(sectionHeaderView: sectionHeaderView, sectionClosed: x)
                }
            }
            self.tableView.reloadData()
            NavigationMenuViewController.abertosFechados[sectionInfo.sectionTitle!] = false
        }
    }

    func sectionHeaderView(sectionHeaderView: SectionHeaderView, sectionClosed: Int) {
        if (sectionClosed != 9 && sectionClosed != 8 && sectionClosed != 1 && sectionClosed != 0){
            let sectionInfo: SectionInfo = NavigationMenuViewController.sectionInfoArray[sectionClosed]
            let countOfRowsToDelete = sectionInfo.itemsInSection.count
            sectionInfo.open = false
            NavigationMenuViewController.abertosFechados[sectionInfo.sectionTitle!] = false
            if countOfRowsToDelete > 0 {
                var indexPathToDelete: [IndexPath] = [IndexPath]()
                for i in 0..<countOfRowsToDelete {
                    indexPathToDelete.append(IndexPath(row: i, section: sectionClosed))
                }
                print("deleting rows: \(indexPathToDelete)")
                self.tableView.deleteRows(at: indexPathToDelete, with: .top)
            }
        }
    }
}

class CelulaMenu: UITableViewCell {
    
    @IBOutlet weak var texto: UILabel!
    @IBOutlet weak var linha: UIView!
    
}
