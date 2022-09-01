import Foundation

struct MLCardFormPAN: Codable {
    var backgroundColor: String?
    var textColor: String?
    var weight: String?
    
    enum CodingKeys: String, CodingKey {
        case backgroundColor
        case textColor
        case weight
    }
}
