//
//  MLCardFormAddCardBinBody.swift
//  MLCardForm
//
//  Created by Leandro Demarco Vedelago on 27/11/2020.
//

import Foundation

struct MLCardFormAddCardBinBody: Codable {
    let flowId: String
    let extraData: MLCardFormAddCardBinExtraData
    
    init(flowId: String, extraDataDict: [AnyHashable: Any]) {
        self.flowId = flowId
        extraData = MLCardFormAddCardBinExtraData(dict: extraDataDict)
    }
}

struct MLCardFormAddCardBinExtraData: Codable {
    let vertical: String
    let flowType: String
    let items: [MLCardFormAddCardBinItemData]
    
    init(dict: [AnyHashable: Any]) {
        let vertical = dict["vertical"] as? String ?? ""
        let flowType = dict["flow_type"] as? String ?? ""
        let dictItems = dict["items"] as? [[AnyHashable: Any]]
        
        let tmpItems: [MLCardFormAddCardBinItemData] = dictItems?.map({ MLCardFormAddCardBinItemData(dict: $0) }) ?? []

        self.vertical = vertical
        self.flowType = flowType
        self.items = tmpItems
    }
}

struct MLCardFormAddCardBinItemData: Codable {
    let id: String
    
    init(dict: [AnyHashable: Any]) {
        id = dict["id"] as? String ?? ""
    }
}
