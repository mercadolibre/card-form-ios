//
//  UIImageView+RemoteImage.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 11/11/2019.
//

import Foundation

extension UIImageView {
    func setRemoteImage(imageUrl: String, success:((UIImage)->Void)? = nil) {
        NetworkLayer.request(imageUrl: imageUrl) { [weak self] (image) in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: { [weak self] in
                        guard let self = self else { return }
                        self.backgroundColor = .clear
                        self.layer.cornerRadius = 0
                        self.image = image
                    }, completion: { _ in
                        success?(image)
                })
            }
        }
    }
}
