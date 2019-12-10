//
//  MLCardFormBaseViewController.swift
//  MLCardForm
//
//  Created by Eric Ertl on 10/12/2019.
//

import Foundation
import MLUI

open class MLCardFormBaseViewController: UIViewController {
    private var fontName: String = ".SFUIDisplay-Regular"
    private var fontLightName: String = ".SFUIDisplay-Light"
    private var fontSemiBoldName: String = ".SFUIDisplay-SemiBold"
    
    var navBarTextColor = MLStyleSheetManager.styleSheet.blackColor
    var navBarBackgroundColor = MLStyleSheetManager.styleSheet.primaryColor
    
    override open var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadStyles()
    }
    
    private func loadStyles() {
        if let navigationController = navigationController {
            // Navigation bar colors
            let fontSize: CGFloat = 18
            let font = getFontWithSize(font: fontName, size: fontSize)
            let titleTextAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: navBarTextColor, NSAttributedString.Key.font: font]
            navigationController.navigationBar.titleTextAttributes = titleTextAttributes
            navigationController.navigationBar.tintColor = navBarBackgroundColor
            navigationController.navigationBar.barTintColor = navBarBackgroundColor
            navigationController.navigationBar.isTranslucent = false
            navigationController.view.backgroundColor = navBarBackgroundColor
            // Navigation back button
            setupBackButton()
        }
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    private func setupBackButton() {
        let backButton = UIBarButtonItem()
        let back = UIImage(named: "back", in: Bundle(for: type(of: self)), compatibleWith: nil)
        backButton.image = back
        backButton.style = .plain
        backButton.target = self
        backButton.tintColor = navBarTextColor
        backButton.action = #selector(pop)
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func pop() {
        navigationController?.popViewController(animated: true)
    }
    
    private func getFontWithSize(font: String, size: CGFloat, weight: UIFont.Weight? = nil) -> UIFont {
        let fontNameToIgnore: String = "Times New Roman"
        let fallBackFontName: String = "Helvetica"
        if let thisFont = UIFont(name: font, size: size) {
            if thisFont.familyName != fontNameToIgnore {
                return thisFont
            } else {
                return UIFont(name: fallBackFontName, size: size) ?? getFallbackFont(size)
            }
        }
        return getFallbackFont(size)
    }
    
    private func getFallbackFont(_ size: CGFloat, weight: UIFont.Weight?=nil) -> UIFont {
        if let targetWeight = weight {
            return UIFont.systemFont(ofSize: size, weight: targetWeight)
        }
        return UIFont.systemFont(ofSize: size)
    }
}
