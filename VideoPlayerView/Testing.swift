////
////  testing.swift
////  VideoPlayerView
////
////  Created by Tech Exactly iPhone 6 on 06/02/25.
////
//
//import SwiftUI
//import AVKit
//import AVFoundation
//
//struct Testing: View {
//    @State private var subtitles: [String] = []
//    @State private var player: AVPlayer?
//
//    var body: some View {
//        VStack {
//            if let player = player {
//                VideoPlayer(player: player)
//                    .frame(height: 300)
//            } else {
//                Text("Loading video...")
//            }
//
//            List(subtitles, id: \.self) { subtitle in
//                Text(subtitle)
//            }
//        }
//        .onAppear {
//            loadVideoAndSubtitles()
//        }
//    }
//
//    private func loadVideoAndSubtitles() {
//        // Replace with your video URL (local or remote)
//        guard let videoURL = Bundle.main.url(forResource: "myvideo", withExtension: "mp4") else {
//            print("Video not found")
//            return
//        }
//
//        let asset = AVAsset(url: videoURL)
//        self.player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
//
//        // Load subtitles
//        loadSubtitles(from: asset)
//    }
//
//    private func loadSubtitles(from asset: AVAsset) {
//        // Get the subtitle tracks
//        let subtitleTracks = asset.mediaSelectionGroup(forMediaCharacteristic: .legible)
//
//        guard let group = subtitleTracks else {
//            print("No subtitles found")
//            return
//        }
//
//        // Extract subtitles
//        for option in group.options {
//            if option.mediaType == .subtitle {
//                let subtitle = option.displayName
//                subtitles.append(subtitle)
//            }
//        }
//    }
//}
//
//struct Testing_Previews: PreviewProvider {
//    static var previews: some View {
//        Testing()
//    }
//}



import SwiftUI
import AVKit
import AVFoundation

struct Testing: View {
    @State private var subtitles: [String] = []
    @State private var player: AVPlayer?
    
    var body: some View {
        VStack {
            if let player = player {
                VideoPlayer(player: player)
                    .frame(height: 300)
            } else {
                Text("Loading video...")
            }
            
            List(subtitles, id: \.self) { subtitle in
                Text(subtitle)
            }
        }
        .onAppear {
            loadVideoAndSubtitles()
        }
    }
    
    private func loadVideoAndSubtitles() {
        // Replace with your video URL (local or remote)
        guard let videoURL = Bundle.main.url(forResource: "myvideo", withExtension: "mp4") else {
            print("Video not found")
            return
        }
        
        let asset = AVAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: playerItem)
        
        // Set up subtitle output
        let legibleOutput = AVPlayerItemLegibleOutput()
        playerItem.add(legibleOutput)
        
        // Add a delegate to capture subtitle events
        let delegate = SubtitleDelegate(subtitles: $subtitles)
        legibleOutput.setDelegate(delegate, queue: DispatchQueue.main)
        
        // Load subtitles
        loadSubtitles(from: asset, playerItem: playerItem)
    }
    
    private func loadSubtitles(from asset: AVAsset, playerItem: AVPlayerItem) {
        // Get the subtitle tracks
        guard let subtitleTracks = asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else {
            print("No subtitles found")
            return
        }
        
        // Extract subtitles (this will be used to toggle the subtitle selection)
        for option in subtitleTracks.options {
            if option.mediaType == .subtitle {
                // Select the subtitle track
                playerItem.select(option, in: subtitleTracks)
            }
        }
    }
}

class SubtitleDelegate: NSObject, AVPlayerItemLegibleOutputPushDelegate {
    @Binding var subtitles: [String]

    init(subtitles: Binding<[String]>) {
        _subtitles = subtitles
    }

    // Delegate method for handling subtitles
    func legibleOutput(_ output: AVPlayerItemLegibleOutput, didOutputAttributedStrings strings: [NSAttributedString], forItemTime time: CMTime) {
        // Process the subtitle content from the output
        for string in strings {
            subtitles.append(string.string)
        }
    }
}

struct Testing_Previews: PreviewProvider {
    static var previews: some View {
        Testing()
    }
}
