import UIKit

protocol PastedTextFieldDelegate: AnyObject {
    func pastedText(_ text: String?)
}

extension PastedTextFieldDelegate {
    func pastedText(_ text: String?) {
        //this is a empty implementation to allow this method to be optional
    }
}

final class PastedTextField: UITextField {
    weak var pastedTextFieldDelegate: PastedTextFieldDelegate? = nil
    
    override func paste(_ sender: Any?) {
        pastedTextFieldDelegate?.pastedText(UIPasteboard.general.string)
        super.paste(sender)
    }
}
