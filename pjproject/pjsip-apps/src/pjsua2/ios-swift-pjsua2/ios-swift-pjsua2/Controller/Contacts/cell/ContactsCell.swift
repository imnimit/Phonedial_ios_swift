//
//  ContactsCell.swift
//  Contacts
//
//  Created by Johnny Perdomo on 12/18/18.
//  Copyright © 2018 Johnny Perdomo. All rights reserved.
//

import UIKit

class ContactsCell: UITableViewCell {

    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var contactNumber: UILabel!
    @IBOutlet weak var lblVW: UIView!
    @IBOutlet weak var lblNameLetter: UILabel!
    @IBOutlet weak var btnInvite: UIButton!
    @IBOutlet weak var btnFavorite: UIButton!
    @IBOutlet weak var PolistionorName: NSLayoutConstraint!
    @IBOutlet weak var heightForFavouriteBtn: NSLayoutConstraint!
    
}
