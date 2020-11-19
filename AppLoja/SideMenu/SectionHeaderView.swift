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
    var itemsInSection = [String]()
    var sectionTitle: String?

    init(itemsInSection: [String], sectionTitle: String) {
        self.itemsInSection = itemsInSection
        self.sectionTitle = sectionTitle
        NavigationMenuViewController.abertosFechados[sectionTitle] = false
    }
}

class SectionHeaderView: UITableViewHeaderFooterView {

    var section: Int = 0
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var disclosureButton: UIButton!
    @IBOutlet weak var linha: UIView!
    @IBOutlet weak var dot: UIImageView!
    
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
                    UIView.animate(withDuration: 0.35) {
                        if (self.linha != nil){
                            if (NavigationMenuViewController.abertosFechados[titulo!]!){
                                self.linha.backgroundColor = hexStringToUIColor("#064789")
                            } else {
                                self.linha.backgroundColor = hexStringToUIColor("#0B6AB0")
                            }
                        }
                    }
                } else {
                    self.delegate?.sectionHeaderView(sectionHeaderView: self, sectionOpened: self.section)
                    UIView.animate(withDuration: 0.35) {
                        if (self.linha != nil){
                            if (NavigationMenuViewController.abertosFechados[titulo!]!){
                                self.linha.backgroundColor = hexStringToUIColor("#064789")
                            } else {
                                self.linha.backgroundColor = hexStringToUIColor("#0B6AB0")
                            }
                        }
                    }
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
        
        self.linha.backgroundColor = hexStringToUIColor("#0B6AB0")
    }

}
