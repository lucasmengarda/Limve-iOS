//
//  SectionHeaderView.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 29/01/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import UIKit

protocol SectionHeaderViewDelegate {
    func sectionHeaderView(sectionHeaderView: SectionHeaderView, sectionOpened: Int)
    func sectionHeaderView(sectionHeaderView: SectionHeaderView, sectionClosed: Int)
}

class SectionInfo {
    var open: Bool = false
    var itemsInSection = [[String : String]]()
    var sectionTitle: String?
    var sectionId: String?

    init(itemsInSection: [[String : String]], sectionTitle: String, sectionId: String) {
        self.itemsInSection = itemsInSection
        self.sectionTitle = sectionTitle
        self.sectionId = sectionId
        NavigationMenuViewController.abertosFechados[sectionTitle] = false
        
        if (self.itemsInSection.count > 0){
            self.itemsInSection.sort { (o1, o2) -> Bool in
            
                let valor1 = o1.values.first!.folding(options: .diacriticInsensitive, locale: .current)
                let valor2 = o2.values.first!.folding(options: .diacriticInsensitive, locale: .current)
                return valor1 < valor2
            }
        
            self.itemsInSection.append(["mostrar-todos": "Mostrar todos +"])
        }
    }
}

class SectionHeaderView: UITableViewHeaderFooterView {

    var section: Int = 0
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var disclosureButton: UIButton!
    @IBOutlet weak var linha: UIView!
    @IBOutlet weak var dot: UIImageView!
    @IBOutlet weak var back: UIView!
    
    @IBAction func toggleOpen() {
        self.toggleOpenWithUserAction(userAction: true)
    }
    
    var delegate: SectionHeaderViewDelegate?

    func toggleOpenWithUserAction(userAction: Bool) {
        if (self.disclosureButton != nil){
            if userAction {
                print("toggleOpen and \(NavigationMenuViewController.abertosFechados)")
                
                let sectionInfo: SectionInfo = NavigationMenuViewController.sectionInfoArray[section]
                let titulo = sectionInfo.sectionTitle
                
                if (NavigationMenuViewController.abertosFechados[titulo!]!) {
                    self.delegate?.sectionHeaderView(sectionHeaderView: self, sectionClosed: self.section)
                } else {
                    self.delegate?.sectionHeaderView(sectionHeaderView: self, sectionOpened: self.section)
                }
            }
        } else {
            self.delegate?.sectionHeaderView(sectionHeaderView: self, sectionOpened: self.section)
        }
    }

    override func awakeFromNib() {
        if (self.disclosureButton != nil){
            self.disclosureButton.setImage(UIImage(named: "more_menu.png"), for: UIControl.State.normal)
        }
        
        var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "toggleOpen")
        self.addGestureRecognizer(tapGesture)
        // change the button image here, you can also set image via IB.
        
        if (self.back != nil){
            self.back.backgroundColor = hexStringToUIColor("#944e6c")
        }
    }

}
