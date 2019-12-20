//
//  MLCardFormViewModelProtocol.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 04/12/2019.
//

import Foundation
import MLCardDrawer

protocol MLCardFormViewModelProtocol: NSObjectProtocol {
    func shouldUpdateCard(cardUI: CardUI)
    func shouldUpdateFields(remoteSettings: [MLCardFormFieldSetting]?)
    func shouldUpdateAppBarTitle(paymentTypeId: String?)
}
