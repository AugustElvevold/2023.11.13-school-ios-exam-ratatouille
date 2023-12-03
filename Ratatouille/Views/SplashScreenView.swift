//
//  SplashScreenView.swift
//  Ratatouille
//
//  Created by Kandidatnr: 2003 on 01/12/2023.
//

import SwiftUI

struct SplashView: View {
	@State private var imageOpacity = 1.0
	
	@EnvironmentObject var splashScreenManager: SplashScreenManager
	
	@State private var loadingPhase: Bool = false
	@State private var finnishPhase: Bool = false
	
	private var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
	
	var body: some View {
		ZStack {
			background
			remyIconSilhuette
			remyIcon
		}
		.opacity(finnishPhase ? 0 : 1)
		.edgesIgnoringSafeArea(.all)
		.onReceive(timer) { input in
			switch splashScreenManager.phase {
				case .first:
					withAnimation(.spring()){
						loadingPhase.toggle()
					}
				case .second:
					withAnimation(.easeIn){
						finnishPhase.toggle()
					}
				default: break
			}
		}
	}
}

#Preview {
	SplashView()
		.environmentObject(SplashScreenManager())
}

private extension SplashView {
	
	var background : some View {
		Color.black
	}
	var remyIcon : some View {
		ZStack{
			Image("ratatouille-remy")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.opacity(imageOpacity)
				.scaleEffect(loadingPhase ? 0.95 : 1.05)
		}
		.onAppear{
			withAnimation(.easeOut(duration: 0.8)) {
				imageOpacity = 0
			}
		}
	}
	
	var remyIconSilhuette : some View {
		Image("ratatouille-remy-silhouette")
			.resizable()
			.aspectRatio(contentMode: .fit)
			.scaleEffect(loadingPhase ? 0.95 : 1.05)
			.scaleEffect(finnishPhase ? UIScreen.main.bounds.size.height / 4 : 1)
	}
}
