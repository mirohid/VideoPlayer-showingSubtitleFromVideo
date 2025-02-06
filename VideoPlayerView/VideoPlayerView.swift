////
////  ContentView.swift
////  VideoPlayerView
////
////  Created by Tech Exactly iPhone 6 on 06/02/25.
////
//
//import SwiftUI
//import AVKit
//
//struct VideoPlayerView: View {
//    @StateObject private var viewModel = VideoPlayerViewModel()
//    
//    var body: some View {
//        VStack {
//            // Video Player
//            VideoPlayer(player: viewModel.player)
//                .frame(height: 300)
//                .onAppear {
//                    viewModel.setupPlayer()
//                }
//            
//            // Subtitle Display
//            Text(viewModel.subtitle)
//                .font(.title)
//                .padding()
//                .multilineTextAlignment(.center)
//        }
//    }
//}
//
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoPlayerView()
//    }
//}
