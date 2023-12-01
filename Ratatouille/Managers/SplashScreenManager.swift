//
//  SplashScreenManager.swift
//  Ratatouille
//
//  Created by Kandidatnr: 2003 on 01/12/2023.
//

import Foundation

enum SplashScreenPhase {
	case first
	case second
	case completed
}

final class SplashScreenManager: ObservableObject {
	@Published private(set) var phase: SplashScreenPhase = .first
	
	func dismiss(){
		phase = .second
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			self.phase = .completed
		}
	}
}
