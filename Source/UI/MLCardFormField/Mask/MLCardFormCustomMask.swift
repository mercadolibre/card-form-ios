import Foundation

/*
 * MLCardFormCustomMask takes a string and returns it with the matching pattern
 * Usualy it is used inside the shouldChangeCharactersInRange method
 *
 *  usage:
 *   func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
 *      self.text = customMask!.formatStringWithRange(range, string: string)
 *      return false
 *   }
 *
 *  Use $ for digits ($$-$$$$)
 *  Use * for characters [a-zA-Z] (**-****)
 */

class MLCardFormCustomMask {
    
    var finalText: String? = String()
    var bufferText: String? = String()

    private var mask: String?
    
    public init(mask: String = String()){
        self.mask = mask
    }

    public func formatString(string: String) -> String {
        
        self.finalText = string
        
        self.bufferText = string
        
        self.finalText?.applyMask(self.mask)
        
        return self.finalText ?? String()
    }

    public func formatStringWithRange(range: NSRange, string: String) -> String {
        
        guard !string.isEmpty else {
            
            if range.upperBound <= finalText?.count ?? 0 {
                finalText?.removeLast()
            }
            
            if range.upperBound <= bufferText?.count ?? 0 {
                bufferText?.removeLast()
            }
            
            return finalText ?? String()
        }
        
        finalText?.appendCharWithMask(Character(string), mask: self.mask)
        bufferText?.append(string)
        
        return finalText ?? String()
    }
}

internal extension String {
    
    mutating func applyMask(_ mask: String?) {
        
        guard let mask = mask, !self.isEmpty else { return }
        
        var result = String()
        var c: Character
        var i = 0
        
        for m in mask {
            
            if m != "$" && m != "*" {
                result.append(m)
                continue
            }
            
            repeat {
                c = self[self.index(self.startIndex, offsetBy: i)]
                i = i + 1
            } while !(m == "$" && c.isNumber) && !(m == "*" && c.isLetter) && i < self.count
        
            result.append(c)
            
            if i >= self.count {
                break
            }
        }

        self = result
    }
    
    mutating func appendCharWithMask(_ character: Character?, mask: String?) {
        
        guard let character = character, let mask = mask, self.count < mask.count else { return }

        var i = self.count
        var c: Character?
        var result = String()
        
        repeat {
            
            if let ch = c {
                result.append(ch)
            }
            
            c = mask[mask.index(mask.startIndex, offsetBy: i)]
            
            i = i + 1
            
        } while c != "$" && c != "*" && i < mask.count
    
        if (c == "$" && character.isNumber) || (c == "*" && character.isLetter) {
            result.append(character)
            self.append(result)
        }
    }
    
    mutating func removeMask(_ mask: String?) {
        
    }
}
