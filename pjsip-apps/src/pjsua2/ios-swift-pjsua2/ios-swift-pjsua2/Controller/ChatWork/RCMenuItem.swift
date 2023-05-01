//
//  RCMenuItem.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 30/01/23.
//

import UIKit

//-----------------------------------------------------------------------------------------------------------------------------------------------
class RCMenuItem: UIMenuItem {

    var indexPath: IndexPath?

    //-------------------------------------------------------------------------------------------------------------------------------------------
    class func indexPath(_ sender: Any?) -> IndexPath? {

        if let menuController = sender as? UIMenuController {
            if let menuItem = menuController.menuItems?.first as? RCMenuItem {
                return menuItem.indexPath
            }
        }
        return nil
    }
}
