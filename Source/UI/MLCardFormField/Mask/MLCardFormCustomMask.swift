import Foundation

/*
 * MLCardFormCustomMask takes a string and returns it with the matching pattern
 * Usualy it is used inside the shouldChangeCharactersInRange method
 *
 *  usage:
 *   func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
 *      textField.text = customMask.shouldChangeCharactersIn(range, with: string)
 *      return false
 *   }
 *
 *  Use $ for digits ($$-$$$$)
 *  Use * for characters [a-zA-Z] (**-****)
 */

final class MLCardFormCustomMask {
    let mask: String
    private(set) var value: String = ""
    var unmaskedText: String { removeMask(to: value) }
    
    init(mask: String) {
        self.mask = mask
    }
    
    func clear() {
        value.removeAll()
    }
    
    @discardableResult
    func applyMask(to string: String) -> String {
        guard !mask.isEmpty, !string.isEmpty else {
            self.value = string
            return string
        }
        
        let string = removeMask(to: string)
        let count = string.count
        var maskedString = ""
        var character: Character
        var index = 0
        
        for m in mask {
            if m != "$" && m != "*" {
                maskedString.append(m)
                continue
            }
            
            repeat {
                character = string[string.index(string.startIndex, offsetBy: index)]
                index += 1
            } while !(m == "$" && character.isNumber) && !(m == "*" && character.isLetter) && index < count
            
            if (m == "$" && character.isNumber) || (m == "*" && character.isLetter) {
                maskedString.append(character)
            }
            
            if index >= count {
                break
            }
        }
        
        self.value = maskedString
        return maskedString
    }
    
    @discardableResult
    func shouldChangeCharactersIn(
        _ range: NSRange,
        with string: String
    ) -> String {
        guard Range.init(range, in: self.value) != nil else {
            return self.value
        }
        let newString = (self.value as NSString).replacingCharacters(in: range, with: string)
        return applyMask(to: newString)
    }
    
    private func removeMask(to string: String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: "\\W", options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, string.count)
            return regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: "")
        } catch {
            return string
        }
    }
}
