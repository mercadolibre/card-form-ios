//
//  MLCardFormBaseViewController.swift
//  MLCardForm
//
//  Created by Eric Ertl on 10/12/2019.
//

import Foundation
import MLUI

/** :nodoc: */
open class MLCardFormBaseViewController: UIViewController {
    var navBarTextColor = MLStyleSheetManager.styleSheet.blackColor
    var navBarBackgroundColor = MLStyleSheetManager.styleSheet.primaryColor

    internal func loadStyles(customNavigationBackgroundColor: UIColor? = nil, customNavigationTextColor: UIColor? = nil) {
        if let navigationController = navigationController {
            // Navigation bar colors
            let font = MLStyleSheetManager.styleSheet.boldSystemFont(ofSize: CGFloat(kMLFontsSizeMedium))
            let titleTextAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: customNavigationTextColor ?? navBarTextColor, NSAttributedString.Key.font: font]
            navigationController.navigationBar.titleTextAttributes = titleTextAttributes
            navigationController.navigationBar.tintColor = customNavigationBackgroundColor ?? navBarBackgroundColor
            navigationController.navigationBar.barTintColor = customNavigationBackgroundColor ?? navBarBackgroundColor
            navigationController.navigationBar.backgroundColor = customNavigationBackgroundColor ?? navBarBackgroundColor
            setupBackButton(textColor: customNavigationTextColor ?? navBarTextColor)
        }
    }

    /// :nodoc
    override open var shouldAutorotate: Bool {
        return false
    }

    /// :nodoc
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    private func setupBackButton(textColor: UIColor? = nil) {
        let backButton = UIBarButtonItem()
        let back = UIImage(named: "back", in: Bundle(for: type(of: self)), compatibleWith: nil)
        backButton.image = back
        backButton.style = .plain
        backButton.target = self
        backButton.tintColor = textColor
        backButton.action = #selector(pop)
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = backButton
        navigationItem.leftBarButtonItem?.accessibilityLabel = "atrás".localized
    }

    @objc private func pop() {
        navigationController?.popViewController(animated: true)
    }
}
