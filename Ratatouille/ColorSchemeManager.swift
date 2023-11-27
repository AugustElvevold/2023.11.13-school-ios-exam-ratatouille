//
//  ColorSchemeManager.swift
//  Ratatouille
//
//  Created by August Elvevold on 27/11/2023.
//

import SwiftUI

enum ColorScheme: Int {
	case unspecified, light, dark
}

class ColorSchemeManager: ObservableObject {
	@AppStorage("colorScheme") var colorScheme: ColorScheme = .unspecified {
		didSet {
			applyColorScheme()
		}
	}
	func applyColorScheme() {
		keyWindow?.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: colorScheme.rawValue) ?? .unspecified
	}
	
	var keyWindow: UIWindow? {
		guard let scene = UIApplication.shared.connectedScenes.first,
		let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
		let window = windowSceneDelegate.window else {
			return nil
		}
		return window
	}
}

