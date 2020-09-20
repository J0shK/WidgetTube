//
//  Placeholder+UIImage.swift
//  YouTubeWidgetExtension
//
//  Created by Josh Kowarsky on 9/21/20.
//

import UIKit

extension UIImage {
    static var placeholder: UIImage {
        return UIImage(systemName: "photo")!.withTintColor(.label, renderingMode: .alwaysTemplate)
    }
}
