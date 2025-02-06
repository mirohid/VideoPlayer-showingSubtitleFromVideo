//
//import AVFoundation
//
//class VideoPlayerViewModel: NSObject, ObservableObject {
//    @Published var subtitle: String = ""
//    var player: AVPlayer!
//
//    func setupPlayer() {
//        // ✅ Change "myvideo" to match your video file name (without extension)
//        guard let url = Bundle.main.url(forResource: "myvideo", withExtension: "mp4") else {
//            print("🚨 Video file not found! Check file name & Xcode project.")
//            return
//        }
//
//        let playerItem = AVPlayerItem(url: url)
//        player = AVPlayer(playerItem: playerItem)
//
//        let output = AVPlayerItemLegibleOutput()
//        output.setDelegate(self, queue: DispatchQueue.main)
//        playerItem.add(output)
//
//        player.play()
//        print("✅ Video is playing successfully!")
//    }
//}
//
//// ✅ Subtitles Extraction
//extension VideoPlayerViewModel: AVPlayerItemLegibleOutputPushDelegate {
//    func legibleOutput(_ output: AVPlayerItemLegibleOutput, didOutputAttributedStrings strings: [NSAttributedString], nativeSampleBuffers: [Any]?, for itemTime: CMTime) {
//        DispatchQueue.main.async {
//            self.subtitle = strings.first?.string ?? ""
//        }
//    }
//}
